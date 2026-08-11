# NixOS unstable migration — post-mortem (shinobu, Aug 11 2026)

Moving the flake from stable to `nixpkgs-unstable` and running `nh os switch .` produced a
black screen after boot. Three separate problems were involved. Only the first one was
actually blocking the desktop; the other two surfaced while fixing it.

| # | Symptom | Root cause | Fix |
|---|---------|-----------|-----|
| 1 | Black screen after `Reached target Graphical Interface` | Nix `''…''` string with backslash "continuations" → invalid TOML for greetd | Build the command with `lib.concatStringsSep " "` |
| 2 | 24 `hyprctl configerrors` | Hyprland 0.54/0.55 removed options and dispatchers | Update to the new option names |
| 3 | `nh home switch` eval failure | `nixfmt-classic` removed from nixpkgs 26.11 | Use `pkgs.nixfmt` |

The common thread: none of these were caused by unstable *breaking* anything. Two were
latent bugs that older versions tolerated, and one was a package that reached the end of
its deprecation window. Moving to unstable just collected the bill.

---

## Problem 1 — greetd failed to start (the black screen)

### What it looked like

Boot reached the end of the systemd log and stopped, showing only a cursor. Different
generations behaved differently:

- kernel 7.1.8 — black screen
- kernel 7.1.2 — worked
- kernel 6.18.44 — black screen

### Reading the screen correctly

The most important detail in the boot output was what was **missing**: no failed units, no
kernel panic, no emergency shell. The log ended with:

```
[  OK  ] Started greetd.service.
[  OK  ] Started SSH Daemon.
[  OK  ] Started Nginx Web Server.
[  OK  ] Reached target Multi-User System.
[  OK  ] Reached target Graphical Interface.
```

systemd reached `graphical.target`. The machine was fully booted and running. Nothing hung.
There was simply no greeter drawing to the display.

That reframes the problem: **the machine was up, it just had no UI**. And because sshd was
running, the machine was reachable the whole time.

### Why the kernel was a red herring

Two very different kernels (7.1.8 and 6.18.44) failed while 7.1.2 worked. A kernel
regression can't explain that. What the two broken generations had in common was that both
were built *after* the move to unstable — so they shared the same userspace. 7.1.2 was the
last generation built before the switch.

**Correlation, not causation.** The kernel version was the most visible thing that changed,
which made it the obvious suspect and the wrong one.

### Getting the evidence

```bash
ssh kokoro@shinobu                  # sshd was running the whole time
journalctl -b -1 -u greetd
```

```
Started greetd.service.
greetd[1047]: expected equals sign on line, but found none
greetd.service: Main process exited, code=exited, status=1/FAILURE
```

greetd started, failed to parse its config, and exited within the same second. All three
log lines share one timestamp.

Alternative routes if SSH hadn't answered:

- `Ctrl+Alt+F2` for another VT
- At the systemd-boot menu, press `e` and append `systemd.unit=multi-user.target` — greetd
  is `wantedBy graphical.target`, so this boots to a plain console login

### The actual bug

```nix
command = ''
  ${pkgs.tuigreet}/bin/tuigreet \
    --time \
    --remember \
    --remember-user-session \
    --cmd Hyprland
'';
```

**Nix indented strings (`''…''`) do not process backslash escapes.** In a `"…"` string, `\`
is an escape character. In `''…''`, the only escape sequence is `''\`. A trailing backslash
is just a literal backslash character.

So `command` was never one line. It was a five-line string containing real newlines, four
literal `\` characters, and a trailing newline. Nix doesn't error on this — it's a perfectly
valid string, just not the intended one.

That string went into `services.greetd.settings`, which the NixOS module serializes to TOML
at `/etc/greetd/config.toml`. A multi-line value came out the other side as something
greetd's parser couldn't read: it hit a line that was neither `key = value` nor a `[table]`
header, and said so.

### Why it only broke now

The string had been malformed the whole time. On stable, either the TOML writer escaped
those newlines into something valid or greetd's parser tolerated the result. Unstable moved
one of the two — a nixpkgs `formats` change or a greetd version bump — and the latent bug
surfaced.

### The fix

```nix
{ config, pkgs, lib, ... }: {
  options.nixos-generic.desktop.tuigreet = {
    enable = lib.mkEnableOption "TUIGreet Display Manager";
  };

  config = lib.mkIf config.nixos-generic.desktop.tuigreet.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = lib.concatStringsSep " " [
            "${pkgs.tuigreet}/bin/tuigreet"
            "--time"
            "--remember"
            "--remember-user-session"
            "--cmd ${lib.getExe pkgs.hyprland}"
          ];
          user = "greeter";
        };
      };
    };
  };
}
```

`concatStringsSep " "` produces a genuine single-line string while keeping the source
readable. `lib.getExe` was also used for Hyprland so the greeter doesn't depend on
`Hyprland` being on `PATH`.

Verify before rebooting:

```bash
nix eval .#nixosConfigurations.shinobu.config.services.greetd.settings.default_session.command --raw
```

Expected — one line, no backslashes:

```
/nix/store/…-tuigreet-0.9.1/bin/tuigreet --time --remember --remember-user-session --cmd /nix/store/…-hyprland-0.56.2/bin/Hyprland
```

Then check the generated file after activation:

```bash
nh os switch .
cat /etc/greetd/config.toml
```

---

## Problem 2 — Hyprland config errors

### What it looked like

With greetd fixed, the desktop came up but with a red error banner:

```
config option <decoration:shadow:ignore_window> does not exist.
config option <dwindle:pseudotile> does not exist.
config option <misc:vfr> does not exist.
Invalid dispatcher, requested "togglesplit" does not exist
windowrulev2 is deprecated.
(19 more...)
```

The banner truncates. Full list:

```bash
hyprctl configerrors
```

24 errors total: 4 option/dispatcher errors, plus one per `windowrulev2` line (20 of them).

### Cause

Unstable jumped Hyprland across two releases with breaking changes.

**0.54 — the layout rewrite.** The `togglesplit` and `swapsplit` dispatchers were removed;
they'd been deprecated for a while. The functionality still exists, but goes through
`layoutmsg` now.

**0.55 — config cleanup.**

- `dwindle:pseudotile` removed (it wasn't doing anything; pseudotiling is per-window now)
- `decoration:shadow:ignore_window` removed (defaults to enabled)
- `misc:vfr` moved to `debug:vfr` — it's a debug variable that shouldn't be changed in
  production

Separately, `windowrulev2` had already folded back into plain `windowrule`. The v2 *syntax*
is the current syntax; only the keyword changed. That's why every rule line errored while
the rules themselves were fine.

### Changes applied

| Old | New |
|-----|-----|
| `decoration.shadow.ignore_window = true` | *(removed)* |
| `dwindle.pseudotile = true` | *(removed)* |
| `misc.vfr = true` | `debug.vfr = true` |
| `"SUPER, T, togglesplit"` | `"$mainMod, T, layoutmsg, togglesplit"` |
| `windowrulev2 = [ … ]` | `windowrule = [ … ]` |

Cleanups made at the same time:

- **Dropped the `master` block.** With `general.layout = "dwindle"` it was inert, and master
  was reworked in the same 0.54 rewrite — dead config that could only generate future errors.
- **`wl-clipboard` was listed twice** in `home.packages`.
- **`"SUPER $mainMod SHIFT, 1"` expanded to `SUPER SUPER SHIFT`.** It worked by accident.
  Everything now uses `$mainMod` consistently.

### Applying without logging out

```bash
nh home switch .
hyprctl reload
hyprctl configerrors     # expect: no errors
```

`hyprctl reload` applies rules, binds, and decoration live. `exec-once` only runs at
compositor startup, so autostart changes need a fresh session.

### Note for later

As of 0.55 the hyprlang config format is deprecated in favour of Lua, though it keeps
working for a few releases. The home-manager `settings` attrset generates hyprlang, and the
HM module now warns about it:

```
The default value of `wayland.windowManager.hyprland.configType` has changed
from "hyprlang" to "lua". You are currently using the legacy default because
home.stateVersion is less than "26.05".
```

To silence it and keep current behaviour explicitly:

```nix
wayland.windowManager.hyprland.configType = "hyprlang";
```

A Lua migration is on the horizon but not urgent.

---

## Problem 3 — home-manager eval failure

### What it looked like

```
error: nixfmt-classic has been removed as it is deprecated and unmaintained.

… while evaluating the option `home.packages':
… while evaluating definitions from
   `…/modules/home-manager/apps/development/languages/nix-lang':
```

### Cause

`nixfmt-classic` is the old Haskell formatter. In nixpkgs 25.11 the RFC-166 formatter became
stable as `pkgs.nixfmt` (deprecating `pkgs.nixfmt-rfc-style`), with classic kept around as
`pkgs.nixfmt-classic` for one more cycle. 26.11 finished the removal.

Nothing to do with the migration itself — the deprecation window simply expired.

### Fix

```bash
grep -rn 'nixfmt-classic' ~/.nixos-dotfiles
```

Replace with `nixfmt` in `modules/home-manager/apps/development/languages/nix-lang`. Output
formatting differs slightly — it's the RFC-166 formatter, not the classic one.

### Related: version mismatch

```
You are using Home Manager version 25.11 and Nixpkgs version 26.11.
```

Not the cause of the error, but a real problem: HM modules track nixpkgs option renames, so
a stale HM eventually generates config for options that no longer exist.

```nix
home-manager = {
  url = "github:nix-community/home-manager";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

HM's `master` tracks `nixpkgs-unstable`. Then `nix flake update home-manager`.

**Don't** set `home.enableNixpkgsReleaseCheck = false` — that silences the warning without
fixing the mismatch, and the signal is worth keeping.

---

## Still outstanding

- **Stylix version mismatch.** Same class of problem as the HM one — bump the input rather
  than setting `stylix.enableReleaseChecks = false`.
- **`home.pointerCursor.enable = true`** — relying on the option's presence to enable cursor
  generation is deprecated; set it explicitly.
- **`xorg.xrdb` → `xrdb`** — warning now, error later.
- **`gtk.gtk4.theme`** — default changed from `config.gtk.theme` to `null` for
  `stateVersion >= 26.05`. Decide which you want and set it explicitly.
- **Duplicate `home = { … }` binding** in the top-level HM config — `stateVersion`/
  `sessionPath`/`sessionVariables` in one, `username`/`homeDirectory` in another. Merge
  them.
- **Commit the tree.** Every build in this session warned `Git tree is dirty`.

---

## Lessons

**Read what the boot log doesn't say.** No failed unit and no panic meant the system was
fine and only the UI was missing. That immediately ruled out the kernel and pointed at
userspace.

**sshd is a lifeline.** With `services.openssh.enable = true`, a machine with no display is
still fully debuggable from another box.

**"Which generations fail" is a diagnostic, not just a symptom.** Two different kernels
failing while one worked ruled out the kernel in one step. The question to ask is what the
failing generations share, not what changed most visibly.

**`''…''` does not do line continuations.** The single most transferable lesson here. If a
multi-line Nix string is going anywhere that expects one line — a TOML value, a systemd
`ExecStart`, an INI field — build it with `concatStringsSep` instead.

**Verify the generated artifact, not just that the build succeeded.** `nix eval` on the
final value and `cat` on the file in `/etc` both catch this class of bug before a reboot
does.

**A stable→unstable move surfaces latent bugs; it rarely creates them.** Two of these three
problems predated the migration. The upgrade only removed the tolerance that was hiding them.
