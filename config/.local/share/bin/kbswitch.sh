#!/usr/bin/env bash

#Get Keyboard Name Devices
hyprctl devices -j | awk '/"keyboards": \[/,/\]/' | grep '"name":' | awk -F'"' '{print $4}' | while read NAME; do
    hyprctl switchxkblayout "${NAME}" next > /dev/null
done
