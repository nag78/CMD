$servers = @('SRV1','SRV2','SRV3','SRV4', 'SRV5')
if (Test-Connection -ComputerName $servers[0] -Quiet -Count 1){
    Get-Content -Path "\\$($servers[0])\c$\App_configurqtion.txt"
}
Get-Content -Path "\\$($servers[1])\c$\App_configuration.txt"