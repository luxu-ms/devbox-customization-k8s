param (
    [Parameter()]
    [string]$RunAsUser
)

if($RunAsUser -eq "true") {
    $CustomizationScriptsDir = "C:\DevBoxCustomizations"
    $RunAsUserScript = "runAsUser.ps1"
    Add-Content -Path "$($CustomizationScriptsDir)\$($RunAsUserScript)" -Value "logoff"
}else{
    logoff
}
