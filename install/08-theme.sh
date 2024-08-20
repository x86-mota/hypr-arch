#!/usr/bin/env bash

# --------------------------------------------------------- #
#               Enable starship in ~/.bashrc                #
# --------------------------------------------------------- #
if ! grep -q 'eval "$(starship init bash)"' "$HOME/.bashrc"; then
    echo -e "\n[${BoldBlue}NOTE${Reset}] - Enabling Starship"
    sed -i '$s/$/\n\n# Starship\n'"$(echo 'eval "$(starship init bash)"')"'\n/' "$HOME/.bashrc"
    _IsAdded 'eval "$(starship init bash)"' "$HOME/.bashrc"
fi

# --------------------------------------------------------- #
#               Install Tokyo Night GTK Theme               #
# --------------------------------------------------------- #
GtkThemeUrl="https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme.git"
GtkThemeName=$(basename ${GtkThemeUrl%.git})
GtkThemePath="${DownloadDirectory}/${GtkThemeName}/themes/install.sh"

echo -e "\n[${BoldBlue}NOTE${Reset}] - Installing ${GtkThemeName} GTK theme" 2>&1 | tee -a "${InstallationLog}"

_CloneRepository "${GtkThemeUrl}" "${DownloadDirectory}/${GtkThemeName}"

bash "${GtkThemePath}" --color dark --libadwaita --tweaks black &>>"${InstallationLog}"

if [ -d "${HOME}/.themes/Tokyonight-Dark"]; then
    echo -e "${Clear}[${BoldGreen}OK${Reset}] - Theme ${GtkThemeName} installed successfully." 2>&1 | tee -a "${InstallationLog}"
else
    echo -e "${Clear}[${BoldRed}ERROR${Reset}] - Theme ${GtkThemeName} installation failed." 2>&1 | tee -a "${InstallationLog}"
fi

# ----------------------------------------------------------------------------------------- #
#               Initiate GTK dark mode and apply icon, cursor theme and fonts               #
# ----------------------------------------------------------------------------------------- #
ColorScheme="prefer-dark"
GtkTheme="Tokyonight-Dark"
IconTheme="Papirus-Dark"
CursorTheme="Bibata-Modern-Ice"
CursorSize="24"
FontName="JetBrainsMono Nerd Font 11"

gsettings set org.gnome.desktop.interface color-scheme "${ColorScheme}"
gsettings set org.gnome.desktop.interface gtk-theme "${GtkTheme}"
gsettings set org.gnome.desktop.interface icon-theme "${IconTheme}"
gsettings set org.gnome.desktop.interface cursor-theme "${CursorTheme}"
gsettings set org.gnome.desktop.interface cursor-size "${CursorSize}"
gsettings set org.gnome.desktop.interface font-name "${FontName}"

# ----------------------------------------------------------------------------------------------------------------------------------------------------- #
#               Sets GTK system theme preferences for Chrome and Brave writing a predefined JSON structure into their 'Preferences' files.              #
# ----------------------------------------------------------------------------------------------------------------------------------------------------- #
ChromePreferencesPath="${HOME}/.config/google-chrome/Default"
BravePreferencesPath="${HOME}/.config/BraveSoftware/Brave-Browser/Default"
Paths=("${ChromePreferencesPath}" "${BravePreferencesPath}")
Preferences='{
    "extensions": {
        "theme": {
            "id": "",
            "system_theme": 1
        }
    }
}'

for p in "${Paths[@]}"; do
    mkdir -p "${p}"
    echo "${Preferences}" >"${p}/Preferences"
done

# ------------------------------------------------- #
#               Install Spotify theme               #
# ------------------------------------------------- #
if _IsInstalled spotify-launcher && _IsInstalled spicetify; then
    if spicetify -c &>/dev/null; then
        SpicetifyPath=$(spicetify -c)
        SpicetifyDirectory="$(dirname "${SpicetifyPath}")"
        ComfyList=("color.ini" "user.css" "theme.js")
        SpotifyThemeUrl="https://raw.githubusercontent.com/Comfy-Themes/Spicetify/main/Comfy"

        if [ -f "${SpicetifyPath}" ]; then
            echo -e "\n[${BoldBlue}NOTE${Reset}] - Applying Spotify theme\n" 2>&1 | tee -a "${InstallationLog}"

            sed -i 's|^spotify_path\s*=\s*.*|spotify_path           = $HOME/.local/share/spotify-launcher/install/usr/share/spotify/|' "${SpicetifyPath}"
            _IsAdded "spotify_path           = \$HOME/.local/share/spotify-launcher/install/usr/share/spotify/" "${SpicetifyPath}"

            sed -i 's|^prefs_path\s*=\s*.*|prefs_path             = '$HOME'/.config/spotify/prefs|' "${SpicetifyPath}"
            _IsAdded "prefs_path             = $HOME/.config/spotify/prefs" "${SpicetifyPath}"

            mkdir -p "${HOME}/.local/share/spotify-launcher/install/usr/share/spotify/"

            spicetify backup apply >>"${InstallationLog}" 2>&1

            mkdir -p "${SpicetifyDirectory}/Themes/Comfy"

            for f in "${ComfyList[@]}"; do
                echo -e "[${BoldBlue}NOTE${Reset}] - Downloading file ${f}..." 2>&1 | tee -a "${InstallationLog}"
                if curl -s "${SpotifyThemeUrl}/${f}" -o "${SpicetifyDirectory}/Themes/Comfy/${f}"; then
                    echo -e "${Clear}[${BoldGreen}OK${Reset}] - ${f} downloaded successfully to ${SpicetifyDirectory}/Themes/Comfy" 2>&1 | tee -a "${InstallationLog}"
                else
                    echo -e "${Clear}[${BoldRed}ERROR${Reset}] - download failed." 2>&1 | tee -a "${InstallationLog}"
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
QtList=("qt5ct" "qt6ct")
for qt in "${QtList[@]}"; do
    QtPath="${HOME}/.config/${qt}/${qt}.conf"
    QtColorsSchemePath="${HOME}/.config/${qt}/colors/Catppuccin-Mocha.conf"
    sed -i "s|^color_scheme_path=.*|color_scheme_path=${QtColorsSchemePath}|" "$QtPath"
done

# ----------------------------------------------------------------- #
#               Install Tokyo Night VSCode extension                #
# ----------------------------------------------------------------- #
if _IsInstalled code; then
    echo -e "[${BoldBlue}NOTE${Reset}] - Installing VS Code Tokyo Night extension..." 2>&1 | tee -a "${InstallationLog}"
    if code --install-extension enkia.tokyo-night >>"${InstallationLog}" 2>&1; then
        echo -e "${Clear}[${BoldGreen}OK${Reset}] - Extension successfully installed" 2>&1 | tee -a "${InstallationLog}"
    else
        echo -e "${Clear}[${BoldRed}ERROR${Reset}] - Extension not installed" 2>&1 | tee -a "${InstallationLog}"
    fi
fi
