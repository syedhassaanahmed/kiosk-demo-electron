param($exeName)

Function LogWrite
{
   Param ([string]$logstring)
   $logstring = "`n" + (Get-Date).ToUniversalTime() + " " + $logstring
   Add-content "powershell.log" -value $logstring
   Write-Host $logstring
}

LogWrite("exeName is " + $exeName)

try {

    #Enable-WindowsOptionalFeature -online -FeatureName Client-EmbeddedShellLauncher -all
       
    $COMPUTER = "localhost"
    $NAMESPACE = "root\standardcimv2\embedded"

    $ShellLauncherClass = [wmiclass]"\\$COMPUTER\${NAMESPACE}:WESL_UserSetting"
    $ShellLauncherClass.SetEnabled($TRUE)
    $IsShellLauncherEnabled = $ShellLauncherClass.IsEnabled()
    LogWrite("Shell Launcher Enabled is set to " + $IsShellLauncherEnabled.Enabled)

    function Get-UsernameSID($AccountName) {
        $NTUserObject = New-Object System.Security.Principal.NTAccount($AccountName)
        $NTUserSID = $NTUserObject.Translate([System.Security.Principal.SecurityIdentifier])
        return $NTUserSID.Value
    }
    
    $Cashier_SID = Get-UsernameSID("kioskelectron")
    LogWrite("Cashier_SID is " + $Cashier_SID)

    try {
        $ShellLauncherClass.RemoveCustomShell($Cashier_SID)
        } catch [Exception] { }
    
    $restart_shell = 0
    $ShellLauncherClass.SetCustomShell($Cashier_SID, $exeName, ($null), ($null), $restart_shell)
    
    LogWrite("New settings for custom shells:")
    $shellSetting = Get-WmiObject -namespace $NAMESPACE -computer $COMPUTER -class WESL_UserSetting | Select-Object Sid, Shell, DefaultAction
    LogWrite($shellSetting)

} catch [Exception] {
    LogWrite($_.Exception.Message)
}