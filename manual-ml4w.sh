#!/bin/bash

### Install yay
## ml4w will autoinstall if not...
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

##### ML4W SETUP #####

flatpak install flathub com.ml4w.dotfilesinstaller

### run dotfileinstaller by hand
# flatpak run com.ml4w.dotfilesinstaller

### ml4w lastest release location
## it stay same all the time... i think
# https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/hyprland-dotfiles-stable.dotinst

### Delete flatpak app's not using...
flatpak uninstall -y com.github.PintaProject.Pinta && flatpak uninstall -y com.ml4w.calendar && sleep 5 && clear

