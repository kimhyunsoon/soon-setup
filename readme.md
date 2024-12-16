### Setting Steps
1. install ripgrep (windows: xclip)
2. install build-essential (or gcc)
3. install go / rust / node (22 LTS)
4. install NerdFont (Hack Mono, D2CodingLighture Mono)
5. install nvim (version 9^)
6. install WezTerm
7. (optional) chmod +x ~/.local/share/nvim/mason/bin/*
8. cp -r ./nvim ~/.config/nvim
9. cp ./.wezterm.lua ~/.wezterm.lua
10. do :Copilot auth on nvim

### Wezterm Options
```
# WezTerm Shell Integration for bash
if [[ -n "$WEZTERM_PANE" ]]; then
  update_cwd() {
    printf "\033]7;file://%s%s\033\\" "$(hostname)" "$PWD"
  }
  if [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND="update_cwd"
  else
    PROMPT_COMMAND="$PROMPT_COMMAND;update_cwd"
  fi
fi
```
