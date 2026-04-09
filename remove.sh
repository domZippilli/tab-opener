#!/bin/bash
# remove.sh — Uninstall the open-tab Launch Agent and app
# Usage: ./remove.sh

PLIST_NAME="com.$USER.open-tab"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_NAME.plist"
APP_PATH="$HOME/Applications/OpenTab.app"

# Unload the agent if it's running
if launchctl list | grep -q "$PLIST_NAME"; then
    launchctl unload "$PLIST_PATH" 2>/dev/null
    echo "Unloaded agent"
fi

# Remove the plist
if [ -f "$PLIST_PATH" ]; then
    rm "$PLIST_PATH"
    echo "Removed $PLIST_PATH"
else
    echo "No plist found at $PLIST_PATH"
fi

# Remove the app
if [ -d "$APP_PATH" ]; then
    rm -rf "$APP_PATH"
    echo "Removed $APP_PATH"
else
    echo "No app found at $APP_PATH"
fi

echo "Done — open-tab has been uninstalled"
