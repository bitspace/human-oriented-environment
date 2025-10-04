# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Snapshot of current Hyprland and supporting configs under `.config/` for reference during compositor migration.
- `AGENTS.md` operational guide replacing the Claude-specific instructions.

### Changed
- Pivoting project focus from Hyprland to Labwc on Arch Linux while maintaining existing hardware and usage profile.
- Rescoping repository workflow toward hands-on agent-driven iteration rather than cross-model consensus artifacts.
- Corrected Labwc natural scrolling by setting the libinput default, non-touch, and touchpad categories to use the natural direction.

### Deprecated
- Marked previous LLM consensus analyses and `llm-outputs/` responses for retirement during Labwc rollout cleanup.
- Retired `CLAUDE.md` now that `AGENTS.md` covers agent workflow guidance.
