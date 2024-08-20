#!/usr/bin/env bash

# --------------------------------------#
#               Functions               #
# --------------------------------------#
function _IsLayoutValid {
    local Layout="$1"
    local i=""
    for i in "${KeyboardLayoutList[@]}"; do
        if [ "${i}" == "${Layout}" ]; then
            return 0
        fi
    done
    return 1
}

function _AdditionalLayouts {
    local NewLayouts="$1"
    local i=""
    IFS=',' read -r -a AdditionalLayouts <<<"${NewLayouts}"
    for i in "${AdditionalLayouts[@]}"; do
        i=$(echo "${i}" | tr -d '[:blank:]')
        if _IsLayoutValid "${i}"; then
            if [[ ! "${KeyboardLayout[@]}" = "${i}" ]]; then
                KeyboardLayout+=("${i}")
            fi
        else
            echo -e "[${BoldRed}ERROR${Reset}] Layout '${i}' not found in the valid list."
            return 1
        fi
    done
    return 0
}

# ----------------------------------------------------------------------------------------------------------------- #
#               Loop through each script file in UserScriptsDirectory and make them executable for the user             #
# ----------------------------------------------------------------------------------------------------------------- #
UserScriptsDirectory="${HOME}/.local/share/bin"
if [ -d "${UserScriptsDirectory}" ]; then
    for sh in "${UserScriptsDirectory}"/*; do
        if [ -f "${sh}" ]; then
            chmod u+x "${sh}"
        fi
    done
fi

# --------------------------------------------- #
#               Set Keyboard Layout             #
# --------------------------------------------- #
HyprlandDirectory="${HOME}/.config/hypr"
KeyboardLayoutFile="../assets/kblayout.lst"
if [ -f "${KeyboardLayoutFile}" ]; then
    echo
    pr -tw160 -4 <"${KeyboardLayoutFile}"
    echo
    KeyboardLayoutList=($(awk -F' ' '{print $1}' <${KeyboardLayoutFile}))
    KeyboardLayout=()

    while true; do
        echo -en "[${BoldYellow}ACTION${Reset}] - Which main keyboard layout? (default = us ): "
        read
        if [ -z "${REPLY}" ]; then
            KeyboardLayout=("us")
            echo -e "${Clear}[${BoldBlue}NOTE${Reset}] - Keeping default keyboard layout: us"
            break
        else
            if _IsLayoutValid "${REPLY}"; then
                KeyboardLayout=("${REPLY}")
                echo -e "${Clear}[${BoldGreen}OK${Reset}] - Main keyboard layout '${REPLY}' added successfully"
                break
            else
                echo -e "${Clear}[${BoldRed}ERROR${Reset}] Layout '${REPLY}' not found. Please try again."
            fi
        fi
    done

    echo -en "[${BoldYellow}ACTION${Reset}] - Would you like to add more keyboard layouts? (y/n): "
    read
    if [[ "${REPLY}" =~ [Yy]$ ]]; then
        while true; do
            echo -en "[${BoldYellow}ACTION${Reset}] - Please enter additional keyboard layouts separated by commas: "
            read
            if _AdditionalLayouts "${REPLY}"; then
                sed -i "s/kb_layout = .*/kb_layout = $(echo ${KeyboardLayout[*]} | tr ' ' ',')/" "${HyprlandDirectory}/theme.conf"
                _IsAdded "kb_layout = $(echo ${KeyboardLayout[*]} | tr ' ' ',')" "${HyprlandDirectory}/theme.conf"
                break
            fi
        done
    else
        sed -i "s/kb_layout = .*/kb_layout = ${KeyboardLayout}/" "${HyprlandDirectory}/theme.conf"
        _IsAdded "kb_layout = ${KeyboardLayout}" "${HyprlandDirectory}/theme.conf"
    fi
fi

# ------------------------------------------------------------- #
#               Adicional Settings for Nvidia users             #
# ------------------------------------------------------------- #
if [[ ${GraphicsCard} = "Nvidia" ]]; then
    echo -e "\n[${BoldBlue}NOTE${Reset}] - Applying settings for nvidia..."
    sed -i "s|^#\(.*source = ~/.config/hypr/nvidia.conf.*\)|\1|" "${HyprlandDirectory}/hyprland.conf"
    _IsAdded "source = ~/.config/hypr/nvidia.conf" "${HyprlandDirectory}/hyprland.conf"

    sed -i '/#no_hardware_cursors = true/ s/#//' "${HyprlandDirectory}/theme.conf"
    _IsAdded "no_hardware_cursors = true" "${HyprlandDirectory}/theme.conf"
fi
