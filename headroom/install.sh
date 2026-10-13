#!/usr/bin/env bash
# Install the pinned Headroom CLI and run its proxy as a launchd agent on 127.0.0.1:8787.
# Run it again after you edit local.headroom.proxy.plist or HEADROOM_VERSION.
set -euo pipefail

HEADROOM_VERSION="0.40.0"
LABEL="local.headroom.proxy"
PORT=8787
SOURCE="$(cd "$(dirname "$0")" && pwd)/$LABEL.plist"
TARGET="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"

if [ "$(uname)" != "Darwin" ]; then
	echo "This installer needs macOS, because it runs the proxy under launchd." >&2
	exit 1
fi
if ! command -v uv >/dev/null; then
	echo "uv is missing. Install it from https://docs.astral.sh/uv/ and run this again." >&2
	exit 1
fi

# `proxy` runs the server. `code` adds tree-sitter for code-aware compression.
uv tool install --python 3.13 "headroom-ai[proxy,code]==$HEADROOM_VERSION"

# Refuse to fight another process, such as an old Docker deployment, for the port.
agent_pid="$(launchctl print "$DOMAIN/$LABEL" 2>/dev/null | awk '$1 == "pid" { print $3; exit }' || true)"
for pid in $(lsof -nP -t -iTCP:"$PORT" -sTCP:LISTEN 2>/dev/null || true); do
	if [ "$pid" != "$agent_pid" ]; then
		echo "Port $PORT is in use by $(ps -o comm= -p "$pid") (PID $pid). Stop it and run this again." >&2
		exit 1
	fi
done

mkdir -p "$(dirname "$TARGET")"
sed "s|@HOME@|$HOME|g" "$SOURCE" > "$TARGET"
plutil -lint -s "$TARGET"

# Reload the agent. launchd can refuse the new job for a few seconds while it releases the old one.
launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
for attempt in $(seq 10); do
	if launchctl bootstrap "$DOMAIN" "$TARGET" 2>/dev/null; then
		break
	fi
	if [ "$attempt" = 10 ]; then
		echo "launchctl could not load $TARGET." >&2
		exit 1
	fi
	sleep 1
done

# Startup loads the compression models, which can take a while.
for _ in $(seq 60); do
	if curl -fsS "http://127.0.0.1:$PORT/readyz" >/dev/null 2>&1; then
		echo "Headroom $HEADROOM_VERSION is ready on 127.0.0.1:$PORT."
		exit 0
	fi
	sleep 1
done
echo "The proxy was not ready after 60 seconds. End of its log:" >&2
tail -n 20 "$HOME/.headroom/logs/proxy-$PORT.log" >&2
exit 1
