#!/bin/bash
# install.sh — Install the open-tab Launch Agent as a signed .app
# Usage: ./install.sh <URL> [HOUR] [MINUTE]
# Example: ./install.sh "https://example.com" 15 0      (3:00 PM)
#          ./install.sh "https://example.com" 9 30      (9:30 AM)

if [ -z "$1" ]; then
    echo "Usage: ./install.sh <URL> [HOUR] [MINUTE]"
    echo "Example: ./install.sh \"https://example.com\" 15 0"
    exit 1
fi

URL="$1"
HOUR="${2:-15}"
MINUTE="${3:-0}"

APP_DIR="$HOME/Applications"
APP_PATH="$APP_DIR/OpenTab.app"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.$USER.open-tab"
PLIST_PATH="$PLIST_DIR/$PLIST_NAME.plist"
TMPSCRIPT=$(mktemp /tmp/open-tab.XXXXXX.applescript)

# Generate a script with the URL baked in
cat > "$TMPSCRIPT" <<APPLESCRIPT
-- Open Tab — opens a URL in a new Chrome tab
-- URL: $URL

tell application "Google Chrome"
    activate

    if (count of windows) is 0 then
        make new window
    end if

    tell front window
        make new tab with properties {URL:"$URL"}
    end tell
end tell
APPLESCRIPT

# Compile the AppleScript into an .app bundle
mkdir -p "$APP_DIR"
osacompile -o "$APP_PATH" "$TMPSCRIPT"
rm "$TMPSCRIPT"
echo "Compiled app to $APP_PATH"

# Set the display name so it shows as "OpenTab" in permissions prompts
defaults write "$APP_PATH/Contents/Info" CFBundleName "OpenTab"
defaults write "$APP_PATH/Contents/Info" CFBundleDisplayName "OpenTab"
defaults write "$APP_PATH/Contents/Info" CFBundleIdentifier "com.$USER.open-tab"

# Ad-hoc sign so macOS gives it a stable identity for permissions
codesign --force --sign - "$APP_PATH" 2>/dev/null
echo "Ad-hoc signed $APP_PATH"

# Unload existing agent if present
if launchctl list | grep -q "$PLIST_NAME"; then
    launchctl unload "$PLIST_PATH" 2>/dev/null
    echo "Unloaded existing agent"
fi

# Generate the plist
mkdir -p "$PLIST_DIR"
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$PLIST_NAME</string>

	<key>ProgramArguments</key>
	<array>
		<string>open</string>
		<string>$APP_PATH</string>
	</array>

	<key>StartCalendarInterval</key>
	<dict>
		<key>Hour</key>
		<integer>$HOUR</integer>
		<key>Minute</key>
		<integer>$MINUTE</integer>
	</dict>
</dict>
</plist>
EOF
echo "Created plist at $PLIST_PATH"

# Load the agent
launchctl load "$PLIST_PATH"
echo "Loaded agent — will open $URL daily at $(printf '%02d:%02d' "$HOUR" "$MINUTE")"

# Run once now to trigger the Automation permission prompt
echo "Opening now to trigger permissions — approve the prompt if macOS asks."
open "$APP_PATH"