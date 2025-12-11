#!/bin/bash
# 모니터 변경 감지 및 waybar 동적 이동

CONFIG_DIR="$HOME/.config/waybar"
CONFIG_FILE="$CONFIG_DIR/config"
TEMP_CONFIG="/tmp/waybar-config-$$.json"

get_primary_monitor() {
  local monitors=$(hyprctl monitors -j | jq -r '.[].name')

  # 우선순위: eDP-1 > DP-1 > HDMI-A-1
  for monitor in eDP-1 DP-1 HDMI-A-1; do
    if echo "$monitors" | grep -q "^$monitor$"; then
      echo "$monitor"
      return 0
    fi
  done
  return 1
}

restart_waybar() {
  local output="$1"

  if [ -z "$output" ]; then
    return 1
  fi

  # waybar 종료
  killall waybar 2>/dev/null
  sleep 0.3

  # 임시 config 생성
  jq --arg output "$output" '.output = [$output]' "$CONFIG_FILE" > "$TEMP_CONFIG"

  # waybar 실행
  waybar -c "$TEMP_CONFIG" -s "$CONFIG_DIR/style.css" &
  disown
}

# 초기 실행
current_monitor=$(get_primary_monitor)
restart_waybar "$current_monitor"

# 모니터 변경 감지 (이벤트 기반)
if command -v socat &> /dev/null; then
  socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    event=$(echo "$line" | cut -d'>' -f1)

    case "$event" in
      monitoradded|monitorremoved)
        sleep 0.5
        new_monitor=$(get_primary_monitor)
        if [ "$new_monitor" != "$current_monitor" ] && [ -n "$new_monitor" ]; then
          current_monitor="$new_monitor"
          restart_waybar "$current_monitor"
        fi
        ;;
    esac
  done
else
  # socat이 없으면 주기적 체크
  while true; do
    sleep 3
    new_monitor=$(get_primary_monitor)

    if [ "$new_monitor" != "$current_monitor" ] && [ -n "$new_monitor" ]; then
      current_monitor="$new_monitor"
      restart_waybar "$current_monitor"
    fi
  done
fi
