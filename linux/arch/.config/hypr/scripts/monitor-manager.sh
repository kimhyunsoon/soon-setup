#!/bin/bash
# 모니터/워크스페이스/waybar 통합 관리

LOG="/tmp/monitor-manager.log"
echo "[$(date '+%H:%M:%S')] Script started" >> "$LOG"

# 클램쉘 상태 확인 및 eDP-1 설정
apply_clamshell() {
  local lid_state=$(cat /proc/acpi/button/lid/LID/state 2>/dev/null | awk '{print $2}')

  # 재시도 로직 추가 (hyprctl이 준비될 때까지 대기)
  local retry=0
  local monitor_count=0
  while [[ $retry -lt 5 ]]; do
    monitor_count=$(hyprctl monitors -j 2>/dev/null | jq 'length' 2>/dev/null)
    if [[ $monitor_count -gt 0 ]]; then
      break
    fi
    sleep 0.3
    ((retry++))
  done

  echo "[$(date '+%H:%M:%S')] Lid: $lid_state, Monitors: $monitor_count" >> "$LOG"

  if [[ "$lid_state" == "closed" ]] && [[ $monitor_count -gt 1 ]]; then
    hyprctl keyword monitor "eDP-1,disable"
    echo "[$(date '+%H:%M:%S')] eDP-1 disabled" >> "$LOG"
  else
    hyprctl keyword monitor "eDP-1,2880x1800@60,960x333,1"
    echo "[$(date '+%H:%M:%S')] eDP-1 enabled" >> "$LOG"
  fi
}

# 워크스페이스를 올바른 모니터로 이동
fix_workspaces() {
  sleep 0.3
  local monitors=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null)
  local active_ws=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id' 2>/dev/null)
  local active_monitor=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.monitor' 2>/dev/null)
  echo "[$(date '+%H:%M:%S')] Active monitors: $(echo $monitors | tr '\n' ' '), Current WS: $active_ws on $active_monitor" >> "$LOG"

  for ws in {1..9}; do
    # 우선순위 결정
    local priority
    if [[ $ws -ge 1 && $ws -le 3 ]]; then
      priority="eDP-1 DP-1 HDMI-A-1"
    elif [[ $ws -ge 4 && $ws -le 6 ]]; then
      priority="DP-1 eDP-1 HDMI-A-1"
    else
      priority="HDMI-A-1 eDP-1 DP-1"
    fi

    # 사용 가능한 모니터 찾기
    for monitor in $priority; do
      if echo "$monitors" | grep -q "^$monitor$"; then
        # 워크스페이스가 있으면 이동
        local current=$(hyprctl workspaces -j 2>/dev/null | jq -r ".[] | select(.id == $ws) | .monitor" 2>/dev/null)
        if [[ -n "$current" && "$current" != "$monitor" ]]; then
          hyprctl dispatch moveworkspacetomonitor "$ws" "$monitor"
          echo "[$(date '+%H:%M:%S')] WS $ws: $current -> $monitor" >> "$LOG"
        fi
        hyprctl keyword workspace "$ws,monitor:$monitor"
        break
      fi
    done
  done

  # 현재 워크스페이스가 존재하고 유효하면 유지, 아니면 1번으로
  if [[ -n "$active_ws" ]] && hyprctl workspaces -j 2>/dev/null | jq -e ".[] | select(.id == $active_ws)" >/dev/null 2>&1; then
    hyprctl dispatch workspace "$active_ws"
    echo "[$(date '+%H:%M:%S')] Kept workspace $active_ws" >> "$LOG"
  else
    hyprctl dispatch workspace 1
    echo "[$(date '+%H:%M:%S')] Switched to workspace 1" >> "$LOG"
  fi
}

# waybar 재시작
restart_waybar() {
  killall waybar 2>/dev/null
  sleep 0.2

  local monitors=$(hyprctl monitors -j | jq -r '.[].name')
  local primary

  # 우선순위에 따라 primary 선택
  for mon in eDP-1 DP-1 HDMI-A-1; do
    if echo "$monitors" | grep -q "^$mon$"; then
      primary="$mon"
      break
    fi
  done

  if [[ -n "$primary" ]]; then
    local config_dir="$HOME/.config/waybar"
    local temp_config="/tmp/waybar-config-$$.json"
    jq --arg output "$primary" '.output = [$output]' "$config_dir/config" > "$temp_config"
    waybar -c "$temp_config" -s "$config_dir/style.css" &
    disown
  fi
}

# 즉시 실행 모드
run_once() {
  echo "[$(date '+%H:%M:%S')] === RUN_ONCE ===" >> "$LOG"
  apply_clamshell
  sleep 0.8
  fix_workspaces
  sleep 0.3
  restart_waybar
  echo "[$(date '+%H:%M:%S')] === DONE ===" >> "$LOG"
}

# 데몬 모드 (이벤트 감지)
run_daemon() {
  # 기존 데몬 종료
  pkill -f "monitor-manager.sh.*--daemon" 2>/dev/null
  sleep 0.3

  # 초기 실행
  run_once

  # 이벤트 감지
  socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    event=$(echo "$line" | cut -d'>' -f1)

    case "$event" in
      monitoradded|monitorremoved)
        sleep 0.5
        fix_workspaces
        restart_waybar
        ;;
    esac
  done
}

# 실행 모드 선택
if [[ "$1" == "--daemon" ]]; then
  run_daemon
else
  run_once
fi
