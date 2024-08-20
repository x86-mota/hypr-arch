#!/usr/bin/env bash

echo -e "[${BoldBlue}NOTE${Reset}] - Installing ${GraphicsCard} packages..." 2>&1 | tee -a "${InstallationLog}"

# --------------------------------------------- #
#               Get kernel headers              #
# --------------------------------------------- #
for k in $(cat /usr/lib/modules/*/pkgbase); do
    GraphicsPackages+=("${k}-headers")
    echo -e "[${BoldBlue}NOTE${Reset}] - ${k}-headers added to installation list" 2>&1 | tee -a "${InstallationLog}"
done

# ----------------------------------------------------- #
#               Install graphics packages               #
# ----------------------------------------------------- #
for p in "${GraphicsPackages[@]}"; do
    _InstallPackage "${p}"
done

# --------------------------------------------------------------------- #
#               Additional configuration for Nvidia users               #
# --------------------------------------------------------------------- #
if [[ ${GraphicsCard} = "Nvidia" ]]; then
    Modules=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
    for MOD in "${Modules[@]}"; do
        if ! grep -wq "^MODULES=.*${MOD}" /etc/mkinitcpio.conf; then
            sudo sed -i "s/^MODULES=(\(.*\))/MODULES=(\1${MOD} )/" /etc/mkinitcpio.conf
            _IsAdded "${MOD}" "/etc/mkinitcpio.conf"
        fi
    done

    sudo mkinitcpio -P &>>"${InstallationLog}"

    NvidiaConfPath="/etc/modprobe.d/nvidia.conf"
    if [ ! -f "${NvidiaConfPath}" ]; then
        echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee -a "${NvidiaConfPath}" &>/dev/null
        _IsAdded "options nvidia_drm modeset=1 fbdev=1" "${NvidiaConfPath}"
    fi
fi
