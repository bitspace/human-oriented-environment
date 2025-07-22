#!/bin/bash
# Phase 2: Development Environment Setup
# For System76 Kudu6 Gentoo Build

set -e

echo "=== Phase 2: Development Environment Setup ==="
echo "Installing core development toolchains and setting up bleeding-edge development environment"
echo

# Check if Phase 1 was completed
if [ ! -f /etc/portage/package.use/development ]; then
    echo "Error: Phase 1 must be completed first (package.use files missing)"
    exit 1
fi

echo "Step 1: Updating system with new configuration..."
sudo emerge --sync
sudo emerge --ask --update --deep --newuse @world

echo
echo "Step 2: Installing core development toolchains..."

# Core build tools
echo "Installing core build tools..."
# Install LLVM first, then clang (clang depends on LLVM)
sudo emerge --ask sys-devel/gcc llvm-core/llvm dev-build/cmake dev-build/ninja

echo "Installing clang compiler..."
sudo emerge --ask llvm-core/clang

# Version control
echo "Installing version control systems..."
sudo emerge --ask dev-vcs/git dev-vcs/mercurial

# Programming languages
echo "Installing programming languages..."
sudo emerge --ask \
    dev-lang/rust \
    dev-java/openjdk:21 \
    dev-lang/go \
    dev-lang/perl \
    dev-lang/lua

# Install Node.js with npm support
echo "Installing Node.js with npm..."
sudo emerge --ask net-libs/nodejs

# Python development tools
echo "Installing Python development tools..."
sudo emerge --ask \
    dev-python/pip \
    dev-python/virtualenv \
    dev-python/pipx \
    dev-python/ipython \
    dev-python/black \
    dev-python/flake8

# Note: Python version management is handled via PYTHON_TARGETS in make.conf
echo "Python version management is configured in make.conf via PYTHON_TARGETS"
echo "Current system should be using Python 3.13 as configured in phase 1"

echo
echo "Step 3: Installing development utilities..."
sudo emerge --ask \
    app-editors/neovim \
    app-misc/tmux \
    sys-process/htop \
    sys-process/iotop \
    app-portage/gentoolkit \
    app-portage/eix \
    dev-debug/gdb \
    dev-debug/strace \
    dev-debug/ltrace

# Update eix database
sudo eix-sync

echo
echo "Step 4: Setting up overlays for bleeding-edge packages..."

# Install eselect-repository for overlay management
sudo emerge --ask app-eselect/eselect-repository

# Add useful overlays
echo "Adding gentoo-audio overlay for professional audio..."
sudo eselect repository enable audio-overlay

echo "Adding GURU overlay for additional packages..."
sudo eselect repository enable guru

# Sync overlays
sudo emerge --sync

echo
echo "Step 5: Installing essential development libraries..."
sudo emerge --ask \
    sys-libs/ncurses \
    sys-libs/readline \
    dev-libs/openssl \
    dev-libs/libffi \
    sys-apps/util-linux

echo
echo "Step 6: Setting up development environment..."

# Create development directory structure
mkdir -p ~/development/{projects,scripts,containers,ai-ml}
mkdir -p ~/.local/bin

# Add ~/.local/bin to PATH if not already present
if ! grep -q '~/.local/bin' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Set up Git configuration
echo "Setting up Git configuration..."
echo "Please enter your Git configuration:"
read -p "Git username: " git_username
read -p "Git email: " git_email

git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global pull.rebase false

echo
echo "Step 7: Installing Rust tools..."
# Install common Rust tools
cargo install ripgrep fd-find bat exa

echo
echo "Step 8: Setting up Python virtual environments..."
# Create virtual environments for different purposes
python3 -m venv ~/.venv/general
python3 -m venv ~/.venv/ai-ml
python3 -m venv ~/.venv/web-dev

echo "Virtual environments created:"
echo "  ~/.venv/general  - General Python development"
echo "  ~/.venv/ai-ml    - AI/ML development"
echo "  ~/.venv/web-dev  - Web development"

echo
echo "Step 9: Installing Node.js global packages..."
# Check if npm is available, if not skip this step
if command -v npm &> /dev/null; then
    echo "Installing useful Node.js global packages..."
    sudo npm install -g \
        typescript \
        @types/node \
        eslint \
        prettier \
        yarn
else
    echo "npm not found. You may need to:"
    echo "1. Restart your shell session to update PATH"
    echo "2. Install npm separately: emerge -a net-libs/nodejs[npm]"
    echo "3. Or install packages manually after completing setup"
fi

echo
echo "=== Phase 2 Complete! ==="
echo
echo "Development environment ready! Key tools installed:"
echo "✓ Core toolchains: GCC, Clang, Python 3.13, Rust, Java 21, Node.js, Go"
echo "✓ Development tools: Neovim, tmux, Git, debugging tools"
echo "✓ Package management: pip, cargo, npm, yarn"
echo "✓ Overlays: audio-overlay, GURU"
echo
echo "Next steps:"
echo "1. Source your ~/.bashrc: source ~/.bashrc"
echo "2. Activate Python virtual environment: source ~/.venv/general/bin/activate"
echo "3. Run phase3-specialized.sh for gaming, audio, AI/ML, and cloud tools"
echo
echo "Pro tips:"
echo "- Use 'eix <package>' for fast package searching"
echo "- Use 'equery' commands from gentoolkit for package info"
echo "- Check 'eselect' for setting defaults (java, python, etc.)"