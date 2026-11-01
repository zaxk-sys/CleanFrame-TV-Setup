# Risk Assessment

## What can go wrong

### Native Home reassignment
- **Home button points to missing app**: If you uninstall CleanFrame without restoring first, the Home button tries to launch a non-existent app. Recovery: run the restore command via the injection channel.
- **Partial apply**: If apply fails midway, the helper attempts immediate restore. If restore also fails, Home may be in an inconsistent state. Recovery: manually set values via vconftool or the helper.
- **Firmware update**: A Samsung firmware update could change the vconf schema or close the injection channel. Recovery becomes much harder if the channel is closed.
- **TV becomes unusable**: In the worst case, the TV boots to a broken Home screen. Recovery may require factory reset (which loses all settings and apps).

### Certificate issues
- **Lost certificate password**: Cannot be recovered. You'd need to generate new certificates and reinstall the app as a different app ID.
- **Expired distributor cert**: Samsung distributor certs are valid for 1 year. After expiry, you can't install updates. Generate a new cert before expiry.
- **Wrong DUID**: If the distributor cert is bound to the wrong DUID, install fails with signature errors.

### General
- **Developer Mode expires**: Developer Mode may need to be re-enabled after firmware updates.
- **TV network changes**: If the TV's IP changes, all commands need updating.
- **Standby drops connection**: The TV closes all ports in standby. Wake-on-LAN or power-on required.

## Recovery procedures

### Restore Samsung Home (emergency)
```powershell
# Via the injection channel (same method as apply)
# Run helper.dll restore with the original baseline
```

### Factory reset (last resort)
1. Settings → General → Reset
2. This wipes everything including Developer Mode
3. Re-enable Developer Mode and start over

### If the injection channel stops working
1. Try power cycling the TV (wall unplug)
2. Check if Developer Mode is still enabled
3. If all else fails, factory reset

## What NOT to do
- Don't uninstall CleanFrame without restoring Home first
- Don't change the app identity after native Home is assigned
- Don't overwrite `.local/native-home/original.json` with applied state
- Don't run the helper on a different TV model/firmware
- Don't attempt root or security policy changes
