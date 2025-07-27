# Kimi K2 Instruct Response via FireworksAI Playground

## Model Parameters

- *Temperature*: 0.6
- *Max Tokens*: 4096
- *Top P*: 1
- *Top K*: 40
- *Presence Penalty*: 0
- *Frequency Penalty*: 0

## Model Response

Below is a concise “first-100-minutes” checklist that will leave you with a fully up-to-date, hardened, **~amd64/test-branch** system, ready for everything on your wish-list (IDEs, LLM tools, cloud SDKs, Steam, music production, etc.).  
Everything is split into **mandatory** (security, toolchain, portage hygiene) and **optional** (per-use-case) sections so you can stop whenever you like.

--------------------------------------------------------------------
1. Portage hygiene – put the system on the bleeding edge
--------------------------------------------------------------------
```
# /etc/portage/make.conf
ACCEPT_KEYWORDS="~amd64"
ACCEPT_LICENSE="*"
EMERGE_DEFAULT_OPTS="--keep-going --with-bdeps=y"
FEATURES="parallel-fetch parallel-install buildpkg"
VIDEO_CARDS="nvidia"           # or amdgpu/radeon if you have an AMD GPU
USE="${USE} systemd dbus elogind X wayland alsa pulseaudio jack"
```
Add a sane set of masks/unmasks for anything that is still keyword-masked:
```
mkdir -p /etc/portage/package.accept_keywords
echo "*/*::gentoo ~amd64" >> /etc/portage/package.accept_keywords/99-bleeding-edge
```

--------------------------------------------------------------------
2. Harden the base system (mandatory)
--------------------------------------------------------------------
```
emerge --sync
emerge -avuND @world

# Kernel hardening (if you built your own kernel)
echo "CONFIG_SECURITY_SELINUX=y" >> /etc/kernel/config.d/50-hardening.conf
emerge -v hardened-sources  # or keep your own .config
eselect kernel set … && genkernel --menuconfig --install all

# Mandatory packages
emerge app-portage/gentoolkit sys-apps/systemd-utils \
       sys-fs/e2fsprogs net-misc/openssh \
       app-admin/sudo app-editors/vim
```
If you use LUKS/dm-crypt, verify cryptsetup is present and keys are backed up.

--------------------------------------------------------------------
3. Daily-driver toolchain (mandatory)
--------------------------------------------------------------------
```
emerge -v dev-vcs/git app-portage/eix app-portage/gentoolkit \
        dev-util/ccache dev-util/icecream \
        sys-devel/clang sys-devel/lld \
        sys-apps/fakeroot dev-libs/openssl

# Rust nightly
eselect rust set stable  # or rustup default nightly
rustup component add rust-src clippy rustfmt
```

--------------------------------------------------------------------
4. Cloud SDKs & CLI helpers
--------------------------------------------------------------------
```
# GCP
emerge -av app-admin/google-cloud-sdk
# AWS
emerge -av dev-python/awscli sys-apps/aws-cli-v2
# Azure (not in main tree)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash  # or use pip
```

--------------------------------------------------------------------
5. Python ecosystem (AI/LLM focus)
--------------------------------------------------------------------
```
eselect python set python3.12
emerge -av dev-python/pipx dev-python/virtualenv dev-python/poetry \
        dev-python/pyenv dev-python/jupyter dev-python/ipython \
        dev-python/uv

pipx install aider-chat
pipx install ollama-cli
pipx install 'claude-code'
```

--------------------------------------------------------------------
6. IDEs & editors
--------------------------------------------------------------------
```
emerge -av app-editors/vscode dev-util/clion dev-util/intellij-idea-ultimate
# JetBrains ToolBox (if you prefer latest EAP builds)
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-*.tar.gz
```

--------------------------------------------------------------------
7. Steam / Proton / gaming
--------------------------------------------------------------------
```
# Enable ~amd64 for games too
echo "games-util/gamemode ~amd64" >> /etc/portage/package.accept_keywords/steam
emerge -av games-util/gamemode games-util/steam-launcher games-util/lutris
# GloriousEggroll Proton
mkdir -p ~/.steam/steam/compatibilitytools.d
cd ~/.steam/steam/compatibilitytools.d
curl -L https://github.com/GloriousEggroll/proton-ge-custom/releases/latest/download/proton-ge-custom.tar.gz | tar xzf -
```
Reboot into multi-user.target, log back in, start Steam once so it bootstraps itself.

--------------------------------------------------------------------
8. Music production (JACK & friends)
--------------------------------------------------------------------
```
emerge -av media-sound/jack2 media-sound/ardour media-sound/qsynth \
        media-sound/carla media-plugins/calf media-plugins/lv2 \
        media-sound/a2jmidid media-sound/alsa-utils media-sound/pulseaudio-jack
# Native Instruments – use the official installer under Wine
emerge -av app-emulation/wine-staging media-plugins/wineasio
```
Add your user to the **audio** and **realtime** groups:
```
gpasswd -a $USER audio
gpasswd -a $USER realtime
```
Create **/etc/security/limits.d/audio.conf**:
```
@audio - rtprio 95
@audio - memlock unlimited
```

--------------------------------------------------------------------
9. Final portage house-keeping
--------------------------------------------------------------------
```
emerge -avuDN @world
eclean-dist -d
eix-update
```

--------------------------------------------------------------------
10. Optional but useful dotfiles helpers
--------------------------------------------------------------------
```
emerge -av app-shells/fish app-shells/starship app-shells/zsh
eselect shell set fish   # or zsh
```

--------------------------------------------------------------------
Quick sanity check
--------------------------------------------------------------------
```
eix-installed -a | grep -iE "clang|rust|python|steam|jack|proton"
systemctl --user status pipewire || systemctl --user start pipewire
```
You should now have:
- bleeding-edge ~amd64 system  
- latest compilers (GCC 14, Clang 18, Rust nightly)  
- Steam + Proton-GE ready  
- cloud SDKs installed  
- Python/AI toolchain set up  
- JACK + Wine for Native Instruments  

From here you can install GNOME/KDE/Hyprland whenever you feel like it; the foundations are solid.
