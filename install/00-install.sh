#!/usr/bin/env bash

clear
echo -e "${ASCII_ART}"

# --------------------------------------------------------------------- #
#               Load functions used throughout the script               #
# --------------------------------------------------------------------- #
if _CheckFileExist "./01-functions.sh"; then
    source ./01-functions.sh
fi

# ------------------------------------------------------------- #
#               Load package lists for installation             #
# ------------------------------------------------------------- #
if _CheckFileExist "./02-packages.sh"; then
    source ./02-packages.sh
fi

# ----------------------------------------------------------------------------------------------------- #
#               Let the user choose which AUR helper to use if none is already installed                #
# ----------------------------------------------------------------------------------------------------- #
AUR_HELPER_LIST=("paru" "yay")
for HELPR in "${AUR_HELPER_LIST[@]}"; do
    if _IsInstalled "$HELPR" &>/dev/null; then
        AUR_HELPER="$HELPR"
        echo -e "[${BLUE}NOTE${RC}] - AUR helper ${AUR_HELPER} found" 2>&1 | tee -a "${INSTALL_LOG}"
        break
    fi
done

if [ -z "$AUR_HELPER" ]; then
    echo -e "${YELLOW}ACTION${RC} - Which AUR helper? (default = 1):\n 1) yay\n 2) paru"
    read -rp "Enter your choice [1-2]: "
    case "$REPLY" in
    1)
        AUR_HELPER="yay"
        ;;
    2)
        AUR_HELPER="paru"
        ;;
    *)
        AUR_HELPER="yay"
        ;;
    esac
    _ClearLines 4
    echo -e "[${BLUE}NOTE${RC}] - ${AUR_HELPER} Selected" 2>&1 | tee -a "${INSTALL_LOG}"
fi

# ------------------------------------------------------------------------- #
#               Let the user choose which graphics card to use              #
# ------------------------------------------------------------------------- #
echo -e "[${YELLOW}ACTION${RC}] - Which Graphics Card? (default = 1):\n 1) AMD\n 2) Intel\n 3) Nvidia"
read -rp "Enter your choice [1-3]: "
case "$REPLY" in
1)
    GRAPHICS_CARD="AMD"
    GPU_PACKAGES=("${AMD[@]}")
    ;;
2)
    GRAPHICS_CARD="Intel"
    GPU_PACKAGES=("${INTEL[@]}")
    ;;
3)
    GRAPHICS_CARD="Nvidia"
    GPU_PACKAGES=("${NVIDIA[@]}")
    ;;
*)
    GRAPHICS_CARD="AMD"
    GPU_PACKAGES=("${AMD[@]}")
    ;;
esac
_ClearLines 5
echo -e "[${BLUE}NOTE${RC}] - ${GRAPHICS_CARD} Selected" 2>&1 | tee -a "${INSTALL_LOG}"
