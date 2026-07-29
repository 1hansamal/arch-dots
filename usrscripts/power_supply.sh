#! /usr/bin/env bash

export XDG_RUNTIME_DIR="/run/user/1000"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

AC_online=$(</sys/class/power_supply/AC/online)
BAT_level=$(</sys/class/power_supply/BAT0/capacity)

notify_body=
notify_summary=

case $AC_online in
	0)
		notify_body='Charger Disconnected'
		;;
	1)
		notify_body='Charger Connected'
		;;
esac

notify-send --app-name=power --replace-id=99905 "$notify_body"
