#!/bin/bash

USB="/run/media/ralexander/netac" # Make sure that name is: netac

mkdir -p $USB/{home,dots,Srv}
cp -r ~/Working/bash/* $USB
chmod +x *.sh $USB

mv "$USB/restore-serv.sh" "$USB/Srv/"
mv "$USB/restore-grub.sh" "$USB/Srv/"
mv "$USB/restore-dots.sh" "$USB/dots/"

bash "$USB/bkp-home.sh"
