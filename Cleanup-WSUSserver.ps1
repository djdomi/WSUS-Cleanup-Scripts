$server = ''
$port = ''
Write-Progress -Activity 'Getting WSUS server'
$WSUSserver = Get-WsusServer -Name $server -PortNumber $port
Write-Progress -Activity 'Getting approved updates, this may take a while...' -PercentComplete -1
$approvedupdates = Get-WsusUpdate -UpdateServer $WSUSserver -Approval Approved -Status InstalledOrNotApplicableOrNoStatus
Write-Progress -Activity 'Retrieved updates' -PercentComplete 90
$i = 0
$superseded = $approvedupdates | ? {$_.Update.IsSuperseded -eq $true -and $_.ComputersNeedingThisUpdate -eq 0}
$total = $superseded.count
foreach ($update in $superseded)
{
    Write-Progress -Activity 'Declining updates' -Status "$($update.Update.Title)" -PercentComplete (($i/$total) * 100)
    $update.Update.Decline()
    $i++
}

Write-Host "Total declined updates: $total" -ForegroundColor Yellow