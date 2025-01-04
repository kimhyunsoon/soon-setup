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
