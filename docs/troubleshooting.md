# Troubleshooting

## TV connection issues

### "failed to connect to remote target"
- TV is in standby. Wake it with WoL or power button.
- Check IP hasn't changed: `curl http://<TV_IP>:8001/api/v2/`
- Developer Mode may have expired. Re-enable it.

### "TV connection was not confirmed"
- SDB daemon not responding. Try: `sdb kill-server && sdb start-server`
- Firewall blocking port 26101. Check Windows Firewall.

### SDB shell returns empty output
- This is normal on Tizen 9. The shell is dead.
- Use the injection channel for any shell commands.
- Only `applist`, `vd_appinstall`, `vd_applaunch`, `vd_appuninstall`, and `execute` work via SDB directly.

## Install issues

### "download failed[16]"
- Use a fresh filename for the remote path (never reuse)
- Check config.xml validity with `tizen build-web`
- Ensure the wgt is properly signed

### "Author certificate not match"
- The app ID in config.xml doesn't match the certificate
- Re-sign with the correct profile

### "Invalid certificate chain"
- Distributor cert DUID doesn't match the TV
- Regenerate the distributor certificate with the correct DUID

## Native Home issues

### Home button opens wrong app
- Query current values: run helper in query mode
- If values are wrong, restore from baseline
- If restore fails, manually set via vconftool or helper

### Helper refuses to run
- Check firmware string matches
- Check app directory exists
- Check UID is 901
- Check BootSupported is non-zero

### Injection channel stops working
- Power cycle TV (wall unplug)
- Check Developer Mode is still enabled
- If all else fails, factory reset

## Common errors

### PowerShell BOM in JSON files
- PowerShell 5.1 `-Encoding utf8` writes BOM (EF BB BF)
- Python's json.loads fails on BOM
- Fix: use `[System.IO.File]::WriteAllText(path, content, (New-Object System.Text.UTF8Encoding($false)))`

### Package Manager GUI stalls
- Kill it: `taskkill /F /IM package-manager.exe`
- Use elevated CLI: `package-manager-cli.exe`
- Requires elevation

### tizen create has no templates
- `tizen create web-project` fails with "Cannot find template"
- Templates are in the IDE plugin, not the CLI
- Generate identity manually with CSPRNG (10 alphanumeric chars)

## Performance

### TV drops off network in standby
- All ports close in standby
- Wake with WoL magic packet or power button
- No need for another wall cycle

### High memory usage on host PC
- Docker/WSL consumes 1GB+
- Multiple browsers consume 500MB+ each
- Close unused apps, limit WSL memory via `.wslconfig`
