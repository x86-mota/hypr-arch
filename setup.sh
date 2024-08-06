#!/usr/bin/env bash

# ------------------------------------------------- #
#               Set Global Variables                #
# ------------------------------------------------- #
ARCH_SETUP_DIR="$HOME/Downloads/hypr-arch"
INSTALL_LOG="${ARCH_SETUP_DIR}/install-$(date +"%Y-%m-%d-%H").log"
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

if [ -d "$ARCH_SETUP_DIR" ]; then
    rm -rf "$ARCH_SETUP_DIR"
fi

mkdir -p "$ARCH_SETUP_DIR"

git clone -n https://gitlab.com/x86_mota/arch-setup "${ARCH_SETUP_DIR}"

cd "${ARCH_SETUP_DIR}" || exit

for FOLDER in  "${INSTALL_FOLDERS[@]}"; do
    git checkout HEAD -- "$FOLDER"
done