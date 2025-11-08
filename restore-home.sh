#!/bin/bash

USB="/run/media/ralexander/netac"
DIRS=(Documents Pictures Obsidian Working Shared VM dots .icons .themes .ssh)

mkdir -p "$HOME/.local/share/icons"
 
for d in "${DIRS[@]}"; do
  rsync -Parh "$USB/home/$d" "$HOME"
  rsync -Prah "$USB/Srv" "$HOME" 
  rsync -Prah "$USB/dots" "$HOME"
  rsync -Prah "$USB/home/LyraX-cursors" "$HOME/.local/share/icons"
done
sleep 2 ; clear

