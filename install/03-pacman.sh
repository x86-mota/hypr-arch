#!/usr/bin/env bash

# --------------------------------------------------------------------- #
#               Uncomment lines if they are commented out               #
# --------------------------------------------------------------------- #
PacmanConfPath="/etc/pacman.conf"
MiscOptions=(Color CheckSpace VerbosePkgLists ParallelDownloads)

echo -e "\n[${BoldBlue}NOTE${Reset}] - Adding extra spice to ${PacmanConfPath}" 2>&1 | tee -a "${InstallationLog}"
for Misc in "${MiscOptions[@]}"; do
    if grep -wq "^#${Misc}" "${PacmanConfPath}"; then
        sudo sed -i "s/^#${Misc}/${Misc}/" "${PacmanConfPath}"
        _IsAdded "^${Misc}" "${PacmanConfPath}"
    else
        echo -e "[${BoldBlue}NOTE${Reset}] - ${Misc} is already added to ${PacmanConfPath}." 2>&1 | tee -a "${InstallationLog}"
    fi
done

# ----------------------------------------------------------------------------------------------------------------------------------------- #
#               Insert ILoveCandy below Color if it is not already present. This parameter is cool and useless at the same time             #
# ----------------------------------------------------------------------------------------------------------------------------------------- #
if ! grep -wq '^ILoveCandy' "${PacmanConfPath}"; then
    sudo sed -i "/Color/a ILoveCandy" "${PacmanConfPath}"
    _IsAdded "^ILoveCandy" "${PacmanConfPath}"
else
    echo -e "[${BoldBlue}NOTE${Reset}] - ILoveCandy is already added to ${PacmanConfPath}." 2>&1 | tee -a "${InstallationLog}"
fi

# --------------------------------------------------------------------- #
#               Enable multilib repository if not already               #
# --------------------------------------------------------------------- #
if grep -q '^#\[multilib\]' "${PacmanConfPath}"; then
    echo -e "[${BoldBlue}NOTE${Reset}] - Enabling multilib repository..." 2>&1 | tee -a "${InstallationLog}"

    sudo sed -i "/^#\[multilib\]/,+1 s/^#//" ${PacmanConfPath}

    if grep -q '^\[multilib\]' "${PacmanConfPath}" && grep -A 1 '^\[multilib\]' "${PacmanConfPath}" | grep -q '^Include'; then
        echo -e "${Clear}[${BoldGreen}OK${Reset}] - multilib repository enabled" 2>&1 | tee -a "${InstallationLog}"
    else
        echo -e "${Clear}[${BoldRed}ERROR${Reset}] - multilib repository was not enabled" 2>&1 | tee -a "${InstallationLog}"
    fi
else
    echo -e "[${BoldBlue}NOTE${Reset}] - multilib repository is already enabled." 2>&1 | tee -a "${InstallationLog}"
fi

# ----------------------------------------- #
#               Update system               #
# ----------------------------------------- #
echo -e "[${BoldBlue}NOTE${Reset}] - Updating system"
if sudo pacman -Syu --noconfirm --needed &>>"${InstallationLog}"; then
    echo -e "${Clear}[${BoldGreen}OK${Reset}] - System updated" 2>&1 | tee -a "${InstallationLog}"
else
    echo -e "${Clear}[${BoldRed}ERROR${Reset}] - System update failed." 2>&1 | tee -a "${InstallationLog}"
    exit 1
fi
