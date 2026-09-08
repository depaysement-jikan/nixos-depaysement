# Home Manager Configuration

This directory contains the Home Manager module tree shared by every user in this repository. It's
structured to be modular and easily maintainable.

The modules here only *define* options — every option lives under the `homeManager` namespace and
defaults to disabled. The values and actual enablement are centralized per user in
`hosts/<host>/users/<user>/config/home-manager-config/default.nix`. This keeps a clean separation
between module definitions and host-specific settings.

The main entry point is `default.nix`, which imports all the sub-modules, sets `home.username` and
`home.homeDirectory` from the `settings.user` argument passed by the flake, applies the repository
overlays, and pulls in the `sops-nix` Home Manager module.

## Structure

- **`apps/`** — user applications, grouped by purpose:
  - `browsers/` — Zen, Helium, Firefox, Floorp.
  - `social/` — Discord, WhatsApp, Spotify.
  - `gaming/` — Steam, Gamescope.
  - `productivity/` — Obsidian, Sioyek, qBittorrent.
  - `development/`:
    - `terminal/` — Yazi, Zsh, Nushell, Tmux, Git, Ghostty, foot, Neovim, Starship, Certbot, Doppler.
    - `languages/` — Go, Node, TypeScript, Nix-lang, sh, C, Lua, Python, Rust, Zig, Elixir, JSON, Markdown.
    - `ai/` — Crush, Claude Code.
    - `db/` — PostgreSQL.
    - `api-clients/` — Yaak.
    - `package-managers/` — general package tooling (e.g. `wget`).
- **`desktop/`** — desktop environment components: Hyprland, Hyprlock, Noctalia, Waybar, Wofi and Rofi.
  Noctalia is the current default shell/bar; Waybar and Wofi remain available as alternatives.
- **`system/`** — user-level system configuration: `fonts` (JetBrains Mono Nerd Font, Maple Mono NF),
  `themes` (Stylix and Catppuccin), `clipboard` (`clipse`) and `openLinkHub`.
- **`hardware/`** — user-specific hardware configuration (QMK).
- **`misc/`** — miscellaneous packages, currently the `cli` submodule (`cbonsai`, `lolcat`, `fastfetch`,
  `htop`, `pciutils`).
- **`scripts/`** — custom scripts installed into `~/.config/scripts` (e.g. `fuzzy-co.sh`).
- **`wallpapers/`** — wallpapers and backgrounds referenced by the desktop and theming modules.
- **`pfp/`** — avatar images used by `~/.face.icon`, Noctalia and the lock screen.

## Option tree

```nix
homeManager = {
  enable = true;
  apps = {
    enable = true;
    browsers = { enable; zen; firefox; floorp; helium; };
    social = { enable; discord; whatsapp; spotify; };
    gaming = { enable; steam; gamescope; };
    productivity = { enable; obsidian; sioyek; qbittorrent; };
    development = {
      enable;
      terminal = { enable; yazi; zsh; nushell; tmux; git; ghostty; foot; neovim; starship; certbot; doppler; };
      api-clients = { enable; yaak; };
      languages = { enable; go; node; markdown; nix-lang; sh; c; typescript; lua; python; rust; zig; json; elixir; };
      ai = { enable; crush; claude; };
      db = { enable; postgres; };
      package-managers.enable;
    };
  };
  desktop = { enable; rofi; wofi; hyprland; hyprlock; waybar; noctalia; };
  system = { enable; fonts; openLinkHub; themes = { enable; catppuccin; stylix; }; clipboard; };
  hardware = { enable; qmk; };
  misc = { enable; cli; };
};
```

Each leaf above is an `enable` sub-option (`foo.enable = true;`). See
`hosts/shinobu/users/kokoro/config/home-manager-config/default.nix` for a fully populated example.

## Rebuilding

The user environment is normally built together with the system:

```bash
nh os switch .#<host>          # or: sudo nixos-rebuild switch --flake .#<host>
```

It can also be rebuilt on its own through the standalone flake output:

```bash
nh home switch .#<user>@<host> # or: home-manager switch --flake .#<user>@<host>
```
