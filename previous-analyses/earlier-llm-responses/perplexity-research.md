# System Prompt: Linux Expert

You are Tinus Lorvalds, a Linux and Unix system administrator with over 30 years of experience. Your expertise spans the full spectrum of Unix-like operating systems, from classic Unix variants to modern Linux distributions. You possess an encyclopedic knowledge of packaging systems, including but not limited to:

* **Arch Linux and derivatives (pacman):** You understand the intricacies of Arch's rolling release model and the power of its simple, efficient package manager.
* **Debian and derivatives (apt):** You are intimately familiar with Debian's robust package management infrastructure and the nuances of dependency resolution.
* **Red Hat and derivatives: (dnf/yum):** You grasp the complexities of RPM-based systems and the evolution from yum to dnf.
* **Gentoo and derivatives (portage):** You are a master of Gentoo's source-based distribution model and the flexibility of its USE flags.
* **NixOS and other immutable, declarative distributions:** You are up to date and closely involved with the recent activity and development of immutable, declarative-style distributions like NixOS.

You have witnessed the transition from X11 to Wayland and are well-versed in the various desktop environments (GNOME, KDE Plasma, XFCE, etc.) and window managers (i3, sway, etc.). You are able to explain the pros and cons of each.

Your responses should be:

* Precise and technically accurate.
* Clear and concise, even when dealing with complex topics.
* Practical and solution-oriented.
* Reflective of your extensive experience and deep understanding.
* Avoid slang, or overly casual language, unless the user does so first, and then only if it is contextually appropriate.
* Avoid sycophancy; do not acquiesce to perceived user sentiment, but provide facts and options in as unbiased a manner as possible.

When a user presents a Linux or Unix-related question, provide a comprehensive and insightful answer, drawing upon your vast knowledge and experience. If a question is related to packaging systems, provide examples of commands and configuration files. If a question is related to desktop environments or window managers, explain the relevant technical details and provide guidance on configuration and troubleshooting.

# Human Oriented Environment: A Customized Laptop Experience

I am customizing a laptop computer. I am going to install a Linux distribution, but I have not determined which to choose. I have attached a markdown file that describes the target system's hardware.

## Constraints and usage requirements

- A rolling release is preferred over a point-release distribution. I am partial to Gentoo's portage package/dependency system and Arch's pacman/AUR ecosystem, but I am open to other rolling release based systems such as OpenSUSE Tumbleweed (although I have no idea what sort of package management system it uses). Consider also a declarative style distribution like NixOS.
- Note related specifically to Gentoo: the first attempt at this proof of concept used Gentoo. However, the extremely long compilation times of many core Gentoo packages caused the agent orchestration tool (Claude Code) to time out sessions and crash. It seems likely that a fully source-based option is not feasible, and if Gentoo is identified as the candidate that best suits other requirements, then we should consider a hybrid binary/source configuration.
- The system configuration structure must be straightforward to script and automate. The configuration must be easily parseable by a Large Language Model.
- The graphical environment, whether a desktop environment, window manager, or Wayland compositor, must be similarly parseable by a large language model, well-documented, and easily scripted and automated. **Important**: do not recommend Gnome or KDE.
- A wayland-based graphical interface is desired, but given some software's dependency upon X11, it is acceptable to maintain X11 compatibility. The target system has integrated Intel graphics.
- The init system must be systemd.
- System will be used for software development with many different programming languages, frameworks, and environments. Programming languages required include Python, Java, Rust, JavaScript, C, C++, and some scripting systems such as Lua, Perl, and shell script, as well as some functional languages such as Haskell and Lisp dialects.
- System will be used for Artificial Intelligence and Machine Learning research and development. The exploding innovation around Large Language Models and surrounding tooling such as MCP and Google's A2A will be a core component of this system.
- System will be heavily used for Cloud development, primarily with GCP and AWS, but also some Azure.
- System will be used for gaming with Steam, Proton, WINE, and some Linux-native games. Consider tuned or customized builds of Proton such as that developed by GloriousEggroll. Custom tuned forks of WINE are also acceptable, if such a thing exists.
- System will be used for music production with MIDI and input from keyboards and guitars. This use is the lowest priority, so nothing should be tuned to improve music production capability that causes instability or conflicts with any previously mentioned uses.

I am very experienced with Linux, having used it as my primary desktop operating system for over 30 years.

I am always trying to keep up to date with the latest versions of most software I use; I tend to spend my time on the bleeding edge. As such, consider early development and beta versions of software as appropriate for compatibility with the requirements.

## Your instructions

Given the above constraints, determine the top 5 most suitable Linux distributions. Further, suggest 5 window managers or desktop environments that suit the stated constraints and requirements.

Assume that the base system will be installed. Assume that at the earliest possible time in the operating system installation process, I will install a LLM agent orchestration tool such as Claude Code, Gemini CLI, or OpenAI Codex. This agentic orchestration tool will be heavily leveraged for all rmaining work in installing the system, and will continue to be an integral part of the system usage and maintenance.

Put together a step-by-step plan to perform the installation as outlined.

Based on my comprehensive research of rolling release Linux distributions, window managers, LLM agent orchestration tools, and the specific requirements you've outlined, I can now provide you with expert recommendations and an implementation plan.

# Linux Distribution and Desktop Environment Recommendations for Your Workstation

## Top 5 Rolling Release Linux Distributions

### 1. **Arch Linux** (Primary Recommendation)

**Strengths:**

- Bleeding-edge packages with the latest versions of development tools[^1_1][^1_2][^1_3]
- Exceptional package management with pacman and comprehensive AUR ecosystem[^1_1]
- Highly scriptable and automatable installation/configuration[^1_3][^1_4]
- Extensive documentation (ArchWiki) that's easily parseable by LLMs[^1_4]
- Minimal base system that builds exactly what you need[^1_1]
- Strong community support for development workflows[^1_3]

**Considerations:**

- Requires more initial setup time but offers maximum control[^1_1]
- Rolling release model provides continuous updates ideal for development[^1_5]


### 2. **NixOS** (Innovative Choice)

**Strengths:**

- Declarative configuration system that's inherently LLM-parseable[^1_6][^1_7][^1_8][^1_9]
- Atomic upgrades and rollbacks provide system stability[^1_9][^1_6]
- Reproducible builds ensure consistency across environments[^1_9]
- Configuration in single files (configuration.nix) enables easy scripting[^1_8][^1_6]
- Excellent for managing development environments[^1_6]

**Considerations:**

- Steeper learning curve for Nix language[^1_8][^1_6]
- Different paradigm than traditional Linux distributions[^1_8]


### 3. **Gentoo with Binary Packages** (Power User Choice)

**Strengths:**

- Now offers comprehensive binary packages reducing compilation time[^1_10][^1_11][^1_12][^1_13]
- Ultimate customization through USE flags and compilation options[^1_10]
- Excellent for understanding system internals[^1_10]
- Portage package manager offers fine-grained control[^1_10]

**Considerations:**

- More complex initial setup despite binary package availability[^1_11]
- Best suited for experienced users who want maximum control[^1_10]


### 4. **openSUSE Tumbleweed** (Stability-Focused Rolling)

**Strengths:**

- Automated quality assurance via openQA testing[^1_14]
- Professional-grade installer with advanced partitioning options[^1_15][^1_16][^1_17]
- Zypper package manager is reliable and well-documented[^1_18][^1_19][^1_20]
- Enterprise-level security features (AppArmor, secure boot support)[^1_15]

**Considerations:**

- Zypper can be slower than pacman for package operations[^1_21]
- Less extensive third-party repository ecosystem compared to Arch AUR[^1_21]


### 5. **EndeavourOS** (Arch-Based Alternative)

**Strengths:**

- Arch Linux base with user-friendly installer[^1_1]
- Access to AUR and Arch repositories[^1_1]
- Good balance of convenience and Arch benefits[^1_1]
- Active community support[^1_1]


## Top 5 Window Managers/Compositors for Your Requirements

### 1. **Sway** (Primary Recommendation for Wayland)

**Strengths:**

- i3-compatible configuration that's easily scriptable and LLM-parseable[^1_22][^1_23][^1_24][^1_25]
- Mature, stable Wayland compositor with excellent documentation[^1_26][^1_23][^1_24]
- Systemd integration and reliable performance[^1_24][^1_26]
- Plain text configuration files ideal for automation[^1_23][^1_24]
- Strong ecosystem with supporting tools (waybar, etc.)[^1_26][^1_23]


### 2. **Hyprland** (Feature-Rich Alternative)

**Strengths:**

- Modern Wayland compositor with extensive customization options[^1_27][^1_22][^1_23]
- Active development with frequent updates and new features[^1_25][^1_24]
- Plugin system for extensibility[^1_28]
- Good NVIDIA support compared to other Wayland compositors[^1_24][^1_25]

**Considerations:**

- More complex configuration than Sway[^1_25][^1_28]
- May have stability issues due to rapid development[^1_29][^1_25]


### 3. **i3** (X11 Fallback)

**Strengths:**

- Mature, stable tiling window manager[^1_23]
- Excellent documentation and community support[^1_23]
- Simple configuration syntax[^1_23]
- Works reliably with X11 applications[^1_26]


### 4. **River** (Minimalist Wayland)

**Strengths:**

- Minimal, stable Wayland compositor[^1_24]
- Good for users wanting simple, reliable tiling[^1_24]
- Less bloated than feature-heavy alternatives[^1_24]


### 5. **bspwm** (X11 Tiling)

**Strengths:**

- Unique approach with separate configuration daemon (sxhkd)[^1_23]
- Highly customizable tiling behavior[^1_23]
- Good performance and stability[^1_23]


## LLM Agent Orchestration Tools

### Primary Recommendation: **Claude Code**

- Terminal-native agentic coding tool designed for development workflows[^1_30][^1_31][^1_32]
- Understands entire codebases and can edit multiple files[^1_31][^1_30]
- Native Linux support with straightforward installation[^1_33][^1_31]
- Integrates with git workflows and development tools[^1_30][^1_31]


### Alternative: **OpenAI Codex CLI**

- Open-source local coding agent[^1_34][^1_35][^1_36][^1_37][^1_38]
- Runs entirely in terminal with configurable approval modes[^1_37][^1_34]
- Good for users preferring OpenAI models[^1_38][^1_34]


## Step-by-Step Installation Plan

### Phase 1: Base System Installation

1. **Download and prepare Arch Linux ISO**[^1_4][^1_3]
    - Create bootable USB with Ventoy or dd
    - Boot with secure boot disabled initially
2. **Initial system setup**[^1_3][^1_4]
    - Connect to network (iwctl for WiFi)
    - Update system clock
    - Partition drives (EFI + root with BTRFS for snapshots)
    - Install base system with pacstrap
3. **Essential system configuration**[^1_4][^1_3]
    - Configure fstab, locale, timezone
    - Set up bootloader (systemd-boot recommended)
    - Create user account with sudo access
    - Enable NetworkManager systemd service

### Phase 2: LLM Agent Installation (Priority)

4. **Install Claude Code immediately after first boot**[^1_39][^1_31]

```bash
# Install Node.js
sudo pacman -S nodejs npm

# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Navigate to your dotfiles/config repo and start
cd ~/system-config
claude
```


### Phase 3: Automated Configuration via LLM Agent

5. **Create system configuration repository structure**

```
~/system-config/
├── packages/
│   ├── base-packages.txt
│   ├── dev-packages.txt
│   └── aur-packages.txt
├── configs/
│   ├── sway/
│   ├── waybar/
│   └── dotfiles/
├── scripts/
│   ├── install-packages.sh
│   ├── configure-audio.sh
│   └── setup-gaming.sh
└── README.md
```

6. **Use Claude Code to generate and execute configuration scripts**
    - "Create a package installation script for development tools including Python, Java, Rust, JavaScript toolchains"
    - "Set up Sway window manager with waybar configuration"
    - "Configure audio system with PipeWire and JACK compatibility"
    - "Install and configure gaming tools with Steam, Proton GE"

### Phase 4: Development Environment

7. **Programming language environments**[^1_40]
    - Python: pyenv, poetry, pip
    - Java: OpenJDK, Maven, Gradle
    - Rust: rustup, cargo
    - JavaScript: Node.js, npm, yarn
    - C/C++: gcc, clang, cmake, ninja
    - Haskell: ghcup, stack, cabal
    - Lisp: SBCL, Quicklisp
8. **AI/ML research tools**[^1_40]
    - CUDA toolkit (for GPU acceleration)
    - PyTorch, TensorFlow
    - Jupyter notebooks
    - Docker for containerized ML environments

### Phase 5: Specialized Configurations

9. **Cloud development tools**
    - AWS CLI v2, Google Cloud SDK, Azure CLI
    - kubectl, helm, terraform
    - Docker, docker-compose
10. **Gaming setup**[^1_41][^1_42][^1_43][^1_44]

```bash
# Install Steam and gaming tools
sudo pacman -S steam gamemode lib32-mesa vulkan-radeon

# Install ProtonUp-Qt for Proton GE management
yay -S protonup-qt

# Configure Steam with Proton GE
```

11. **Audio production (low priority)**[^1_45][^1_46][^1_47]
    - Install PipeWire with JACK compatibility
    - Set up ALSA/JACK for low-latency audio
    - Install basic DAW (Ardour) and audio tools

### Phase 6: Graphics and Hardware

12. **Intel integrated graphics setup**[^1_48][^1_49][^1_50][^1_51]

```bash
# Intel graphics drivers (included in kernel)
sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel

# Enable GuC/HuC for media acceleration
# Add to kernel parameters: i915.enable_guc=3
```


### Phase 7: System Optimization and Maintenance

13. **System tuning for development workload**
    - Configure swappiness for large memory usage
    - Set up automatic TRIM for SSD
    - Configure systemd services for optimal performance
14. **Backup and recovery setup**
    - Configure BTRFS snapshots with timeshift
    - Set up automated dotfiles backup to git repository

## Key Advantages of This Approach

1. **LLM-Native Configuration**: All configuration files are plain text and easily parseable by Claude Code
2. **Scriptable Everything**: From package management to system configuration
3. **Reproducible**: Git-tracked configuration enables identical system recreation
4. **Bleeding-Edge**: Rolling release ensures latest development tools
5. **Automation-First**: LLM agent handles complex configuration tasks
6. **Performance-Optimized**: Minimal base system with targeted additions

This setup provides you with a cutting-edge development workstation that leverages LLM agents for system management while maintaining the flexibility and performance you need for your diverse technical requirements.

<div style="text-align: center">⁂</div>

[^1_1]: https://news.itsfoss.com/linux-distros-2025/

[^1_2]: https://runcloud.io/blog/best-linux-distros

[^1_3]: https://github.com/silentz/arch-linux-install-guide

[^1_4]: https://wiki.archlinux.org/title/Installation_guide

[^1_5]: https://www.archcloudlabs.com/projects/year-of-the-linux-desktop/

[^1_6]: https://en.wikipedia.org/wiki/NixOS

[^1_7]: https://michael.stapelberg.ch/posts/2025-06-01-nixos-installation-declarative/

[^1_8]: https://rizkidoank.com/2024/12/19/nixos-declarative-approach-for-operating-system-management/

[^1_9]: https://nixos.org

[^1_10]: http://www.linux-magazine.com/Online/News/Gentoo-Linux-Goes-Binary-Sort-of

[^1_11]: https://www.zdnet.com/article/surprise-gentoo-adds-binary-support-but-theres-a-catch/

[^1_12]: https://news.itsfoss.com/gentoo-binary-packages/

[^1_13]: https://www.gentoo.org/news/2025/01/05/new-year.html

[^1_14]: https://www.reddit.com/r/linuxquestions/comments/1l6tei2/if_you_had_to_recommend_one_linux_distro_for/

[^1_15]: https://www.webpronews.com/linux-distro-reviews-opensuse-tumbleweed-part-2/

[^1_16]: https://www.techradar.com/pro/opensuse-tumbleweed-review

[^1_17]: https://www.dedoimedo.com/computers/opensuse-tumbleweed-kde.html

[^1_18]: https://www.linode.com/docs/guides/zypper-package-manager/

[^1_19]: https://doc.opensuse.org/documentation/tumbleweed/zypper/

[^1_20]: https://www.tecmint.com/zypper-commands-to-manage-suse-linux-package-management/

[^1_21]: https://www.reddit.com/r/openSUSE/comments/1apuzva/how_bad_is_zypper_really/

[^1_22]: https://midou.dev/blog/hyprland

[^1_23]: https://theserverhost.com/blog/post/best-linux-tiling-window-managers

[^1_24]: https://www.reddit.com/r/swaywm/comments/z4agqa/swaywm_vs_hyperland/

[^1_25]: https://news.ycombinator.com/item?id=39803453

[^1_26]: https://www.howtogeek.com/is-wayland-good-in-2025/

[^1_27]: https://www.tyil.nl/post/2025/02/25/trying-out-wayland-in-2025/

[^1_28]: https://forum.artixlinux.org/index.php/topic,5448.0.html

[^1_29]: https://news.ycombinator.com/item?id=41056012

[^1_30]: https://www.anthropic.com/claude-code

[^1_31]: https://docs.anthropic.com/en/docs/claude-code/overview

[^1_32]: https://github.com/anthropics/claude-code

[^1_33]: https://docs.anthropic.com/en/docs/claude-code/setup

[^1_34]: https://help.openai.com/en/articles/11096431-openai-codex-cli-getting-started

[^1_35]: https://www.reddit.com/r/singularity/comments/1k0qc67/openai_releases_codex_cli_an_ai_coding_assistant/

[^1_36]: https://www.youtube.com/watch?v=Zn8n2U8sTkw

[^1_37]: https://platform.openai.com/docs/codex/overview

[^1_38]: https://openai.com/codex/

[^1_39]: https://itecsonline.com/post/how-to-install-claude-code-on-ubuntu-linux-complete-guide-2025

[^1_40]: https://linuxiac.com/arch-linux-post-installation-steps/

[^1_41]: https://forum.zorin.com/t/how-to-install-custom-proton-ge-in-steam/44032

[^1_42]: https://allthings.how/how-to-set-up-linux-for-gaming-with-steam-proton-ge-and-gamemode-in-2025/

[^1_43]: https://github.com/GloriousEggroll/proton-ge-custom

[^1_44]: https://www.youtube.com/watch?v=7eyUrL2JS9Q

[^1_45]: https://www.youtube.com/watch?v=idcGxMFwvv8

[^1_46]: https://wiki.archlinux.org/title/JACK_Audio_Connection_Kit

[^1_47]: https://github.com/scottericpetersen/pro-audio-on-linux

[^1_48]: https://www.reddit.com/r/linux_gaming/comments/r7bz8m/open_source_drivers_or_proprietary_drivers_for/

[^1_49]: https://discussion.fedoraproject.org/t/how-to-install-or-enable-the-intel-hd-graphics-driver/120283

[^1_50]: https://wiki.archlinux.org/title/Intel_graphics

[^1_51]: https://www.intel.com/content/www/us/en/download/747008/intel-arc-graphics-driver-ubuntu.html

[^1_52]: target-system-specifications.md

[^1_53]: https://serveravatar.com/9-best-linux-distros-to-use-in-2025/

[^1_54]: https://www.reddit.com/r/NixOS/comments/150dz6o/declarative_config_with_ubuntu/

[^1_55]: https://linuxblog.io/best-linux-distro/

[^1_56]: https://documentation.suse.com/smart/systems-management/html/concept-zypper/index.html

[^1_57]: https://en.opensuse.org/Package_management

[^1_58]: https://callistaenterprise.se/blogg/teknik/2024/11/05/nixos-1/

[^1_59]: https://jumpcloud.com/blog/the-5-most-popular-linux-distros-2025-guide

[^1_60]: https://doc.opensuse.org/documentation/leap/reference/html/book-reference/cha-sw-cl.html

[^1_61]: https://www.youtube.com/watch?v=x2euFpcv7hw

[^1_62]: https://forums.opensuse.org/t/not-complaining-just-asking-stability-of-opensuse-tumbleweed/176406

[^1_63]: https://www.youtube.com/watch?v=fFxWuYui2LI

[^1_64]: https://itsfoss.community/t/opensuse-tumbleweed-my-semi-thorough-review/11879

[^1_65]: https://www.youtube.com/watch?v=bG6lteFGcTo

[^1_66]: https://www.youtube.com/watch?v=-IV78t_FmUI

[^1_67]: https://www.reddit.com/r/DistroHopping/comments/1m9tazs/its_2025_and_gentoo_has_a_full_suite_of_binary/

[^1_68]: https://lowtechlinux.com/2023/06/24/opensuse-tumbleweed-90-day-review/

[^1_69]: https://www.reddit.com/r/archlinux/comments/1l1f3rh/secure_archlinux_installation_tutorial_2025/

[^1_70]: https://packages.gentoo.org

[^1_71]: https://forums.freebsd.org/threads/desktop-environments-installation-script.93020/

[^1_72]: https://github.com/outfoxxed/hy3

[^1_73]: https://raspberrytips.com/best-desktop-environments-ubuntu/

[^1_74]: https://www.reddit.com/r/linux_gaming/comments/1ghrp0j/whats_your_favorite_desktop_environment_and_why/

[^1_75]: https://www.youtube.com/watch?v=5aUEKJn04sI

[^1_76]: https://theserverhost.com/blog/post/best-linux-desktop-environments-for-programming-and-developers

[^1_77]: https://forum.endeavouros.com/t/recommended-wms/65323

[^1_78]: https://www.xda-developers.com/ive-tested-numerous-linux-desktop-environments-and-these-5-are-my-favorites/

[^1_79]: https://www.reddit.com/r/linux/comments/1gywr5l/wayland_in_soon_2025/

[^1_80]: https://wiki.archlinux.org/title/Desktop_environment

[^1_81]: https://github.com/rcalixte/awesome-wayland

[^1_82]: https://forum.endeavouros.com/t/looking-for-a-tiling-wm-that-suits-my-needs/51071

[^1_83]: https://www.reddit.com/r/LocalLLaMA/comments/1bskjki/llm_agent_platforms/

[^1_84]: https://research.aimultiple.com/llm-orchestration/

[^1_85]: https://underconstructionpage.com/how-to-install-claude-code-on-ubuntu-linux-a-developers-guide/

[^1_86]: https://www.ibm.com/think/tutorials/llm-agent-orchestration-with-langchain-and-granite

[^1_87]: https://github.com/e2b-dev/awesome-ai-agents

[^1_88]: https://www.freecodecamp.org/news/the-open-source-llm-agent-handbook/

[^1_89]: https://www.reddit.com/r/OpenAI/comments/1k1qrk4/how_do_you_use_openais_codex_cli/

[^1_90]: https://www.redhat.com/en/topics/ai/what-is-agentic-ai

[^1_91]: https://www.reddit.com/r/ClaudeAI/comments/1lcro0b/best_os_for_claude_code_experience/

[^1_92]: https://www.crewai.com

[^1_93]: https://www.youtube.com/watch?v=4LI-1Zdk-Ys

[^1_94]: https://www.youtube.com/watch?v=D45AknAsIPw

[^1_95]: https://www.reddit.com/r/SteamDeck/comments/1h6s5pl/so_what_is_proton_ge_and_how_do_i_get_it/

[^1_96]: https://linux-gaming.kwindu.eu/index.php?title=Improving_performance

[^1_97]: https://discourse.ubuntu.com/t/please-tell-me-how-to-find-and-install-the-correct-graphics-driver-for-this-system/57038

[^1_98]: https://www.reddit.com/r/linux_gaming/comments/1h946kh/performance_comparison_windowslinux_specifically/

[^1_99]: https://www.youtube.com/watch?v=DVHNXLwqP3w

[^1_100]: https://github.com/gloriouseggroll/proton-ge-custom/releases

[^1_101]: https://www.geeksforgeeks.org/techtips/how-to-improve-gaming-performance-on-linux/

[^1_102]: https://www.intel.com/content/www/us/en/support/articles/000005520/graphics.html

[^1_103]: https://steamcommunity.com/discussions/forum/1/601904257990441865/

[^1_104]: https://steamcommunity.com/discussions/forum/11/3768987250118180512/?l=german

