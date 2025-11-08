#!/bin/bash

#!/usr/bin/env bash
# Edit /etc/default/grub to set:
# - GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash"
# - GRUB_TERMINAL_OUTPUT=gfxterm (uncomment/fix odd "console" line too)
# - GRUB_GFXMODE=1440x1080x32
# - GRUB_THEME="/boot/grub/themes/lateralus/theme.txt"
# Then rebuild the GRUB config.

set -euo pipefail

# Re-run as root if needed
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  exec sudo -p "[sudo] password for %u: " "$0" "$@"
fi

GRUB_DEFAULT_FILE="/etc/default/grub"
BACKUP="/etc/default/grub.bak.$(date +%Y%m%d-%H%M%S)"

if [[ ! -f "$GRUB_DEFAULT_FILE" ]]; then
  echo "Error: $GRUB_DEFAULT_FILE not found." >&2
  exit 1
fi

echo "Creating backup: $BACKUP"
cp -a "$GRUB_DEFAULT_FILE" "$BACKUP"

# Apply edits in-place
# Notes:
#  - Use | as sed delimiter to avoid escaping slashes in theme path
#  - ^#? matches commented or uncommented variants
#  - Also handle the odd '#GRUB_TERMINAL_OUTPUTconsole' line explicitly
sed -Ei \
  -e 's|^#?GRUB_CMDLINE_LINUX_DEFAULT=.*$|GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash"|' \
  -e 's|^#?GRUB_GFXMODE=.*$|GRUB_GFXMODE=1440x1080x32|' \
  -e 's|^#?GRUB_THEME=.*$|GRUB_THEME="/boot/grub/themes/lateralus/theme.txt"|' \
  -e 's|^#?GRUB_TERMINAL_OUTPUT=.*$|GRUB_TERMINAL_OUTPUT=gfxterm|' \
  -e 's|^#?GRUB_TERMINAL_OUTPUTconsole$|GRUB_TERMINAL_OUTPUT=gfxterm|' \
  "$GRUB_DEFAULT_FILE"

# Ensure GRUB_THEME exists if it wasn't present at all (append once)
if ! grep -Eq '^[#]?GRUB_THEME=' "$GRUB_DEFAULT_FILE"; then
  echo 'GRUB_THEME="/boot/grub/themes/lateralus/theme.txt"' >> "$GRUB_DEFAULT_FILE"
fi

echo "Updated $GRUB_DEFAULT_FILE"

# Rebuild grub configuration depending on distro
rebuild_grub() {
  if command -v update-grub >/dev/null 2>&1; then
    # Debian/Ubuntu
    update-grub
    return
  fi

  if command -v grub2-mkconfig >/dev/null 2>&1; then
    # RHEL/Fedora family
    # Try to resolve the correct target automatically
    local cfg=""
    if [[ -L /etc/grub2-efi.cfg ]]; then
      cfg="$(readlink -f /etc/grub2-efi.cfg)"
    elif [[ -L /etc/grub2.cfg ]]; then
      cfg="$(readlink -f /etc/grub2.cfg)"
    elif [[ -f /boot/grub2/grub.cfg ]]; then
      cfg="/boot/grub2/grub.cfg"
    elif [[ -d /boot/efi/EFI ]]; then
      # Fallback guess for EFI systems (vendor dir may vary)
      # This may not exist on every system, but is a reasonable default
      cfg="$(find /boot/efi/EFI -maxdepth 2 -type f -name grub.cfg 2>/dev/null | head -n1)"
    fi

    if [[ -n "$cfg" ]]; then
      grub2-mkconfig -o "$cfg"
      return
    fi
  fi

  echo "Warning: Could not automatically rebuild GRUB config. Please run the appropriate command for your system (e.g., 'update-grub' or 'grub2-mkconfig -o /boot/grub2/grub.cfg')." >&2
}

rebuild_grub

echo "Done."

