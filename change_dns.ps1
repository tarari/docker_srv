start-process PowerShell -verb runas
Set-DnsClientServerAddress -InterfaceAlias "Ethernet*" -ServerAddresses ("10.0.3.250","8.8.8.8")
Get-DnsClientServerAddress -InterfaceAlias "Ethernet*"
ipconfig /flushdns
