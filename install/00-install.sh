#!/usr/bin/env bash

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

# ----------------------------------------------------------------------------------------- #
#               Load script for configuring Pacman package manager                          #
#               This script edits /etc/pacman.conf to adjust Pacman settings                #
# ----------------------------------------------------------------------------------------- #
if _CheckFileExist "./03-pacman.sh"; then
    source ./03-pacman.sh
fi

# ----------------------------------------------------------------------------- #
#               Load script for configuring the bootloader                      #
#               This script makes changes to GRUB configurations                #
# ----------------------------------------------------------------------------- #
if _CheckFileExist "./04-bootloader.sh"; then
    source ./04-bootloader.sh
fi

# --------------------------------------------------------------------------------- #
#               Update makepkg configuration to optimize build threads              #
# --------------------------------------------------------------------------------- #
MAKEPKG_PATH="/etc/makepkg.conf"
NUM_CORES=$(nproc)
PROC="-j$((NUM_CORES >= 6 ? NUM_CORES - 2 : NUM_CORES))"

echo -e "\n[${BLUE}NOTE${RC}] - Editing ${MAKEPKG_PATH}..." 2>&1 | tee -a "${INSTALL_LOG}"
sudo sed -i "s/^MAKEFLAGS=.*\|^#MAKEFLAGS=.*/MAKEFLAGS=\"${PROC}\"/" "${MAKEPKG_PATH}"
if _IsAdded "${PROC}" "${MAKEPKG_PATH}"; then
    source "${MAKEPKG_PATH}"
fi

# ----------------------------------------------------------------------------------------------------- #
#               Let the user choose which AUR helper to use if none is already installed                #
# ----------------------------------------------------------------------------------------------------- #
AUR_HELPER_LIST=("paru" "yay")
for HELPR in "${AUR_HELPER_LIST[@]}"; do
    if _IsInstalled "$HELPR" &>/dev/null; then
        AUR_HELPER="$HELPR"
        echo -e "\n[${BLUE}NOTE${RC}] - AUR helper ${AUR_HELPER} found" 2>&1 | tee -a "${INSTALL_LOG}"
        break
    fi
done

if [ -z "$AUR_HELPER" ]; then
    echo -e "\n${YELLOW}ACTION${RC} - Which AUR helper? (default = 1):\n 1) yay\n 2) paru"
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
    echo -e "${CL}${CL}${CL}${CL}[${BLUE}NOTE${RC}] - ${AUR_HELPER} Selected" 2>&1 | tee -a "${INSTALL_LOG}"

    if _CheckFileExist "./05-aurhelper.sh"; then
        source ./05-aurhelper.sh
    fi
fi

# ------------------------------------------------------------------------- #
#               Let the user choose which graphics card to use              #
# ------------------------------------------------------------------------- #
echo -e "\n[${YELLOW}ACTION${RC}] - Which Graphics Card? (default = 1):\n 1) AMD\n 2) Intel\n 3) Nvidia"
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
echo -e "${CL}${CL}${CL}${CL}${CL}[${BLUE}NOTE${RC}] - ${GRAPHICS_CARD} Selected" 2>&1 | tee -a "${INSTALL_LOG}"

if _CheckFileExist "./06-graphics.sh"; then
    source ./06-graphics.sh
fi

# ------------------------------------------------- #
#               Install System Packages             #
# ------------------------------------------------- #
echo -e "\n[${BLUE}NOTE${RC}] - Installing system packages"
for PKG in "${SYSTEM[@]}"; do
    _InstallPackage "${PKG}"
done

# ---------------------------------------------------------------#
#               Copy configuration and script files              #
# ---------------------------------------------------------------#
echo -e "\n[${BLUE}NOTE${RC}] - Copying configuration files..." 2>&1 | tee -a "${INSTALL_LOG}"
_CopyFiles "${DownloadDirectory}/config/.config" "${HOME}/.config"

echo -e "\n[${BLUE}NOTE${RC}] - Copying scripts..." 2>&1 | tee -a "${INSTALL_LOG}"
_CopyFiles "${DownloadDirectory}/config/.local" "${HOME}/.local"

# --------------------------------------------------------------------- #
#               Load script to configure Hyprland settings              #
# --------------------------------------------------------------------- #
if _CheckFileExist "./07-hyprland.sh"; then
    source ./07-hyprland.sh
fi

# ---------------------------------------------------------- #
#               Load script to install themes                #
# ---------------------------------------------------------- #
if _CheckFileExist "./08-theme.sh"; then
    source ./08-theme.sh
fi

# ----------------------------------------- #
#               Enable services             #
# ----------------------------------------- #
sudo systemctl enable ly.service &>>"${INSTALL_LOG}"

# ------------------------------------------------- #
#               Setup completed message             #
# ------------------------------------------------- #
echo -e "[${GREEN}OK${RC}] - Installation Completed\n"
echo -en "[${YELLOW}ACTION${RC}] - Would you like to reboot now? (y/n): "
read
if [[ "$REPLY" =~ [Yy]$ ]]; then
    systemctl reboot
fi
