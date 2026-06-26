#!/usr/bin/env bash

blue_state="$(bluetoothctl show | awk -F": " '/Powered/ {print $2}')"

notify=

case $blue_state in
  'no') 
    bluetoothctl power on 
    notify="Bluetooth Powered On"
    ;;
  'yes') 
    bluetoothctl power off 
    notify="Bluetooth Powered Off"
    ;;
esac

notify-send --app-name=bluetoothctl --replace-id=99910 "$notify"