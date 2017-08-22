param([string]$userName)

function LogWrite
{
   Param ([string]$logstring)
   $logstring = "`n" + (Get-Date).ToUniversalTime() + " " + $logstring
   Add-content "powershell.log" -value $logstring
   Write-Host $logstring
}

try {

    $COMPUTER = "localhost"
    $NAMESPACE = "root\standardcimv2\embedded"

    $ShellLauncherClass = [wmiclass]"\\$COMPUTER\${NAMESPACE}:WESL_UserSetting"
    
    function Get-UsernameSID($AccountName) {
        $NTUserObject = New-Object System.Security.Principal.NTAccount($AccountName)
        $NTUserSID = $NTUserObject.Translate([System.Security.Principal.SecurityIdentifier])
        return $NTUserSID.Value
    }
    
    LogWrite("userName is " + $userName)
    $Cashier_SID = Get-UsernameSID($userName)
    LogWrite("Cashier_SID is " + $Cashier_SID)
    
    try {
        $ShellLauncherClass.RemoveCustomShell($Cashier_SID)
        } catch [Exception] {
            LogWrite("No existing custom shell found")
        }
    
    LogWrite("New settings for custom shells:")
    $shellSetting = Get-WmiObject -namespace $NAMESPACE -computer $COMPUTER -class WESL_UserSetting | Select-Object Sid, Shell, DefaultAction
    LogWrite($shellSetting)
    
    $ShellLauncherClass.SetEnabled($FALSE)
    $IsShellLauncherEnabled = $ShellLauncherClass.IsEnabled()
    LogWrite("Shell Launcher Enabled is set to " + $IsShellLauncherEnabled.Enabled)

} catch [Exception] {
    LogWrite($_.Exception.Message)
}