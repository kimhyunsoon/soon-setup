#!/bin/bash

function linker() {
  local origin=$1
  local target=$2
  if [ -L "$target" ] ||  [ -e "$target" ]; then
    rm -rf $target
  fi
  ln -s "$(realpath $origin)" "$target"
}

# nvim
linker ./nvim $HOME/.config/nvim
# wezterm
linker ./.wezterm.lua $HOME/.wezterm.lua
# ghostty
linker ./ghostty $HOME/.config/ghostty

# claude
linker ./claude/CLAUDE.md $HOME/.claude/CLAUDE.md
linker ./claude/settings.json $HOME/.claude/settings.json
linker ./claude/statusline-command.sh $HOME/.claude/statusline-command.sh
