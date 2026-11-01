# Install an app on the TV via SDB
param(
  [Parameter(Mandatory=$true)][string]$AppId,
  [Parameter(Mandatory=$true)][string]$WgtPath,
  [string]$TvIp = "192.168.1.120",
  [string]$SdbPath = "C:\tizen-studio\tools\sdb.exe"
)
$serial = "${TvIp}:26101"
$remote = "/home/owner/share/tmp/sdk_tools/$(Split-Path $WgtPath -Leaf)"
& $SdbPath -s $serial connect $serial
& $SdbPath -s $serial push $WgtPath $remote
"--- installing ---"
& $sdb -s $serial shell 0 vd_appinstall $AppId $remote