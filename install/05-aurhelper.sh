#!/usr/bin/env bash

# --------------------------------------------- #
#               Install AUR Helper              #
# --------------------------------------------- #
echo -e "[${BoldBlue}NOTE${Reset}] - Installing AUR helper ${AUR_HELPER}..." 2>&1 | tee -a "${InstallationLog}"

_CloneRepository "https://aur.archlinux.org/${AUR_HELPER}.git" "${DownloadDirectory}/${AUR_HELPER}"

cd "${DownloadDirectory}/${AUR_HELPER}" || exit

if ! _IsInstalled base-devel; then
    _InstallPackage base-devel
fi

makepkg --noconfirm -si &>>"${InstallationLog}"

if _IsInstalled "${AUR_HELPER}"; then
    "${AUR_HELPER}" -Syu --noconfirm &>>"${InstallationLog}"
    echo -e "${Clear}[${BoldGreen}OK${Reset}] - ${AUR_HELPER} installed" 2>&1 | tee -a "${InstallationLog}"
else
    echo -e "${Clear}[${BoldRed}ERROR${Reset}] - ${AUR_HELPER} installation failed." 2>&1 | tee -a "${InstallationLog}"
    exit 1
fi

cd "${DownloadDirectory}/install" || exit
