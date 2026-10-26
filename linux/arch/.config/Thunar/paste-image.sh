#!/bin/bash

# Thunar 커스텀 액션: 클립보드의 이미지를 현재 폴더에 파일로 저장
DIR="$1"

if ! wl-paste -l 2>/dev/null | grep -q '^image/'; then
  notify-send "이미지 붙여넣기" "클립보드에 이미지가 없습니다"
  exit 1
fi

FILE="$DIR/clipboard_$(date +%Y%m%d_%H%M%S).png"
if ! wl-paste -t image/png > "$FILE"; then
  rm -f "$FILE"
  notify-send "이미지 붙여넣기" "저장에 실패했습니다"
  exit 1
fi
