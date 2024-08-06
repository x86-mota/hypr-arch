#!/usr/bin/env bash

clear
echo -e "${ASCII_ART}"

# --------------------------------------------------------------------- #
#               Uncomment lines if they are commented out               #
# --------------------------------------------------------------------- #
PACMAN_PATH="/etc/pacman.conf"
MISC_OPTIONS=(Color CheckSpace VerbosePkgLists ParallelDownloads)

echo -e "[${BLUE}NOTE${RC}] - Adding extra spice to ${PACMAN_PATH}\n" 2>&1 | tee -a "${INSTALL_LOG}"
for MISC in "${MISC_OPTIONS[@]}"; do
    if grep -wq "^#${MISC}" "${PACMAN_PATH}"; then
        sudo sed -i "s/^#${MISC}/${MISC}/" "${PACMAN_PATH}"
        _IsAdded "^${MISC}" "${PACMAN_PATH}"
    else
        echo -e "[${BLUE}NOTE${RC}] - ${MISC} is already added to ${PACMAN_PATH}." 2>&1 | tee -a "${INSTALL_LOG}"
    fi
done

# ----------------------------------------------------------------------------------------------------------------------------------------- #
#               Insert ILoveCandy below Color if it is not already present. This parameter is cool and useless at the same time             #
# ----------------------------------------------------------------------------------------------------------------------------------------- #
if ! grep -wq '^ILoveCandy' "${PACMAN_PATH}"; then
    sudo sed -i "/Color/a ILoveCandy" "${PACMAN_PATH}"
    _IsAdded "^ILoveCandy" "${PACMAN_PATH}"
else
    echo -e "[${BLUE}NOTE${RC}] - ILoveCandy is already added to ${PACMAN_PATH}." 2>&1 | tee -a "${INSTALL_LOG}"
fi

# --------------------------------------------------------------------- #
#               Enable multilib repository if not already               #
# --------------------------------------------------------------------- #
if grep -q '^#\[multilib\]' "${PACMAN_PATH}"; then
    echo -e "[${BLUE}NOTE${RC}] - Enabling multilib repository..." 2>&1 | tee -a "${INSTALL_LOG}"

    sudo sed -i "/^#\[multilib\]/,+1 s/^#//" ${PACMAN_PATH}

    if grep -q '^\[multilib\]' "${PACMAN_PATH}" && grep -A 1 '^\[multilib\]' "${PACMAN_PATH}" | grep -q '^Include'; then
        _ClearLines 1
        echo -e "[${GREEN}OK${RC}] - multilib repository enabled" 2>&1 | tee -a "${INSTALL_LOG}"
    else
        _ClearLines 1
        echo -e "[${RED}ERROR${RC}] - multilib repository was not enabled" 2>&1 | tee -a "${INSTALL_LOG}"
    fi
else
    echo -e "[${BLUE}NOTE${RC}] - multilib repository is already enabled." 2>&1 | tee -a "${INSTALL_LOG}"
fi

# ----------------------------------------- #
#               Update system               #
# ----------------------------------------- #
echo -e "[${BLUE}NOTE${RC}] - Updating system"
if sudo pacman -Syu --noconfirm --needed &>>"${INSTALL_LOG}"; then
    _ClearLines 1
    echo -e "[${GREEN}OK${RC}] - System updated" 2>&1 | tee -a "${INSTALL_LOG}"
else
    _ClearLines 1
    echo -e "[${RED}ERROR${RC}] - System update failed." 2>&1 | tee -a "${INSTALL_LOG}"
    exit 1
fi
