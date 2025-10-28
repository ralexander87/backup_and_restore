#!/bin/bash
set -e  # Exit before you get fucked...

echo "------------------------------------------------------------------------------------"

# === SMTH, SMTH ===
TIMESTAMP=$(date '+%j-%Y-%R')
BKP_BASE="$HOME/Shared/ArchBKP"
BKP_FOLDER="$BKP_BASE/$TIMESTAMP"
BKP_TAR="$BKP_BASE/$TIMESTAMP.tar.xz"

mkdir -p "$BKP_FOLDER"
echo "Starting fucking BKP to: $BKP_FOLDER"

# === System files (with sudo) ===
declare -A SYSTEM_PATHS=(
    ["/boot/grub/themes/lateralus"]="$BKP_FOLDER"
    ["/etc/mkinitcpio.conf"]="$BKP_FOLDER/mkinitcpio.conf"
    ["/etc/default/grub"]="$BKP_FOLDER/grub"
    ["/usr/share/plymouth/plymouthd.defaults"]="$BKP_FOLDER/plymouthd.defaults"
    ["/etc/samba/smb.conf"]="$BKP_FOLDER/smb.conf"
    ["/etc/ssh/sshd_config"]="$BKP_FOLDER/sshd_config"
    ["/usr/lib/sddm/sddm.conf.d/default.conf"]="$BKP_FOLDER/dafault.conf"
)

for src in "${!SYSTEM_PATHS[@]}"; do
    echo "Backing up $src..."
    sudo rsync -a "$src" "${SYSTEM_PATHS[$src]}"
done

# === User files ===
USER_PATHS=(
    "$HOME/.mydotfiles/com.ml4w.dotfiles.stable/.config"
    "$HOME/.themes"
    "$HOME/.icons"
    "$HOME/.ssh"
    "$HOME/Working"
    "$HOME/Obsidian"
    "$HOME/Documents"
)

for path in "${USER_PATHS[@]}"; do
    echo "Backing up $path..."
    rsync -a "$path" "$BKP_FOLDER/"
done

# Install pigz if is not...
if ! command -v pigz >/dev/null 2>&1; then
  echo "pigz not found, installing..."
  if [[ $EUID -ne 0 ]]; then
    sudo pacman -S --noconfirm pigz
  else
    pacman -S --noconfirm pigz
  fi
else
  echo "pigz already installed, continuing..."
fi

# === Start bully the backup ===
echo "Compressing backup..."
tar -I pigz -cf "$BKP_TAR" -C "$BKP_BASE" "$TIMESTAMP"

echo "Bully complete."
echo "Uncompressed folder: $BKP_FOLDER"
echo "Compressed archive : $BKP_TAR"
echo "------------------------------------------------------------------------------------"

