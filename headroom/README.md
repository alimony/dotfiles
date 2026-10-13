# Headroom proxy

How to run the [Headroom](https://docs.headroomlabs.ai/docs) proxy as a launchd agent on `127.0.0.1:8787`. Headroom compresses tool output before it reaches the model, for Claude Code and any other client that reads `ANTHROPIC_BASE_URL`.

## Before you start

- You need macOS and [uv](https://docs.astral.sh/uv/).
- `.exports` in this repo points new shells at the proxy, but only while the agent is installed.

## Install or update

Run the installer:

```bash
~/Documents/dotfiles/headroom/install.sh
```

It installs the pinned Headroom version, writes `~/Library/LaunchAgents/local.headroom.proxy.plist` and starts the proxy. Open a new terminal window afterwards, so that your shell picks up `ANTHROPIC_BASE_URL`.

To change a proxy setting, edit `local.headroom.proxy.plist` in this folder and run the installer again. To upgrade Headroom, change `HEADROOM_VERSION` in `install.sh` and run the installer again.

## Check the proxy

```bash
curl -s http://127.0.0.1:8787/readyz   # answers when the proxy is ready
headroom savings                       # tokens and cost saved
```

The proxy writes its log to `~/.headroom/logs/proxy-8787.log`.

## Skip the proxy for one session

Remote Control needs a direct connection to `api.anthropic.com`. Start that session without the proxy:

```bash
env -u ANTHROPIC_BASE_URL claude
```

## Debug a proxy that does not start

launchd discards the proxy's console output. To see it, stop the agent and run the same command in the foreground:

```bash
launchctl bootout gui/$(id -u)/local.headroom.proxy
HEADROOM_BEACON=off ~/.local/bin/headroom proxy --host 127.0.0.1 --port 8787 --mode cache
```

Press Ctrl+C when you are done, then run the installer to start the agent again.

## Remove

```bash
launchctl bootout gui/$(id -u)/local.headroom.proxy
rm ~/Library/LaunchAgents/local.headroom.proxy.plist
```

New shells then stop setting `ANTHROPIC_BASE_URL`. To remove Headroom itself, run `uv tool uninstall headroom-ai`.
