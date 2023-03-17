<# read config file #>
$config = Get-Content '.\config.json' | Out-String | ConvertFrom-Json

Start-Transcript -Append ".\logs\$((get-date).ToUniversalTime().ToString("yyyy-MM-dd-HHmmss")).log"

<# get all data from config #>
ForEach($conf in $config) {
    Write-Host "Clear Mail group '$($conf.groupIdentityName)' before seed" -ForegroundColor Green
    Get-ADGroupMember "$($conf.groupIdentityName)" | ForEach-Object {Remove-ADGroupMember "$($conf.groupIdentityName)" $_ -Confirm:$false}
    Write-Host "Adding members to group: '$($conf.groupIdentityName)'." -ForegroundColor Yellow
    ForEach($uDn in $conf.usersDn){
        $users = Get-ADUser -Filter * -SearchBase $uDn
        ForEach($u in $users) {
            <# add members to grops #>
            Add-ADGroupMember -Identity "$($conf.groupIdentityName)" -Members $u.SamAccountName
        }
    }
}
Write-Host "Done!" -ForegroundColor Cyan

Stop-Transcript