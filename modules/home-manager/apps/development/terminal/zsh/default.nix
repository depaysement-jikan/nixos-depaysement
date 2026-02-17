{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {zsh.enable = lib.mkEnableOption "Enable zsh module";};
  config = lib.mkIf config.myHomeConfig.apps.development.terminal.zsh.enable {
    home = {
      shell = {enableZshIntegration = true;};
      sessionPath = ["$HOME/.local/share/pnpm"];
      sessionVariables = {PNPM_HOME = "$HOME/.local/share/pnpm";};
      packages = with pkgs; [zoxide ripgrep fd fzf];
    };
    programs = {
      eza.enable = true;
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        initContent = ''
          export PATH=$PATH:~/.local/bin/
          export PATH=/tmp/lazy-lvim/bin:$PATH

          # Autosuggest
          ZSH_AUTOSUGGEST_USE_ASYNC="true"

          # Group matches and describe.
          zstyle ':completion:*' sort false
          zstyle ':completion:complete:*:options' sort false
          zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
          zstyle ':completion:*' special-dirs true
          zstyle ':completion:*' rehash true

          zstyle ':completion:*' menu yes select
          zstyle ':completion:*' list-grouped false
          zstyle ':completion:*' list-separator '''
          zstyle ':completion:*' group-name '''
          zstyle ':completion:*' verbose yes
          zstyle ':completion:*:matches' group 'yes'
          zstyle ':completion:*:warnings' format '%F{red}%B-- No match for: %d --%b%f'
          zstyle ':completion:*:messages' format '%d'
          zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
          zstyle ':completion:*:descriptions' format '[%d]'

          # Fuzzy match mistyped completions.
          zstyle ':completion:*' completer _complete _match _approximate
          zstyle ':completion:*:match:*' original only
          zstyle ':completion:*:approximate:*' max-errors 1 numeric

          # Don't complete unavailable commands.
          zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

          # Array completion element sorting.
          zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

          # fzf-tab
          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
          zstyle ':fzf-tab:complete:_zlua:*' query-string input
          zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
          zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'
          zstyle ':fzf-tab:complete:kill:*' popup-pad 0 3
          zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
          zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0
          zstyle ':fzf-tab:*' switch-group ',' '.'
          zstyle ":completion:*:git-checkout:*" sort false
          zstyle ':completion:*' file-sort modification
          # zstyle ':completion:*:eza' sort false
          zstyle ':completion:files' sort false

          # zoxide
          eval "$(zoxide init zsh)"
          eval "$(ssh-agent -s)" > /dev/null 2>&1

          #starship
          eval "$(starship init zsh)"

          # Aliases
          alias n='nvim'
          alias lg='lazygit'
          alias cd='z'
          alias git-co='sh ~/.config/scripts/fuzzy-co.sh'
          alias k='kubectl'

          # Nuke starship if needed
          # sed -i '/starship/d' ~/.zshrc
        '';
        oh-my-zsh = {
          enable = true;
          plugins = ["git" "colorize" "colored-man-pages" "history-substring-search"];
        };

        plugins = with pkgs; [
          {
            name = "zsh-autopair";
            file = "zsh-autopair.plugin.zsh";
            src = zsh-autopair;
          }
          {
            name = "fzf-tab";
            file = "fzf-tab.plugin.zsh";
            src = zsh-fzf-tab;
          }
        ];
      };
    };
  };
}
