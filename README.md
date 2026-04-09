# Open Tab — Scheduled Chrome Tab

Opens any URL in a new Chrome tab on a daily schedule using a compiled AppleScript app and a macOS Launch Agent.

## Files

- `open-tab.applescript` — Source AppleScript (compiled into an app by the installer)
- `install.sh` — Compiles the script into a signed `.app`, creates a Launch Agent, and loads it
- `remove.sh` — Uninstalls the app and Launch Agent

## Quick start

```bash
chmod +x install.sh remove.sh
./install.sh "https://example.com" 15 0
```

That compiles the AppleScript into `~/Applications/OpenTab.app`, ad-hoc signs it, and schedules it for 3:00 PM daily. The URL is required; hour and minute default to 15:00 if omitted.

The first time it fires, macOS will prompt you to grant OpenTab Automation access to Chrome. Go to **System Settings → Privacy & Security → Automation** to approve it. Because it runs as its own `.app` rather than through `osascript`, the permission is scoped to OpenTab only — other scripts won't inherit Chrome access.

## What the installer does

1. Compiles `open-tab.applescript` into `~/Applications/OpenTab.app` via `osacompile`
2. Ad-hoc signs the app with `codesign` so macOS gives it a stable identity (permissions won't reset after moves or updates)
3. Generates a Launch Agent plist at `~/Library/LaunchAgents/com.$USER.open-tab.plist`
4. Loads the agent via `launchctl`

## Managing the schedule

To change the time or URL, just re-run the installer:

```bash
./install.sh "https://example.com/other-page" 8 0
```

To stop it:

```bash
launchctl unload ~/Library/LaunchAgents/com.$USER.open-tab.plist
```

To fully uninstall:

```bash
./remove.sh
```

## Customization

- **App location** — By default the installer places the app in `~/Applications/`. Edit `install.sh` if you prefer a different location.
