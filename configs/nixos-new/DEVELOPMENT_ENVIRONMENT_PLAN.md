# Development Environment Setup Plan
**Target**: LLM-optimized polyglot development workstation  
**Focus**: AI learning, research, cloud development, music production

## Phase 1: Core Development Languages & Tools

### Programming Languages (via Home Manager)
**Primary Languages:**
- **Python** - ML/AI development, automation
  - `python3` with `pip`, `poetry`, `pipx`
  - Virtual environment management
  - Common ML libraries as user packages

- **JavaScript/TypeScript** - Web development, tooling
  - `nodejs_20` (LTS), `npm`, `yarn`, `pnpm`
  - `deno` for secure runtime
  - `bun` for fast JS tooling

- **Rust** - Systems programming, CLI tools
  - `rustc`, `cargo`, `rust-analyzer`
  - `rustfmt`, `clippy` for code quality

- **Go** - Cloud/infrastructure tools
  - `go`, `gopls` (language server)
  - `gotools` for development utilities

**Secondary Languages:**
- **C/C++** - Low-level development
  - `gcc`, `clang`, `cmake`, `ninja`
  - `gdb`, `lldb` for debugging

### Text Editors & IDEs
- **VS Code** - Primary IDE for most development
- **Neovim** - Terminal-based editing with modern features
- **Helix** - Modern modal editor alternative

### Version Control & Collaboration
- Enhanced git configuration (already configured)
- **GitHub CLI** - `gh` for repository management
- **Git UI tools** - `lazygit` (already installed)

## Phase 2: Language Servers & Development Tooling

### Language Servers
- `rust-analyzer` (Rust)
- `gopls` (Go)  
- `pyright` or `pylsp` (Python)
- `typescript-language-server` (JS/TS)
- `clangd` (C/C++)

### Code Quality & Formatting
- **Python**: `black`, `isort`, `flake8`, `mypy`
- **JavaScript/TypeScript**: `prettier`, `eslint`
- **Rust**: `rustfmt`, `clippy` (included with Rust)
- **Go**: `gofmt`, `golangci-lint`
- **Shell**: `shellcheck`, `shfmt`

### Development Utilities
- **JSON/YAML**: `jq`, `yq` (already installed)
- **HTTP/API**: `httpie`, `curl` (curl already installed)
- **Database**: `sqlite` for local development
- **Performance**: `hyperfine` for benchmarking
- **Documentation**: `mdbook` for Rust-style docs

## Phase 3: Containerization & Virtualization

### Container Tools (System-level)
- **Docker** - Container runtime and development
  - Enable dockerd service
  - Add user to docker group
  - Docker Compose for multi-container apps

- **Alternative**: Consider `podman` for rootless containers

### VM/Development Environments
- **Direnv** - Per-project environment management (already installed)
- **Nix shells** - Project-specific development environments
- **QEMU/KVM** - System-level virtualization if needed

## Phase 4: Cloud Development Tools

### AWS Tools
- `awscli2` - AWS command line interface
- Consider `aws-vault` for credential management

### GCP Tools  
- `google-cloud-sdk` - Google Cloud CLI

### Kubernetes
- `kubectl` - Kubernetes CLI
- `k9s` - Terminal-based Kubernetes dashboard
- `helm` - Package manager for Kubernetes

### Infrastructure as Code
- **Terraform** - Note: You removed this in package-removals, reconsider?
- **Nix** - Use Nix itself for reproducible environments

## Phase 5: AI/ML Development Environment

### Python ML Stack
- **Core Libraries**: `numpy`, `scipy`, `pandas`, `matplotlib`
- **ML Frameworks**: `scikit-learn`, `jupyter`
- **Deep Learning**: Consider `pytorch` or `tensorflow` via pip/conda
- **Notebooks**: `jupyterlab` for interactive development

### GPU Support (if needed)
- CUDA toolkit configuration for NVIDIA GPU
- ROCm for AMD GPU (if applicable)

### LLM Development
- **API Clients**: `openai`, `anthropic` Python packages
- **Local Models**: Consider `ollama` for local LLM serving
- **Vector DBs**: `chromadb`, `weaviate-client` for embeddings

### Research & Data Tools
- **R** - Statistical computing (consider if needed)
- **Julia** - High-performance scientific computing
- **Visualization**: `plotly`, `seaborn` via pip

## Phase 6: Music Production (Basic)

### Audio Development
- **JACK** - Low-latency audio server (system-level)
- **PipeWire JACK** - Already configured, good for most use cases
- **MIDI**: `alsa-utils` for MIDI support

### Music Software (Optional)
- **Audacity** - Basic audio editing (already have?)
- **LMMS** - Linux MultiMedia Studio for composition
- Consider `reaper` if available and needed

## Implementation Strategy

### Home Manager Approach
**Advantages**:
- No sudo required for development tool changes
- Per-user development environments
- Easy to experiment and rollback
- Version controlled user configurations

### System vs User Decisions
**System-level** (requires sudo):
- Docker daemon and services
- Virtualization support (QEMU/KVM)
- Hardware-specific drivers
- System-wide development dependencies

**User-level** (Home Manager):
- Programming languages and runtimes
- Development tools and utilities  
- Language servers and formatters
- Text editors and IDEs

### Incremental Deployment
1. **Start minimal** - Core languages first
2. **Add tooling** - Language servers and development utilities
3. **Add services** - Docker, databases as needed
4. **Expand gradually** - AI/ML tools, cloud tools as projects require

### LLM Optimization Considerations
- **Declarative configs** - Everything in Nix expressions
- **Reproducible environments** - Use `nix develop` for projects
- **Structured outputs** - Prefer tools with JSON/structured output
- **Automation friendly** - CLI-first tools over GUI when possible

## Questions for Review

1. **Language Priorities**: Which languages are most important for your immediate projects?

2. **AI/ML Focus**: Do you need heavy ML frameworks immediately, or start with basic Python data science?

3. **Cloud Platforms**: AWS vs GCP vs both for your cloud development?

4. **Containerization**: Docker vs Podman preference?

5. **IDE Preference**: VS Code vs terminal-based (Neovim/Helix) for primary development?

6. **System Services**: Which services (Docker, databases) should run system-wide vs per-project?

This plan balances your LLM orchestration needs with practical polyglot development while maintaining the clean NixOS architecture we've established.