param($UserName, $Password, $ExeName, $AutoLogonCount)

function LogWrite
{
   param ($Logstring)
   $Logstring = "`n" + (Get-Date).ToUniversalTime() + " " + $Logstring
   Add-content "powershell.log" -value $Logstring
   Write-Host $Logstring
}

try {

    Enable-WindowsOptionalFeature -online -FeatureName Client-EmbeddedShellLauncher -all -NoRestart
       
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
    
    LogWrite("UserName is " + $UserName)
    $Cashier_SID = Get-UsernameSID($UserName)
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

    LogWrite("ExeName is " + $ExeName)    
    $ShellLauncherClass.SetCustomShell($Cashier_SID, $ExeName, ($null), ($null), $restart_shell)
    
    LogWrite("New settings for custom shells:")
    $shellSetting = Get-WmiObject -namespace $NAMESPACE -computer $COMPUTER -class WESL_UserSetting | Select-Object Sid, Shell, DefaultAction
    LogWrite($shellSetting)

    # Set Autologon registry
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String
    Set-ItemProperty $RegPath "DefaultUsername" -Value "$UserName" -type String
    Set-ItemProperty $RegPath "DefaultPassword" -Value "$Password" -type String
    Set-ItemProperty $RegPath "AutoLogonCount" -Value "$AutoLogonCount" -type DWord

} catch [Exception] {
    LogWrite($_.Exception.Message)
}