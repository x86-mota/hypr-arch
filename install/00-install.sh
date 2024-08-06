#!/usr/bin/env bash

clear
echo -e "${ASCII_ART}"

# --------------------------------------------------------------------- #
#               Load functions used throughout the script               #
# --------------------------------------------------------------------- #
if _CheckFileExist "./01-functions.sh"; then
    source ./01-functions.sh
fi

# ------------------------------------------------------------- #
#               Load package lists for installation             #
# ------------------------------------------------------------- #
if _CheckFileExist "./02-packages.sh"; then 
    source ./02-packages.sh
fi
