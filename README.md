# CleanFrame on Samsung TV — Full Setup Guide

A complete record of deploying [CleanFrame](https://github.com/nthnclrk/CleanFrame) to a Samsung Crystal UHD TV (UE55U7000FKXXU), including the undocumented native Home button reassignment.

> **Warning:** This involves undocumented system modifications. Read the risks section before proceeding. This is not a recommendation — it's a record of an experiment on my own TV.

## What was achieved

- ✅ CleanFrame installed and running as a signed app
- ✅ Native Home button reassigned to open CleanFrame (via undocumented vconf injection)
- ✅ Verified restore/reapply cycle (rollback tested and passed)
- ✅ Custom app shortcuts (Netflix, BBC iPlayer, Prime Video, YouTube, Apple TV, Spotify)
- ✅ Samsung Home remains accessible via Back button / Settings

## Hardware

| Item | Value |
|---|---|
| TV | Samsung UE55U7000FKXXU (55" Crystal UHD) |
| Model string | 25_KSUE_UB |
| Firmware | T-KSU2EFDEUC-0090-1300.9 |
| Tizen | 9.0 |
| Architecture | armv7 / 32-bit ARM |
| Host PC | Windows 11, 192.168.1.190 |
| TV IP | 192.168.1.120 |

## Quick start

1. Read [docs/setup.md](docs/setup.md) for the full walkthrough
2. Read [docs/native-home.md](docs/native-home.md) before attempting Home reassignment
3. Read [docs/risks.md](docs/risks.md) to understand what can go wrong

## Repository structure

```
├── README.md
├── docs/
│   ├── setup.md              # Full setup walkthrough
│   ├── certificate.md        # Samsung certificate creation
│   ├── signing.md            # App identity and signing
│   ├── native-home.md        # Undocumented Home reassignment
│   ├── recovery.md           # Restore and rollback
│   ├── troubleshooting.md    # Common issues
│   └── risks.md              # Risk assessment
├── scripts/
│   ├── wake-tv.ps1           # Wake-on-LAN for the TV
│   ├── connect.ps1           # SDB connect helper
│   └── install-app.ps1       # Manual app install via SDB
└── .local-example/
    ├── signing.example.json  # Template for signing config
    └── device.example.json   # Template for device config
```

## Key lessons learned

1. **Developer Mode** requires a full wall-unplug power cycle (not just standby). Survives standby after that.
2. **Package Manager GUI** silently stalls. Use elevated `package-manager-cli.exe` instead.
3. **PowerShell 5.1 `-Encoding utf8` writes a BOM** — use `[System.IO.File]::WriteAllText(..., UTF8Encoding($false))` for files Python parses.
4. **The Tizen shell is dead** (`sdb shell 0 "echo"` returns nothing) but the **package-name injection workaround** still works on Tizen 9.
5. **Samsung distributor certs** are DUID-bound. The TV's serial number (13-char) is the DUID, not the UUID from the API.
6. **vconftool writes corrupt privilege fields** — use native `vconf_set_str` via a compiled helper instead.
7. **App identity must be unique** — never reuse the maintainer's `nClrkHome1` identity.
8. **Native Home reassignment** requires testing restore before keeping. Apply → verify → restore → verify → reapply.

## What doesn't work

- **Streaming in Tizen webviews** — HLS video requires AVPlay, which only works in dedicated apps, not webviews loading external sites
- **Overscan browser** — requires a partner certificate (not available with developer cert)
- **Samsung Internet video playback** — doesn't support HLS streams
- **Startup/power-on behavior** — setting `startup_appid` alone doesn't establish startup; the system manages this

## Credits

- [CleanFrame](https://github.com/nthnclrk/CleanFrame) by Nathan Clarke
- [couchroot](https://github.com/splitcipher/couchroot) by splitcipher (S90D native Home method)
- [Apps2Samsung/Overscan](https://github.com/Apps2Samsung/Overscan) (TV browser reference)
