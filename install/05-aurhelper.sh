#!/usr/bin/env bash

# --------------------------------------------- #
#               Install AUR Helper              #
# --------------------------------------------- #
echo -e "[${BoldBlue}NOTE${Reset}] - Installing AUR helper ${AurHelper}..." 2>&1 | tee -a "${InstallationLog}"

_CloneRepository "https://aur.archlinux.org/${AurHelper}.git" "${DownloadDirectory}/${AurHelper}"

cd "${DownloadDirectory}/${AurHelper}" || exit

if ! _IsInstalled base-devel; then
    _InstallPackage base-devel
fi

makepkg --noconfirm -si &>>"${InstallationLog}"

if _IsInstalled "${AurHelper}"; then
    "${AurHelper}" -Syu --noconfirm &>>"${InstallationLog}"
    echo -e "${Clear}[${BoldGreen}OK${Reset}] - ${AurHelper} installed" 2>&1 | tee -a "${InstallationLog}"
else
    echo -e "${Clear}[${BoldRed}ERROR${Reset}] - ${AurHelper} installation failed." 2>&1 | tee -a "${InstallationLog}"
    exit 1
fi

cd "${DownloadDirectory}/install" || exit
