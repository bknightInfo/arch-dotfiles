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

# Update system first
info "Updating system..."
sudo pacman -Syu --noconfirm

info "Install core applications"
sudo pacman -S --needed git base-devel neovim curl wget unzip fastfetch mesa vulkan-radeon libva-mesa-driver wayland wayland-protocols \
xorg-xwayland hyprland xdg-user-dirs xdg-desktop-portal xdg-desktop-portal-hyprland uwsm kitty vulkan-tools mesa-utils stow hypridle

info "Setting up AUR"
if ! command_exists paru; then
    info "Installing yay AUR helper..."
    git clone https://aur.archlinux.org/paru.git paru
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
    success "paru installed"
else
    warn "paru already installed"
fi

info "Install lucid shell..."
git clone https://github.com/Sn3akyy1/lucid.git && cd lucid && ./install.sh --no-apps --with-hypr --no-sddm

info "move folders from .config to dots files location..."
mkdir -p ~/.local/share/dotfiles/{.config,.local,Pictures}

# --- move folders from .config to dots files ---
mv ~/.config/hypr ~/.local/share/dotfiles/.config
mv ~/.config/lucid ~/.local/share/dotfiles/.config

# --- move folders from .config to dots files ---
cp -r mydots/fastfetch ~/.local/share/dotfiles/.config
cp -r mydots/kitty ~/.local/share/dotfiles/.config
cp -r mydots/zshrc ~/.local/share/dotfiles/.config

if [ -d ".config/fastfetch" ]; then rm -rf ".config/fastfetch"; fi
if [ -d ".config/kitty" ]; then rm -rf ".config/kitty"; fi
if [ -d ".config/fish" ]; then rm -rf ".config/fish"; fi
if [ -d ".config/zshrc" ]; then rm -rf ".config/zshrc"; fi

cp -f custom/hypridle.conf ~/.local/share/dotfiles/.config/hypr/
cp -f custom/lucid-startup.lua ~/.local/share/dotfiles/.config/hypr/
cp -f custom/keybinds.json ~/.local/share/dotfiles/.config/lucid/

info "create symbolic links!..."
stow --adopt -d ~/.local/share/dotfiles/ -t ~/ .

./scripts/clean-dead-symlinks.sh --delete

rm  ~/.zshrc
ln -s ~/.mydotfiles/dotfiles/kitty ~/.config/
ln -s ~/.mydotfiles/dotfiles/zshrc/.zshrc ~/.

#media
info "installing media application..."
sudo pacman -S --needed handbrake mpv celluloid qt5-wayland
git clone https://aur.archlinux.org/makemkv.git
cd makemkv
makepkg -si
cd ..
rm -rf makemkv
sudo modprobe sg

#misc
info "installing misc applications..."
sudo pacman -S --needed yazi
paru -S --needed onlyoffice-bin

#zsh
info "installing zsh config..."
sudo pacman -S --needed bat eza zoxide zsh fnm
sudo pacman -Rns fish
sudo chsh -s $(which zsh)

#greetd
info "installing greet config..."
sudo ./scripts/greetd.sh
