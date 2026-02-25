# TODO: pihole https
{
  lib,
  config,
  ...
}: {
  imports = [
    ./external-dns-rbac
    ./namespace
  ];

  options.homelab.pihole = {
    enable = lib.mkEnableOption "pihole";
    password = lib.mkOption {type = lib.types.str;};
    ingressHost = lib.mkOption {
      type = lib.types.str;
      default = "pi.home";
    };
    dns = lib.mkOption {type = lib.types.str;};
    gated = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to gate this service behind oauth2-proxy";
    };
    webLoadBalancerIP = lib.mkOption {type = lib.types.str;};
    dnsLoadBalancerIP = lib.mkOption {type = lib.types.str;};
    adlists = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    replicas = lib.mkOption {
      type = lib.types.int;
      default = 1;
    };
  };

  config.services.k3s = lib.mkIf config.homelab.pihole.enable {
    autoDeployCharts = {
      pihole = {
        name = "pihole";
        repo = "https://mojo2600.github.io/pihole-kubernetes";
        version = "2.18.0";
        hash = "sha256-IPXWgsxtZ5E3ybsMjMuyWduMIH3HLwDHch8alipRNNo=";
        targetNamespace = "pihole-system";
        values = {
          DNS1 = config.homelab.pihole.dns;
          persistentVolumeClaim = {
            enabled = true;
          };
          ingress = {
            enabled = config.homelab.pihole.ingressHost != null;
            ingressClassName = "nginx";
            hosts = [config.homelab.pihole.ingressHost];
          };
          serviceWeb = {
            loadBalancerIP = config.homelab.pihole.webLoadBalancerIP;
            annotations."metallb.universe.tf/allow-shared-ip" = "pihole-svc";
            type = "LoadBalancer";
          };
          serviceDns = {
            loadBalancerIP = config.homelab.pihole.dnsLoadBalancerIP;
            annotations."metallb.universe.tf/allow-shared-ip" = "pihole-svc";
            type = "LoadBalancer";
          };
          replicaCount = config.homelab.pihole.replicas;
          admin = {
            enabled = true;
            existingSecret = "pihole-password";
            passwordKey = "password";
          };
          inherit (config.homelab.pihole) adlists;
        };
      };

      externaldns-pihole = {
        name = "externaldns-pihole";
        targetNamespace = "pihole-system";
        repo = "oci://registry-1.docker.io/bitnamicharts/external-dns";
        version = "9.0.0";
        hash = "sha256-uanyYjrtTuErABr9qNn/z36QP3HV3Ew2h6oJvpB+FwA=";
        values = {
          global.security.allowInsecureImages = true;
          image = {
            registry = "registry.k8s.io";
            repository = "external-dns/external-dns";
            tag = "v0.14.0";
          };
          provider = "pihole";
          policy = "upsert-only";
          txtOwnerId = "homelab";
          pihole.server = "http://pihole-web.pihole-system.svc.cluster.local";

          livenessProbe = {
            enabled = true;
            initialDelaySeconds = 30;
            periodSeconds = 30;
            timeoutSeconds = 5;
            failureThreshold = 3;
            successThreshold = 1;
          };

          readinessProbe = {
            enabled = true;
            initialDelaySeconds = 10;
            periodSeconds = 10;
            timeoutSeconds = 5;
            failureThreshold = 3;
            successThreshold = 1;
          };

          logLevel = "info";
          logFormat = "json";
          interval = "2m";

          extraEnvVars = [
            {
              name = "EXTERNAL_DNS_PIHOLE_PASSWORD";
              valueFrom.secretKeyRef = {
                name = "pihole-password";
                key = "password";
              };
            }
          ];
          serviceAccount = {
            create = true;
            name = "external-dns";
            automountServiceAccountToken = true;
          };
          ingressClassFilters = ["nginx"];
        };
      };
    };

    secrets = [
      {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "pihole-password";
          namespace = "pihole-system";
        };
        stringData = {
          inherit (config.homelab.pihole) password;
        };
      }
    ];
  };
}
