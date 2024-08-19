#!/usr/bin/env bash

# ------------------------------------------------------------------------------------------ #
#               Checks if the parameter was added/edited successfully into file              #
# ------------------------------------------------------------------------------------------ #
function _IsAdded {
    VALUE="${1/^/}"
    if grep -qw -- "$1" "$2"; then
        echo -e "[${BoldGreen}OK${Reset}] - '${VALUE}' successfully added to $2" 2>&1 | tee -a "${InstallationLog}"
        return 0
    else
        echo -e "[${BoldRed}ERROR${Reset}] - '${VALUE}' was not added to the file $2" 2>&1 | tee -a "${InstallationLog}"
        return 1
    fi
}

# ----------------------------------------------------------------- #
#               Checks if package is already installed              #
# ----------------------------------------------------------------- #
function _IsInstalled {
    if command -v "$1" &>/dev/null || pacman -Q "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# ----------------------------------------------------------------------------- #
#               Checks if package is available in Arch repositories             #
# ----------------------------------------------------------------------------- #
function _IsPacmanAvailable {
    if pacman -Si "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# ----------------------------------------------------------------------------- #
#               Checks if package is available in AUR repositories              #
# ----------------------------------------------------------------------------- #
function _IsAURAvailable {
    if ${AUR_HELPER} -Si "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# ----------------------------------------------------------------------- #
#               Install Package from Arch repositories or AUR             #
# ----------------------------------------------------------------------- #
function _InstallPackage {
    if ! _IsInstalled "$1"; then
        if _IsPacmanAvailable "$1"; then
            echo -e "[${BoldBlue}NOTE${Reset}] - Installing $1..." 2>&1 | tee -a "${InstallationLog}"
            sudo pacman -S --noconfirm --needed "$1" &>>"${InstallationLog}"

        elif _IsAURAvailable "$1"; then
            echo -e "[${BoldBlue}NOTE${Reset}] - Installing $1 from AUR. This may take a while..." 2>&1 | tee -a "${InstallationLog}"
            ${AUR_HELPER} -S --noconfirm --needed "$1" &>>"${InstallationLog}"
        else
            echo -e "${Clear}[${BoldRed}ERROR${Reset}] - Unknown package $1." 2>&1 | tee -a "${InstallationLog}"
            return
        fi

        if _IsInstalled "$1"; then
            echo -e "${Clear}[${BoldGreen}OK${Reset}] - $1 installed." 2>&1 | tee -a "${InstallationLog}"
        else
            echo -e "${Clear}[${BoldRed}ERROR${Reset}] - $1 install had failed, please check the install.log" 2>&1 | tee -a "${InstallationLog}"
            exit 1
        fi
    else
        echo -e "[${BoldBlue}NOTE${Reset}] - $1 already installed." 2>&1 | tee -a "${InstallationLog}"
    fi
}

# ------------------------------------------------- #
#               Function to capy files              #
# ------------------------------------------------- #
function _CopyFiles {
    local SOURCE_DIR="$1"
    local DEST_DIR="$2"

    mkdir -p "$DEST_DIR"
    
    for ITEM in "${SOURCE_DIR}"/*; do
         if cp -r "${SOURCE_DIR}/${ITEM##*/}" "${DEST_DIR}"; then
            echo -e "[${BoldGreen}OK${Reset}] - File copied: ${ITEM##*/} to ${DEST_DIR}" 2>&1 | tee -a "${InstallationLog}"
        else
            echo -e "[${BoldRed}ERROR${Reset}] - Failed to copy file: ${ITEM##*/}" 2>&1 | tee -a "${InstallationLog}"
        fi
    done
}

# ---------------------------------------------------------------- #
#               Function to clone a remote repository              #
# ---------------------------------------------------------------- #
function _CloneRepository {
    local URL="$1"
    local TARGET_DIR="$2"

    if ! _IsInstalled git; then
        _InstallPackage git
    fi

    if [ -d "$TARGET_DIR" ]; then
        rm -rf "$TARGET_DIR"
    fi

    if git ls-remote --exit-code "$URL" &>>"${InstallationLog}"; then
        echo -e "[${BoldBlue}NOTE${Reset}] - Cloning ${URL} repository..." 2>&1 | tee -a "${InstallationLog}"
        if git clone "${URL}" "${TARGET_DIR}" &>>"${InstallationLog}"; then
            echo -e "${Clear}[${BoldGreen}OK${Reset}] - Cloned repository ${URL}" 2>&1 | tee -a "${InstallationLog}"
        else
            echo -e "${Clear}[${BoldRed}ERROR${Reset}] - Clone of ${URL} repository failed. Please check the log" 2>&1 | tee -a "${InstallationLog}"
            exit 1
        fi
    else
        echo -e "${Clear}[${BoldRed}ERROR${Reset}] - The repository ${URL} does not exist." 2>&1 | tee -a "${InstallationLog}"
        exit 1
    fi
}
