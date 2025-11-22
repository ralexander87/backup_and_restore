#!/bin/bash

SRV="$HOME/Srv"

### SMB/SAMBA
sudo modprobe cifs
sudo cp "$SRV/smb.conf" "/etc/samba"
sudo systemctl enable wsdd.service smb.service avahi-daemon.service nmb.service && sudo systemctl start wsdd.service smb.service avahi-daemon.service nmb.service

sudo mkdir -m 1750 /SMB
sudo mkdir /SMB/{euclid,pneuma,SCP}
sudo chown -R ralexander:ralexander /SMB
sudo smbpasswd -a ralexander

sleep 2
sudo systemctl restart wsdd.service smb.service avahi-daemon.service nmb.service

### SSH
sudo rsync -Prah "$SRV/.ssh" "$HOME"
sudo cp "$SRV/sshd_config" "/etc/ssh"
sudo systemctl enable sshd.service && sudo systemctl start sshd.service

