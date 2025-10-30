#!/bin/bash

USB="/run/media/ralexander/netac"
SRV="$USB/Srv"
GRUB="/etc/default/grub"
GRUB_THEME_DIR="/boot/grub/themes"

set -euo pipefail
# Functions. Fancy looking color shit... 
info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
error_exit() { echo -e "\033[1;31m[ERROR]\033[0m $1" >&2; exit 1; }

# Ensure script is run with zero fuck...
if [[ $EUID -ne 0 ]]; then
  error_exit "This script must be run as root (use sudo)."
fi

# Copy GRUB theme...
info "Copying GRUB theme..."
cp -r "$SRV/lateralus" "$GRUB_THEME_DIR"

# Modify GRUB config
info "Modifying GRUB config..."
sed -i \
  -e 's|^#GRUB_TERMINAL_OUTPUT=console|GRUB_TERMINAL_OUTPUT=gfxterm|' \
  -e 's|^GRUB_GFXMODE=auto|GRUB_GFXMODE=1440x1080x32|' \
  -e 's|^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"|GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash"|' \
  -e "s|^#GRUB_THEME=.*|GRUB_THEME=$GRUB_THEME_DIR/lateralus/theme.txt|" \
  "$GRUB"

# Update fucking GRUB
echo "Updating GRUB config..."
grub-mkconfig -o /boot/grub/grub.cfg
