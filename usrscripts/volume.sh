#! /usr/bin/env bash

min=0
max=100

dev=
action=
value=

device=
dev_state=
dev_volume=
dev_icon=
dev_name=

pactl() {
	command pactl "$1" "$device" "${@:2}"
}

get_state() {
	local state
	state=$(pactl "get-$dev_state" | awk '{print $2}')

	case $state in
		'yes') printf "muted" ;;
		'no')  printf "unmuted" ;;
	esac
}

get_volume() {
	pactl "get-$dev_volume" | grep -Po '\d+(?=%)' | head -n 1
}

set_state () 
{
	local mute_state

	pactl "set-$dev_state" toggle

	notify_state=$(get_state)

	notify-send --app-name=pactl --replace-id=99902 "$dev_name: $notify_state"
}

set_volume () 
{
	local new_level
	local curr_level

	curr_level=$(get_volume)

	case $action in
		'raise')
			new_level=$((curr_level + value))
			((new_level > max)) && new_level=$max
			;;
		'lower')
			new_level=$((curr_level - value))
			((new_level < min)) && new_level=$min
			;;
	esac

	pactl "set-$dev_volume" "$new_level%"

	notify-send --app-name=pactl --replace-id=99902 -h int:value:$new_level "$dev_name: $new_level %"
}

main () 
{
	dev=$1
	action=$2
	value=$3

	case $dev in
		'input')
			device="@DEFAULT_SOURCE@"
			dev_state="source-mute"
			dev_volume="source-volume"
			dev_icon="mic-volume"
			dev_name="Microphone"
			;;
		'output')
			device="@DEFAULT_SINK@"
			dev_state="sink-mute"
			dev_volume="sink-volume"
			dev_icon="audio-volume"
			dev_name="Speakers"
			;;
	esac

	case $action in
		'mute')
			set_state 
			;;
		'raise' | 'lower')
			set_volume 
			;;
	esac
}

main $@
