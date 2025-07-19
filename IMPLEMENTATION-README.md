# Gentoo Linux Optimization for System76 Kudu6

This repository contains a comprehensive, optimized Gentoo Linux build plan specifically designed for the System76 Kudu6 laptop, synthesizing recommendations from multiple AI models (ChatGPT, Claude, Gemini, Perplexity) to create a bleeding-edge system optimized for:

- 🎮 **Gaming Performance** (Steam, Proton, Wine)
- 💻 **Development Environment** (Python, Rust, Java, JavaScript, C/C++)
- 🤖 **AI/ML Development** (CUDA, PyTorch, TensorFlow)
- ☁️ **Cloud Development** (AWS, GCP, Azure, Containers)
- 🎵 **Music Production** (Professional audio with low latency)
- 🔒 **Security Hardening** (Without sacrificing performance)

## 📁 Repository Contents

### Core Documentation

- **`optimized-gentoo-build-plan.md`** - Complete synthesis and analysis of all AI recommendations
- **`initial-llm-prompt.md`** - Original requirements sent to all AI models
- **`troubleshooting-guide.md`** - Solutions for common issues during build process
- **`gimli-system-specifications.md`** - Hardware and software specifications for the target system

### Implementation Scripts

- **`phase1-core-hardening.sh`** - Security hardening and base configuration
- **`phase2-development.sh`** - Development environment setup
- **`phase3-specialized.sh`** - Gaming, audio, AI/ML, and cloud tools

### Configuration Files

- **`optimized-make.conf`** - Bleeding-edge make.conf with performance optimizations
- **`kernel-config-guide.md`** - Detailed kernel configuration for security and performance

### AI Model Responses (Source Material)

- **`chatgpt-input.md`** - ChatGPT 4o, o3, o4-mini responses
- **`claude-web-input.md`** - Claude Sonnet 4 and Opus 4 responses  
- **`gemini-web-input.md`** - Gemini 2.5 Flash and Pro responses
- **`perplexity-web-input.md`** - Perplexity "Best" model responses

## 🚀 Quick Start

### Prerequisites

- System76 Kudu6 laptop with base Gentoo installation complete
- systemd desktop profile selected
- Working network connection

### Installation Steps

1. **Clone this repository on your Gentoo system:**

```bash
git clone <repository-url>
cd gentoo-laptop
```

2. **Make scripts executable:**

```bash
chmod +x phase*.sh
```

3. **Execute phases in order:**

```bash
# Phase 1: Core hardening and security
./phase1-core-hardening.sh

# Phase 2: Development environment
./phase2-development.sh

# Phase 3: Choose specialized workloads
./phase3-specialized.sh
```

4. **Configure kernel (optional but recommended):**

```bash
# Follow kernel-config-guide.md for optimal configuration
sudo emerge --ask sys-kernel/gentoo-sources
cd /usr/src/linux
sudo make menuconfig
# Use guide for security and performance options
```

## 🎯 Key Decisions Made

### Desktop Environment

- **Choice**: Wayland + sway (tiling window manager)
- **Rationale**: Future-focused, secure, excellent for development workflow
- **Fallback**: XWayland for compatibility

### Audio System  

- **Choice**: PipeWire with JACK compatibility
- **Rationale**: Modern, low-latency, supports professional audio workflows

### Security vs Performance

- **Approach**: Kernel-level hardening without runtime performance impact
- **Avoided**: Heavy MAC systems (SELinux/AppArmor) for single-user desktop

### Package Strategy

- **Choice**: Testing branch (~amd64) with selective stable fallbacks
- **Rationale**: Bleeding-edge preference with stability where needed

## 🔧 Customization

### Hardware-Specific Adjustments

**GPU Configuration:**

```bash
# For NVIDIA (in make.conf)
VIDEO_CARDS="nvidia"

# For AMD  
VIDEO_CARDS="amdgpu radeonsi"
```

**CPU Optimization:**

```bash
# Adjust in make.conf based on CPU cores
MAKEOPTS="-j9"  # CPU cores + 1
```

### Workload-Specific Tuning

**Gaming Focus:**

- Enable all multilib packages
- Latest Mesa/Vulkan drivers
- GameMode for runtime optimization

**AI/ML Focus:**

- CUDA toolkit for NVIDIA
- Optimized BLAS/LAPACK libraries  
- Virtual environments for Python ML

**Music Production:**

- Real-time kernel configuration
- Professional audio group permissions
- Low-latency audio optimizations

## 📚 Documentation Hierarchy

1. **Start Here**: `optimized-gentoo-build-plan.md` - Executive summary and full plan
2. **Implement**: Follow `phase1` → `phase2` → `phase3` scripts
3. **Optimize**: Use `kernel-config-guide.md` for custom kernel
4. **Troubleshoot**: Consult `troubleshooting-guide.md` for issues

## 🤝 Contributing

This project synthesizes AI recommendations into practical implementation. To contribute:

1. Test implementations on actual hardware
2. Report issues with specific error messages
3. Suggest optimizations based on real-world usage
4. Update guides based on Gentoo changes

## ⚠️ Important Notes

- **Backup First**: Always backup your system before major changes
- **Test Incrementally**: Don't run all phases at once - test each phase
- **Monitor Resources**: Watch disk space during compilation
- **Read Logs**: Check `/var/log/portage/elog/summary.log` for issues

## 🔗 Resources

- [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)
- [System76 Kudu6 Specs](https://tech-docs.system76.com/models/kudu6/README.html)
- [Gentoo Forums](https://forums.gentoo.org/)
- [Gentoo Wiki](https://wiki.gentoo.org/)

## 📄 [License](LICENSE)

**Built with AI assistance from**: ChatGPT (OpenAI), Claude (Anthropic), Gemini (Google), Perplexity  
**Optimized for**: System76 Kudu6 + Gentoo Linux + Bleeding-edge workflow
