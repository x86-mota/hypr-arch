# About
This repository is dedicated to the installation of packages and customization of a clean installation of Arch Linux.. It contains a script that automates the process of installing and initial system configuration.

<br>

![Preview](https://github.com/x86-mota/hyrp-arch/blob/main/preview.png)

<br>

## Requirements
- A clean installation of Arch Linux
- sudo privileges (requires sudo package install)
- git

<br>

## Installation
Just copy this command in your terminal and execute
```bash
bash <(curl -sL https://raw.githubusercontent.com/x86-mota/hyrp-arch/main/setup.sh)
```
<br>

## Main Packages

|   Name                                                                                    | Function              |
|   :--------                                                                               |:----------            |
|   [ly](https://github.com/fairyglade/ly)                                                  | Display/Login Manager |
|   [hyprland](https://hyprland.org/)                                                       | Wayland Compositor    |
|   [waybar](https://github.com/Alexays/Waybar)                                             | Status Bar            |
|   [kitty](https://sw.kovidgoyal.net/kitty/)                                               | Terminal Emulator     |
|   [rofi](https://github.com/davatorium/rofi)                                              | App Launcher          |
|   [wlogout](https://github.com/ArtsyMacaw/wlogout) <sup>AUR</sup>                         | Power Menu            |
|   [swww](https://github.com/LGFae/swww)                                                   | Wallpaper Manager     |
|   [fastfetch](https://github.com/fastfetch-cli/fastfetch)                                 | Fetch Tool            |
|   [vscode](https://aur.archlinux.org/packages/visual-studio-code-bin) <sup>AUR</sup>      | Code/Text Editor      |
|   [thunar](https://docs.xfce.org/xfce/thunar/start)                                       | File Explorer         |
|   [btop](https://github.com/aristocratos/btop)                                            | System Monitor        |
|   [swaync](https://github.com/ErikReider/SwayNotificationCenter)                          | Notifications         |
|   [brave](https://aur.archlinux.org/packages/brave-bin) <sup>AUR</sup>                    | Web Browser           |
|   [eog](https://wiki.gnome.org/Apps/EyeOfGnome)                                           | Image Viewer          |

> [!NOTE]
> You can find all packages [here](https://github.com/x86-mota/hyrp-arch/blob/main/install/02-packages.sh)

<br>

## Keybindings

| Keys                                                                                              | Action                    |
| :---                                                                                              | :---                      |
| <kbd>Super</kbd>  +   <kbd>Enter</kbd>                                                            | Application Launcher      |
| <kbd>Super</kbd>  +   <kbd>F4</kbd>                                                               | Power menu                |
| <kbd>Super</kbd>  +   <kbd>B</kbd>                                                                | Web browser               |
| <kbd>Super</kbd>  +   <kbd>E</kbd>                                                                | File Manager              |
| <kbd>Super</kbd>  +   <kbd>C</kbd>                                                                | Code/Text Editor          |
| <kbd>Super</kbd>  +   <kbd>T</kbd>                                                                | Terminal Emulator         |
| <kbd>Super</kbd>  +   <kbd>D</kbd>                                                                | Discord                   |
| <kbd>Super</kbd>  +   <kbd>S</kbd>                                                                | Spotify                   |
| <kbd>Super</kbd>  +   <kbd>Shift</kbd>    +   <kbd>S</kbd>                                        | Screenshot                |
| <kbd>Super</kbd>  +   <kbd>Q</kbd>                                                                | Close focused window      |
| <kbd>Super</kbd>  +   <kbd>←</kbd><kbd>→</kbd><kbd>↑</kbd><kbd>↓</kbd>                            | Move Focus                |
| <kbd>Super</kbd>  +   <kbd>Shift</kbd>    +   <kbd>←</kbd><kbd>→</kbd><kbd>↑</kbd><kbd>↓</kbd>    | Change Window             |
| <kbd>Super</kbd>  +   <kbd>Shift</kbd>    +   <kbd>[0-9]</kbd>                                    | Move to Workspaces        |
| <kbd>Super</kbd>  +   <kbd>[0-9]</kbd>                                                            | Switch workspaces         |
| <kbd>Super</kbd>  +   <kbd>W</kbd>                                                                | Toggle the window float   |
| <kbd>CTRL</kbd>   +   <kbd>SHIT</kbd>     +     <kbd>K</kbd>                                      | Switch keyboard Layout    |
| <kbd>CTRL</kbd>   +   <kbd>SHIT</kbd>     +     <kbd>B</kbd>                                      | Launch/Restart Waybar     |
| <kbd>CTRL</kbd>   +   <kbd>SHIT</kbd>     +     <kbd>W</kbd>                                      | Launch/Restart swww       |

<br>