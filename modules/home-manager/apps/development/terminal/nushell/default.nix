{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {nushell.enable = lib.mkEnableOption "Enable nushell module";};
  config = lib.mkIf config.myHomeConfig.apps.development.terminal.nushell.enable {
    home = {
      packages = with pkgs; [
        nufmt
        inshellisense
        zoxide
      ];
      file.".zoxide.nu" = {
        source =
          pkgs.runCommand "generate-zoxide-nu" {
            buildInputs = [pkgs.zoxide];
          } ''
            zoxide init nushell > $out
          '';
      };
    };
    programs = {
      nushell = {
        enable = true;
        configFile.text = ''
          let carapace_completer = {|spans|
              ${config.programs.carapace.package}/bin/carapace $spans.0 nushell ...$spans | from json
          }

          $env.config = {
            ls: {
              clickable_links: true
            }

            show_banner: false
            edit_mode: "vi"

            completions: {
              algorithm: "fuzzy"
              case_sensitive: false
              quick: true
              partial: true
              sort: "smart"
              external: {
                enable: true
                max_results: 100
                completer: $carapace_completer
              }
            }
            cursor_shape: {
              vi_insert: line
              vi_normal: block
            }
            keybindings: [
              {
                name: completion_menu
                modifier: none
                keycode: tab
                mode: [vi_insert vi_normal]
                event: { send: menu name: completion_menu }
              },
            ]
            use_kitty_protocol: true
            render_right_prompt_on_last_line: false
          }

          mkdir ($nu.data-dir | path join "vendor/autoload")
          starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

          source ~/.zoxide.nu
        '';
        extraEnv = ''
          $env.TRANSIENT_PROMPT_COMMAND = ">"
          $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
        '';
        shellAliases = {
          nv = "nvim";
          lg = "lazygit";
          cd = "z";
          git-co = "sh ~/.config/scripts/fuzzy-co.sh";
        };
      };
      carapace.enable = true;
    };
  };
}
