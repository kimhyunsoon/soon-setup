#!/bin/bash
# HDMI-A-1 신호 복구 (해상도 변경으로 HDMI 핸드셰이크 재시작)
# disable 사용 시 wl_output 제거 → GDK3 dangling pointer → Firefox SIGSEGV

LOG="/tmp/monitor-manager.log"
HDMI="HDMI-A-1,3840x2160@60,7680x0,1,transform,1"

log() {
  echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"
}

if ! hyprctl monitors -j 2>/dev/null | jq -e '.[] | select(.name == "HDMI-A-1")' >/dev/null 2>&1; then
  log "HDMI-A-1 not detected, skipping"
  notify-send -t 3000 "HDMI-A-1 감지되지 않음"
  exit 0
fi

SUPPRESS_FILE="/tmp/monitor-manager-suppress"

# HDMI에서 포커스 이동 (알림이 보이도록)
local_monitors=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null)
for mon in DP-1 eDP-1; do
  if echo "$local_monitors" | grep -q "^$mon$"; then
    hyprctl dispatch focusmonitor "$mon"
    break
  fi
done

log "HDMI-A-1 reset start"
notify-send -t 15000 "HDMI-A-1 재연결 중..."

# 데몬의 모니터 이벤트 처리 억제
echo $$ > "$SUPPRESS_FILE"

for i in 1 2 3; do
  log "HDMI-A-1 cycle $i"
  hyprctl dispatch dpms off HDMI-A-1
  sleep 2
  hyprctl keyword monitor "HDMI-A-1,1920x1080@60,7680x0,1,transform,1"
  sleep 2
  hyprctl keyword monitor "$HDMI"
  sleep 2
done

hyprctl dispatch dpms on HDMI-A-1
log "HDMI-A-1 reset done"

# 억제 해제 후 1회만 실행
rm -f "$SUPPRESS_FILE"
~/.config/hypr/scripts/monitor-manager.sh

notify-send -t 3000 "HDMI-A-1 재연결 완료"
