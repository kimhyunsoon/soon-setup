#!/bin/bash

# JSON 입력 읽기
input=$(cat)

# JSON에서 필요한 데이터 추출
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')

# 현재 디렉토리명
get_current_dir() {
  local dirname=$(basename "$cwd")
  printf "\033[38;2;66;165;245m󰉋\033[0m \033[38;5;250m%s\033[0m" "$dirname"
}

# Claude 모델 정보
get_model_info() {
  printf "\033[38;2;179;136;255m󰚩\033[0m \033[38;5;250m%s\033[0m" "$model_name"
}

dir_info=$(get_current_dir)
model_info=$(get_model_info)

# 최종 출력
printf "%s %s   %s\n" "$dir_info" "$model_info"
