# Native Home Reassignment

## Overview

This is the high-risk, undocumented part. It reassigns the TV's physical Home button to open CleanFrame instead of Samsung Home.

**Read [risks.md](risks.md) before proceeding.**

## How it works

Samsung TVs use `vconf` (a key-value store) and an app operation binding to determine what opens when you press Home. The relevant values:

| Key | Type | Purpose |
|---|---|---|
| `db/appfw/home_appid` | string | Home button target |
| `db/appfw/startup_appid` | string | Startup app |
| `db/appfw/booting_appid_backup` | string | Boot backup |
| `db/first_screen/type` | string | First screen type |
| `db/menu/smart_hub/ontvsetting/auto_start` | int | Home autostart (0/1) |
| `http://tizen.org/appcontrol/operation/main` | operation | Home operation binding |

## The injection channel

The TV's SDB shell is dead (returns `closed`). But there's a workaround using the package-name parser:

1. Push a shell script to `/home/owner/share/tmp/sdk_tools/`
2. Encode a bash command as base64
3. Create a fake package name: `new2.tpk\`printf ...base64...-d|bash\`.tpk`
4. Run `sdb shell 0 appinstall tpk <fake_name>`
5. The SDB daemon parses the package name and executes the injected command as UID 901
6. Output is sent back via TCP callback to the host PC

## The .NET helper

A compiled .NET 6 app (linux-arm) that calls native libraries via P/Invoke:

```csharp
[DllImport("libvconf.so.0")] static extern int vconf_set_str(string key, string value);
[DllImport("libaul.so.0")] static extern int aul_svc_set_operation(IntPtr b, string op);
[DllImport("libcapi-appfw-app-operation-tv.so.0")] static extern int app_operation_set_current_app(string op, string app);
```

### Adaptation for your TV

1. Change `Target` to your app ID
2. Change firmware check: `info.Contains("Version=YOUR_FIRMWARE;")`
3. Change directory check: `Directory.Exists("/opt/usr/apps/YOUR_PACKAGE")`
4. Build: `dotnet publish -c Release -r linux-arm --self-contained false`
5. Push DLL + runtimeconfig + deps to TV
6. Run: `/usr/bin/dotnet /path/to/helper.dll query|apply|restore <baseline>`

### Usage

```bash
# Query (read-only)
/usr/bin/dotnet helper.dll query

# Apply (requires baseline file)
/usr/bin/dotnet helper.dll apply original.json

# Restore (revert to original)
/usr/bin/dotnet helper.dll restore original.json
```

### The baseline file

Save the query output as `original.json` before applying. **Never overwrite it with applied state.**

```json
{
  "Home": "com.samsung.tv.csfs",
  "Strings": {
    "db/appfw/home_appid": "com.samsung.tv.csfs",
    "db/appfw/startup_appid": "com.samsung.tv.csfs",
    "db/appfw/booting_appid_backup": "com.samsung.tv.csfs",
    "db/first_screen/type": "com.samsung.tv.csfs"
  },
  "Autostart": 1,
  "Uid": 901,
  "BootSupported": 1
}
```

### Apply → Verify → Restore → Reapply

1. **Apply**: Run apply, read back values
2. **Verify**: Press Home button, confirm CleanFrame opens
3. **Restore**: Run restore, read back values
4. **Verify**: Press Home button, confirm Samsung Home opens
5. **Reapply**: Run apply again (only if steps 3-4 passed)

This is the repo's exact sequence. Never skip the restore test.
