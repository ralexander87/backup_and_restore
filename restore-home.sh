#!/bin/bash

FOOB="/run/media/ralexander/NC512/home"
BAR="$FOOB/Srv"
DIRS=(Documents Pictures Obsidian Working Shared VM dots)

for d in "${DIRS[@]}"; do
  rsync -Parh "$FOOB/$d" "$HOME" && mv "$BAR" "$HOME"
done
sleep 5 ; clear



