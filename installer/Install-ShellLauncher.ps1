param([string]$userName, [string]$exeName)

function LogWrite
{
   Param ([string]$logstring)
   $logstring = "`n" + (Get-Date).ToUniversalTime() + " " + $logstring
   Add-content "powershell.log" -value $logstring
   Write-Host $logstring
}

try {

    Enable-WindowsOptionalFeature -online -FeatureName Client-EmbeddedShellLauncher -all
       
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
    
    LogWrite("userName is " + $userName)
    $Cashier_SID = Get-UsernameSID($userName)
    LogWrite("Cashier_SID is " + $Cashier_SID)

    try {
        # Remove previous custom shell otherwise setting it again will fail
        $ShellLauncherClass.RemoveCustomShell($Cashier_SID)
        } catch [Exception] { }
    
    $restart_shell = 0

    # Explicitly set default shell to explorer.exe otherwise modifying cutom shell would change it to cmd.exe for users other than cashier
    $ShellLauncherClass.SetDefaultShell("explorer.exe", $restart_shell)
    $DefaultShellObject = $ShellLauncherClass.GetDefaultShell()        
    LogWrite("Default Shell is set to " + $DefaultShellObject.Shell + " and the default action is set to " + $DefaultShellObject.defaultaction)

    LogWrite("exeName is " + $exeName)    
    $ShellLauncherClass.SetCustomShell($Cashier_SID, $exeName, ($null), ($null), $restart_shell)
    
    LogWrite("New settings for custom shells:")
    $shellSetting = Get-WmiObject -namespace $NAMESPACE -computer $COMPUTER -class WESL_UserSetting | Select-Object Sid, Shell, DefaultAction
    LogWrite($shellSetting)

} catch [Exception] {
    LogWrite($_.Exception.Message)
}