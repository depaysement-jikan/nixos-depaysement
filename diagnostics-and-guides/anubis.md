# Anubis in the homelab — architecture, deployment options & plan of action

**Subject:** [Anubis](https://github.com/TecharoHQ/anubis) v1.27.0 (`ghcr.io/techarohq/anubis`)
**Cluster:** single-node k3s, ingress-nginx + MetalLB + cert-manager + Pi-hole/external-dns
**Date:** 2026-09-08
**Status:** Research and design only. Nothing is deployed; no Nix files are touched by this document.

---

## 0. Summary

Anubis is a proof-of-work interstitial that sits between a reverse proxy and an application to make
mass scraping expensive. Running it here needs **no Helm** (there is no official chart, and this
repo never invokes `helm` at runtime anyway) and **no MetalLB address** (it is a `ClusterIP`
service reached only from inside the cluster). It hooks into **ingress-nginx**, which is already
the single entry point for every `*.home` host.

The honest conclusion, stated up front: **nothing in this homelab is reachable from the public
internet** — LAN plus a Tailscale subnet route, no port forwards, no tunnel. Anubis blocks internet
scrapers, and there are none inside `192.168.1.0/24`. Anubis is aware enough of this case to ship a
bundled policy, `data/common/allow-private-addresses.yaml`, whose entire job is to `ALLOW`
`192.168.0.0/16` and `100.64.0.0/10` — your LAN and Tailscale's CGNAT range respectively. That is
every client you own.

So this is a learning exercise and future-proofing, which is a perfectly good reason to do it. It
is just not a mitigation yet.

Second operational fact: **`homelab.enable = false` on all four hosts**
(`hosts/*/config/homelab-config/default.nix:9`), and every module is gated on
`lib.mkIf (config.homelab.<svc>.enable && config.homelab.enable)`. Nothing deploys until that
global toggle is flipped.

---

## 1. What Anubis is

A small Go HTTP proxy placed **between the reverse proxy and the application**. When an unverified
browser-like client requests a page, Anubis returns an interstitial carrying a proof-of-work
challenge. The browser solves it in JavaScript — find a hash with N leading zeroes — posts the
solution back, and receives a signed JWT in a cookie named `techaro.lol-anubis` (7-day default
expiry). Requests carrying a valid cookie are proxied straight through.

The economics are the whole idea: the challenge costs a real browser a fraction of a second and
costs a crawler working through ten million URLs a fortune in CPU. Upstream is candid that this is
a stopgap — the design docs describe the PoW as *"a hack whose real purpose is to give a 'good
enough' placeholder solution"* while better headless-browser fingerprinting is developed.

The container runs as UID/GID 1000. Pin `:v1.27.0` rather than `:latest`.

### What it is not

| Not | Because |
|---|---|
| Authentication | Anyone who solves the PoW gets a cookie. It identifies nobody. |
| Authorization | No concept of users or roles. |
| A WAF | No SQLi/XSS/traversal inspection. |
| Rate limiting or DDoS protection | Nothing at L3/L4. |

It is also **allow-by-default**: the implicit final rule permits anything that did not match an
explicit `DENY` or `CHALLENGE`, and that rule cannot be removed.

---

## 2. Who actually gets challenged

This is the most misunderstood part, and it determines the real blast radius. Anubis presents a
challenge only when **all** of these hold:

- the `User-Agent` contains the string `Mozilla`
- the path is not `/.well-known/*`, `/robots.txt`, or `/favicon.ico`
- the path does not look like a feed (`.rss`, `.xml`, `.atom`)

Everything else falls through to the implicit allow. **`curl`, `git`, `go get`, OCI clients and
most mobile apps are never challenged by default** — none of them claim to be Mozilla.

On top of that sits a weight/threshold system. A stock browser carries weight 10, which lands in
the default `moderate-suspicion` threshold:

```yaml
- name: moderate-suspicion
  expression:
    all:
      - weight >= 10
      - weight < 20
  action: CHALLENGE
  challenge:
    algorithm: fast
    difficulty: 2   # two leading zeros — very fast for most clients
```

So a normal visitor gets `fast` difficulty **2**, not the `DIFFICULTY=4` environment default (which
applies to the legacy single-rule path). Thresholds are skipped entirely when a request matches a
bot rule with an explicit `CHALLENGE` action.

Available challenge algorithms: `fast` (multithreaded JS SHA-256), `slow` (legacy), `metarefresh`
(the only no-JS option, not enabled by default while its false-positive rate is assessed), and a
WASM family added in v1.27.0 (`argon2id`, `hashx`, `sha256` — note these count leading *bits*, not
nibbles). JavaScript and Web Workers are required for everything except `metarefresh`.

---

## 3. Do we need Helm? No.

**There is no official Anubis Helm chart.** Verified against the repository tree and the TecharoHQ
org's public repos. The upstream Kubernetes page points at two third-party projects instead:

| Project | What it is | Caveat |
|---|---|---|
| [`eznix86/anubis-kubernetes-operator`](https://github.com/eznix86/anubis-kubernetes-operator) | CRD operator (`AnubisProxy`) with an embedded chart, v0.5.0 | Chart is vendored inside the operator; not confirmed published standalone |
| [`jaredallard/ingress-anubis`](https://github.com/jaredallard/ingress-anubis) | ingress-nginx wrapper controller | Self-describes as *"NOT AT ALL production software and may never be"* |

Neither is needed, because this repo has two deployment mechanisms and only one involves charts:

**`services.k3s.autoDeployCharts`** — used by ingress-nginx, cert-manager, MetalLB, Forgejo, Immich,
Pi-hole and the Prometheus stack. Nix runs `helm pull` at **build time** into a fixed-output
derivation (`fetchHelm`, `modules/homelab/services/k3s/default.nix:54-84`), places the `.tgz` under
`/var/lib/rancher/k3s/server/static/charts`, and emits a `helm.cattle.io/v1` HelmChart CR that
k3s's **bundled** helm-controller installs. There is no `helm` binary on any host — it never
appears in `environment.systemPackages`.

**`services.k3s.manifests.<name>.content`** — plain Nix attrsets rendered to YAML and symlinked into
the k3s auto-deploy directory. Used for every namespace, Certificate, ClusterIssuer, PVC,
NetworkPolicy and CloudNativePG cluster in the repo.

Anubis is a container plus a ConfigMap. It belongs in the **second** bucket. No chart to pin, no
third-party operator to trust.

---

## 4. What it needs to run alongside

| Component | Needed? | Why |
|---|---|---|
| **MetalLB** | **No** | MetalLB hands `192.168.1.201-254` to `type: LoadBalancer` Services so Vaultwarden, Pi-hole etc. get stable LAN IPs. Anubis is only ever contacted from inside the cluster — by ingress-nginx, or by the other container in its own Pod. A `ClusterIP` is correct; don't spend a pool address. |
| **ingress-nginx** | **Yes — this is the integration point** | The controller runs `hostNetwork = true` with `service.enabled = false` (`modules/homelab/ingress-nginx/default.nix:30-35`), so it binds `:80`/`:443` directly on the node instead of taking a MetalLB IP. TLS terminates here; Anubis speaks plain HTTP behind it. |
| **cert-manager** | **Indirectly** | Anubis needs no certificate of its own, but `COOKIE_SECURE` defaults to `true`, so the browser must be on HTTPS. Every `*.home` host already has a self-signed Certificate, so this is satisfied. If a host is ever served over plain HTTP, set `COOKIE_SECURE=false` **and** `COOKIE_SAME_SITE=Lax` or the cookie is silently rejected and you get an infinite challenge loop. |
| **external-dns / Pi-hole** | **Free** | external-dns watches Ingresses with `ingressClassFilters = ["nginx"]` and writes them into Pi-hole every `2m`. Any new hostname gets DNS automatically. |
| **Longhorn / PVCs** | **No** | Only if using the `bbolt` store backend. See §7. |

---

## 5. Topologies

### 5.1 The official pattern — one sidecar per service

Upstream documents exactly one Kubernetes topology, and is blunt about its granularity:
*"One instance of Anubis must be used per service you are protecting."* Anubis runs as a **second
container inside the workload's own Pod**; the Service gains a second port; the Ingress backend is
repointed at that port.

```
client ──► ingress-nginx (TLS) ──► Service:anubis ──► Anubis sidecar ──► app (localhost:5000)
```

The sidecar, from the upstream example (target on `:5000`, Anubis on `:8080`):

```yaml
- name: anubis
  image: ghcr.io/techarohq/anubis:v1.27.0
  env:
    - name: BIND
      value: ":8080"
    - name: TARGET
      value: "http://localhost:5000"
    - name: DIFFICULTY
      value: "4"
    - name: METRICS_BIND
      value: ":9090"
    - name: SERVE_ROBOTS_TXT
      value: "true"
    - name: ED25519_PRIVATE_KEY_HEX
      valueFrom:
        secretKeyRef:
          name: anubis-key
          key: ED25519_PRIVATE_KEY_HEX
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    capabilities: { drop: [ALL] }
    seccompProfile: { type: RuntimeDefault }
```

Then the Service gains `port: 8080 / name: anubis`, and the Ingress backend switches from
`port.name: http` to `port.name: anubis`.

> **`PUBLIC_URL` must be left unset in this mode.** Setting it makes redirect construction produce
> `redir=null`. It is required only in forward-auth mode — the inversion catches people out.

There is no documented "Anubis in front of the ingress controller" topology, and it would not work
well regardless: `TARGET` is a single upstream, so one Anubis cannot fan out to eight `*.home` hosts.

### 5.2 Forward-auth — the only way to cover many hosts with one deployment

Set `TARGET=" "` (a literal single space) and Anubis stops proxying entirely, instead answering
`GET /.within.website/x/cmd/anubis/api/check` with pass/fail. That maps onto ingress-nginx's
`auth-url` / `auth-signin` annotations — the same shape already used for oauth2-proxy at
`modules/homelab/vaultwarden/default.nix:85-89`.

The upstream raw-nginx recipe, which is what would need translating:

```nginx
location /.within.website/ {
    proxy_pass http://127.0.0.1:8923;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    auth_request off;
}

location @redirectToAnubis {
    return 307 /.within.website/?redir=$scheme://$host$request_uri;
    auth_request off;
}

location / {
    auth_request /.within.website/x/cmd/anubis/api/check;
    error_page 401 = @redirectToAnubis;
}
```

Note that `/.within.website/*` must be served **on the same hostname** with auth disabled — the
cookie is host-scoped and the challenge assets live under that prefix. In ingress-nginx terms that
means a second Ingress object per protected host.

---

## 6. Three traps

### 6.1 Forward-auth fails *open* by default

Anubis ships these status codes deliberately:

```yaml
# By default, send HTTP 200 back to clients that either get issued a challenge
# or a denial. This seems weird, but this is load-bearing due to the fact that
# the most aggressive scraper bots seem to really, really, want an HTTP 200 and
# will stop sending requests once they get it.
status_codes:
  CHALLENGE: 200
  DENY: 200
```

Under nginx `auth_request`, a 2xx from the auth subrequest means *authentication succeeded*. So
with the stock policy, **every denial is read as an allow and passed straight through**. The
override is mandatory:

```yaml
status_codes:
  CHALLENGE: 200
  DENY: 403
```

### 6.2 The ingress-nginx recipe is unverified

Upstream documents subrequest auth for **raw nginx, Caddy and Traefik only**. There is no published
ingress-nginx annotation recipe, from upstream or (as far as this research found) from the
community. The `auth-url` + `auth-signin` translation above is inference; `@redirectToAnubis` has
no exact annotation equivalent, and `auth-signin` with `auth-signin-redirect-param` is the closest
approximation. Treat forward-auth here as something to prototype behind a throwaway service, not
something to trust in front of Vaultwarden.

### 6.3 `homelab.auth` does not exist

`modules/homelab/vaultwarden/default.nix:86` references
`config.homelab.auth.oauth2-proxy.ingressHost`, which is declared nowhere in this repo. Nix
laziness keeps it from being forced only while `gated = false`; setting `vaultwarden.gated = true`
(or `pihole.gated = true`, which has the same option and no consumer at all) fails evaluation.
Do not copy that as a pattern — declare options properly.

---

## 7. Operational requirements

**Signing key — mandatory.** Without `ED25519_PRIVATE_KEY_HEX`, Anubis generates a fresh keypair at
every startup, invalidating every issued cookie and re-challenging everyone. Generate with
`openssl rand -hex 32`. Prefer `ED25519_PRIVATE_KEY_HEX_FILE` fed from a sops secret — the repo
already has the file-path pattern (`modules/homelab/security/sops.nix`; Tailscale's `authKeyFile`
is the closest example).

> The design page `docs/design/how-anubis-works` still claims keypairs cannot be shared between
> instances. That page is stale — the environment variable exists and the Kubernetes page mandates it.

**Replicas.** More than one replica needs the same key **and** a shared store
(`store.backend: valkey`). `bbolt` takes an exclusive lock on its database and cannot be shared;
`memory` is documented as *"Do not use this persistently in production."* For a homelab: one
replica, `strategy: Recreate`, fixed key. Don't scale it.

**Policy reload.** Policy files load at startup only. Every allowlist tweak is a pod restart.

**Client IP.** Anubis needs `X-Real-IP` and `X-Forwarded-For`, and strips private ranges from XFF
by default (`XFF_STRIP_PRIVATE=true`). In the sidecar topology it sees the ingress controller's pod
IP unless propagation is correct — and the pod CIDR falls inside `10.0.0.0/8`, so importing
`allow-private-addresses.yaml` naively would allow *everything*, including public traffic, the
moment something is exposed.

---

## 8. What would actually break

Because only `Mozilla`-UA requests are challenged, the blast radius is narrower than it first
appears:

| Client | Verdict |
|---|---|
| `git clone` / `push` over HTTPS | **Fine by default** — git's UA is not Mozilla. `(data)/clients/git.yaml` exists to make it explicit. |
| Uptime Kuma HTTP monitors | **Fine by default** — not a browser UA. |
| Prometheus scraping | **Fine** — in-cluster, non-browser UA. |
| Immich mobile app | **Likely fine** — Dart/Flutter UA. Verify rather than assume. |
| Vaultwarden browser extension | **At risk** — runs inside the browser, sends a Mozilla UA to `/api` and `/identity`. Needs `(data)/common/json-api.yaml` or an explicit `ALLOW`. |
| Anything spoofing a browser UA | At risk. |
| RSS at a path like `/feed` (no extension) | At risk — the built-in exemption keys on `.rss`/`.xml`/`.atom`. |

Useful bundled snippets, imported with the `(data)/` prefix:

```yaml
bots:
  - import: (data)/clients/git.yaml
  - import: (data)/clients/go-get.yaml
  - import: (data)/clients/docker-client.yaml
  - import: (data)/common/json-api.yaml
  - import: (data)/common/keep-internet-working.yaml
```

**Forgejo-specific:** it needs `REVERSE_PROXY_TRUSTED_PROXIES` widened to the CNI pod CIDR, or it
misattributes every request to the proxy. Upstream documents this as a named caveat.

---

## 9. Plan of action

Recommended order. Steps 1–2 are the actual first move; 3–5 are contingent on wanting to go further.

**1. Prove it works in isolation.**
Flip `homelab.enable = true` on one host. Deploy Anubis standalone in an `anubis-system` namespace
with `TARGET` pointed at a throwaway backend. Confirm the challenge page renders and the two-curl
contrast in §10 behaves. No real service is at risk at this stage.

**2. Put it in front of Forgejo, sidecar topology.**
The canonical use case — git forges are crawled hardest, every commit, blame and diff URL being a
distinct page, and Gitea is a project sponsor. One namespace of blast radius, and it is the service
most likely to be exposed publicly later. Add `REVERSE_PROXY_TRUSTED_PROXIES`, import
`(data)/clients/git.yaml`, and verify `git clone` still works before declaring victory.

**3. Only then consider wider coverage.**
Cluster-wide means forward-auth, which means the unverified ingress-nginx translation *and* the
`DENY: 403` override *and* a second Ingress per host. Prototype against the throwaway service from
step 1, never directly against Vaultwarden.

**4. If it becomes a permanent fixture, build the module.**
Following repo convention — `modules/homelab/anubis/` with `default.nix` (options + manifests),
`policy/` (ConfigMap holding `botPolicies.yaml`), and a namespace subdir if standalone. Register it
by adding one line to the `imports` list in `modules/homelab/default.nix:6-27`. Gate everything on
`lib.mkIf (config.homelab.anubis.enable && config.homelab.enable)`. Note the four
`hosts/*/config/homelab-config/default.nix` files are byte-identical, so any new option block is
added four times unless that duplication is refactored first.

**5. Revisit if anything is ever actually exposed.**
That is the point at which Anubis stops being a lab exercise. Pair the `high-load-average` /
`low-load-average` WEIGH rules with thresholds so it only challenges under real load.

---

## 10. How to test

1. **Health and metrics** — both on `METRICS_BIND` (`:9090`). `/healthz` is a plain endpoint, so an
   `httpGet` probe is cheaper than the `anubis --healthcheck` exec form. `/metrics` is Prometheus
   format; the existing kube-prometheus-stack can scrape it.

2. **The two-curl contrast — this *is* the test.** Port-forward, then:

   ```bash
   # no Mozilla in the UA -> passes straight through
   curl -s http://localhost:8080/

   # spoofed browser -> challenge page
   curl -s -A 'Mozilla/5.0 (X11; Linux x86_64) Gecko/20100101 Firefox/137.0' \
        http://localhost:8080/ | head
   ```

   With default `status_codes` **both return 200**, so judge by the response body and by the
   `X-Anubis-Rule` / `X-Anubis-Action` / `X-Anubis-Status` headers Anubis passes to the backend —
   not by status code.

3. **Forward-auth check endpoint**, if testing that mode:

   ```bash
   curl -si http://localhost:8080/.within.website/x/cmd/anubis/api/check
   ```

   With no cookie this should be a 401. Confirm this before touching any Ingress.

4. **In a browser** — visit the protected host. Expect a brief interstitial ("Making sure you're not
   a bot!"), then the real page. Reload is instant because the cookie is set. Raise `difficulty`
   temporarily if you want to actually watch it work.

5. **Regression check** — `git clone https://forgejo.home/...`, and confirm the Uptime Kuma monitor
   for the protected host is still green. These are the two that matter.

6. **Debug** — `SLOG_LEVEL=DEBUG` logs every request and rule evaluation as JSON on stderr.

---

## 11. Sources

Upstream docs live at **`anubis.techaro.lol`** (note: `anubis.techaro.dev` is the CRD API group used
by the third-party operator, not a website).

- [TecharoHQ/anubis](https://github.com/TecharoHQ/anubis) · [releases](https://github.com/TecharoHQ/anubis/releases)
- [Kubernetes deployment](https://anubis.techaro.lol/docs/admin/environments/kubernetes)
- [Installation & environment variables](https://anubis.techaro.lol/docs/admin/installation)
- [Bot policies](https://anubis.techaro.lol/docs/admin/policies) · [thresholds](https://anubis.techaro.lol/docs/admin/configuration/thresholds) · [CEL expressions](https://anubis.techaro.lol/docs/admin/configuration/expressions)
- [Subrequest authentication](https://anubis.techaro.lol/docs/admin/configuration/subrequest-auth)
- [Default-allow behavior](https://anubis.techaro.lol/docs/admin/default-allow-behavior)
- [Gitea/Forgejo caveats](https://anubis.techaro.lol/docs/admin/caveats-gitea-forgejo) · [X-Forwarded-For caveats](https://anubis.techaro.lol/docs/admin/caveats-xff)
- [Discussion #1173 — Some Kubernetes cases](https://github.com/TecharoHQ/anubis/discussions/1173)
- Default policy: [`data/botPolicies.yaml`](https://github.com/TecharoHQ/anubis/blob/main/data/botPolicies.yaml) and the `data/{common,clients,bots,crawlers,meta}/` snippets
