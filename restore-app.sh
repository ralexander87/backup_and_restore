#!/bin/bash

flatpak uninstall -y com.github.PintaProject.Pinta && flatpak uninstall -y com.ml4w.calendar && sleep 5 && clear

# (optional) leave -e off so errors here don't kill the whole script
set -u

ensure_pacman_packages() {
# PKG as arguments or fall back to a default list
  local pkgs=("$@")
  if ((${#pkgs[@]} == 0)); then
    pkgs=(obsidian bitwarden veracrypt base eza 7zip unzip dosfstools exfat-utils gnome-disk-utility gnome-text-editor man-db man-pages gvfs-smb gvfs-wsdd ntfs-3g plymouth polkit smbclient gimp pigz cava swappy rsync)
  fi

### Use sudo if not root
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
  echo "Checking installed..."
  for pkg in "${pkgs[@]}"; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
      echo "✓ $pkg is installed. Skipping."
    else
      echo "• $pkg is not installed. Will install."
      missing+=("$pkg")
    fi
  done

  if ((${#missing[@]} == 0)); then
    echo "Already installed."
    return 0
  fi

  echo "Installing missing: ${missing[*]}"
  if ! $SUDO pacman -S --needed --noconfirm "${missing[@]}"; then
    echo "Installation failed."
    return 1
  fi

  echo "Package ensure step complete."
  return 0
}

### Use it like this
ensure_pacman_packages \
obsidian bitwarden veracrypt base eza 7zip unzip dosfstools exfat-utils gnome-disk-utility gnome-text-editor man-db man-pages gvfs-smb gvfs-wsdd ntfs-3g plymouth polkit smbclient gimp pigz cava swappy rsync
