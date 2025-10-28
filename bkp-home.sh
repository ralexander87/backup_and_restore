#!/bin/bash
set -e

FOOB="/run/media/ralexander/NC512/home"
BKP_FOLDER="$FOOB/Srv"
DIRS=(Documents Pictures Obsidian Working Shared VM)

for d in "${DIRS[@]}"; do
  rsync -Parh "$HOME/$d" "$FOOB"
done

rsync -Parh "$HOME/.mydotfiles/com.ml4w.dotfiles.stable/.config/" "$FOOB/dots/"
rsync -Prah "$HOME/.ssh" "$BKP_FOLDER"
cp ~/Working/bash/bkp-home.sh "$FOOB/dots"
cp ~/Working/bash/restore-home.sh "$FOOB"
cp ~/Working/bash/restore-zshrc.sh "$FOOB/dots"
cp ~/Working/bash/restore-dots.sh "$FOOB/dots"
cp ~/Working/bash/restore-serv.sh "$BKP_FOLDER"
cp ~/Working/bash/restore-serv.sh "$FOOB/Srv"

echo "Copy Done..."
sleep 5 ; clear

# === System files (with sudo) ===
declare -A SYSTEM_PATHS=(
  ["/boot/grub/themes/lateralus"]="$BKP_FOLDER"
  ["/etc/mkinitcpio.conf"]="$BKP_FOLDER/mkinitcpio.conf"
  ["/etc/default/grub"]="$BKP_FOLDER/grub"
  ["/usr/share/plymouth/plymouthd.defaults"]="$BKP_FOLDER/plymouthd.defaults"
  ["/etc/samba/smb.conf"]="$BKP_FOLDER/smb.conf"
  ["/etc/ssh/sshd_config"]="$BKP_FOLDER/sshd_config"
)

for src in "${!SYSTEM_PATHS[@]}"; do
  echo "Backing up $src..."
  sudo rsync -a "$src" "${SYSTEM_PATHS[$src]}"
done

