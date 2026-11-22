#!/bin/bash

# Script to set up greetd with true auto-login to Hyprland (no password prompt)
# Run with sudo privileges

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root (use sudo)"
    exit 1
fi

# Get current username
CURRENT_USER=$(logname)
if [ -z "$CURRENT_USER" ]; then
    CURRENT_USER=$(whoami)
fi

print_status "Setting up greetd with true auto-login to Hyprland for user: $CURRENT_USER"

# Check if Hyprland is installed
if ! pacman -Q hyprland &>/dev/null; then
    print_error "Hyprland is not installed. Please install it first:"
    print_error "sudo pacman -S hyprland"
    exit 1
fi

# Install greetd
print_status "Installing greetd..."
pacman -S --noconfirm greetd

# Create greetd configuration directory if it doesn't exist
mkdir -p /etc/greetd

# Create greetd configuration for direct auto-login (no greeter)
print_status "Creating direct auto-login configuration..."
cat > /etc/greetd/config.toml << EOF
[terminal]
# Use the first virtual terminal
vt = 1

[default_session]
# Direct command to start Hyprland without any greeter
command = "bash -c 'export XDG_SESSION_TYPE=wayland; export XDG_CURRENT_DESKTOP=Hyprland; exec uwsm start hyprland.desktop'"

# Run as the current user for auto-login
user = "$CURRENT_USER"

# Optional: Set session type
[env]
XDG_SESSION_TYPE = "wayland"
XDG_CURRENT_DESKTOP = "Hyprland"
EOF

# Alternative method using agreety (simple auto-login)
print_status "Also creating agreety configuration as backup..."
cat > /etc/greetd/agreety-config.toml << EOF
[terminal]
vt = 1

[default_session]
command = "agreety --autologin $CURRENT_USER --cmd Hyprland"
user = "greeter"
EOF

# Create the greeter user if it doesn't exist
if ! id "greeter" &>/dev/null; then
    print_status "Creating greeter user..."
    useradd -r -s /bin/false greeter
fi

# Set permissions for the greeter user
print_status "Setting permissions..."
chown -R greeter:greeter /etc/greetd

# Enable and start greetd service
print_status "Enabling and starting greetd service..."
systemctl enable greetd.service
systemctl start greetd.service

# Disable getty on tty1 to avoid conflicts
if systemctl is-active getty@tty1.service >/dev/null 2>&1; then
    print_status "Disabling getty on tty1 to avoid conflict..."
    systemctl disable getty@tty1.service
    systemctl stop getty@tty1.service
fi

# Create a custom session starter script
print_status "Creating custom session starter script..."
cat > /usr/local/bin/start-hyprland-session << 'EOF'
#!/bin/bash
# Start Hyprland session with proper environment variables

export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

exec uwsm start hyprland.desktop
EOF

chmod +x /usr/local/bin/start-hyprland-session

# Update the config to use the custom starter
print_status "Updating configuration to use custom session starter..."
cat > /etc/greetd/config.toml << EOF
[terminal]
vt = 1

[default_session]
command = "/usr/local/bin/start-hyprland-session"
user = "$CURRENT_USER"

[env]
XDG_SESSION_TYPE = "wayland"
XDG_CURRENT_DESKTOP = "Hyprland"
EOF

print_status "Configuration complete!"
print_status "True auto-login has been set up for user: $CURRENT_USER"
print_status "The system will now boot directly into Hyprland without any login prompts"
print_warning ""
print_warning "If you need to switch to a different TTY for maintenance:"
print_warning "  Press Ctrl+Alt+F2 to switch to TTY2"
print_warning "  Login normally and use commands"
print_warning "  Return to Hyprland with Ctrl+Alt+F1"
print_warning ""
print_status "To test the configuration, reboot your system:"
print_status "  sudo reboot"
