# Human Oriented Environment: A Customized Laptop Experience

I am customizing a laptop computer. The device's hardware specifications are in the file `target-system-specifications.md`. I intend to optimize this system for ease of automation, scripting, and ease of parseability and management by large language models and AI agents. I plan to use various AI agent orchestration utilities such as Claude Code, Gemini CLI, OpenAI Codex CLI, and Cursor CLI to enable my interaction with the system to be as close to fully "natural language" as possible, both via CLI and via future input mechanisms such as voice.

The design and build of the system should prioritize ease of LLM and AI agent integration over all alse.  

The plan is to install just enough of a base system with networking to install and use an AI agent, and to leverage the AI agent to plan and execute the remainder of the installation and configuration of the system and applications to meet the needs listed below.  

The primary uses of this system will be, in descending order of priority:  

1. Polyglot software development: Python, Java, JavaScript, Rust, shell script, and some experimentation with various Lisp dialects. Visual Studio Code (Insiders) is my primary development tool, but I also use JetBrains products extensively.
2. AI development, learning, research, prompt engineering. The system has a weak GPU so I won't be doing any heavy model training or inference, but there will be an increasing demand for tooling to facilitate MLOps and AI Engineering.
3. Cloud development and engineering for AWS and GCP, with future Azure needs likely.
4. Gaming via Steam, WINE, Lutris, Proton/Vulkan. Consider tuned or customized builds of Proton such as that developed by GloriousEggroll. Custom tuned forks of WINE are also acceptable, if such a thing exists.
5. Audio engineering and music production with MIDI and input from keyboards and guitars. This use is the lowest priority, so nothing should be tuned to improve music production capability that causes instability or conflicts with any previously mentioned uses.

## Constraints and usage requirements

- A rolling release is strongly preferred over a point-release distribution. I am partial to Gentoo's portage package/dependency system and Arch's pacman/AUR ecosystem, but I am open to other rolling release based systems such as OpenSUSE Tumbleweed (although I have no idea what sort of package management system it uses).
- My first iteration of this project used Gentoo, and it did not go well. The extremely long compilation times of many core Gentoo packages caused the agent orchestration tool (Claude Code) to time out sessions and crash. It seems likely that a fully source-based option is not feasible, and if Gentoo is identified as the candidate that best suits other requirements, then we should consider a hybrid binary/source configuration.
- My second iteraton of this project used NixOS. The declarative system configuration and the nix programming language were both excellent arguments for NixOS when considering the ease of automation and scripting and how easy it would be for an LLM to parse. However, the immutable nature of the distribution ultimately proved to be incredibly difficult to manage for a user-facing system and my requirements to use non-standard software versions. It is not a usable system for day-to-day use for me.
- The system configuration structure must be straightforward to script and automate. The configuration must be easily parseable by a Large Language Model.
- The graphical environment, whether a desktop environment, window manager, or Wayland compositor, must be similarly parseable by a large language model, well-documented, and easily scripted and automated. It should also be visually pleasing, or straightforward to configure to be visually pleasing. **Important**: do not recommend Gnome or KDE.
- A wayland-based graphical interface is desired, but given some software's dependency upon X11, it is acceptable to maintain X11 compatibility. The target system has integrated Intel graphics.
- The init system must be systemd.

I am very experienced with Linux, having used it as my primary desktop operating system for over 30 years.  

I am always trying to keep up to date with the latest versions of most software I use; I tend to spend my time on the bleeding edge. As such, consider early development and beta versions of software as appropriate for compatibility with the requirements.

## Your instructions

Given the above constraints, determine the top 5 most suitable Linux distributions. Do not recommend Gentoo or NixOS. Further, suggest 5 window managers or desktop environments that suit the stated constraints and requirements. Do not recomment Gnome or KDE. I strongly prefer Qt-based GUI applications over GTK-based GUI applications.

Assume that the base system will be installed. Assume that at the earliest possible time in the operating system installation process, I will install a LLM agent orchestration tool such as Claude Code, Gemini CLI, or OpenAI Codex. This agentic orchestration tool will be heavily leveraged for all rmaining work in installing the system, and will continue to be an integral part of the system usage and maintenance.

Put together a step-by-step plan to perform the installation as outlined.
