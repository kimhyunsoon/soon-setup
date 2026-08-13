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
    # --type 명시: wl-copy의 MIME 자동감지(xdg-mime -> xprop)가 X11 소켓에서 멈추는 것 방지
    if [[ "$selected" == *"[[ binary data"* ]]; then
      fmt=$(grep -oE 'png|jpe?g|gif|webp|bmp' <<< "$selected" | head -1)
      [ "$fmt" = "jpg" ] && fmt="jpeg"
      echo "$selected" | cliphist decode | wl-copy --type "image/${fmt:-png}"
    else
      echo "$selected" | cliphist decode | wl-copy --type text/plain
    fi
    break
  elif [ "$exit_code" -eq 10 ] || [ "$exit_code" -eq 11 ]; then
    echo "$selected" | cliphist delete
  else
    break
  fi
done
