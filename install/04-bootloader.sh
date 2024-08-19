#!/usr/bin/env bash

# ------------------------------------------------------------------------------------------------- #
#               Checks if grub is installed and replaces the default configuration file             #
# ------------------------------------------------------------------------------------------------- #
if _IsInstalled grub && [ -f "/boot/grub/grub.cfg" ]; then
    GRUB_CONFIG_FILE="/etc/default/grub"
    echo -e "\n[${BoldBlue}NOTE${Reset}] - Editing ${GRUB_CONFIG_FILE}." 2>&1 | tee -a "${InstallationLog}"
    if [ ! -f "${GRUB_CONFIG_FILE}.bak" ]; then
        sudo mv "${GRUB_CONFIG_FILE}" "${GRUB_CONFIG_FILE}.bak"
    fi

    if echo "# GRUB boot loader configuration
        GRUB_DEFAULT=0
        GRUB_TIMEOUT_STYLE=hidden
        GRUB_TIMEOUT=0
        GRUB_DISTRIBUTOR=\`( . /etc/os-release; echo \${NAME} ) 2>/dev/null || echo Arch Linux\`
        GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"
        GRUB_CMDLINE_LINUX=\"\"
        " | sed 's/^[ \t]*//' | sudo tee -a "${GRUB_CONFIG_FILE}" >/dev/null; then
        echo -e "[${BoldGreen}OK${Reset}] - GRUB file edited successfully." 2>&1 | tee -a "${InstallationLog}"
    else
        sudo mv "$GRUB_CONFIG_FILE.bak" "$GRUB_CONFIG_FILE"
    fi

    # --------------------------------------------------------------------- #
    #               Additional configuration for NVIDIA users               #
    # --------------------------------------------------------------------- #
    if [[ ${GRAPHICS_CARD} = "Nvidia" ]]; then
        MODESET="nvidia_drm.modeset=1"
        if ! grep -q "${MODESET}" /etc/default/grub; then
            sudo sed -i "s/\(GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*\)/\1 ${MODESET}/" /etc/default/grub
            _IsAdded "${MODESET}" "/etc/default/grub"
        else
            echo -e "${Clear}[${BoldBlue}NOTE${Reset}] - ${MODESET} is already present in /etc/default/grub" 2>&1 | tee -a "${InstallationLog}"
        fi
    fi

    echo -e "[${BoldBlue}NOTE${Reset}] - Updating GRUB..."
    if sudo grub-mkconfig -o /boot/grub/grub.cfg &>>"${InstallationLog}"; then
        echo -e "${Clear}[${BoldGreen}OK${Reset}] - GRUB updated successfully." 2>&1 | tee -a "${InstallationLog}"
    else
        echo -e "${Clear}[${BoldRed}ERROR${Reset}] - GRUB update had failed." 2>&1 | tee -a "${InstallationLog}"
    fi
fi
