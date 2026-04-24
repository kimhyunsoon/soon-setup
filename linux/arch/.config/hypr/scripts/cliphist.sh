#!/bin/bash
# 클립보드 히스토리 (cliphist + rofi)
# Ctrl+D / Ctrl+X: 선택 항목 삭제
while true; do
  selected=$(cliphist list | rofi -dmenu \
    -theme-str 'element { children: [ element-text ]; }' \
    -kb-remove-char-forward '' \
    -kb-custom-1 'Control+d' \
    -kb-custom-2 'Control+x')
  exit_code=$?

  if [ "$exit_code" -eq 0 ]; then
    echo "$selected" | cliphist decode | wl-copy
    break
  elif [ "$exit_code" -eq 10 ] || [ "$exit_code" -eq 11 ]; then
    echo "$selected" | cliphist delete
  else
    break
  fi
done
