# Wake the TV via Wake-on-LAN
$macBytes = [byte[]]@(0xB0,0xF2,0xF6,0x25,0x00,0x1A)  # Replace with your TV's MAC
$packet = New-Object byte[] 102
for ($i = 0; $i -lt 6; $i++) { $packet[$i] = 0xFF }
for ($i = 0; $i -lt 16; $i++) {
  for ($j = 0; $j -lt 6; $j++) { $packet[6 + ($i * 6) + $j] = $macBytes[$j] }
}
$udp = New-Object System.Net.Sockets.UdpClient
$udp.EnableBroadcast = $true
$ep = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Broadcast, 9)
foreach ($n in 1..3) { $udp.Send($packet, $packet.Length, $ep) | Out-Null; Start-Sleep -Milliseconds 300 }
$udp.Close()
"Sent WoL magic packet"
Start-Sleep -Seconds 8
# Check if TV is awake
foreach ($port in 26101, 8001) {
  "Port ${port}: " + (Test-NetConnection -ComputerName "192.168.1.120" -Port $port -WarningAction SilentlyContinue -InformationLevel Quiet)
}