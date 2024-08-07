#!/usr/bin/env bash

# ------------------------------------------------------------------------------------------------- #
#               Checks if grub is installed and replaces the default configuration file             #
# ------------------------------------------------------------------------------------------------- #
if _IsInstalled grub && [ -f "/boot/grub/grub.cfg" ]; then
    GRUB_CONFIG_FILE="/etc/default/grub"
    echo -e "[${BLUE}NOTE${RC}] - Editing ${GRUB_CONFIG_FILE}.\n" 2>&1 | tee -a "${INSTALL_LOG}"
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
        echo -e "${CL}[${GREEN}OK${RC}] - GRUB file edited successfully." 2>&1 | tee -a "${INSTALL_LOG}"
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
            echo -e "${CL}[${BLUE}NOTE${RC}] - ${MODESET} is already present in /etc/default/grub" 2>&1 | tee -a "${INSTALL_LOG}"
        fi
    fi

    echo -e "[${BLUE}NOTE${RC}] - Updating GRUB..."
    if sudo grub-mkconfig -o /boot/grub/grub.cfg &>>"${INSTALL_LOG}"; then
        echo -e "${CL}[${GREEN}OK${RC}] - GRUB updated successfully." 2>&1 | tee -a "${INSTALL_LOG}"
    else
        echo -e "${CL}[${RED}ERROR${RC}] - GRUB update had failed." 2>&1 | tee -a "${INSTALL_LOG}"
    fi
fi
