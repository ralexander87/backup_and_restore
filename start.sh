#!/bin/bash

USB="/run/media/ralexander/netac" # Make sure that name is: netac
DOTS="$HOME/.mydotfiles/com.ml4w.dotfiles.stable/.config/"
DIRS=(Documents Pictures Obsidian Working Shared VM .icons .themes)
SRV="$USB/Srv"

mkdir -p $USB/{home,dots,Srv}
cp ~/Working/bash/*.sh "$USB"
chmod +x *.sh "$USB"
sleep 3

### Run bkp
set -e

for d in "${DIRS[@]}"; do
  rsync -Parh "$HOME/$d" "$USB/home"
done

sleep 3
rm -rf "$HOME/.ssh/agent"
rsync -Prah "$HOME/.ssh" "$SRV"
rsync -Parh "$DOTS" "$USB/dots/"

sleep 3
cp "$HOME/.config/com.ml4w.hyprlandsettings/hyprctl.json" "$USB/dots"
cp -r "$HOME/.local/share/icons/LyraX-cursors" "$USB/home"

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

sleep 2
mv "$USB/restore-serv.sh" "$USB/Srv" ; mv "$USB/restore-grub.sh" "$USB/Srv"
mv "$USB/restore-dots.sh" "$USB/dots" ; mv "$USB/restore-app.sh" "$USB/dots"
