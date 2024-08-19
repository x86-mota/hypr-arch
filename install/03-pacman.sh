#!/usr/bin/env bash

# --------------------------------------------------------------------- #
#               Uncomment lines if they are commented out               #
# --------------------------------------------------------------------- #
PACMAN_PATH="/etc/pacman.conf"
MISC_OPTIONS=(Color CheckSpace VerbosePkgLists ParallelDownloads)

echo -e "\n[${BoldBlue}NOTE${Reset}] - Adding extra spice to ${PACMAN_PATH}" 2>&1 | tee -a "${InstallationLog}"
for MISC in "${MISC_OPTIONS[@]}"; do
    if grep -wq "^#${MISC}" "${PACMAN_PATH}"; then
        sudo sed -i "s/^#${MISC}/${MISC}/" "${PACMAN_PATH}"
        _IsAdded "^${MISC}" "${PACMAN_PATH}"
    else
        echo -e "[${BoldBlue}NOTE${Reset}] - ${MISC} is already added to ${PACMAN_PATH}." 2>&1 | tee -a "${InstallationLog}"
    fi
done

# ----------------------------------------------------------------------------------------------------------------------------------------- #
#               Insert ILoveCandy below Color if it is not already present. This parameter is cool and useless at the same time             #
# ----------------------------------------------------------------------------------------------------------------------------------------- #
if ! grep -wq '^ILoveCandy' "${PACMAN_PATH}"; then
    sudo sed -i "/Color/a ILoveCandy" "${PACMAN_PATH}"
    _IsAdded "^ILoveCandy" "${PACMAN_PATH}"
else
    echo -e "[${BoldBlue}NOTE${Reset}] - ILoveCandy is already added to ${PACMAN_PATH}." 2>&1 | tee -a "${InstallationLog}"
fi

# --------------------------------------------------------------------- #
#               Enable multilib repository if not already               #
# --------------------------------------------------------------------- #
if grep -q '^#\[multilib\]' "${PACMAN_PATH}"; then
    echo -e "[${BoldBlue}NOTE${Reset}] - Enabling multilib repository..." 2>&1 | tee -a "${InstallationLog}"

    sudo sed -i "/^#\[multilib\]/,+1 s/^#//" ${PACMAN_PATH}

    if grep -q '^\[multilib\]' "${PACMAN_PATH}" && grep -A 1 '^\[multilib\]' "${PACMAN_PATH}" | grep -q '^Include'; then
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
