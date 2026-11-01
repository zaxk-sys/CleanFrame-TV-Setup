# Full Setup Guide

## Prerequisites

- Windows 10/11 PC on the same network as the TV
- Samsung TV with Developer Mode capability
- Samsung account (for certificate creation)
- Tizen Studio 6.1+ installed at `C:\tizen-studio` (no spaces in path)
- Python 3.11+ with `python3` shim
- Node.js 18+

## Phase 1: Enable Developer Mode on the TV

1. On the TV remote: **Home → Apps → Settings (gear) → Developer Mode → On**
2. Enter your PC's IP address (e.g., `192.168.1.190`)
3. **Unplug the TV from the wall** (not just standby) and plug back in
4. Verify: `curl http://<TV_IP>:8001/api/v2/` should show `"developerMode":"1"`

> Developer Mode survives standby after the initial power cycle.

## Phase 2: Install Tizen Studio

1. Download Tizen Studio from Samsung Developer
2. Install to `C:\tizen-studio` (no spaces)
3. Install TV extensions via elevated CLI:
   ```powershell
   # Kill Package Manager GUI first
   taskkill /F /IM package-manager.exe
   # Run CLI elevated
   & "C:\tizen-studio\package-manager\package-manager-cli.exe" install ...
   ```
4. Verify: `tizen security-profiles` works and `platforms/tizen-10.0` exists

## Phase 3: Create Samsung Certificate

1. Open Certificate Manager: `C:\tizen-studio\tools\certificate-manager\certificate-manager.exe`
2. Click **+** → Select **Samsung** → Next
3. Sign in with Samsung account
4. Author Certificate: name + password (8+ chars, upper+lower+number)
5. Distributor Certificate: select TV or enter DUID (TV's serial number, 13 chars)
6. Profile name: e.g., `Zak`
7. Verify: `tizen security-profiles list` shows your profile as active

> The TV's DUID is its serial number (13 chars), NOT the UUID from the API.

## Phase 4: Clone and Configure CleanFrame

```powershell
git clone https://github.com/nthnclrk/CleanFrame.git
cd CleanFrame
npm ci
```

Create `.local/signing.json` (gitignored):
```json
{
  "sdk_path": "C:/tizen-studio",
  "profile": "Zak",
  "package_id": "YOUR_10_CHAR_ID",
  "app_id": "YOUR_10_CHAR_ID.CleanFrame",
  "password_file": null
}
```

Create `.local/device.json` (BOM-free!):
```json
{"host": "192.168.1.120"}
```

> Use `[System.IO.File]::WriteAllText(path, content, (New-Object System.Text.UTF8Encoding($false)))` to avoid BOM.

## Phase 5: Generate App Identity

The Tizen SDK's project wizard generates a 10-character alphanumeric package ID. If you can't use the wizard (no templates installed), generate one with a CSPRNG:

```powershell
$bytes = New-Object byte[] 10
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
# ... (see scripts/generate-id.ps1)
```

Requirements: exactly 10 chars, alphanumeric, starts with letter.

## Phase 6: Package and Install

```powershell
npm run package          # Creates dist\CleanFrame.wgt
npm run tv:install       # Pushes and installs to TV
npm run tv:launch        # Launches the app
```

Verify: `sdb -s <TV_IP>:26101 shell 0 applist` should show your app ID.

## Phase 7: Native Home Reassignment (Optional, High Risk)

See [docs/native-home.md](native-home.md) for the full procedure.

**Summary:**
1. Query current values (read-only) via .NET helper
2. Save baseline to `.local/native-home/original.json`
3. Apply changes
4. Verify Home button opens CleanFrame
5. Test restore (revert to Samsung Home)
6. Verify restore worked
7. Reapply if desired

### How the injection works

The TV's SDB shell is dead (returns `closed` for all commands). But there's a workaround:

1. Push a shell script to `/home/owner/share/tmp/sdk_tools/`
2. Encode a bash command as base64
3. Create a fake package name: `new2.tpk\`printf ...base64...-d|bash\`.tpk`
4. Run `sdb shell 0 appinstall tpk <fake_name>`
5. The SDB daemon parses the package name and executes the injected command
6. The command runs as UID 901 (SDK user)
7. Output is sent back via a TCP callback to the host PC

This is the same method used by the CleanFrame project's native-home helper.

### The .NET helper

A compiled .NET 6 app (linux-arm) that calls native libraries:
- `libvconf.so` — read/write vconf keys
- `libaul.so` — set default app for operations
- `libcapi-appfw-app-operation-tv.so` — `app_operation_set_current_app`

It must be adapted for your TV:
- Change `Target` to your app ID
- Change firmware check to your firmware string
- Change directory check to your app's install path

### Values changed by apply
| Key | Before | After |
|---|---|---|
| Home operation | com.samsung.tv.csfs | your_app_id |
| db/appfw/home_appid | com.samsung.tv.csfs | your_app_id |
| db/appfw/startup_appid | com.samsung.tv.csfs | your_app_id (system-synced) |
| db/appfw/booting_appid_backup | com.samsung.tv.csfs | your_app_id (system-synced) |
| db/first_screen/type | com.samsung.tv.csfs | unchanged |
| db/menu/smart_hub/ontvsetting/auto_start | 1 | 1 (unchanged) |

## Phase 8: Custom App Shortcuts

Edit `app/main.js` → `PRIMARY_APPS` array. Each entry:
```js
{ id: 'unique_id', name: 'Display Name', mark: true/false, appId: 'com.example.app' }
```

- `mark: true` requires an SVG icon in `app/assets/icons/`
- `mark: false` shows a monogram (initials)
- `appId` must match an installed TV app's ID (verify via `sdb shell 0 applist`)

Verify app IDs exist on your TV before adding them. Common ones:
- Netflix: `org.tizen.netflix-app`
- YouTube: `9Ur5IzDKqV.TizenYouTube`
- Prime Video: `org.tizen.primevideo`
- Disney+: `MCmYXNxgcu.DisneyPlus`
- Apple TV: `com.samsung.tv.aria-video`
- Spotify: `rJeHak5zRg.Spotify`
- BBC iPlayer: `DqEoaplKlw.bbchybrid`
