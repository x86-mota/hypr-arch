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