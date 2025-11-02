#!/bin/bash


### if git,curl,wget are installed, will skip
set -u
ensure_pacman_packages() {
# PKG as arguments or fall back to a default list
  local pkgs=("$@")
  if ((${#pkgs[@]} == 0)); then
    pkgs=(git curl wget)
  fi

### sudo if not root
  local SUDO=""
  if [[ $EUID -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
      SUDO="sudo"
    else
      echo "Need root (sudo missing)... Skipping installed..."
      return 1
    fi
  fi

  local missing=()
  echo "Checking installed packages..."
  for pkg in "${pkgs[@]}"; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
      echo "✓ $pkg is installed... Skipping..."
    else
      echo "• $pkg not installed... Will install..."
      missing+=("$pkg")
    fi
  done

  if ((${#missing[@]} == 0)); then
    echo "Already installed..."
    return 0
  fi

  echo "Installing missing: ${missing[*]}"
  if ! $SUDO pacman -S --needed --noconfirm "${missing[@]}"; then
    echo "Installation failed..."
    return 1
  fi

  echo "Package ensure step complete..."
  return 0
}

### Use it like this
ensure_pacman_packages \
  git curl wget
clear

### Install yay
## ml4w will autoinstall if not...
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

##### ML4W SETUP #####

flatpak install flathub com.ml4w.dotfilesinstaller

### run dotfileinstaller by hand
# flatpak run com.ml4w.dotfilesinstaller

### ml4w lastest release location
## it stay same all the time... i think
# https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/hyprland-dotfiles-stable.dotinst

### Delete flatpak app's not using...
flatpak uninstall -y com.github.PintaProject.Pinta && flatpak uninstall -y com.ml4w.calendar && sleep 5 && clear

