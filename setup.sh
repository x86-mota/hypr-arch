#!/usr/bin/env bash

# ------------------------------------------------- #
#               Set Global Variables                #
# ------------------------------------------------- #
declare -r DownloadDirectory="/tmp/hypr-arch"
declare -r InstallationLog="${DownloadDirectory}/install-$(date +"%Y-%m-%d-%H").log"
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RC='\033[0m'
CL='\033[1A\033[K'
ASCII_ART="${GREEN}

                    -@                           
                   .##@                          
                  .####@                         
                  @#####@                        
                . *######@                       
               .##@o@#####@                                                                ,,                           ,,  
              /############@                      \`7MMF'  \`7MMF'                         \`7MM                         \`7MM  
             /##############@             M         MM      MM                             MM                           MM  
            @######@**%######@            M         MM      MM \`7M'   \`MF\`7MMpdMAo\`7Mb,od8 MM  ,6\"Yb. \`7MMpMMMb.   ,M\"\"bMM  
           @######\`     %#####o       mmmmMmmmm     MMmmmmmmMM   VA   ,V   MM   \`Wb MM' \"' MM 8)   MM   MM    MM ,AP    MM  
          @######@       ######%          M         MM      MM    VA ,V    MM    M8 MM     MM  ,pm9MM   MM    MM 8MI    MM  
        -@#######h       ######@.\`        M         MM      MM     VVV     MM   ,AP MM     MM 8M   MM   MM    MM \`Mb    MM  
       /#####h**\`\`       \`**%@####@               .JMML.  .JMML.   ,V      MMbmmd'.JMML. .JMML\`Moo9^Yo.JMML  JMML.\`Wbmd\"MML.
      @H@*\`                    \`*%#@                              ,V       MM                                               
     *\`                            \`*                          OOb\"      .JMML.                                             

${RC}"

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

# --------------------------------- #
#               BEGIN               #
# --------------------------------- #

clear
echo -e "${ASCII_ART}"

# --------------------------------------------------------- #
#               Verify the system is Arch Linux             #
# --------------------------------------------------------- #
if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [ ! "${ID}" == "arch" ]; then
        echo -e "[${RED}ERROR${RC}] - It seems that the system is not ArchLinux. Aborting..."
        exit 1
    fi
fi

# ------------------------------------------------------------------------- #
#               Checks if the current user has sudo privileges              #
# ------------------------------------------------------------------------- #
if ! sudo -l >/dev/null 2>&1; then
    echo -e "[${RED}ERROR${RC}] - You need to have sudo privileges to run this script!"
    exit 1
fi

# ----------------------------------------------------------------- #
#               Download files from remote repository               #
# ----------------------------------------------------------------- #
INSTALL_FOLDERS=(
    assets
    config
    install
)

if [ -d "$DownloadDirectory" ]; then
    rm -rf "$DownloadDirectory"
fi

echo -e "[${BLUE}NOTE${RC}] - Downloading installation files..."
if git clone -nq https://github.com/x86-mota/hyrp-arch.git "${DownloadDirectory}"; then
    cd "${DownloadDirectory}" || exit
    for FOLDER in "${INSTALL_FOLDERS[@]}"; do
        git checkout HEAD -- "$FOLDER"
    done
    echo -e "${CL}[${GREEN}OK${RC}] - Installation files downloaded into ${DownloadDirectory}."
fi

# ------------------------------------------------------------------------------------- #
#               Enter the install directory and set executable permissions              #
# ------------------------------------------------------------------------------------- #
if [ -d "${DownloadDirectory}/install" ]; then
    cd "${DownloadDirectory}/install" || exit

    if [ -f ./00-install.sh ]; then
        chmod a+x 00-install.sh
        source ./00-install.sh
    else
        echo -e "[${RED}ERROR${RC}] - 00-install.sh not found" 2>&1 | tee -a "${InstallationLog}"
        exit 1
    fi
else
    echo -e "[${RED}ERROR${RC}] - Directory not found or inaccessible" 2>&1 | tee -a "${InstallationLog}"
    exit 1
fi