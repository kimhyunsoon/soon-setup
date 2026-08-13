#!/usr/bin/env bash
# Firefox private 창 등이 붙이는 sensitive 힌트를 무시하고 히스토리에 저장
[[ "$CLIPBOARD_STATE" == "sensitive" ]] && export CLIPBOARD_STATE=data
exec cliphist store
