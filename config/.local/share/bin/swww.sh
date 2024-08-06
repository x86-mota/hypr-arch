#!/usr/bin/env bash

function _VerifyDirectory {
    local WALLPAPERSDIR="${HOME}/.config/wallpapers"
    local EXTENSIONS=("jpeg" "jpg" "png" "gif" "pnm" "tga" "tiff" "webp" "bmp" "farbfeld")
    local SUPORTEDFILES=()

    if [ -d "${WALLPAPERSDIR}" ]; then
        for EXT in "${EXTENSIONS[@]}"; do
            while IFS= read -r -d '' ARQ; do
                SUPORTEDFILES+=("$ARQ")
            done < <(find "${WALLPAPERSDIR}" -maxdepth 1 -type f -name "*.${EXT}" -print0)
        done

        if [ -n "${SUPORTEDFILES}" ]; then
            _SetWallpaper "${SUPORTEDFILES[@]}"
        else
            notify-send "The wallpaper folder is expected to have a least 1 image."
            exit 1
        fi
    fi
}

function _SetWallpaper {
    local FILES=("$@")

    if [ "${#FILES[@]}" -eq 1 ]; then
        swww img "${FILES[0]}" --transition-type none
    else
        local TIMEOUT=900
        local WALLPAPER=""
        local PREVIOUS=""
        
        while true; do
            while [ "${WALLPAPER}" == "${PREVIOUS}" ]; do
                WALLPAPER="${FILES[RANDOM % ${#FILES[@]}]}"
            done

            PREVIOUS="${WALLPAPER}"

            swww img "${WALLPAPER}" --transition-type random --transition-fps 60 --transition-step 10 --transition-duration 10
            sleep "${TIMEOUT}"
        done
    fi
}


if ! pacman -Qs swww >/dev/null 2>&1; then
    notify-send "Package swww is not installed. Wallpapers will not display correctly." 
    exit 1
fi

SWWWDAEMON="swww-daemon"
if pgrep -x "${SWWWDAEMON}" >/dev/null; then
    _VerifyDirectory
else
    swww-daemon &
    sleep 2
    if pgrep -x "${SWWWDAEMON}" >/dev/null; then
        _VerifyDirectory
    else
        notify-send "Failed to start the ${SWWWDAEMON} process."
        exit 1
    fi
fi