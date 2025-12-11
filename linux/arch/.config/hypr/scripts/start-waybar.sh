#!/bin/bash
# waybar를 우선순위가 가장 높은 연결된 모니터에만 표시

# 연결된 모니터 확인
monitors=$(hyprctl monitors -j | jq -r '.[].name')

# 우선순위: eDP-1 > DP-1 > HDMI-A-1
output=""
for monitor in eDP-1 DP-1 HDMI-A-1; do
  if echo "$monitors" | grep -q "^$monitor$"; then
    output="$monitor"
    break
  fi
done

# 연결된 모니터가 없으면 종료
if [ -z "$output" ]; then
  exit 1
fi

# config 생성
config_dir="$HOME/.config/waybar"
temp_config="/tmp/waybar-config.json"
jq --arg output "$output" '.output = [$output]' "$config_dir/config" > "$temp_config"

# waybar 실행
waybar -c "$temp_config" -s "$config_dir/style.css"
