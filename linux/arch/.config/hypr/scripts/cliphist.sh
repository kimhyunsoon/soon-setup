#!/bin/bash
# 클립보드 히스토리 (cliphist + rofi)
# Ctrl+D / Ctrl+X: 선택 항목 삭제

# 바이너리 항목을 [image:파일명]으로 표기 (직전에 저장된 스크린샷 경로에서 파일명 추출)
list_entries() {
  cliphist list | awk -F'\t' '
    {
      if ($2 ~ /^\[\[ binary data/) {
        if (prev ~ /\/screenshots\/[0-9_]+\.png$/) {
          n = split(prev, parts, "/")
          print $1 "\t[image:" parts[n] "]"
        } else {
          label = $2
          gsub(/\[\[ binary data /, "", label)
          gsub(/ \]\]$/, "", label)
          # 크기 제거 → "png 546x387"
          sub(/^[0-9.]+ [A-Za-z]+ /, "", label)
          print $1 "\t[image:" label "]"
        }
      } else print
      prev = $2
    }'
}

while true; do
  selected=$(list_entries | rofi -dmenu \
    -theme-str 'element { children: [ element-text ]; }' \
    -kb-remove-char-forward '' \
    -kb-custom-1 'Control+d' \
    -kb-custom-2 'Control+x')
  exit_code=$?

  if [ "$exit_code" -eq 0 ]; then
    # --type 명시: wl-copy의 MIME 자동감지(xdg-mime -> xprop)가 X11 소켓에서 멈추는 것 방지
    if [[ "$selected" == *$'\t'"[image:"* ]]; then
      fmt=$(grep -oE 'png|jpe?g|gif|webp|bmp' <<< "${selected#*$'\t'}" | head -1)
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
