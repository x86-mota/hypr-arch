#!/usr/bin/env bash

clear
echo -e "${ASCII_ART}"

# --------------------------------------------- #
#               Get kernel headers              #
# --------------------------------------------- #
for KRNL in $(cat /usr/lib/modules/*/pkgbase); do
    GPU_PACKAGES+=("${KRNL}-headers")
    echo -e "[${BLUE}NOTE${RC}] - ${KRNL}-headers added to installation list" 2>&1 | tee -a "${INSTALL_LOG}"
done

# ----------------------------------------------------- #
#               Install graphics packages               #
# ----------------------------------------------------- #
for PKG in "${GPU_PACKAGES[@]}"; do
    _InstallPackage "${PKG}"
done

# --------------------------------------------------------------------- #
#               Additional configuration for NVIDIA users               #
# --------------------------------------------------------------------- #
if [[ ${GRAPHICS_CARD} = "Nvidia" ]]; then
    MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
    for MOD in "${MODULES[@]}"; do
        if ! grep -wq "^MODULES=.*${MOD}" /etc/mkinitcpio.conf; then
            sudo sed -i "s/^MODULES=(\(.*\))/MODULES=(\1${MOD} )/" /etc/mkinitcpio.conf
            _IsAdded "${MOD}" "/etc/mkinitcpio.conf"
        fi
    done

    sudo mkinitcpio -P &>>"${INSTALL_LOG}"

    CONFIGFILE="/etc/modprobe.d/nvidia.conf"
    if [ ! -f "${CONFIGFILE}" ]; then
        echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee -a "${CONFIGFILE}" &>/dev/null
        _IsAdded "options nvidia_drm modeset=1 fbdev=1" "${CONFIGFILE}"
    fi
fi

clear
echo -e "${ASCII_ART}"
