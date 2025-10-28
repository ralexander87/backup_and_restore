#!/bin/bash

USB="/run/media/ralexander/NC512/home"
SRV="$USB/Srv"
DIRS=(Documents Pictures Obsidian Working Shared VM dots)

for d in "${DIRS[@]}"; do
  rsync -Parh "$USB/$d" "$HOME" && mv "$SRV" "$HOME"
done
sleep 5 ; clear



