#!/bin/bash

### Script who alos include `Home backup` script
# Var
USB="/run/media/ralexander/netac" # Make sure that name is: netac
SRV="$USB/Srv"
DOTS="$HOME/.mydotfiles/com.ml4w.dotfiles.stable/.config/"
DIRS=(Documents Pictures Obsidian Working Shared VM .icons .themes)

# Add `chmod +x` to bash directory
chmod +x *.sh "$HOME/Working/bash"

# Create, if not, 3 main directory to $USB
mkdir -p $USB/{home,dots,Srv}
sleep 2

### Run bkp
set -e

# rsync directories from `$DIRS` variable 
for d in "${DIRS[@]}"; do
  rsync -Parh "$HOME/$d" "$USB/home"
done

# Remove agent content from .ssh, and then rsync rest of content
# rsync ml4w dotfiles
sleep 2
rm -rf "$HOME/.ssh/agent"
rsync -Prah "$HOME/.ssh" "$SRV"
rsync -Parh "$DOTS" "$USB/dots/"

# Copy cursor pack and hyprctl settings
sleep 2
cp -r "$HOME/.local/share/icons/LyraX-cursors" "$USB/home"
cp "$HOME/.config/com.ml4w.hyprlandsettings/hyprctl.json" "$USB/dots"

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

# Separate restore scripts
cp ~/Working/bash/restore-home.sh "$USB"
cp ~/Working/bash/restore-dots.sh "$USB/dots"
cp ~/Working/bash/restore-grub.sh "$SRV"
cp ~/Working/bash/restore-serv.sh "$SRV"
sleep 2
