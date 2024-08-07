#!/usr/bin/env bash

# --------------------------------------#
#               Functions               #
# --------------------------------------#
function _IsLayoutValid {
    local LAYOUT="$1"
    local i=""
    for i in "${KB_LAYOUT_LIST[@]}"; do
        if [ "$i" == "${LAYOUT}" ]; then
            return 0
        fi
    done
    return 1
}

function _AdditionalLayouts {
    local NEW_LAYOUTS="$1"
    local i=""
    IFS=',' read -r -a ADDITIONAL_LAYOUTS <<<"${NEW_LAYOUTS}"
    for i in "${ADDITIONAL_LAYOUTS[@]}"; do
        i=$(echo "${i}" | tr -d '[:blank:]')
        if _IsLayoutValid "${i}"; then
            if [[ ! "${KB_LAYOUT[@]}" = "${i}" ]]; then
                KB_LAYOUT+=("${i}")
            fi
        else
            echo -e "[${RED}ERROR${RC}] Layout '${i}' not found in the valid list."
            return 1
        fi
    done
    return 0
}

sleep 1
clear
echo -e "${ASCII_ART}"

# ----------------------------------------------------------------------------------------------------------------- #
#               Loop through each script file in USER_SCRIPTS_DIR and make them executable for the user             #
# ----------------------------------------------------------------------------------------------------------------- #
USER_SCRIPTS_DIR="${HOME}/.local/share/bin"
if [ -d "${USER_SCRIPTS_DIR}" ]; then
    for SH in "${USER_SCRIPTS_DIR}"/*; do
        if [ -f "${SH}" ]; then
            chmod u+x "${SH}"
        fi
    done
fi

# --------------------------------------------- #
#               Set Keyboard Layout             #
# --------------------------------------------- #
HYPR_DIR="${HOME}/.config/hypr"
KB_LAYOUT_FILE="../assets/kblayout.lst"
if [ -f "${KB_LAYOUT_FILE}" ]; then
    pr -tw160 -4 <"${KB_LAYOUT_FILE}"
    echo
    KB_LAYOUT_LIST=($(awk -F' ' '{print $1}' <${KB_LAYOUT_FILE}))
    KB_LAYOUT=()

    while true; do
        echo -en "[${YELLOW}ACTION${RC}] - Which main keyboard layout? (default = us ): "
        read
        if [ -z "${REPLY}" ]; then
            KB_LAYOUT=("us")
            echo -e "${CL}[${BLUE}NOTE${RC}] - Keeping default keyboard layout: us"
            break
        else
            if _IsLayoutValid "${REPLY}"; then
                KB_LAYOUT=("${REPLY}")
                echo -e "${CL}[${GREEN}OK${RC}] - Main keyboard layout '${REPLY}' added successfully"
                break
            else
                echo -e "${CL}[${RED}ERROR${RC}] Layout '${REPLY}' not found. Please try again."
            fi
        fi
    done

    echo -en "[${YELLOW}ACTION${RC}] - Would you like to add more keyboard layouts? (y/n): "
    read
    if [[ "${REPLY}" =~ [Yy]$ ]]; then
        while true; do
            echo -en "[${YELLOW}ACTION${RC}] - Please enter additional keyboard layouts separated by commas: "
            read
            if _AdditionalLayouts "${REPLY}"; then
                sed -i "s/kb_layout = .*/kb_layout = $(echo ${KB_LAYOUT[*]} | tr ' ' ',')/" "${HYPR_DIR}/theme.conf"
                _IsAdded "kb_layout = $(echo ${KB_LAYOUT[*]} | tr ' ' ',')" "${HYPR_DIR}/theme.conf"
                break
            fi
        done
    else
        sed -i "s/kb_layout = .*/kb_layout = ${KB_LAYOUT}/" "${HYPR_DIR}/theme.conf"
        _IsAdded "kb_layout = ${KB_LAYOUT}" "${HYPR_DIR}/theme.conf"
    fi
fi

# ------------------------------------------------------------- #
#               Adicional Settings for NVIDIA users             #
# ------------------------------------------------------------- #
if [[ ${GRAPHICS_CARD} = "Nvidia" ]]; then
    sed -i "s|^#\(.*source = ~/.config/hypr/nvidia.conf.*\)|\1|" "${HYPR_DIR}/hyprland.conf"
    _IsAdded "source = ~/.config/hypr/nvidia.conf" "${HYPR_DIR}/hyprland.conf"

    sed -i '/#no_hardware_cursors = true/ s/#//' "${HYPR_DIR}/theme.conf"
    _IsAdded "no_hardware_cursors = true" "${HYPR_DIR}/theme.conf"
fi
