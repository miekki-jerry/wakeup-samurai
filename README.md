# Wake Samurai

Wake Samurai is a small open-source macOS menu bar app that keeps your Mac awake while AI coding agents are working in the background.

> Wake the f*ck up, Samurai. Your agent is still working.

The first version watches for Codex and Claude processes. When one is detected, Wake Samurai creates a macOS idle-sleep assertion. When no supported agent is running, the assertion is released.

## Why

Long-running coding agents can stop when macOS goes to sleep. Wake Samurai gives you a visible menu bar status and prevents idle sleep only while supported agents are active.

## Features

- Native macOS menu bar app
- Detects Codex and Claude processes
- Prevents idle sleep only while an agent is running
- Manual pause toggle
- Launch at login checkbox
- Simple off-App-Store packaging

## Requirements

- macOS 13 or newer
- Apple Silicon Mac for local release builds
- Xcode command line tools for development builds

## Install

Download `WakeSamurai.dmg` from the latest [GitHub Release](https://github.com/miekki-jerry/wake-samurai/releases/latest).

Do not use `Code -> Download ZIP` if you want to install the app. That ZIP is only the source code.

1. Open `WakeSamurai.dmg`.
2. Drag `Wake Samurai.app` into `Applications`.
3. Open Wake Samurai from `Applications`.

Current public builds are ad hoc signed because the project does not have a Developer ID certificate yet. On first launch, macOS may show:

```text
Apple could not verify “Wake Samurai” is free of malware.
```

For now:

1. Click `Done` in the warning dialog. Do not click `Move to Trash`.
2. Open `System Settings -> Privacy & Security`.
3. In the `Security` section, click `Open Anyway` for Wake Samurai.
4. Confirm the second launch prompt.

This is a temporary distribution limitation, not a privacy permission requirement. Wake Samurai does not need Accessibility, Full Disk Access, Screen Recording, or network permissions.

After a Developer ID certificate is available, releases should be signed and notarized so this extra step goes away.

## Build From Source

```bash
git clone https://github.com/miekki-jerry/wake-samurai.git
cd wake-samurai
./scripts/package.sh
open dist/Wake\ Samurai.app
```

For a distributable file:

```bash
open dist/WakeSamurai.dmg
```

## Development

Run tests:

```bash
swift test
```

Run locally:

```bash
swift run WakeSamurai
```

Build a release app bundle and DMG:

```bash
./scripts/package.sh
```

Regenerate the app icon:

```bash
./scripts/generate-icon.swift
```

## Detection Model

Wake Samurai intentionally starts simple. It scans the local process table and matches supported provider names:

- Codex: `codex`
- Claude: `claude`, `claude-code`

The scanner ignores Wake Samurai's own process. Future providers should be added in `Sources/WakeSamuraiCore/AgentProvider.swift` with focused tests.

## Security

Wake Samurai does not require admin privileges, network access, shell injection, or access to your code. It reads process names and command arguments through `/bin/ps`, then uses macOS power management APIs to prevent idle sleep.

Do not commit signing certificates, provisioning profiles, API keys, or private release credentials to this repository.

## License

MIT. See [LICENSE](LICENSE).
