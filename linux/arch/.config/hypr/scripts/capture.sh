#!/bin/bash

# 영역 선택 캡처 (Super+A) — 선택 중 다시 누르면 취소, OCR 진행 중이면 무시
SAVE_DIR="$HOME/Downloads/screenshots"
PID_FILE="/tmp/capture.pid"

# 이미 선택 중이면 취소
if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  pkill -P "$(cat "$PID_FILE")" -x slurp
  exit 0
fi

# OCR 진행 중이면 무시
( flock -n 9 ) 9>> /tmp/ocr.lock || exit 0
# 다른 선택 UI(OCR의 slurp 등) 진행 중이면 무시
pgrep -x slurp > /dev/null && exit 0

trap 'rm -f "$PID_FILE"' EXIT
echo $$ > "$PID_FILE"
GEOM=$(slurp) || exit 0
# 선택 완료 후에는 새 캡처 시작 허용 (satty 편집과 무관)
rm -f "$PID_FILE"

mkdir -p "$SAVE_DIR"
FILE="$SAVE_DIR/$(date +%Y%m%d_%H%M%S).png"
grim -g "$GEOM" - | tee "$FILE" >(wl-copy -t image/png) | satty --filename -
