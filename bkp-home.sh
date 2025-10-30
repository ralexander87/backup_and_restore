#!/bin/bash

set -e
USB="/run/media/ralexander/netac" # Make sure that name is: netac
SRV="$USB/Srv"
DIRS=(Documents Pictures Obsidian Working Shared VM .icons .themes .ssh)
DOTS="$HOME/.mydotfiles/com.ml4w.dotfiles.stable/.config/"

for d in "${DIRS[@]}"; do
  rsync -Parh "$HOME/$d" "$USB/home"
done

rsync -Parh "$DOTS" "$USB/dots/"
rsync -Prah "$HOME/.ssh" "$SRV"
cp "$HOME/.config/com.ml4w.hyprlandsettings/hyprctl.json" "$USB"

echo "Copy Done..."
sleep 5 ; clear

### System files (with sudo)
declare -A SYSTEM_PATHS=(
  ["/boot/grub/themes/lateralus"]="$SRV"
  ["/etc/mkinitcpio.conf"]="$SRV/mkinitcpio.conf"
  ["/etc/default/grub"]="$SRV/grub"
  ["/usr/share/plymouth/plymouthd.defaults"]="$SRV/plymouthd.defaults"
  ["/etc/samba/smb.conf"]="$SRV/smb.conf"
  ["/etc/ssh/sshd_config"]="$SRV/sshd_config"
)

for src in "${!SYSTEM_PATHS[@]}"; do
  echo "Backing up $src..."
  sudo rsync -a "$src" "${SYSTEM_PATHS[$src]}"
done

