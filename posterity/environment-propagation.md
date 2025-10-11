# Environment Variable Propagation for GUI Applications

## The Problem
Shell configuration files (`.bashrc`, `.profile`) are only read by shell sessions. GUI applications launched from desktop environments don't inherit these variables.

## Solutions by Desktop Environment

### Hyprland (Current Setup)
Environment variables must be set in `hyprland.conf`:
```bash
# In ~/.config/hypr/hyprland.conf
env = ANTHROPIC_API_KEY,$ANTHROPIC_API_KEY
env = OPENAI_API_KEY,$OPENAI_API_KEY

# Then propagate to systemd and dbus
exec-once = dbus-update-activation-environment --systemd ANTHROPIC_API_KEY OPENAI_API_KEY
exec-once = systemctl --user import-environment ANTHROPIC_API_KEY OPENAI_API_KEY
```

### Alternative: Systemd User Environment
```bash
# ~/.config/environment.d/api-keys.conf
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-proj-...
```

## Recommended Approach for LLM Integration

1. **Secure storage**: All API keys in 1Password
2. **Shell access**: Via `op read` commands in shell configs
3. **GUI access**: Via systemd user environment files
4. **Runtime updates**: Via `systemctl --user set-environment`

## Implementation Strategy

```bash
# 1. Store in 1Password
op item create --category=login --title="Anthropic API" credential="your_key"

# 2. Create shell helper
# ~/.config/shell/load-api-keys.sh
export ANTHROPIC_API_KEY=$(op read "op://Private/Anthropic API/credential")

# 3. Update systemd user environment
systemctl --user set-environment ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"

# 4. GUI apps now inherit the variable
```