#!/bin/bash

set -euo pipefail

SRV="$HOME/Srv"
GRUB_DIR="/etc/default"
GRUB_FILE="$GRUB_DIR/grub"
GRUB_THEME_DIR="/boot/grub/themes"
THEME_NAME="lateralus"

info()       { echo -e "\033[1;34m[INFO]\033[0m ${1-}"; }
error_exit() { echo -e "\033[1;31m[ERROR]\033[0m ${1-}" >&2; exit 1; }

# must be root
[[ ${EUID} -eq 0 ]] || error_exit "Sudo ?!?"

# sanity checks
[[ -d "$SRV/$THEME_NAME" ]] || error_exit "Missing theme dir: $SRV/$THEME_NAME"
[[ -f "$GRUB_FILE" ]] || error_exit "Missing $GRUB_FILE"

# Copy GRUB theme
info "Copying GRUB theme..."
cp -r "$SRV/$THEME_NAME" "$GRUB_THEME_DIR"

# Modify GRUB config
info "Modifying GRUB config..."
sed -i \
  -e 's|^#\?GRUB_TERMINAL_OUTPUT=.*|GRUB_TERMINAL_OUTPUT=gfxterm|' \
  -e 's|^GRUB_GFXMODE=.*|GRUB_GFXMODE=1440x1080x32|' \
  -e 's|^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"|GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash"|' \
  -e "s|^#\?GRUB_THEME=.*|GRUB_THEME=\"$GRUB_THEME_DIR/$THEME_NAME/theme.txt\"|" \
  "$GRUB_FILE"

# Update GRUB
info "Updating GRUB..."
grub-mkconfig -o /boot/grub/grub.cfg
info "Done."

