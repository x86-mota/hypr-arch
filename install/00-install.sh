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
MakepkgConfPath="/etc/makepkg.conf"
Processors="-j$(( $(nproc) >= 6 ? $(nproc) - 2 : $(nproc) ))"
echo -e "\n[${BoldBlue}NOTE${Reset}] - Editing ${MakepkgConfPath}..." 2>&1 | tee -a "${InstallationLog}"
sudo sed -i "s/^MAKEFLAGS=.*\|^#MAKEFLAGS=.*/MAKEFLAGS=\"${Processors}\"/" "${MakepkgConfPath}"
if _IsAdded "${Processors}" "${MakepkgConfPath}"; then
    source "${MakepkgConfPath}"
fi

# ----------------------------------------------------------------------------------------------------- #
#               Let the user choose which AUR helper to use if none is already installed                #
# ----------------------------------------------------------------------------------------------------- #
ListAurHelpers=("paru" "yay")
for h in "${ListAurHelpers[@]}"; do
    if _IsInstalled "$h" &>/dev/null; then
        AurHelper="$h"
        echo -e "\n[${BoldBlue}NOTE${Reset}] - AUR helper ${AurHelper} found" 2>&1 | tee -a "${InstallationLog}"
        break
    fi
done

if [ -z "$AurHelper" ]; then
    echo -e "\n${BoldYellow}ACTION${Reset} - Which AUR helper? (default = 1):\n 1) yay\n 2) paru"
    read -rp "Enter your choice [1-2]: "
    case "$REPLY" in
    1)
        AurHelper="yay"
        ;;
    2)
        AurHelper="paru"
        ;;
    *)
        AurHelper="yay"
        ;;
    esac
    echo -e "${Clear}${Clear}${Clear}${Clear}[${BoldBlue}NOTE${Reset}] - ${AurHelper} Selected" 2>&1 | tee -a "${InstallationLog}"

    if _CheckFileExist "./05-aurhelper.sh"; then
        source ./05-aurhelper.sh
    fi
fi

# ------------------------------------------------------------------------- #
#               Let the user choose which graphics card to use              #
# ------------------------------------------------------------------------- #
echo -e "\n[${BoldYellow}ACTION${Reset}] - Which Graphics Card? (default = 1):\n 1) Amd\n 2) Intel\n 3) Nvidia"
read -rp "Enter your choice [1-3]: "
case "$REPLY" in
1)
    GraphicsCard="Amd"
    GraphicsPackages=("${Amd[@]}")
    ;;
2)
    GraphicsCard="Intel"
    GraphicsPackages=("${Intel[@]}")
    ;;
3)
    GraphicsCard="Nvidia"
    GraphicsPackages=("${Nvidia[@]}")
    ;;
*)
    GraphicsCard="Amd"
    GraphicsPackages=("${Amd[@]}")
    ;;
esac
echo -e "${Clear}${Clear}${Clear}${Clear}${Clear}[${BoldBlue}NOTE${Reset}] - ${GraphicsCard} Selected" 2>&1 | tee -a "${InstallationLog}"

if _CheckFileExist "./06-graphics.sh"; then
    source ./06-graphics.sh
fi

# ------------------------------------------------- #
#               Install System Packages             #
# ------------------------------------------------- #
echo -e "\n[${BoldBlue}NOTE${Reset}] - Installing system packages"
for PKG in "${System[@]}"; do
    _InstallPackage "${PKG}"
done

# ---------------------------------------------------------------#
#               Copy configuration and script files              #
# ---------------------------------------------------------------#
echo -e "\n[${BoldBlue}NOTE${Reset}] - Copying configuration files..." 2>&1 | tee -a "${InstallationLog}"
_CopyFiles "${DownloadDirectory}/config/.config" "${HOME}/.config"

echo -e "\n[${BoldBlue}NOTE${Reset}] - Copying scripts..." 2>&1 | tee -a "${InstallationLog}"
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
sudo systemctl enable ly.service &>>"${InstallationLog}"

# ------------------------------------------------- #
#               Setup completed message             #
# ------------------------------------------------- #
echo -e "[${BoldGreen}OK${Reset}] - Installation Completed\n"
echo -en "[${BoldYellow}ACTION${Reset}] - Would you like to reboot now? (y/n): "
read
if [[ "$REPLY" =~ [Yy]$ ]]; then
    systemctl reboot
fi
