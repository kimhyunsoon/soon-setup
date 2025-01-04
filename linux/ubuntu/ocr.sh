#!/bin/bash
TMP_IMG="/tmp/screenshot.png"
TMP_TXT_BASE="/tmp/screenshot"

gnome-screenshot -a -f "$TMP_IMG" || {
    echo "Screenshot capture cancelled." | wl-copy
    exit 1
}

if [ ! -f "$TMP_IMG" ]; then
    echo "No screenshot file found." | wl-copy
    exit 1
fi

tesseract "$TMP_IMG" "$TMP_TXT_BASE" -l eng || {
    echo "OCR processing failed." | wl-copy
    rm "$TMP_IMG"
    exit 1
}

TMP_TXT="$TMP_TXT_BASE.txt"

if [ -f "$TMP_TXT" ]; then
    wl-copy < "$TMP_TXT"
    rm "$TMP_TXT"
else
    echo "OCR produced no output text." | wl-copy
fi

rm "$TMP_IMG"
