# Systemd Timer Deployment Instructions

## Files Created
- `system-update.service` - The service unit that runs the update script
- `system-update.timer` - The timer unit that schedules when to run

## Deployment Steps

1. **Review and modify the configuration** (if needed):
   - Check the paths in `system-update.service` are correct
   - Adjust the schedule in `system-update.timer` if desired
   - Current schedule: Weekly on Sundays at 3 AM

2. **Copy files to systemd user directory**:
   ```bash
   cp staging/system-update.service ~/.config/systemd/user/
   cp staging/system-update.timer ~/.config/systemd/user/
   ```

3. **Reload systemd daemon to recognize new units**:
   ```bash
   systemctl --user daemon-reload
   ```

4. **Test the service manually** (optional but recommended):
   ```bash
   systemctl --user start system-update.service
   # Check status and logs
   systemctl --user status system-update.service
   journalctl --user -u system-update.service -f
   ```

5. **Enable and start the timer**:
   ```bash
   # Enable timer to start on boot
   systemctl --user enable system-update.timer
   
   # Start the timer now
   systemctl --user start system-update.timer
   ```

6. **Verify timer is active**:
   ```bash
   # Check timer status
   systemctl --user status system-update.timer
   
   # List all timers and next run times
   systemctl --user list-timers
   ```

## Useful Commands

- **Check when the timer will run next**:
  ```bash
  systemctl --user list-timers system-update.timer
  ```

- **View service logs**:
  ```bash
  journalctl --user -u system-update.service
  # Or check the log files directly:
  tail -f ~/.local/share/update-logs/systemd-update.log
  ```

- **Disable the timer** (if needed):
  ```bash
  systemctl --user stop system-update.timer
  systemctl --user disable system-update.timer
  ```

- **Run the update immediately**:
  ```bash
  systemctl --user start system-update.service
  ```

## Notes

- The timer runs as your user, not root, so package operations requiring sudo will fail
- Consider running with `--dry-run` flag initially by modifying ExecStart in the service file
- Logs are saved to `~/.local/share/update-logs/`
- The service won't run if on battery power (laptop safety feature)
- The timer has a 30-minute random delay to avoid exact-time load spikes
- If the system is off during scheduled time, it will run on next boot (Persistent=true)