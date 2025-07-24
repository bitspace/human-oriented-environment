#!/bin/bash
# Phase 3: Specialized Workloads (Gaming, Audio, AI/ML, Cloud)
# For System76 Kudu6 Gentoo Build

set -e

echo "=== Phase 3: Specialized Workloads Setup ==="
echo "Installing gaming, audio production, AI/ML, and cloud development tools"
echo

# Check prerequisites
if [ ! -f /etc/portage/package.use/gaming ]; then
    echo "Error: Phase 1 must be completed first (package.use files missing)"
    exit 1
fi

echo "What would you like to install? (you can run multiple sections)"
echo "1) Gaming infrastructure"
echo "2) Professional audio"
echo "3) AI/ML stack"
echo "4) Cloud development tools"
echo "5) All of the above"
echo
read -p "Enter your choice (1-5): " choice

install_gaming() {
    echo
    echo "=== Installing Gaming Infrastructure ==="
    
    # Check GPU type
    echo "Detecting GPU..."
    if lspci | grep -i nvidia > /dev/null; then
        echo "NVIDIA GPU detected"
        VIDEO_CARD="nvidia"
    elif lspci | grep -i amd > /dev/null; then
        echo "AMD GPU detected"
        VIDEO_CARD="amdgpu"
    else
        echo "Intel or unknown GPU detected"
        VIDEO_CARD="intel"
    fi
    
    # Install GPU drivers
    echo "Installing GPU drivers for $VIDEO_CARD..."
    if [ "$VIDEO_CARD" = "nvidia" ]; then
        sudo emerge --ask x11-drivers/nvidia-drivers
        # Add nvidia modules to kernel
        echo "nvidia" | sudo tee -a /etc/modules-load.d/nvidia.conf
        echo "nvidia_modeset" | sudo tee -a /etc/modules-load.d/nvidia.conf
        echo "nvidia_uvm" | sudo tee -a /etc/modules-load.d/nvidia.conf
        echo "nvidia_drm" | sudo tee -a /etc/modules-load.d/nvidia.conf
    else
        sudo emerge --ask media-libs/mesa
    fi
    
    # Install Vulkan support
    echo "Installing Vulkan support..."
    sudo emerge --ask \
        media-libs/vulkan-loader \
        dev-util/vulkan-tools \
        dev-util/vulkan-headers
    
    # Install gaming platforms
    echo "Installing gaming platforms..."
    
    # Configure webkit-gtk build settings to avoid memory issues
    echo "Configuring webkit-gtk build settings..."
    sudo mkdir -p /etc/portage/package.env /etc/portage/env
    
    # Create multiple environment options for webkit-gtk
    cat | sudo tee /etc/portage/env/webkit-minimal.conf <<EOF
MAKEOPTS="-j2 -l2"
CFLAGS="\${CFLAGS} -pipe"
CXXFLAGS="\${CXXFLAGS} -pipe"
EOF
    
    # Try to use binary packages first, fallback to source with minimal settings
    echo "Attempting webkit-gtk installation with binary packages first..."
    if ! sudo emerge --getbinpkg --usepkg --ask net-libs/webkit-gtk; then
        echo "Binary package unavailable, configuring for minimal resource build..."
        # Reference the minimal environment file for webkit-gtk
        echo 'net-libs/webkit-gtk webkit-minimal.conf' | sudo tee /etc/portage/package.env/webkit
        
        # Also try disabling some features to reduce build complexity
        cat | sudo tee -a /etc/portage/package.use/webkit-reduced <<EOF
net-libs/webkit-gtk -gamepad -jpegxl -avif
EOF
        echo "Webkit-gtk configured for minimal build - this may take several hours."
    fi
    
    # Install non-Steam gaming tools first (without lutris if webkit-gtk problematic)
    echo "Installing core gaming packages..."
    sudo emerge --ask \
        app-emulation/wine-staging \
        app-emulation/winetricks \
        games-util/gamemode
    
    # Try to install lutris separately (requires webkit-gtk)
    echo "Attempting to install Lutris (requires webkit-gtk)..."
    if ! sudo emerge --ask games-util/lutris; then
        echo "WARNING: Lutris installation failed due to webkit-gtk build issues."
        echo "You can install it later after webkit-gtk is resolved, or use alternative gaming tools."
        echo "Consider using GameHub, Bottles, or directly using Wine for now."
    fi
    
    # Handle Steam installation (requires steam-overlay)
    echo
    echo "Installing Steam..."
    echo "Note: Steam requires the steam-overlay. Setting up..."
    
    # Install prerequisites for overlay management
    sudo emerge --ask --noreplace app-eselect/eselect-repository
    
    # Add and sync steam-overlay
    echo "Enabling steam-overlay repository..."
    if ! sudo eselect repository enable steam-overlay; then
        echo "Steam-overlay not available, trying to add it manually..."
        sudo eselect repository add steam-overlay git https://github.com/gentoo-mirror/steam-overlay.git
        sudo eselect repository enable steam-overlay
    fi
    
    echo "Syncing steam-overlay..."
    sudo emaint sync -r steam-overlay
    
    # Verify steam-overlay is available
    if [ ! -d "/var/db/repos/steam-overlay" ]; then
        echo "ERROR: Steam-overlay sync failed. Cannot install Steam."
        echo "You can install Steam manually later or use Flatpak version."
        return 1
    fi
    
    # Create license acceptance for Steam
    sudo mkdir -p /etc/portage/package.license
    echo "games-util/steam-launcher ValveSteamLicense" | sudo tee /etc/portage/package.license/steam
    
    # Configure USE flags for Steam dependencies
    sudo mkdir -p /etc/portage/package.use
    cat | sudo tee /etc/portage/package.use/steam <<EOF
# Steam dependencies require 32-bit ABI support
sys-libs/libudev-compat abi_x86_32
media-libs/libpulse abi_x86_32
x11-drivers/nvidia-drivers abi_x86_32
gui-libs/egl-gbm abi_x86_32
gui-libs/egl-wayland abi_x86_32
gui-libs/egl-x11 abi_x86_32
media-libs/libsndfile abi_x86_32
net-libs/libasyncns abi_x86_32
media-libs/opus abi_x86_32
media-sound/lame abi_x86_32
media-plugins/alsa-plugins pulseaudio abi_x86_32

# Additional audio/video libraries that may be needed
media-libs/alsa-lib abi_x86_32
media-libs/fontconfig abi_x86_32
media-libs/freetype abi_x86_32
x11-libs/libX11 abi_x86_32
x11-libs/libXext abi_x86_32
x11-libs/libXrandr abi_x86_32
x11-libs/libXinerama abi_x86_32
x11-libs/libXrender abi_x86_32
x11-libs/libXcomposite abi_x86_32
x11-libs/libXcursor abi_x86_32
x11-libs/libXdamage abi_x86_32
x11-libs/libXfixes abi_x86_32
x11-libs/libXi abi_x86_32
x11-libs/libXtst abi_x86_32
media-libs/mesa abi_x86_32
virtual/opengl abi_x86_32
EOF
    
    # Unmask required dependencies for Steam
    sudo mkdir -p /etc/portage/package.accept_keywords
    cat | sudo tee /etc/portage/package.accept_keywords/steam <<EOF
# Steam and its dependencies
games-util/steam-launcher ~amd64
games-util/game-device-udev-rules ~amd64
sys-libs/libudev-compat ~amd64
sys-fs/eudev ~amd64
sys-apps/hwids ~amd64
EOF

    # Handle eudev slot conflicts
    sudo mkdir -p /etc/portage/package.mask
    cat | sudo tee /etc/portage/package.mask/steam-conflicts <<EOF
# Mask conflicting eudev version for Steam
=sys-fs/eudev-3.2.14
EOF
    
    # Install Steam
    echo "Installing Steam launcher..."
    if ! sudo emerge --ask games-util/steam-launcher; then
        echo "WARNING: Steam installation failed."
        echo "You can try installing Steam via Flatpak as an alternative:"
        echo "  flatpak install flathub com.valvesoftware.Steam"
        echo "Or install it manually later after resolving dependencies."
    fi
    
    # Install gaming enhancements
    echo "Installing gaming enhancements..."
    sudo emerge --ask \
        media-libs/dxvk \
        media-libs/vkd3d-proton \
        games-util/antimicro
    
    # Add user to games group
    sudo usermod -a -G games $USER
    
    echo "✓ Gaming infrastructure installed"
    echo "  Next: Reboot, then run Steam and enable Proton in Steam settings"
}

install_audio() {
    echo
    echo "=== Installing Professional Audio ==="
    
    # Install PipeWire and audio infrastructure
    echo "Installing PipeWire audio system..."
    sudo emerge --ask \
        media-video/pipewire \
        media-sound/wireplumber \
        media-sound/pavucontrol \
        media-sound/jack2 \
        media-sound/qjackctl
    
    # Install audio production software
    echo "Installing audio production software..."
    sudo emerge --ask \
        media-sound/ardour \
        media-sound/audacity \
        media-sound/lmms \
        media-sound/guitarix \
        media-sound/fluidsynth \
        media-sound/qsynth
    
    # Install audio plugins
    echo "Installing audio plugins..."
    sudo emerge --ask \
        media-plugins/calf \
        media-plugins/swh-plugins \
        media-plugins/tap-plugins
    
    # Add user to audio groups
    sudo usermod -a -G audio,realtime $USER
    
    # Configure real-time privileges
    sudo tee /etc/security/limits.d/audio.conf <<EOF
@audio - rtprio 95
@audio - memlock unlimited
@realtime - rtprio 95
@realtime - memlock unlimited
EOF
    
    # Enable PipeWire services
    systemctl --user enable pipewire pipewire-pulse wireplumber
    
    echo "✓ Professional audio installed"
    echo "  Next: Reboot, then start audio services with 'systemctl --user start pipewire'"
}

install_ai_ml() {
    echo
    echo "=== Installing AI/ML Stack ==="
    
    # Check for CUDA support
    if [ "$VIDEO_CARD" = "nvidia" ]; then
        echo "Installing CUDA toolkit for NVIDIA..."
        sudo emerge --ask dev-util/nvidia-cuda-toolkit
    fi
    
    # Install core ML libraries (system level)
    echo "Installing system ML libraries..."
    sudo emerge --ask \
        sci-libs/openblas \
        sci-libs/lapack \
        dev-python/numpy \
        dev-python/scipy
    
    # Install Jupyter for interactive development
    echo "Installing Jupyter ecosystem..."
    sudo emerge --ask \
        dev-python/jupyterlab \
        dev-python/notebook \
        dev-python/ipykernel
    
    # Set up AI/ML Python environment
    echo "Setting up AI/ML Python environment..."
    source ~/.venv/ai-ml/bin/activate
    
    # Install core AI/ML packages
    pip install --upgrade pip
    pip install \
        torch torchvision torchaudio \
        tensorflow \
        transformers \
        huggingface-hub \
        openai \
        google-generativeai \
        anthropic \
        pandas \
        matplotlib \
        seaborn \
        scikit-learn \
        opencv-python
    
    # Install development tools
    pip install \
        jupyter \
        jupyterlab \
        ipython \
        black \
        flake8
    
    deactivate
    
    echo "✓ AI/ML stack installed"
    echo "  Activate with: source ~/.venv/ai-ml/bin/activate"
    echo "  Start Jupyter with: jupyter lab"
}

install_cloud() {
    echo
    echo "=== Installing Cloud Development Tools ==="
    
    # Install container platforms
    echo "Installing container platforms..."
    sudo emerge --ask \
        app-containers/docker \
        app-containers/docker-compose \
        app-containers/podman \
        app-containers/buildah
    
    # Install cloud CLI tools
    echo "Installing cloud CLI tools..."
    sudo emerge --ask \
        app-admin/awscli \
        sys-cluster/kubectl \
        sys-cluster/helm
    
    # Install Google Cloud SDK (often needs manual install)
    echo "Installing Google Cloud SDK..."
    if ! command -v gcloud &> /dev/null; then
        cd /tmp
        curl https://sdk.cloud.google.com | bash
        echo "Google Cloud SDK installed to ~/google-cloud-sdk"
        echo "Add to PATH: echo 'source ~/google-cloud-sdk/path.bash.inc' >> ~/.bashrc"
    fi
    
    # Install Azure CLI via pip
    echo "Installing Azure CLI..."
    pip3 install --user azure-cli
    
    # Install additional tools
    echo "Installing additional cloud tools..."
    sudo emerge --ask \
        app-admin/terraform \
        app-containers/skopeo \
        sys-cluster/minikube
    
    # Add user to docker group
    sudo usermod -a -G docker $USER
    
    # Enable Docker service
    sudo systemctl enable docker
    
    echo "✓ Cloud development tools installed"
    echo "  Next: Reboot to activate docker group membership"
    echo "  Configure cloud CLIs: aws configure, gcloud init, az login"
}

# Execute based on user choice
case $choice in
    1)
        install_gaming
        ;;
    2)
        install_audio
        ;;
    3)
        install_ai_ml
        ;;
    4)
        install_cloud
        ;;
    5)
        install_gaming
        install_audio
        install_ai_ml
        install_cloud
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo
echo "=== Phase 3 Section Complete! ==="
echo
echo "Important post-installation steps:"
echo "1. Reboot to activate all kernel modules and group memberships"
echo "2. For gaming: Test with 'vulkaninfo' and enable Proton in Steam"
echo "3. For audio: Start PipeWire services and test with qjackctl"
echo "4. For AI/ML: Activate venv and test with 'python -c \"import torch; print(torch.cuda.is_available())\"'"
echo "5. For cloud: Configure CLI tools and test Docker with 'docker run hello-world'"
echo
echo "Next phase: Install desktop environment (Wayland + sway)"
echo "Ready to proceed with GUI installation!"