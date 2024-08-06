#!/usr/bin/env bash

# ------------------------------------------------- #
#               Checks if file exists               #
# ------------------------------------------------- #
function _CheckFileExist {
    if [ -f "$1" ]; then
        return 0
    else
        echo -e "[${RED}ERROR${RC}] - file '$1' not found."
        exit 1
    fi
}

# ------------------------------------------------- #
#               Function to clear lines             #
# ------------------------------------------------- #
function _ClearLines {
    for ((i = 0; i < $1; i++)); do
        echo -ne "${CL}"
    done
}

# ------------------------------------------------------------------------------------------ #
#               Checks if the parameter was added/edited successfully into file              #
# ------------------------------------------------------------------------------------------ #
function _IsAdded {
    VALUE="${1/^/}"
    if grep -qw -- "$1" "$2"; then
        echo -e "[${GREEN}OK${RC}] - '${VALUE}' successfully added to $2" 2>&1 | tee -a "${INSTALL_LOG}"
        return 0
    else
        echo -e "[${RED}ERROR${RC}] - '${VALUE}' was not added to the file $2" 2>&1 | tee -a "${INSTALL_LOG}"
        return 1
    fi
}

# ----------------------------------------------------------------- #
#               Checks if package is already installed              #
# ----------------------------------------------------------------- #
function _IsInstalled {
    if command -v "$1" || pacman -Q "$1" &>/dev/null; then
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
            echo -e "[${BLUE}NOTE${RC}] - Installing $1..." 2>&1 | tee -a "${INSTALL_LOG}"
            sudo pacman -S --noconfirm --needed "$1" &>>"${INSTALL_LOG}"

        elif _IsAURAvailable "$1"; then
            echo -e "[${BLUE}NOTE${RC}] - Installing $1 from AUR. This may take a while..." 2>&1 | tee -a "${INSTALL_LOG}"
            ${AUR_HELPER} -S --noconfirm --needed "$1" &>>"${INSTALL_LOG}"
        else
            echo -e "${CL}[${RED}ERROR${RC}] - Unknown package $1." 2>&1 | tee -a "${INSTALL_LOG}"
            return
        fi

        if _IsInstalled "$1"; then
            echo -e "${CL}[${GREEN}OK${RC}] - $1 installed." 2>&1 | tee -a "${INSTALL_LOG}"
        else
            echo -e "${CL}[${RED}ERROR${RC}] - $1 install had failed, please check the install.log" 2>&1 | tee -a "${INSTALL_LOG}"
            exit 1
        fi
    else
        echo -e "[${BLUE}NOTE${RC}] - $1 already installed." 2>&1 | tee -a "${INSTALL_LOG}"
    fi
}

# ------------------------------------------------- #
#               Function to capy files              #
# ------------------------------------------------- #
function _CopyFiles {
    local SOURCE_DIR="$1"
    local DEST_DIR="$2"

    for ITEM in "${SOURCE_DIR}"/*; do
        if cp -r "${ITEM}" "${DEST_DIR}"; then
            echo -e "[${GREEN}OK${RC}] - File copied: ${ITEM##*/} to ${DEST_DIR}" 2>&1 | tee -a "${INSTALL_LOG}"
        else
            echo -e "[${RED}ERROR${RC}] - Failed to copy file: ${ITEM##*/}" 2>&1 | tee -a "${INSTALL_LOG}"
        fi
    done
}