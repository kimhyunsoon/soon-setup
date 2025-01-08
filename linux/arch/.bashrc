# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# ble.sh start
[[ $- == *i* ]] && source $HOME/ble.sh/out/ble.sh

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# fzf to dir
fcd() {
  local dir
  dir=$(find ~ -type d 2> /dev/null | \
    fzf --preview 'ls -la --color=always {} | head -100' \
      --preview-window=right:50% \
      --height=80% \
      --layout=reverse \
      --border=rounded \
      --query="$1" \
      --color='hl:yellow,hl+:yellow' \
      --prompt=' ')
  
  if [[ -n "$dir" ]]; then
    cd "$dir"
  fi
}

# fzf to file
ff() {
  local file
  file=$(find ~ -type f 2> /dev/null | \
    fzf --height=80% \
      --layout=reverse \
      --border=rounded \
      --query="$1" \
      --prompt=' ')
  if [[ -n "$file" ]]; then
    cd "$(dirname "$file")"
  fi
}

# ocr
ocr() {
  SCREENSHOT_DIR="$HOME/ocr_screenshot"
  rm -rf "$SCREENSHOT_DIR" 2>/dev/null && mkdir -p "$SCREENSHOT_DIR"
  hyprshot -m region -o "$SCREENSHOT_DIR" --silent

  for i in {1..3}; do
    SCREENSHOT_FILE=$(ls $SCREENSHOT_DIR/* 2>/dev/null | head -n 1)
    [ -f "$SCREENSHOT_FILE" ] && break
    [ $i -eq 3 ] && { notify-send "OCR 실패" "스크린샷 생성 실패"; rm -rf "$SCREENSHOT_DIR"; exit 1; }
    sleep 1
  done

  TEXT=$(tesseract "$SCREENSHOT_FILE" stdout -l eng+kor)
  if [ -n "$TEXT" ]; then
    printf '%s' "$TEXT" | wl-copy && notify-send "OCR 완료" "$TEXT"
  else
    notify-send "OCR 실패" "텍스트 추출 실패"
  fi

  rm -rf "$SCREENSHOT_DIR"
}

# wezterm detect cwd
if [[ -n "$WEZTERM_PANE" ]]; then
  update_cwd() {
    printf "\033]7;file://%s%s\033\\" "${HOSTNAME}" "$PWD"
  }
  if [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND="update_cwd"
  else
    PROMPT_COMMAND="$PROMPT_COMMAND;update_cwd"
  fi
fi

