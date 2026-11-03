#!/bin/bash
# 절전 관련 시스템 설정 설치 (sudo 필요)
#   - 블루투스 키보드로 절전 해제 (udev)
#   - 절전 해제 원인 커널 로그 (tmpfiles)
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo ln -sf "$DIR/bt-wakeup.rules" /etc/udev/rules.d/90-bt-wakeup.rules
sudo ln -sf "$DIR/pm-debug.conf" /etc/tmpfiles.d/pm-debug.conf
sudo udevadm control --reload
sudo udevadm trigger --action=add /sys/bus/pci/devices/0000:c3:00.3 /sys/bus/usb/devices/{usb1,1-3,1-3.1}
sudo udevadm settle
sudo systemd-tmpfiles --create /etc/tmpfiles.d/pm-debug.conf

echo "== 확인 (모두 enabled / 1 이어야 함)"
ok=1
for f in /sys/bus/pci/devices/0000:c3:00.3/power/wakeup \
         /sys/bus/usb/devices/{usb1,1-3,1-3.1}/power/wakeup \
         /sys/power/pm_debug_messages; do
  v=$(cat "$f" 2>/dev/null || echo "없음")
  printf '%-48s %s\n' "$f" "$v"
  [[ "$v" == enabled || "$v" == 1 ]] || ok=0
done

if ((ok)); then
  echo "완료"
else
  echo "일부 설정이 적용되지 않았습니다" >&2
  exit 1
fi
