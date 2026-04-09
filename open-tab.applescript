-- Open a URL in a new Chrome tab
-- Usage: osascript open-tab.applescript <URL>

on run argv
	if (count of argv) is 0 then
		error "Usage: osascript open-tab.applescript <URL>"
	end if

	set targetURL to item 1 of argv

	tell application "Google Chrome"
		activate

		if (count of windows) is 0 then
			make new window
		end if

		tell front window
			make new tab with properties {URL:targetURL}
		end tell
	end tell
end run
