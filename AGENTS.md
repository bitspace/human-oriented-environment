# Agent Operations Guide

## Mission Overview

This repository contains the working configuration and automation plans for an Arch Linux installation on a Lenovo ThinkPad P16. The project is currently pivoting from a Hyprland-centric Wayland environment to Labwc while preserving existing workflows for software development, gaming, writing, and AI research. All work should prioritize reproducibility, LLM-parseable configuration, and human/agent collaboration.

## Environment Context

- **Hardware**: Lenovo ThinkPad P16, dual external Gigabyte M27Q monitors, integrated display at 3840x2400.
- **Operating System**: Arch Linux (paru preferred for package management).
- **Current Compositors**:
  - Reference: Hyprland configs under `.config/hypr/` (kept for parity mapping).
  - Target: Labwc configs under `.config/labwc/` (active development).
- **Supporting Tools**: Waybar, kanshi, dunst, gtklock, swaybg, swayidle, nm-applet, polkit agent, gaming stack (Steam/Proton, gamescope as needed).

## Sandbox Protocol

- Filesystem access: workspace-write; edit within repo paths only.
- Network: restricted; avoid commands requiring outbound access without approval.
- Approval policy: on-request. For commands needing escalated permissions, set `with_escalated_permissions=true` with a one-sentence justification.
- Never run destructive commands (e.g., `rm -rf`, `git reset --hard`) unless explicitly instructed.
- Respect existing uncommitted changes; do not revert user modifications.

## Repository Structure

- `.config/hypr/`: Hyprland reference configuration (monitor layout, wallpaper rotation, idle/lock) used for parity comparisons.
- `.config/labwc/`: Labwc configuration under active development (rc.xml, autostart, helper scripts).
- `.config/kanshi/`: Display profile automation scripts and configs.
- `CHANGELOG.md`: Tracks notable changes; update alongside config edits.
- `README.md`: Legacy narrative from the earlier LLM-consensus experiment (may be outdated but kept for context).
- `target-system-specifications.md`: Hardware reference for the ThinkPad P16 build target.
- `staging/`: Scratch area for temporary files; contents are non-authoritative and typically ignored by Git.

> Legacy directories such as `llm-inputs/`, `llm-outputs/`, and `previous-analyses/` have been removed. If referenced in older documents, treat them as historical context only.

## Workflow Guidelines

1. **Understand the Objective**: Align work with Labwc parity goals—restore user experience (window switching, workspace ergonomics, gaming support) without relying on Hyprland-specific behaviours.
2. **Plan Before Editing**: Outline steps using the plan tool for multi-step tasks; skip only for trivial changes.
3. **Implement Incrementally**: Use targeted commits/changes that are easy to review. Maintain declarative, ASCII-friendly configs.
4. **Document Work**: Update `CHANGELOG.md` for any notable change. Where configuration choices may be unclear, add concise comments.
5. **Validate**: Where possible, describe manual validation steps (e.g., launch Labwc session, test Alt-Tab, confirm wallpaper rotation). Add test scripts if necessary, removing temporary files post-validation.
6. **Escalation Path**: If a task demands privileges or touching live configs outside the repo, pause and request user direction.

## Labwc Migration Checklist

- [ ] Inventory Hyprland behaviours (workspaces, autostart apps, window rules, gaming tweaks).
- [ ] Design Labwc UX: keybindings, workspace count, panel/menu choices, window decorations.
- [ ] Implement Labwc configs: `rc.xml`, `autostart`, helper scripts for wallpaper, idle, kanshi, etc.
- [ ] Ensure supporting tools are installed/configured (`paru -S labwc swaybg swayidle gtklock wlopm`).
- [ ] Validate in a Labwc session: monitor layouts, keyboard shortcuts, notifications, gaming scenarios.
- [ ] Retire Hyprland-specific artefacts after parity is confirmed; ensure no legacy consensus files are reintroduced.
- [ ] Update documentation (README/CHANGELOG) to reflect the new baseline.

## Coordination Practices

- Communicate uncertainties or conflicting requirements.
- Flag risks promptly (e.g., missing packages, sandbox limits, deviations from reproducibility goals).
- When referencing files in messages, use clickable relative paths with line numbers (e.g., `.config/labwc/rc.xml:12`).

## Success Criteria

- Labwc environment delivers smooth window management with keyboard-native workflows (Alt-Tab, workspace navigation).
- Automation scripts and configs remain easy for humans and agents to parse.
- Gaming workflows (Steam/Proton, fullscreen handoff, VRR) operate as well as or better than the Hyprland setup.
- Legacy consensus artefacts are retired without losing necessary historical context.
