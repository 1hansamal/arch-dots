#! /usr/bin/env bash

notify () 
{
	local brightness
	brightness=$(brightnessctl -m | awk -F, '{print substr($4, 0, length($4)-1)}')

	notify-send --app-name=brightnessctl --replace-id 99901 -h int:value:"$brightness" "Display Brightness: $brightness %"
}

case $1 in
	up)
		brightnessctl set 2%+
		notify
		;;
	down)
		brightnessctl set 2%-
		notify
		;;
esac