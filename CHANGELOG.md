# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-10-05

### Added
- Window switcher fields in Labwc showing icon, desktop entry, and identifier to simplify run-or-raise bindings.
- DPMS helper scripts and a gtklock wrapper so swayidle can safely manage power and screen locking.
- systemd-logind drop-in to suspend and lock on lid close for Labwc sessions.
- systemd --user unit (recommended) to keep the idle manager running across restarts.

### Changed
- Labwc idle manager mirrors Hypridle behavior, re-locks on resume, and restores displays after DPMS.
- Wallpaper rotation script now logs the chosen image and supports multiple formats.

### Fixed
- Natural scrolling honored by using libinput categories in Labwc.
- Lid-close now reliably suspends and shows gtklock on resume.

### Added
- Snapshot of current Hyprland and supporting configs under `.config/` for reference during compositor migration.
- `AGENTS.md` operational guide replacing the Claude-specific instructions.

### Changed
- Pivoting project focus from Hyprland to Labwc on Arch Linux while maintaining existing hardware and usage profile.
- Rescoping repository workflow toward hands-on agent-driven iteration rather than cross-model consensus artifacts.
- Corrected Labwc natural scrolling by setting the libinput default, non-touch, and touchpad categories to use the natural direction.
- Added Labwc window switcher field configuration so Alt-Tab shows each window's identifier for run-or-raise tuning.
- Updated the Labwc idle manager to mirror the Hypridle dpms/lock flow, added helpers to avoid duplicate gtklock instances, and supplied a systemd-logind drop-in that locks before suspend on lid close.

### Deprecated
- Marked previous LLM consensus analyses and `llm-outputs/` responses for retirement during Labwc rollout cleanup.
- Retired `CLAUDE.md` now that `AGENTS.md` covers agent workflow guidance.
