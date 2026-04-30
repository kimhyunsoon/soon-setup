#!/bin/bash
# HDMI-A-1 확장/미러링 토글

HDMI_EXTENDED="HDMI-A-1,3840x2160@60,7680x0,1,transform,1"
HDMI_MIRROR="HDMI-A-1,preferred,auto,1,mirror,eDP-1"
STATE_FILE="/tmp/hdmi-mirror-state"

if ! grep -q "^connected" /sys/class/drm/card*-HDMI-A-1/status 2>/dev/null; then
  notify-send -t 3000 "HDMI-A-1 감지되지 않음"
  exit 0
fi

# 초기 상태: hyprland.conf 기본값이 mirror이므로 파일 없으면 mirror
current=$(cat "$STATE_FILE" 2>/dev/null || echo "mirror")

if [[ "$current" == "mirror" ]]; then
  hyprctl keyword monitor "$HDMI_EXTENDED"
  echo "extended" > "$STATE_FILE"
  notify-send -t 3000 "HDMI-A-1 확장 모드로 전환"
else
  hyprctl keyword monitor "$HDMI_MIRROR"
  echo "mirror" > "$STATE_FILE"
  notify-send -t 3000 "HDMI-A-1 미러링 모드로 전환"
fi

sleep 0.5
hyprctl hyprpaper wallpaper "HDMI-A-1,~/.config/hypr/wallpaper.jpg"
~/.config/hypr/scripts/monitor-manager.sh
