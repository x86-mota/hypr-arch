#!/usr/bin/env bash

sleep 1
clear
echo -e "${ASCII_ART}"

# --------------------------------------------------------- #
#               Enable starship in ~/.bashrc                #
# --------------------------------------------------------- #
sed -i '$s/$/\n\n# Starship\n'"$(echo 'eval "$(starship init bash)"')"'\n/' "$HOME/.bashrc"

# --------------------------------------------------------- #
#               Install Tokyo Night GTK Theme               #
# --------------------------------------------------------- #
GTK_THEME_URL="https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme.git"
GTK_THEME_NAME=$(basename ${GTK_THEME_URL%.git})
GTK_THEME_PATH="${ARCH_SETUP_DIR}/${GTK_THEME_NAME}/themes/install.sh"

_CloneRepository "${GTK_THEME_URL}" "${ARCH_SETUP_DIR}/${GTK_THEME_NAME}"

echo -e "[${BLUE}NOTE${RC}] - Installing ${GTK_THEME_NAME} GTK theme" 2>&1 | tee -a "${INSTALL_LOG}"
bash "${GTK_THEME_PATH}" --color dark --libadwaita --tweaks black &>>"${INSTALL_LOG}"

if [ -d $HOME/.themes/Tokyonight-Dark ]; then
    echo -e "${CL}[${GREEN}OK${RC}] - Theme ${GTK_THEME_NAME} installed successfully." 2>&1 | tee -a "${INSTALL_LOG}"
else
    echo -e "${CL}[${RED}ERROR${RC}] - Theme ${GTK_THEME_NAME} installation failed." 2>&1 | tee -a "${INSTALL_LOG}"
fi

# ----------------------------------------------------------------------------------------- #
#               Initiate GTK dark mode and apply icon, cursor theme and fonts               #
# ----------------------------------------------------------------------------------------- #
COLOR_SCHEME="prefer-dark"
GTK_THEME="Tokyonight-Dark"
ICON_THEME="Papirus-Dark"
CURSOR_THEME="Bibata-Modern-Ice"
CURSOR_SIZE="24"
FONT_NAME="JetBrainsMono Nerd Font 11"

gsettings set org.gnome.desktop.interface color-scheme "${COLOR_SCHEME}"
gsettings set org.gnome.desktop.interface gtk-theme "${GTK_THEME}"
gsettings set org.gnome.desktop.interface icon-theme "${ICON_THEME}"
gsettings set org.gnome.desktop.interface cursor-theme "${CURSOR_THEME}"
gsettings set org.gnome.desktop.interface cursor-size "${CURSOR_SIZE}"
gsettings set org.gnome.desktop.interface font-name "${FONT_NAME}"

# ----------------------------------------------------------------------------------------------------------------------------------------------------- #
#               Sets GTK system theme preferences for Chrome and Brave writing a predefined JSON structure into their 'Preferences' files.              #
# ----------------------------------------------------------------------------------------------------------------------------------------------------- #
CHROME_PREFS_PATH="${HOME}/.config/google-chrome/Default"
BRAVE_PREFS_PATH="${HOME}/.config/BraveSoftware/Brave-Browser/Default"
PATHS=("${CHROME_PREFS_PATH}" "${BRAVE_PREFS_PATH}")
PREFERENCES='{
    "extensions": {
        "theme": {
            "id": "",
            "system_theme": 1
        }
    }
}'

for P in "${PATHS[@]}"; do
    mkdir -p "${P}"
    echo "${PREFERENCES}" >"${P}/Preferences"
done

# ------------------------------------------------- #
#               Install Spotify theme               #
# ------------------------------------------------- #
echo -e "[${BLUE}NOTE${RC}] - Applying theme"
SPOTIFY_THEME_URL="https://raw.githubusercontent.com/Comfy-Themes/Spicetify/main/Comfy"
SPICETIFY_DIR="$(dirname "$(spicetify -c)")"

mkdir -p "${SPICETIFY_DIR}/Themes/Comfy"

curl --silent --output "${SPICETIFY_DIR}/Themes/Comfy/color.ini" "${SPOTIFY_THEME_URL}/color.ini"
curl --silent --output "${SPICETIFY_DIR}/Themes/Comfy/user.css" "${SPOTIFY_THEME_URL}/user.css"
curl --silent --output "${SPICETIFY_DIR}/Themes/Comfy/theme.js" "${SPOTIFY_THEME_URL}/theme.js"

spicetify config current_theme Comfy color_scheme catppuccin-mocha
spicetify config inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1
spicetify apply
echo -e "[${GREEN}OK${RC}] - All done!"
