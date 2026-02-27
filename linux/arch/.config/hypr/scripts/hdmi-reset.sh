#!/bin/bash
# HDMI-A-1 신호 복구 (disable → 1080p → 4K)

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

notify-send -t 7000 "HDMI-A-1 재연결 중..."
log "HDMI-A-1 reset start"
hyprctl keyword monitor "HDMI-A-1,disable"
sleep 5
hyprctl keyword monitor "HDMI-A-1,1920x1080@60,7680x0,1,transform,1"
sleep 2
hyprctl keyword monitor "$HDMI"
log "HDMI-A-1 reset done"
notify-send -t 3000 "HDMI-A-1 재연결 완료"
