#! /usr/bin/env bash

wallpaper_dir='/home/ihansamal/.wallpapers'

rnd_wallpaper () 
{
	find $wallpaper_dir -maxdepth 1 -type f | shuf -n 1
}

set_wallpaper ()
{
	awww img --resize crop --crop-gravity center $@
}

LVDS_wall=$(rnd_wallpaper)
HDMI_wall=$(rnd_wallpaper)

HDMI_enabled=$(</sys/class/drm/card1-HDMI-A-3/enabled)
LVDS_enabled=$(</sys/class/drm/card1-LVDS-1/enabled)

export AWWW_TRANSITION="fade"
export AWWW_TRANSITION_STEP=90
export AWWW_TRANSITION_DURATION=3
export AWWW_TRANSITION_FPS=60
# export AWWW_TRANSITION_ANGLE=
export AWWW_TRANSITION_BEZIER=".39,.02,.25,.95"
# export AWWW_TRANSITION_WAVE=
# export AWWW_TRANSITION_POS="top-right"

[[ $HDMI_enabled == 'enabled' ]] && set_wallpaper --outputs HDMI-A-3 $HDMI_wall
[[ $LVDS_enabled == 'enabled' ]] && set_wallpaper --outputs LVDS-1 $LVDS_wall