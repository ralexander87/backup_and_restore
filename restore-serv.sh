#!/bin/bash

SRV="$HOME/Srv"

##### Services
set -u

ensure_pacman_packages() {
# PKG as arguments or fall back to a default list
  local pkgs=("$@")
  if ((${#pkgs[@]} == 0)); then
    pkgs=(rsync openssh avahi wsdd smbclient gvfs gvfs-smb cifs-utils)
  fi

# Use sudo if not root
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
      echo "• $pkg is not installed... Will install..."
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

##### Use it like this
ensure_pacman_packages \
  rsync openssh avahi wsdd smbclient gvfs gvfs-smb cifs-utils


##### SMB/SAMBA
sudo modprobe cifs
sudo cp "$SRV/smb.conf" "/etc/samba"
sudo systemctl enable wsdd.service smb.service avahi-daemon.service nmb.service && sudo systemctl start wsdd.service smb.service avahi-daemon.service nmb.service

##### SSH
rsync -Parh "$SRV/.ssh/" "$HOME/.ssh"
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
chmod 644 ~/.ssh/*.pub
chmod 600 ~/.ssh/config
sudo mv "/etc/ssh/sshd_config{,.bkp}" && sudo cp "$SRV/sshd_config" "/etc/ssh"
sudo systemctl enable sshd.service && sudo systemctl start sshd.service

