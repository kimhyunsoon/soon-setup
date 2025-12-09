#!/bin/bash

# 워크스페이스별 모니터 우선순위 매핑
get_monitor_priority() {
  local ws=$1

  if [[ $ws -ge 1 && $ws -le 3 ]]; then
    echo "eDP-1 DP-1 HDMI-A-1"
  elif [[ $ws -ge 4 && $ws -le 6 ]]; then
    echo "DP-1 eDP-1 HDMI-A-1"
  elif [[ $ws -ge 7 && $ws -le 9 ]]; then
    echo "HDMI-A-1 eDP-1 DP-1"
  fi
}

# 연결된 모니터 확인
is_monitor_connected() {
  local monitor=$1
  hyprctl monitors -j | jq -r '.[].name' | grep -q "^${monitor}$"
}

# 워크스페이스별 모니터 할당
assign_workspaces() {
  for ws in {1..9}; do
    local priority=$(get_monitor_priority $ws)

    for monitor in $priority; do
      if is_monitor_connected "$monitor"; then
        hyprctl keyword workspace "$ws,monitor:$monitor" >/dev/null 2>&1
        break
      fi
    done
  done
}

# 초기 할당
assign_workspaces

# 모니터 이벤트 감지
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
  event=$(echo "$line" | cut -d'>' -f1)

  case "$event" in
    monitoradded|monitorremoved)
      sleep 0.3
      assign_workspaces
      ;;
  esac
done
