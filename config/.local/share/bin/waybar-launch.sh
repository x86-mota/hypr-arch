#!/usr/bin/env bash

if pgrep -x "waybar" >/dev/null; then
    killall waybar
    sleep 0.2
    waybar &
    exit
else
    waybar &
fi
