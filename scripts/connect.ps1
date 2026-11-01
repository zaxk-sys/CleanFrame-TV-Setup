# Connect to TV via SDB
param(
  [string]$TvIp = "192.168.1.120",
  [string]$SdbPath = "C:\tizen-studio\tools\sdb.exe"
)
$serial = "${TvIp}:26101"
& $SdbPath connect $serial
& $SdbPath devices