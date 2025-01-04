#!/bin/bash

function linker() {
  local origin=$1
  local target=$2
  if [ -L "$target" ] ||  [ -e "$target" ]; then
    rm -rf $target
  fi
  ln -s "$(realpath $origin)" "$target"
}

linker ./.blerc $HOME/.blerc
linker .bashrc $HOME/.bashrc

# .config/
for dir in ./.config/*/; do
  linker $(realpath $dir) $HOME/.config/$(basename $dir)
done
