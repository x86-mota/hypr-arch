#!/usr/bin/env bash

# --------------------------------------------------------- #
#               Enable starship in ~/.bashrc                #
# --------------------------------------------------------- #
if ! grep -q 'eval "$(starship init bash)"' "$HOME/.bashrc"; then
    echo -e "\n[${BLUE}NOTE${RC}] - Enabling Starship"
    sed -i '$s/$/\n\n# Starship\n'"$(echo 'eval "$(starship init bash)"')"'\n/' "$HOME/.bashrc"
    _IsAdded 'eval "$(starship init bash)"' "$HOME/.bashrc"
fi

# --------------------------------------------------------- #
#               Install Tokyo Night GTK Theme               #
# --------------------------------------------------------- #
GTK_THEME_URL="https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme.git"
GTK_THEME_NAME=$(basename ${GTK_THEME_URL%.git})
GTK_THEME_PATH="${DownloadDirectory}/${GTK_THEME_NAME}/themes/install.sh"

echo -e "\n[${BLUE}NOTE${RC}] - Installing ${GTK_THEME_NAME} GTK theme" 2>&1 | tee -a "${InstallationLog}"

_CloneRepository "${GTK_THEME_URL}" "${DownloadDirectory}/${GTK_THEME_NAME}"

bash "${GTK_THEME_PATH}" --color dark --libadwaita --tweaks black &>>"${InstallationLog}"

if [ -d $HOME/.themes/Tokyonight-Dark ]; then
    echo -e "${CL}[${GREEN}OK${RC}] - Theme ${GTK_THEME_NAME} installed successfully." 2>&1 | tee -a "${InstallationLog}"
else
    echo -e "${CL}[${RED}ERROR${RC}] - Theme ${GTK_THEME_NAME} installation failed." 2>&1 | tee -a "${InstallationLog}"
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
if _IsInstalled spotify-launcher && _IsInstalled spicetify; then
    if spicetify -c &>/dev/null; then
        SPICETIFY_PATH=$(spicetify -c)
        SPICETIFY_DIR="$(dirname "${SPICETIFY_PATH}")"
        COMFY_LIST=("color.ini" "user.css" "theme.js")
        SPOTIFY_THEME_URL="https://raw.githubusercontent.com/Comfy-Themes/Spicetify/main/Comfy"

        if [ -f "${SPICETIFY_PATH}" ]; then
            echo -e "\n[${BLUE}NOTE${RC}] - Applying Spotify theme\n" 2>&1 | tee -a "${InstallationLog}"

            sed -i 's|^spotify_path\s*=\s*.*|spotify_path           = $HOME/.local/share/spotify-launcher/install/usr/share/spotify/|' "${SPICETIFY_PATH}"
            _IsAdded "spotify_path           = \$HOME/.local/share/spotify-launcher/install/usr/share/spotify/" "${SPICETIFY_PATH}"

            sed -i 's|^prefs_path\s*=\s*.*|prefs_path             = '$HOME'/.config/spotify/prefs|' "${SPICETIFY_PATH}"
            _IsAdded "prefs_path             = $HOME/.config/spotify/prefs" "${SPICETIFY_PATH}"

            mkdir -p "${HOME}/.local/share/spotify-launcher/install/usr/share/spotify/"

            spicetify backup apply >>"${InstallationLog}" 2>&1

            mkdir -p "${SPICETIFY_DIR}/Themes/Comfy"

            for FILE in "${COMFY_LIST[@]}"; do
                echo -e "[${BLUE}NOTE${RC}] - Downloading file ${FILE}..." 2>&1 | tee -a "${InstallationLog}"
                if curl -s "${SPOTIFY_THEME_URL}/${FILE}" -o "${SPICETIFY_DIR}/Themes/Comfy/${FILE}"; then
                    echo -e "${CL}[${GREEN}OK${RC}] - ${FILE} downloaded successfully to ${SPICETIFY_DIR}/Themes/Comfy" 2>&1 | tee -a "${InstallationLog}"
                else
                    echo -e "${CL}[${RED}ERROR${RC}] - download failed." 2>&1 | tee -a "${InstallationLog}"
                fi
            done

            spicetify config current_theme Comfy color_scheme catppuccin-mocha
            spicetify config inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1
            spicetify apply >>"${InstallationLog}" 2>&1
        fi
    fi
fi

# ------------------------------------------------------------- #
#               Set COlor Scheme Path for QT Apps               #
# ------------------------------------------------------------- #
QT_LIST=("qt5ct" "qt6ct")
for QT in "${QT_LIST[@]}"; do
    QT_PATH="${HOME}/.config/${QT}/${QT}.conf"
    COLOR_SCHEME_PATH="${HOME}/.config/${QT}/colors/Catppuccin-Mocha.conf"
    sed -i "s|^color_scheme_path=.*|color_scheme_path=${COLOR_SCHEME_PATH}|" "$QT_PATH"
done

# ----------------------------------------------------------------- #
#               Install Tokyo Night VSCode extension                #
# ----------------------------------------------------------------- #
if _IsInstalled code; then
    echo -e "[${BLUE}NOTE${RC}] - Installing VS Code Tokyo Night extension..." 2>&1 | tee -a "${InstallationLog}"
    if code --install-extension enkia.tokyo-night >>"${InstallationLog}" 2>&1; then
        echo -e "${CL}[${GREEN}OK${RC}] - Extension successfully installed" 2>&1 | tee -a "${InstallationLog}"
    else
        echo -e "${CL}[${RED}ERROR${RC}] - Extension not installed" 2>&1 | tee -a "${InstallationLog}"
    fi
fi
