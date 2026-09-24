# CHANGELOG

## v0.3.0 (2026-09-24)

- Overhauled pane readiness check for Copilot. Previously we naively waited 4 seconds and attempted to inject the prompt, now we loop until Copilot has initialized up to 20 seconds. This can be tuned with the following env vars:
  - `PORTGRID_WAIT_TIMEOUT_SEC` (default 20)
  - `PORTGRID_WAIT_INTERVAL_SEC` (default 0.25)
  - `PORTGRID_READY_STABLE_POLLS` (default 3)

## v0.2.0 (2026-05-09)

- Support for multiple PortGrid sessions simultaneously (if one exists, PortGrid will warn and ask if you want to create a new session with an incremented number)

## v0.1.0 (2026-05-08)

- Create tmux session with windows for every project having code ported to it
- Support for Claude Code
- Support for Copilot CLI
- Support for custom porting prompt
