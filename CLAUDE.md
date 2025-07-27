# Claude Code Orchestration Guide for Gentoo Linux Laptop Build

## Project Overview

You are tasked with orchestrating the synthesis of multiple LLM responses to create an optimized Gentoo Linux build plan for a System76 Kudu laptop (kudu6). This document provides your guidance and constraints for this task.

## Input Files to Process

1. `initial-llm-prompt.md` - The original prompt sent to all models
2. `linux-sme-system-prompt.md` - System prompt for Linux expertise context
3. `gimli-system-specifications.md` - System specifications for the System76 Kudu laptop
4. `llm-responses/chatgpt-o3.md` - Response from ChatGPT o3 model
5. `llm-responses/chatgpt-o4-mini-high.md` - Response from ChatGPT o4 mini high model
6. `llm-responses/chatgpt-o4-mini.md` - Response from ChatGPT o4 mini model
7. `llm-responses/claude-opus-4.md` - Response from Claude Opus 4 model
8. `llm-responses/claude-sonnet-3.7.md` - Response from Claude Sonnet 3.7 model
9. `llm-responses/claude-sonnet-4.md` - Response from Claude Sonnet 4 model
10. `llm-responses/deepseek-r1-0528.md` - Response from DeepSeek R1 0528 model
11. `llm-responses/gemini-2.5-flash-consumer-custom-system-prompt.md` - Response from Gemini 2.5 Flash consumer with custom system prompt
12. `llm-responses/gemini-2.5-flash-consumer-default-system-prompt.md` - Response from Gemini 2.5 Flash consumer with default system prompt
13. `llm-responses/gemini-2.5-flash-enterprise-custom-system-prompt.md` - Response from Gemini 2.5 Flash enterprise with custom system prompt
14. `llm-responses/gemini-2.5-flash-enterprise-default-system-prompt.md` - Response from Gemini 2.5 Flash enterprise with default system prompt
15. `llm-responses/gemini-2.5-pro-consumer-custom-system-prompt.md` - Response from Gemini 2.5 Pro consumer with custom system prompt
16. `llm-responses/gemini-2.5-pro-consumer-default-system-prompt.md` - Response from Gemini 2.5 Pro consumer with default system prompt
17. `llm-responses/gemini-2.5-pro-enterprise-custom-system-prompt.md` - Response from Gemini 2.5 Pro enterprise with custom system prompt
18. `llm-responses/gemini-2.5-pro-enterprise-default-system-prompt.md` - Response from Gemini 2.5 Pro enterprise with default system prompt
19. `llm-responses/kimi-k2-instruct.md` - Response from Kimi K2 Instruct model
20. `llm-responses/perplexity.md` - Response from Perplexity model

## Primary Objectives

Create a comprehensive, optimized build plan that prioritizes:

1. **Gaming Performance** - Optimize for WINE, Proton, Steam, and other gaming platforms
2. **Development Environment** - Support for diverse programming languages and frameworks
3. **AI/ML Development** - Tools and libraries for AI learning and development
4. **Cloud Development** - Integration with GCP and AWS
5. **Security** - Strong security for a single-user system on private network
6. **Maintainability** - Consider ease of maintenance (secondary to performance)

## Decision-Making Framework

When synthesizing conflicting recommendations:

1. **Primary Authority**: Official Gentoo best practices and documentation
2. **Secondary Authority**: Gentoo community consensus
3. **Hardware Constraint**: All decisions must be compatible with [System76 Kudu6](gimli-system-specifications.md)

## Key Constraints

- **Profile**: systemd desktop profile for amd64 (already installed)
- **Pending Decision**: Wayland vs X11 (analyze recommendations from all models)
- **Pending Decision**: Desktop environment/window manager choice

## Synthesis Process

1. **Extract and Categorize**:
   - Parse each model's response
   - Group recommendations by category (kernel config, USE flags, packages, etc.)
   - Note which model(s) suggested each recommendation

2. **Conflict Resolution**:
   - Identify where models disagree
   - Research using Gentoo Wiki and official documentation
   - Apply decision-making framework
   - Document rationale for choices

3. **Validation**:
   - Verify hardware compatibility with Kudu6 specs
   - Check for package conflicts
   - Ensure gaming/development requirements are met

4. **Attribution**:
   - Tag each recommendation with source model(s)
   - Use format: `[Suggested by: Model1, Model2]`

## Output Structure

Create `optimized-gentoo-build-plan.md` with these sections:

```markdown
# Optimized Gentoo Build Plan for System76 Kudu6

## Executive Summary
- Key decisions made
- Wayland vs X11 recommendation with rationale
- DE/WM recommendation with rationale

## Hardware-Specific Configuration
- Kernel configuration for Kudu6
- Driver requirements
- Power management

## USE Flags Strategy
- Global USE flags
- Per-package USE flags
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
- [Attribution for each]

### AI/ML Stack
- Frameworks (TensorFlow, PyTorch, etc.)
- CUDA/ROCm setup
- Development tools
- [Attribution for each]

### Cloud Development
- AWS CLI and tools
- GCP SDK
- Container tools
- [Attribution for each]

### Security Hardening
- Firewall configuration
- SELinux/AppArmor considerations
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

## Research Resources

Primary:

- Gentoo Wiki: <https://wiki.gentoo.org/>
- Gentoo Handbook: <https://wiki.gentoo.org/wiki/Handbook:AMD64>
- Gentoo Forums: <https://forums.gentoo.org/>

Hardware-specific:

- System76 Kudu6 specs: <https://tech-docs.system76.com/models/kudu6/README.html>
- System76 driver repository

Gaming:

- ProtonDB for compatibility checking
- Wine AppDB
- Gentoo Gaming Guide

## Special Considerations

1. **Performance Optimization**:
   - Prefer `-march=native` for CPU optimization
   - Consider PGO (Profile-Guided Optimization) for critical packages
   - Evaluate compiler flags for gaming performance

2. **GPU Configuration**:
   - Research both NVIDIA and AMD options (check Kudu6 specs)
   - Consider PRIME/Bumblebee for hybrid graphics if applicable

3. **Storage Strategy**:
   - Plan for AI model storage requirements

## Conflict Documentation

When models disagree, create a decision log:

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
- [ ] USE flag conflicts resolved
- [ ] Gaming requirements verified
- [ ] Development toolchain completeness checked
- [ ] Security measures adequate for use case
- [ ] Build order creates bootable system at each phase

## Next Steps

After creating the optimized plan:

1. Create implementation checklist
2. Generate troubleshooting guide for common issues
3. Document post-installation optimization steps
4. Create maintenance calendar/schedule

---

Remember: The goal is not just to merge the responses, but to create a superior, cohesive plan that leverages the best insights from all models while maintaining consistency with Gentoo best practices and the specific hardware requirements.
