{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  options = {tmux.enable = lib.mkEnableOption "Enable tmux module";};
  config = lib.mkIf config.myHomeConfig.apps.development.terminal.tmux.enable {
    programs.tmux = {
      enable = true;
      clock24 = true;
      baseIndex = 1;
      terminal = "tmux-256color";
      escapeTime = 0;
      keyMode = "vi";
      prefix = "C-s";
      mouse = true;
      newSession = true;
      secureSocket = true;
      plugins = let
        tmuxPluginsList = with pkgs.tmuxPlugins; [
          yank
          sensible
          tmux-fzf
          vim-tmux-navigator
          {
            plugin = resurrect;
            extraConfig = "set -g @resurrect-strategy-nvim 'session'";
          }
        ];
      in
        tmuxPluginsList;
      extraConfig = ''
        set -ag terminal-overrides ",xterm-256color:RGB"
        #--------------------------------------------------------------------------
        # Keybinds
        #--------------------------------------------------------------------------
        # Window bindings
        bind -n M-H previous-window
        bind -n M-L next-window
        bind = split-window -h
        bind - split-window -v
        bind x kill-pane

        # Copy mode
        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        # Tmux popups
        # bind -n C-p display-popup -w 90 -h 30 -E "zsh"

        unbind p
        unbind r

        bind p paste-buffer

        # Don't exit from tmux when closing a session
        set -g detach-on-destroy off

        # Renumber all windows when any window is closed
        set -g renumber-windows on

        # Tmux sessionizer
        bind -r f run-shell "tmux neww tmux-sessionizer-script"

        #--------------------------------------------------------------------------
        # Status Bar Gitmux
        #--------------------------------------------------------------------------

        # set -g status-left "#[fg=blue,bold]#S #[fg=white,nobold]#(${pkgs.gitmux}/bin/gitmux -cfg ${
          ./gitmux.yml
        }) "

        #--------------------------------------------------------------------------
        # Status Bar by conaN
        #--------------------------------------------------------------------------
        set -g @terminal_background             "default" # Original: #232634
        set -g @terminal_foreground             "#c6d0f5"

        set -g @pane_active_border              "#838ba7"
        set -g @pane_inactive_border            "#414559"

        set -g @status_background               "#303446"
        set -g @status_foreground               "#c6d0f5"
        set -g @status_separator_left           ""
        set -g @status_separator_right          ""

        set -g @window_active_color             "#51576d"
        set -g @window_inactive_color           "#303446"
        set -g @window_separator_left           ""
        set -g @window_separator_right          ""

        set -g @session_normal_color            "#8caaee"
        set -g @session_prefix_color            "#a6d189"
        set -g @session_mode_color              "#e5c890"
        set -g @session_zoom_color              "#ca9ee6"

        set -g @directory_icon                  " "
        set -g @directory_icon_color            "#e5c890"

        set -g @git_icon                        " "
        set -g @git_icon_color                  "#a6d189"

        set -g @icon_nvim                       " "
        set -g @color_nvim                      "#81c8be"
        set -g @icon_fish                       " "
        set -g @color_fish                      "#ea999c"
        set -g @icon_yazi                       " "
        set -g @color_yazi                      "#e5c890"
        set -g @icon_lazygit                    " "
        set -g @color_lazygit                   "#a6d189"
        set -g @icon_neogit                     " "
        set -g @color_neogit                    "#cba6f7"
        set -g @icon_fallback                   " "
        set -g @color_fallback                  "#8caaee"
        #======================================================================================================================================================================================================================#
        set -g focus-events on
        set -g allow-passthrough on
        set -g monitor-bell off
        set -g visual-bell off

        set -g status-right-length 100
        set -g status-left-length 100
        set -g status 2
        set -g status-format[1] ""
        set -g status-interval 2
        set -g status-position top

        set -g status-style 'bg=default' # transparent
        # set -g status-style "bg=#{@terminal_background},fg=#{@terminal_foreground}" # Original, but I want to use transparency
        set -g mode-style "bg=#{@terminal_foreground},fg=#{@terminal_background}"
        set -g pane-active-border-style "bg=#{@terminal_background},fg=#{@pane_active_border}"
        set -g pane-border-style "bg=#{@terminal_background},fg=#{@pane_inactive_border}"
        #======================================================================================================================================================================================================================#
        set -g window-status-current-format "\
        #[fg=#{@window_active_color}]#[bg=#{@terminal_background}]#{@window_separator_left}\
        #[bg=#{@window_active_color}]\
        \
        #{?#{==:#{pane_current_command},nvim},#[fg=#{@color_nvim}]#{@icon_nvim}#[fg=#{@status_foreground}]#{pane_current_command},\
        #{?#{==:#{pane_current_command},fish},#[fg=#{@color_fish}]#{@icon_fish}#[fg=#{@status_foreground}]#{pane_current_command},\
        #{?#{==:#{pane_current_command},yazi},#[fg=#{@color_yazi}]#{@icon_yazi}#[fg=#{@status_foreground}]#{pane_current_command},\
        #{?#{==:#{pane_current_command},lazygit},#[fg=#{@color_lazygit}]#{@icon_lazygit}#[fg=#{@status_foreground}]#{pane_current_command},\
        \
        #[fg=#{@color_fallback}]#{@icon_fallback}#[fg=#{@status_foreground}]#{pane_current_command}}}}}\
        \
        #[fg=#{@window_active_color}]#[bg=#{@terminal_background}]#{@window_separator_right}"
        #======================================================================================================================================================================================================================#

        #======================================================================================================================================================================================================================#
        set -g window-status-format "\
        #[fg=#{@window_inactive_color}]#[bg=#{@terminal_background}]#{@window_separator_left}\
        #[bg=#{@window_inactive_color}]\
        \
        #{?#{==:#{pane_current_command},nvim},#[fg=#{@color_nvim}]#{@icon_nvim}#[fg=#{@status_foreground}]#{pane_current_command},\
        #{?#{==:#{pane_current_command},fish},#[fg=#{@color_fish}]#{@icon_fish}#[fg=#{@status_foreground}]#{pane_current_command},\
        #{?#{==:#{pane_current_command},yazi},#[fg=#{@color_yazi}]#{@icon_yazi}#[fg=#{@status_foreground}]#{pane_current_command},\
        #{?#{==:#{pane_current_command},lazygit},#[fg=#{@color_lazygit}]#{@icon_lazygit}#[fg=#{@status_foreground}]#{pane_current_command},\
        \
        #[fg=#{@color_fallback}]#{@icon_fallback}#[fg=#{@status_foreground}]#{pane_current_command}}}}}\
        \
        #[fg=#{@window_inactive_color}]#[bg=#{@terminal_background}]#{@window_separator_right}"
        #======================================================================================================================================================================================================================#

        #======================================================================================================================================================================================================================#
        set -g status-left "\
        #[fg=#{?client_prefix,#{@session_prefix_color},#{?pane_in_mode,#{@session_mode_color},#{?window_zoomed_flag,#{@session_zoom_color},#{@session_normal_color}}}},bg=#{@terminal_background}]#{@status_separator_left}\
        #[fg=#{@terminal_background},bg=#{?client_prefix,#{@session_prefix_color},#{?pane_in_mode,#{@session_mode_color},#{?window_zoomed_flag,#{@session_zoom_color},#{@session_normal_color}}}}]\
        #S\
        #[fg=#{?client_prefix,#{@session_prefix_color},#{?pane_in_mode,#{@session_mode_color},#{?window_zoomed_flag,#{@session_zoom_color},#{@session_normal_color}}}},bg=#{@terminal_background}]#{@status_separator_right}\
         "
        #======================================================================================================================================================================================================================#

        #======================================================================================================================================================================================================================#
        set -g status-right "\
         \
        #[fg=#{@status_background},bg=#{@terminal_background}]#{@status_separator_left}\
        #[fg=#{@directory_icon_color},bg=#{@status_background}]#{@directory_icon}\
        #[fg=#{@status_foreground},bg=#{@status_background}]\
        \
        #(if [ \"#{pane_current_path}\" = \"\$HOME\" ]; then echo \"~\"; else echo \"#{pane_current_path}\" | awk -F/ '{if(NF>2) print \$(NF-1)\"/\"\$NF; else print \$NF}'; fi)\
        \
        #[fg=#{@status_background},bg=#{@terminal_background}]#{@status_separator_right}"

        set -ag status-right "\
         \
        #[fg=#{@status_background},bg=#{@terminal_background}]#{@status_separator_left}\
        #[fg=#{@git_icon_color},bg=#{@status_background}]#{@git_icon}\
        #[fg=#{@status_foreground},bg=#{@status_background}]\
        \
        #(git -C \"#{pane_current_path}\" branch --show-current 2>/dev/null || printf '·')\
        \
        #[fg=#{@status_background},bg=#{@terminal_background}]#{@status_separator_right}"
        #======================================================================================================================================================================================================================#
      '';
    };
    home.packages = with pkgs; [
      # https://frontendmasters.github.io/dev-prod-2/lessons/navigation/tmux
      tmux-sessionizer
      gitmux
      # Script to find files with tmux in vim
      (writeShellScriptBin "tmux-sessionizer-script" ''
        selected=$(find ~/work ~/ztm ~/personal ~/projects ~/opensource  -maxdepth 1 -mindepth 1 -type d | fzf)
        if [[ -z "$selected" ]]; then
            exit 0
        fi
        selected_name=$(basename $selected | tr ".,: " "____")

        switch_to() {
            if [[ -z "$TMUX" ]]; then
                tmux attach-session -t $selected_name
            else
                tmux switch-client -t $selected_name
            fi
        }

        if tmux has-session -t="$selected_name"; then
            switch_to
        else
            tmux new-session -ds $selected_name -c $selected
            switch_to
        fi
      '')
      (pkgs.writeShellScriptBin "tmux-init"
        # bash
        ''
          if [ -z "$TMUX" ]; then
            i=0
            while true; do
                session_name="base-$i"
                if tmux has-session -t "$session_name" 2>/dev/null; then
                    clients_count=$(tmux list-clients | grep $session_name | wc -l)
                    if [ $clients_count -eq 0 ]; then
                        tmux attach-session -t $session_name
                        break
                    fi
                    ((i++))
                else
                    tmux new-session -d -s $session_name
                    tmux attach-session -d -t $session_name
                    break
                fi
            done
          fi
        '')
    ];
  };
}
