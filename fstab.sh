#!/bin/bash

# Append CIFS mounts to /etc/fstab (idempotent), then optionally mount.
# Entries:
# 1) //192.168.8.40/pneumasmb -> /SMB/pneuma (uses /etc/samba/creds-laptop)
# 2) //192.168.8.60/e         -> /SMB/euclid (inline credentials)
# 3) //192.168.8.155/smb      -> /SMB/council (inline credentials)

set -euo pipefail

# Re-run as root if needed
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  exec sudo -p "[sudo] password for %u: " "$0" "$@"
fi

FSTAB="/etc/fstab"
BACKUP="/etc/fstab.bak.$(date +%Y%m%d-%H%M%S)"

[[ -f "$FSTAB" ]] || { echo "Error: $FSTAB not found." >&2; exit 1; }

echo "Backing up $FSTAB -> $BACKUP"
cp -a "$FSTAB" "$BACKUP"

# Ensure parent directory for mount points
mkdir -p /SMB/pneuma /SMB/euclid /SMB/council

# The entries to add (exact lines)
read -r -d '' ENTRY1_COMMENT <<'EOF'
# //<server_ip>/<share_name>   <mount_point>   cifs   <options>   0   0
EOF
read -r -d '' ENTRY1 <<'EOF'
//192.168.8.40/pneumasmb   /SMB/pneuma   cifs   username=pelican,password=fred321,iocharset=utf8,uid=1000,gid=1000,file_mode=0644,dir_mode=0755,nofail,x-systemd.automount   0   0
EOF

read -r -d '' ENTRY2_COMMENT <<'EOF'
# //<server_ip>/<share_name>   <mount_point>   cifs   <options>   0   0
EOF
read -r -d '' ENTRY2 <<'EOF'
//192.168.8.60/e   /SMB/euclid   cifs    _netdev,username=ralex,password=svetac128#!,uid=1000,gid=1000   0 0
EOF

read -r -d '' ENTRY3_COMMENT <<'EOF'
# //<server_ip>/<share_name>   <mount_point>   cifs   <options>   0   0
EOF
read -r -d '' ENTRY3 <<'EOF'
//192.168.8.155/smb   /SMB/council   cifs   username=ralex,password=supernova128#!,iocharset=utf8,uid=1000,gid=1000,file_mode=0644,dir_mode=0755,nofail,x-systemd.automount   0   0
EOF

append_if_missing() {
  local line="$1"
  local comment="$2"

  # If the exact fstab line already exists, skip
  if grep -Fxq "$line" "$FSTAB"; then
    echo "Already present: $line"
    return
  fi

  # Ensure fstab ends with a newline before appending
  if [[ -s "$FSTAB" ]] && [[ $(tail -c1 "$FSTAB" | wc -l) -eq 0 ]]; then
    echo >> "$FSTAB"
  fi

  printf "%s\n%s\n" "$comment" "$line" >> "$FSTAB"
  echo "Appended: $line"
}

append_if_missing "$ENTRY1" "$ENTRY1_COMMENT"
append_if_missing "$ENTRY2" "$ENTRY2_COMMENT"
append_if_missing "$ENTRY3" "$ENTRY3_COMMENT"

echo
echo "Done updating $FSTAB."
echo "Mount points ensured: /SMB/pneuma /SMB/euclid /SMB/council"
echo
echo "Next steps:"
echo "  - Make sure cifs-utils is installed (e.g., apt install cifs-utils or dnf install cifs-utils)."
echo "  - Verify /etc/samba/creds-laptop exists and is readable only by root (chmod 600)."
echo "  - Mount now with: sudo mount -a"


