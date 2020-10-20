$ports = @('2740', '2741', '2760-2791')

New-NetFirewallRule -DisplayName '1C_License_port' -Direction Inbound -Action Allow TCP -LocalPort $ports
