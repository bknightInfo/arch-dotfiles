#!/usr/bin/env bash

set -e

# --- Colors ---
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- UI ---
info() { echo -e "${BLUE}[BOOTSTRAP]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

#remove
info "Removing unwanted applications..."
sudo pacman -Rns btop htop firefox vim rofi waybar vlc gnome-text-editor

#Delete configs
rm ~/.mydotfiles/com.ml4w.dotfiles/.config/bashrc
rm ~/.mydotfiles/com.ml4w.dotfiles/.config/btop
rm ~/.mydotfiles/com.ml4w.dotfiles/.config/fish
rm ~/.mydotfiles/com.ml4w.dotfiles/.config/ohmyposh
rm ~/.mydotfiles/com.ml4w.dotfiles/.config/rofi
rm ~/.mydotfiles/com.ml4w.dotfiles/.config/waybar
rm ~/.mydotfiles/com.ml4w.dotfiles/.config/vim
rm ~/.mydotfiles/com.ml4w.dotfiles/.config/chromium-flags.conf
rm ~/.mydotfiles/com.ml4w.dotfiles/.config/edge-flags.conf
rm ~/.mydotfiles/com.ml4w.dotfiles/.config/zshrc
rm ~/.mydotfiles/com.ml4w.dotfiles/.config/kitty

#mydots
mkdir ~/.mydotfiles/dotfiles

#media
info "installing media application..."
sudo pacman -S --needed handbrake mpv celluloid qt5-base
git clone https://aur.archlinux.org/makemkv.git
cd makemkv
makepkg -si
cd ..
rm -rf makemkv
sudo modprobe sg

#misc
info "installing misc applications..."
sudo pacman -S --needed yazi ttf-nerd-fonts-symbols-mono
yay -S --needed onlyoffice-bin

#zsh
info "installing zsh config..."
sudo pacman -S --needed bat eza starship zoxide zsh
sudo chsh -s $(which zsh)
