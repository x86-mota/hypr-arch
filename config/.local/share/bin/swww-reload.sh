#!/usr/bin/env bash

if ps aux | grep -q "[s]www.sh"; then
    ps aux | grep "[s]www.sh" | awk '{print $2}' | while read -r SW_PID; do
        echo "swww -  ${SW_PID}"
        kill "${SW_PID}"
    done

    ps aux | grep "[s]leep" | awk '{print $2}' | while read -r SL_PID; do
        echo "sleep - ${SL_PID}"
        kill "${SL_PID}"
    done
fi

if pgrep -x swww-daemon; then
    killall swww-daemon
fi

${HOME}/.local/share/bin/swww.sh &