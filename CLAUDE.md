# Claude Code Orchestration Guide for LLM-Optimized Linux Laptop Build

## Project Overview

You are tasked with orchestrating the synthesis of multiple LLM responses to create an optimized Linux build plan for a System76 Kudu laptop (kudu6). This system should be optimized for LLM integration, software development, and gaming. The system should prioritize configuration parseability by LLMs and automation capabilities.

## Input Files to Process

The directory `llm-inputs` contains the various prompts and context information supplied to the different LLMs:

1. `linux-sme-system-prompt.md` - System prompt for Linux expertise context
2. `initial-llm-prompt.md` - The original prompt sent to all models
3. `gimli-system-specifications.md` - System specifications for the System76 Kudu laptop
4. `generic-chatbot-input.md` - A collation of `linux-sme-system-prompt.md`, `gimli-system-specifications.md`, and `initial-llm-prompt.md` created for input to models that do not present a UX control through which to provide a system prompt or to attach context information

The directory `llm-responses` contains the responses from the different LLMs:

1. `chatgpt-o3-deepresearch.md` - response from OpenAI's ChatGPT-o3 model with "Deep Research" enabled
2. `claude-opus-4-research.md` - response from Anthropic's Claude Opus 4 with "Research" enabled
3. `cohere-command-a-03-2025.md` - response from Cohere's Command-A 03/2025
4. `deepseek-r1-0528.md` - response from Deepseek R1 05/28
5. `gemini-2.5-pro-deep-research.md` - response from Google's Gemini 2.5 Pro with Deep Research enabled
6. `kimi-k2-instruct.md` - response from Kimi K2 Instruct
7. `llama.md` - response from Meta's Llama 3.1 405B
8. `mistral.md` - response from Mistral's "Le Chat" with Research enabled
9. `perplexity-research.md` - response from Perplexity's chat interface with Research enabled
10. `qwen.md` - response from Qwen3 Coder 480B A35B Instruct

## Primary Objectives

1. **Ease of Automation and Parsability by LLM tools**: As much of the system and user interface configuration as possible should be open for automation, scripting, and ease of parsing by LLMs
2. **Gaming Performance** - Optimize for WINE, Proton, Steam, and other gaming platforms
3. **Development Environment** - Support for diverse programming languages and frameworks
4. **AI/ML Development** - Tools and libraries for AI learning and development
5. **Cloud Development** - Integration with GCP and AWS
6. **Security** - Strong security for a single-user system on private network
7. **Maintainability** - Consider ease of maintenance (secondary to performance)

## Decision-Making Framework

When synthesizing conflicting recommendations:

1. **Primary Authority**: Official best practices and documentation for the chosen distribution
2. **Secondary Authority**: Community consensus and proven patterns
3. **Hardware Constraint**: All decisions must be compatible with System76 Kudu6 specifications
4. **LLM Parseability**: Prefer text-based, declarative configurations over binary formats

## Key Design Principles

### 1. Configuration Parseability
- Use declarative configuration formats (YAML/TOML/JSON)
- Avoid binary configuration files
- Standardize configuration locations
- Document all configuration options inline
- Use consistent naming conventions

### 2. Automation First
- Every manual step should have a scripted alternative where feasible
- Use idempotent operations
- Implement rollback capabilities
- Version control all configurations
- Create comprehensive logging

### 3. LLM Integration Points
- Structured command outputs (JSON where possible)
- Predictable file locations
- Self-documenting systems
- API-first design for system interaction
- Standardized error formats

## Synthesis Process

### Phase 1: Data Collection & Analysis
- Parse each model's response from `llm-responses/`
- Extract key recommendations from each model
- Group recommendations by category (kernel config, packages, configuration, etc.)
- Identify consensus patterns across models
- Flag conflicting recommendations for resolution
- Create summary matrix of recommendations by category

### Phase 2: Conflict Resolution
- Research using distribution documentation and community resources
- Apply decision-making framework
- Document rationale for choices
- Create decision log for disagreements

### Phase 3: System Architecture Design
Based on consensus analysis, design:
- Base distribution selection
- Package management strategy
- Configuration management approach
- Directory structure optimized for LLM parsing
- Automation framework selection

### Phase 4: Implementation Planning
Create detailed plans for:
- Initial system installation scripts
- Configuration file templates
- Development environment setup
- Gaming layer configuration
- LLM integration points

## Output Deliverables

### 1. Consensus Analysis (`consensus-analysis.md`)
- Summary of all LLM recommendations
- Identified patterns and conflicts
- Recommended resolutions
- Priority ranking of features
- Attribution for each recommendation using format: `[Suggested by: Model1, Model2]`

### 2. Optimized Build Plan (`llm-optimized-linux-build-plan.md`)
Structure:
```markdown
# Optimized Build Plan for System76 Kudu6

## Executive Summary
- Key decisions made
- Distribution choice and rationale
- Wayland vs X11 recommendation with rationale
- DE/WM recommendation with rationale

## Hardware-Specific Configuration
- Kernel configuration for Kudu6
- Driver requirements
- Power management
- GPU configuration (NVIDIA/AMD options)

## Configuration Strategy
- Global configuration approach
- Per-application configuration
- Rationale for choices

## Package Categories

### Gaming Infrastructure
- WINE/Proton setup
- Steam configuration
- Graphics optimization
- [Attribution for each]

### Development Environment
- Language toolchains
- IDEs and editors
- Version control
- Container technologies
- [Attribution for each]

### AI/ML Stack
- Frameworks (TensorFlow, PyTorch, etc.)
- CUDA/ROCm setup
- Development tools
- Model storage strategy
- [Attribution for each]

### Cloud Development
- AWS CLI and tools
- GCP SDK
- Container tools
- [Attribution for each]

### Security Hardening
- Firewall configuration
- Security framework considerations
- Security tools
- [Attribution for each]

## Build Order and Dependencies
- Phased installation approach
- Critical path items

## Maintenance Strategy
- Update procedures
- Backup recommendations
- Performance monitoring
```

### 3. Implementation Scripts
- `install.sh` - Base system installation
- `configure.py` - System configuration manager
- `setup-dev.sh` - Development environment setup
- `setup-gaming.sh` - Gaming layer setup
- `backup-restore.sh` - Backup and recovery

### 4. Configuration Templates
- `/etc/llm-laptop/` - System-wide configs
- `~/.config/llm-laptop/` - User configs
- All configs in YAML/TOML with schemas

### 5. Documentation
- `README.md` - Project overview and quick start
- `CONFIGURATION.md` - All configuration options
- `DEVELOPMENT.md` - Development workflow guide
- `TROUBLESHOOTING.md` - Common issues and solutions
- `DECISION_LOG.md` - Record of conflict resolutions

## Implementation Guidelines

### Code Standards
- Use type hints in Python
- Implement comprehensive error handling
- Add logging at appropriate levels
- Write unit tests for critical functions
- Document all public interfaces

### File Organization
```
llm-laptop/
├── analysis/          # Working files for synthesis
├── scripts/
│   ├── install/
│   ├── configure/
│   └── maintain/
├── configs/
│   ├── system/
│   ├── user/
│   └── schemas/
├── docs/
├── tests/
└── tools/
```

### Conflict Documentation Template
When models disagree, document as:
```markdown
### Decision: [Topic]
**Options proposed:**
- Model A: [recommendation]
- Model B: [recommendation]

**Research findings:**
- [Official documentation says...]
- [Community consensus indicates...]

**Decision:** [Choice made]
**Rationale:** [Why this choice aligns with objectives]
```

## Validation Checklist

Before finalizing:
- [ ] All recommendations tested against Kudu6 hardware specs
- [ ] Package conflicts resolved
- [ ] Gaming requirements verified (ProtonDB, Wine AppDB checked)
- [ ] Development toolchain completeness checked
- [ ] AI/ML storage requirements planned
- [ ] Security measures adequate for use case
- [ ] Build order creates functional system at each phase
- [ ] All configurations parseable by major LLMs
- [ ] Automation scripts tested

## Success Criteria
- System boots and functions as daily driver
- All configurations parseable by major LLMs
- Development workflows are faster than traditional setup
- Gaming performance acceptable (60+ FPS in target games)
- Full system reproducible from scripts in <2 hours
- Recovery from failure in <30 minutes

## Special Considerations

1. **Performance Optimization**:
   - Consider CPU-specific optimizations
   - Evaluate compiler flags for gaming performance
   - Plan for AI model storage requirements

2. **GPU Configuration**:
   - Research both NVIDIA and AMD options per Kudu6 specs
   - Consider hybrid graphics solutions if applicable

3. **Storage Strategy**:
   - Plan for large AI model storage
   - Optimize for fast context switching between projects

## Getting Started
1. Create `analysis/` directory for working files
2. Parse LLM response files from `llm-responses/`
3. Begin with consensus analysis
4. Generate conflict resolution documentation
5. Create initial build plan draft
6. Iterate based on findings

## Notes for Claude Code
- Prioritize consensus over any single LLM's recommendation
- When in doubt, choose simplicity and parseability
- Test assumptions with minimal prototypes
- Keep human in the loop for major decisions
- Generate comparative analysis tables for decision points
- Flag security implications of all recommendations
- Remember: The goal is a system that feels native to both humans and LLMs