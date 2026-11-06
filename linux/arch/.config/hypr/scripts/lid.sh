#!/bin/bash
# 덮개/외장 모니터 처리 (logind 대신 담당, Hyprland 설정의 handle-lid-switch 억제 참고)
#   close   덮개 닫힘: 외장 있으면 클램쉘, 없으면 유예 후 절전
#   open    덮개 열림: 유예/절전 대기 취소, 내장 화면 복귀
#   check   모니터 연결 변화 시 재평가 (monitor-manager.sh에서 호출)
#   inhibit logind의 덮개 처리 억제 (Hyprland exec-once, Hyprland 종료 시 해제)

source "$(dirname "$0")/power-lib.sh"

PIDFILE="$STATE/lid-grace.pid"
# 덮개 닫힘 + 외장 모니터 없음 상태에서 절전까지 유예
GRACE_SEC=${POWER_GRACE_SEC:-300}

grace_running() {
  kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null
}

start_grace() {
  grace_running && return
  setsid "$0" _grace > /dev/null 2>&1 < /dev/null &
}

run_grace() {
  # 모니터 이벤트마다 check가 동시에 실행되므로 유예는 하나만
  exec 9> "$STATE/lid-grace.lock"
  flock -n 9 || exit 0
  echo $$ > "$PIDFILE"
  trap '[[ "$(cat "$PIDFILE" 2>/dev/null)" == $$ ]] && rm -f "$PIDFILE"' EXIT
  trap exit TERM
  log "유예 시작 (${GRACE_SEC}초)"
  local end=$((SECONDS + GRACE_SEC))
  while :; do
    # monitor-manager가 내장 화면을 다시 켤 수 있으므로 매번 끔
    hypr_dpms off eDP-1
    sleep 2
    lid_closed || { log "유예 취소: 덮개 열림"; exit; }
    (($(external_count) > 0)) && { log "유예 취소: 외장 연결"; exit; }
    if ! ac_online && battery_low; then
      log "배터리 부족"
      break
    fi
    # 화면만 끄기 모드에서는 작업 유지 (모드가 끝난 뒤부터 다시 유예)
    if [[ "$(cat "$STATE/mode" 2>/dev/null)" == screenoff ]]; then
      end=$((SECONDS + GRACE_SEC))
    fi
    ((SECONDS >= end)) && break
  done
  log "유예 종료 → 절전"
  "$SCRIPTS/power.sh" suspend
}

case "$1" in
  close)
    log "덮개 닫힘 (외장: $(external_count))"
    if (($(external_count) > 0)); then
      hypr_monitor_disable eDP-1 && sleep 0.5 && "$SCRIPTS/monitor-manager.sh"
    else
      start_grace
    fi
    ;;
  open)
    log "덮개 열림"
    kill_pidfile "$PIDFILE"
    "$SCRIPTS/power.sh" cancel
    hypr_monitor_set eDP-1 2880x1800@60 960x333 1 && sleep 0.5 && "$SCRIPTS/monitor-manager.sh"
    dpms_on
    ;;
  check)
    # 모니터 이벤트가 연달아 올 수 있으므로 안정될 때까지 대기
    sleep 3
    lid_closed || exit 0
    if (($(external_count) == 0)); then
      start_grace
    elif grace_running; then
      kill_pidfile "$PIDFILE"
      log "유예 취소: 외장 연결"
    fi
    ;;
  inhibit)
    exec systemd-inhibit --what=handle-lid-switch --who=Hyprland --why="lid.sh가 덮개 처리" --mode=block \
      tail --pid="$(pgrep -xo Hyprland)" -f /dev/null
    ;;
  _grace) run_grace ;;
  *) echo "usage: $0 close|open|check|inhibit" >&2; exit 1 ;;
esac
