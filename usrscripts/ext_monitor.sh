#! /usr/bin/env bash

HDMI_status="$(</sys/class/drm/card1-HDMI-A-3/status)"
HDMI_enabled="$(</sys/class/drm/card1-HDMI-A-3/enabled)"
LVDS_enabled="$(</sys/class/drm/card1-LVDS-1/enabled)"

status_file='/tmp/display_mode'

LVDS='LVDS-1'
HDMI='HDMI-A-3'


display ()
{
	niri msg output $@
}

mode_menu () 
{
	fuzzel --dmenu --index --minimal-lines  --hide-prompt 
}

check_HDMI ()
{
	if [[ $HDMI_status != 'connected' ]]; then
		notify-send --app-name=monitorctl --replace-id=99903 \
					'Cable Not Connected' 'connect your monitor cable'
		exit 0
	fi
}

docked_mode ()
{
	display "$LVDS" off
	notify-send --app-name=monitorctl --replace-id=99903 \
				'Docked Mode Enabled' 'externnal display is now primary'
	echo 'docked' > $status_file
	exit 0
}

default_mode ()
{
	[[ $LVDS_enabled != 'enabled' ]] && display $LVDS on
	[[ $HDMI_enabled == 'enabled' ]] && display $HDMI off

	notify-send --app-name=monitorctl --replace-id=99903 \
				'Default Mode Enabled' 'External Display Disabled'
	echo 'default' > $status_file
	exit 0
}

extend_mode() 
{
	local notify_position
    local position

    position=$(printf "%s\n" \
        "Left of Laptop" \
        "Right of Laptop" \
        "Above Laptop" \
        "Below Laptop" |
        mode_menu)

    [[ $LVDS_enabled != 'enabled' ]] && display $LVDS on
	[[ $HDMI_enabled != 'enabled' ]] && display $HDMI on

    case $position in
        0)
            display $HDMI position set 0 0
            display $LVDS position set 1920 0
            notify_position='left of the laptop'
            ;;
        1)
            display $LVDS position set 0 0
            display $HDMI position set 1366 0
            notify_position='right of the laptop'
            ;;
        2)
            display $HDMI position set 0 0
            display $LVDS position set 0 1080
            notify_position='above the laptop'
            ;;
        3)
            display $LVDS position set 0 0
            display $HDMI position set 0 768
            notify_position='below the laptop'
            ;;
    esac

    notify-send --app-name=monitorctl --replace-id=99903 \
    			'Extended Mode Enabled' "extended to the $notify_position"
    echo 'extended' > $status_file
    exit 0
}

main () 
{

	local current_status
	local selected_mode
	
	[[ -f $status_file ]] || echo 'default' > $status_file

	current_status=$(<$status_file)
	
	if [[ $LVDS_enabled != "enabled" && $current_status != "docked" ]]; then
    	display $LVDS on
	fi
	check_HDMI

	case $current_status in
		'default') 
			selected_mode=$(printf "%s\n" \
									"Extend Laptop Display" \
									"Dock Laptop Display" | mode_menu)
			[[ $selected_mode == 0 ]] && extend_mode
			[[ $selected_mode == 1 ]] && docked_mode
			;;
		'extended')
			selected_mode=$(printf "%s\n" \
									"Extend Laptop Display" \
									"Disconnect External Display" \
									"Dock Laptop Display" | mode_menu)
			[[ $selected_mode == 0 ]] && extend_mode
			[[ $selected_mode == 1 ]] && default_mode
			[[ $selected_mode == 2 ]] && docked_mode
			;;
		'docked')
			selected_mode=$(printf "%s\n" \
									"Disconnect External Display" \
									"Extend Laptop Display" | mode_menu)
			[[ $selected_mode == 0 ]] && default_mode
			[[ $selected_mode == 1 ]] && extend_mode
			;;
	esac

	exit 0
}

main