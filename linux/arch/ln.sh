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

# limits (io_uring memlock 상향, 다음 로그인부터 적용. pam이 root로 읽으므로 복사)
sudo install -m 644 "$SCRIPT_DIR/limits/memlock.conf" /etc/security/limits.d/90-memlock.conf

# logid (logiops 설치된 경우만, sudo 필요)
if command -v logid &> /dev/null; then
  sudo ln -sf "$(realpath $SCRIPT_DIR/logid/logid.cfg)" /etc/logid.cfg
  sudo ln -sf "$(realpath $SCRIPT_DIR/logid/restart.rules)" /etc/udev/rules.d/99-logid-restart.rules
  sudo udevadm control --reload
fi
