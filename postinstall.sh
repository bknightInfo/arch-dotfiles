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
sudo pacman -S --needed git base-devel wget unzip vulkan-radeon xorg-xwayland hyprland xdg-user-dirs uwsm stow

xdg-user-dirs-update

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

info "Remove unwanted applications from lucid shell..."
sudo pacman -Rns gnome-calculator kdeconnect upower xdg-user-dirs wf-recorder tesseract tesseract-data-eng songrec

info "move folders from .config to dots files location..."
mkdir -p ~/.local/share/dotfiles/{.config,.local,Pictures}

# --- move folders from .config to dots files ---
mv ~/.config/hypr ~/.local/share/dotfiles/.config
mv ~/.config/lucid ~/.local/share/dotfiles/.config

# --- move folders from .config to dots files ---
cp -fr mydots/fastfetch ~/.local/share/dotfiles/.config
cp -fr mydots/kitty ~/.local/share/dotfiles/.config
cp -fr mydots/zshrc ~/.local/share/dotfiles/.config

if [ -d "$HOME/.config/fastfetch" ]; then rm -rf "$HOME/.config/fastfetch"; fi
if [ -d "$HOME/.config/kitty" ]; then rm -rf "$HOME/.config/kitty"; fi
if [ -d "$HOME/.config/fish" ]; then rm -rf "$HOME/.config/fish"; fi
if [ -d "$HOME/.config/zshrc" ]; then rm -rf "$HOME/.config/zshrc"; fi

info "create symbolic links!..."
stow --adopt -d ~/.local/share/dotfiles/ -t ~/ .

cp -f custom/hypridle.conf ~/.local/share/dotfiles/.config/hypr/
cp -f custom/lucid-startup.lua ~/.local/share/dotfiles/.config/hypr/
cp -f custom/keybinds.json ~/.local/share/dotfiles/.config/lucid/
cp -f custom/keybinds.json ~/.local/share/dotfiles/.config/quickshell/lucidprefs/

./scripts/clean-dead-symlinks.sh --delete

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
sudo pacman -S --needed stow
paru -S --needed onlyoffice-bin

#zsh
info "installing zsh config..."
sudo pacman -S --needed bat eza zoxide zsh fnm
ln -s ~/.config/zshrc/.zshrc ~/.
sudo pacman -Rns fish
chsh -s /usr/bin/zsh

info "installing dev apps..."
sudo pacman -S --needed neovim yazi zed
paru -S --needed github-desktop-bin

#greetd
info "installing greet config..."
sudo ./scripts/greetd.sh
