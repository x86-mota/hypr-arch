#!/usr/bin/env bash

# ------------------------------------------------- #
#               Set Global Variables                #
# ------------------------------------------------- #
declare -r DownloadDirectory="/tmp/hypr-arch"
declare -r InstallationLog="${HOME}/install-$(date +"%Y-%m-%d-%H").log"
declare -r BoldRed='\033[1;31m'
declare -r BoldGreen='\033[1;32m'
declare -r BoldYellow='\033[1;33m'
declare -r BoldBlue='\033[1;34m'
declare -r Reset='\033[0m'
declare -r Clear='\033[1A\033[K'

# ------------------------------------------------- #
#               Checks if file exists               #
# ------------------------------------------------- #
function _CheckFileExist {
    if [ -f "$1" ]; then
        return 0
    else
        echo -e "[${BoldRed}ERROR${Reset}] - file '$1' not found."
        exit 1
    fi
}

# --------------------------------- #
#               BEGIN               #
# --------------------------------- #

clear
echo -e "${BoldGreen}
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

${Reset}"

# --------------------------------------------------------- #
#               Verify the system is Arch Linux             #
# --------------------------------------------------------- #
if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [ ! "${ID}" == "arch" ]; then
        echo -e "[${BoldRed}ERROR${Reset}] - It seems that the system is not ArchLinux. Aborting..."
        exit 1
    fi
fi

# ------------------------------------------------------------------------- #
#               Checks if the current user has sudo privileges              #
# ------------------------------------------------------------------------- #
if ! sudo -l >/dev/null 2>&1; then
    echo -e "[${BoldRed}ERROR${Reset}] - You need to have sudo privileges to run this script!"
    exit 1
fi

# ----------------------------------------------------------------- #
#               Download files from remote repository               #
# ----------------------------------------------------------------- #
[ -d "${DownloadDirectory}" ] && sudo rm -rf "${DownloadDirectory}"

echo -e "[${BoldBlue}NOTE${Reset}] - Downloading installation files..." 2>&1 | tee -a "${InstallationLog}"
if git clone -n https://github.com/x86-mota/hyrp-arch.git "${DownloadDirectory}" >>"${InstallationLog}" 2>&1; then
    Folders=(assets config install)
    cd "${DownloadDirectory}" || exit
    for f in "${Folders[@]}"; do
        git checkout HEAD -- "${f}"
    done
    echo -e "${Clear}[${BoldGreen}OK${Reset}] - Installation files downloaded into ${DownloadDirectory}." 2>&1 | tee -a "${InstallationLog}"
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
        echo -e "[${BoldRed}ERROR${Reset}] - 00-install.sh not found" 2>&1 | tee -a "${InstallationLog}"
        exit 1
    fi
else
    echo -e "[${BoldRed}ERROR${Reset}] - Directory not found or inaccessible" 2>&1 | tee -a "${InstallationLog}"
    exit 1
fi