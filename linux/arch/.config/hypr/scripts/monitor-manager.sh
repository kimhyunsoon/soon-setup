#!/bin/bash
# 모니터/워크스페이스/waybar 통합 관리

LOG="/tmp/monitor-manager.log"

EDP="eDP-1,2880x1800@60,960x333,1"

log() {
  echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"
}

log "Script started ($1)"

# 클램쉘 상태 확인 및 eDP-1 설정
apply_clamshell() {
  local lid_state=$(cat /proc/acpi/button/lid/LID/state 2>/dev/null | awk '{print $2}')

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

  log "Lid: $lid_state, Monitors: $monitor_count"

  if [[ "$lid_state" == "closed" ]] && [[ $monitor_count -gt 1 ]]; then
    hyprctl keyword monitor "eDP-1,disable"
    log "eDP-1 disabled"
  else
    hyprctl keyword monitor "$EDP"
    log "eDP-1 enabled"
  fi
}

# 워크스페이스를 올바른 모니터로 이동
fix_workspaces() {
  sleep 0.3
  local monitors=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null)
  local workspaces=$(hyprctl workspaces -j 2>/dev/null)
  local active_ws=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id' 2>/dev/null)
  log "Monitors: $(echo $monitors | tr '\n' ' '), WS: $active_ws"

  for ws in {1..9}; do
    local priority
    if [[ $ws -le 3 ]]; then
      priority="eDP-1 DP-1 HDMI-A-1"
    elif [[ $ws -le 6 ]]; then
      priority="DP-1 eDP-1 HDMI-A-1"
    else
      priority="HDMI-A-1 eDP-1 DP-1"
    fi

    for monitor in $priority; do
      if echo "$monitors" | grep -q "^$monitor$"; then
        local current=$(echo "$workspaces" | jq -r ".[] | select(.id == $ws) | .monitor" 2>/dev/null)
        if [[ -n "$current" && "$current" != "$monitor" ]]; then
          hyprctl dispatch moveworkspacetomonitor "$ws" "$monitor"
          log "WS $ws: $current -> $monitor"
        fi
        hyprctl keyword workspace "$ws,monitor:$monitor"
        break
      fi
    done
  done

  if [[ -n "$active_ws" ]] && echo "$workspaces" | jq -e ".[] | select(.id == $active_ws)" >/dev/null 2>&1; then
    hyprctl dispatch workspace "$active_ws"
  else
    hyprctl dispatch workspace 1
  fi
}

# waybar 재시작 (flock으로 동시 실행 방지)
_restart_waybar() {
  (
    flock -n 200 || { log "waybar restart skipped (locked)"; return; }

    log "waybar restart executing"

    local monitors
    monitors=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null)

    local primary
    for mon in eDP-1 DP-1 HDMI-A-1; do
      if echo "$monitors" | grep -q "^$mon$"; then
        primary="$mon"
        break
      fi
    done

    if [[ -z "$primary" ]]; then
      log "No primary monitor found"
      return
    fi

    local config_dir="$HOME/.config/waybar"
    local temp_config="/tmp/waybar-config.json"
    jq --arg output "$primary" '.output = [$output]' "$config_dir/config" > "$temp_config"

    pkill -x waybar 2>/dev/null
    sleep 0.5
    waybar -c "$temp_config" -s "$config_dir/style.css" 200>&- &
    disown
    log "waybar started on $primary"
  ) 200>/tmp/waybar-restart.lock
}

# 즉시 실행 모드
run_once() {
  log "=== RUN_ONCE ==="
  apply_clamshell
  sleep 0.8
  fix_workspaces
  _restart_waybar &
  disown
  log "=== DONE ==="
}

# 데몬 모드 (이벤트 감지)
run_daemon() {
  # 기존 데몬 모두 종료 (자기 자신 제외)
  local old_pids
  old_pids=$(pgrep -f "monitor-manager.sh --daemon" | grep -v "^$$\$")
  if [[ -n "$old_pids" ]]; then
    echo "$old_pids" | xargs kill 2>/dev/null
    sleep 0.5
  fi

  local watchdog_pid
  trap 'kill $watchdog_pid 2>/dev/null' EXIT

  # 초기 실행
  run_once

  # waybar watchdog (5초마다 체크, 죽었으면 재시작)
  (while true; do
    sleep 5
    if ! pgrep -x waybar > /dev/null; then
      log "waybar watchdog: not running, restarting"
      _restart_waybar
    fi
  done) &
  watchdog_pid=$!

  # 이벤트 감지 (디바운스 3초)
  local debounce_file="/tmp/monitor-manager-debounce"
  echo 0 > "$debounce_file"

  socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    case "${line%%>>*}" in
      monitoradded|monitorremoved)
        local now=$(date +%s)
        local last=$(cat "$debounce_file" 2>/dev/null || echo 0)
        if (( now - last < 3 )); then
          log "Debounced: $line"
          continue
        fi
        echo "$now" > "$debounce_file"
        sleep 1
        apply_clamshell
        sleep 0.5
        fix_workspaces
        _restart_waybar &
        ;;
    esac
  done
}

case "$1" in
  --daemon) run_daemon ;;
  *) run_once ;;
esac
