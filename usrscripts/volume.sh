#!/usr/bin/env bash

STEP=4
NOTIFY_ID=99902

case "$1" in
    sink)
        DEV="@DEFAULT_AUDIO_SINK@"
        NAME="󰕾 Speakers" ;;
    source)
        DEV="@DEFAULT_AUDIO_SOURCE@"
        NAME="󰍬 Microphone" ;;
    *)
        echo "Usage: $0 {sink|source} {raise|lower|mute}"
        exit 1 ;;
esac

case "$2" in
    raise)
        wpctl set-volume -l 1.0 "$DEV" "${STEP}%+" ;;
    lower)
        wpctl set-volume "$DEV" "${STEP}%-" ;;
    mute)
        wpctl set-mute "$DEV" toggle ;;
    *)
        echo "Usage: $0 {sink|source} {raise|lower|mute}"
        exit 1 ;;
esac

status=$(wpctl get-volume "$DEV")
volume=$(awk '{printf "%.0f", $2 * 100}' <<<"$status")

if [[ $status == *"[MUTED]"* ]]; then
    # icon="audio-volume-muted-symbolic"
    text="Muted"
else
    # if (( volume == 0 )); then
    #     icon="audio-volume-muted-symbolic"
    # elif (( volume < 35 )); then
    #     icon="audio-volume-low-symbolic"
    # elif (( volume < 70 )); then
    #     icon="audio-volume-medium-symbolic"
    # else
    #     icon="audio-volume-high-symbolic"
    # fi
    text=$(awk '{printf "%3.0f", $1}' <<<"$volume")
fi

notify-send --app-name=wpctl --replace-id="$NOTIFY_ID" -h "int:value:$volume" "$NAME: $text%"