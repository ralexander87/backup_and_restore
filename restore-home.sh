#!/bin/bash

USB="/run/media/ralexander/netac"
SRV="$USB/Srv"
DIRS=(Documents Pictures Obsidian Working Shared VM dots)


#### Check for installed
set -u

ensure_pacman_packages() {
# Accept packages as arguments or fall back to a default list
  local pkgs=("$@")
  if ((${#pkgs[@]} == 0)); then
    pkgs=(rsync)
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
  rsync

for d in "${DIRS[@]}"; do
  rsync -Parh "$USB/home/$d" "$HOME" && cp -r "$SRV" "$HOME" && cp -r "$USB/dots" "$HOME" && cp "$USB/*.sh" "$HOME/dots"
done
sleep 5 ; clear

