#!/bin/bash

# 스크립트 파일의 디렉토리 경로 가져오기
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function linker() {
  local origin=$1
  local target=$2
  if [ -L "$target" ] ||  [ -e "$target" ]; then
    rm -rf $target
  fi
  ln -s "$(realpath $origin)" "$target"
}

linker "$SCRIPT_DIR/.blerc" $HOME/.blerc
linker "$SCRIPT_DIR/.bashrc" $HOME/.bashrc

# .config/
for dir in "$SCRIPT_DIR/.config/"*/; do
  linker $(realpath $dir) $HOME/.config/$(basename $dir)
done
