#!/bin/bash

USB="/run/media/ralexander/netac" # Make sure that name is: netac

mkdir -p $USB/{home,dots,Srv}
cp -r ~/Working/bash/* $USB
chmod +x *.sh $USB

mv "$USB/restore-serv.sh" "$USB/Srv" ; mv "$USB/restore-grub.sh" "$USB/Srv"
mv "$USB/restore-dots.sh" "$USB/dots" ; mv "$USB/restore-app.sh" "$USB/dots"
mv "$USB/manual-ml4w.sh" "$USB/dots" ; mv "$USB/manual-ml4w.sh" "$USB/dots"

### Run bkp-home.sh

target="${USB}/bkp-home.sh"

# Is it here ?
if [[ ! -f "$target" ]]; then
  echo "Error: '$target' not found."
  exit 1
fi

# Ask for confirmation (default = No)
read -r -p "Run backup script at '$target'? [y/N] " reply
case "$reply" in
  [Yy]|[Yy][Ee][Ss])
    echo "Starting backup..."
    bash "$target"
    ;;
  *)
    echo "Aborted."
    ;;
esac
