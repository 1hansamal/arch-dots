#!/usr/bin/env bash

options=" Lock
 Logout
 Sleep
󰒲 Hibernate
 Reboot
 Power Off"

mode_menu () 
{
	fuzzel --dmenu --index --minimal-lines  --hide-prompt --mesg "Power Menu"
}

chosen=$(printf "%s\n" "$options" | mode_menu)


case $chosen in
    0)
        gtklock -d
        ;;
    1)
        niri msg action quit
        ;;
    2)
        systemctl suspend
        ;;
    3)
        systemctl hibernate
        ;;
    4)
        systemctl reboot
        ;;
    5)
        systemctl poweroff
        ;;
esac