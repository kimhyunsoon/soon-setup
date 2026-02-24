#!/bin/bash

# Spotify 우선, 없으면 다른 플레이어 사용
if playerctl --player=spotify status &>/dev/null; then
    player="--player=spotify"
else
    player=""
fi

player_status=$(playerctl $player status 2>/dev/null)

if [ "$player_status" = "Playing" ] || [ "$player_status" = "Paused" ]; then
    artist=$(playerctl $player metadata artist 2>/dev/null)
    album=$(playerctl $player metadata album 2>/dev/null)
    title=$(playerctl $player metadata title 2>/dev/null)
    track_number=$(playerctl $player metadata xesam:trackNumber 2>/dev/null)

    # 재생 중이면 녹색, 일시정지면 흰색
    if [ "$player_status" = "Playing" ]; then
        color="#1db954"
    else
        color="white"
    fi

    # 출력: 아티스트 • 앨범 | #트랙번호 곡명
    printf "<span color='white'>%s</span> <span color='#888888'>•</span> <span color='white'>%s</span> <span color='#888888'>|</span> <span color='%s'>#%s %s</span>" \
        "$artist" "$album" "$color" "$track_number" "$title"
else
    echo ""
fi
