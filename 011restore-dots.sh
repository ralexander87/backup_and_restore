#!/bin/bash

DOTS="$HOME/.mydotfiles/com.ml4w.dotfiles.stable/.config"
HYPR="$DOTS/hypr/conf"
SRC="$HOME/dots"

##### PRE INSTALL TODO #####
### SDDM Autologin user: ralexander
sudo sed -i '/^User=/s//User=ralexander/' /usr/lib/sddm/sddm.conf.d/default.conf
echo "Auto login set..." ; sleep 3

### Font install NerdFont 3.4.0
bash "$HOME/Shared/fonts/install.sh" ; sleep 3 ; clear

set -u  # (optional) leave -e off so errors here don't kill the whole script

ensure_pacman_packages() {
# Accept packages as arguments or fall back to a default list
  local pkgs=("$@")
  if ((${#pkgs[@]} == 0)); then
    pkgs=(flatpak pigz cava rsync swappy openssh)
  fi

# Use sudo if not root
  local SUDO=""
  if [[ $EUID -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
      SUDO="sudo"
    else
      echo "Need root priv (sudo missing). Skipping installed."
      return 1
    fi
  fi

  local missing=()
  echo "Checking installed packages..."
  for pkg in "${pkgs[@]}"; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
      echo "✓ $pkg is installed. Skipping."
    else
      echo "• $pkg is not installed. Will install."
      missing+=("$pkg")
    fi
  done

  if ((${#missing[@]} == 0)); then
    echo "All already installed."
    return 0
  fi

  echo "Installing missing: ${missing[*]}"
  if ! $SUDO pacman -S --needed --noconfirm "${missing[@]}"; then
    echo "Package installation failed."
    return 1
  fi

  echo "Package ensure step complete."
  return 0
}

# --- use it like this ---
ensure_pacman_packages \
  flatpak pigz cava rsync swappy openssh

##### ML4W SETUP #####

# flatpak install flathub com.ml4w.dotfilesinstaller
# flatpak run com.ml4w.dotfilesinstaller
# https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/hyprland-dotfiles-stable.dotinst

### Delete flatpak app
flatpak uninstall -y com.github.PintaProject.Pinta && flatpak uninstall -y com.ml4w.calendar && sleep 5 && clear

### pacman & shell
bash "$DOTS/ml4w/scripts/arch/pacman.sh"
bash "$DOTS/ml4w/scripts/shell.sh"

### Set keybindings
cp "$SRC/hypr/conf/keybindings/lateralus.conf" "$HYPR/keybindings/"
echo 'source = ~/.config/hypr/conf/keybindings/lateralus.conf' > "$HYPR/keybinding.conf"

### Wallpapers update ML4W
rm -rf "$DOTS/ml4w/wallpapers" && ln -s ~/Pictures/wallpapers  "$DOTS/ml4w"

### HYPR
# echo '' > "$FOO/hypr/"
sed -i -e 's/480/4200/g' -e 's/600/5600/g' -e 's/660/5660/g' -e 's/1800/6000/g' "$DOTS/hypr/hypridle.conf"
sed -i -E 's/^([[:space:]]*)font_family([[:space:]]*=[[:space:]]*)?.*$/\1font_family = Monofur Nerd Font/' "$DOTS/hypr/hyprlock.conf"

### HYPR GUI configuration
echo 'env = AQ_DRM_DEVICES,/dev/dri/card1:/dev/dri/card2' >> "$HYPR/environments/nvidia.conf"
echo 'source = ~/.config/hypr/conf/animations/default.conf' > "$HYPR/animation.conf"
echo 'source = ~/.config/hypr/conf/decorations/no-rounding.conf' > "$HYPR/decoration.conf"
echo 'source = ~/.config/hypr/conf/environments/nvidia.conf' > "$HYPR/environment.conf"
echo 'source = ~/.config/hypr/conf/layouts/laptop.conf' > "$HYPR/layout.conf"
echo 'source = ~/.config/hypr/conf/monitors/1920x1080.conf' > "$HYPR/monitor.conf"
echo 'source = ~/.config/hypr/conf/windows/no-border.conf' > "$HYPR/window.conf"

### Screenshot
echo 'screenshot_folder="$HOME/Pictures/SC"' > "$DOTS/ml4w/settings/screenshot-folder.sh"
echo "swappy -f" > "$DOTS/ml4w/settings/screenshot-editor.sh" && echo "thunar" > "$DOTS/ml4w/settings/filemanager.sh"

### Matugen
rm -rf "$DOTS/matugen" &&  cp -r "$SRC/matugen" "$DOTS"

### Waybar
cp -r "$SRC/waybar/themes/lateralus" "$DOTS/waybar/themes/"
echo '/lateralus;/lateralus' > "$DOTS/ml4w/settings/waybar-theme.sh"
bash "$HOME/.config/waybar/launch.sh"

### ROFI in ml4w
echo '* { border-radius: 0em; }' > "$DOTS/ml4w/settings/rofi-border-radius.rasi"
echo '* { border-width: 0px; }' > "$DOTS/ml4w/settings/rofi-border.rasi"
echo '0' > "$DOTS/ml4w/settings/rofi_bordersize.sh"
echo 'configuration { font: "Monofur Nerd Font 12"; }' > "$DOTS/ml4w/settings/rofi-font.rasi"
rm -rf "$DOTS/rofi" ; cp -r "$SRC/rofi"

# ROFI in rofi
rm -rf "$DOTS/rofi" && cp -r "$SRC/rofi" "$DOTS"
find "$DOTS/rofi/" -type f -exec sed -i 's/Fira Sans 11/Monofur Nerd Font 12/g' {} +

### Wlogout
sed -i 's/Fira Sans Semibold/Monofur Nerd Font/g' "$DOTS/wlogout/style.css"

### Kitty
rm -rf "$DOTS/kitty" && cp -r "$SRC/kitty" "$DOTS" && echo 'kitty' > "$DOTS/ml4w/settings/terminal.sh"

### Fastfetch config
rm -rf "$DOTS/fastfetch" && cp -r "$SRC/fastfetch" "$DOTS"

### CAVA
mv "$HOME/.config/cava" "$DOTS" && ln -s "$DOTS/cava" "$HOME/.config"

### nVim
rm -rf "$DOTS/nvim" && cp -r "$SRC/nvim" "$DOTS"

