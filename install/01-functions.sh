#!/usr/bin/env bash

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