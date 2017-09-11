function LogWrite
{
   param ($Logstring)
   $Logstring = "`n" + (Get-Date).ToUniversalTime() + " " + $Logstring
   Add-content "powershell.log" -value $Logstring
   Write-Host $Logstring
}

try {

    $COMPUTER = "localhost"
    $NAMESPACE = "root\standardcimv2\embedded"

    $ShellLauncherClass = [wmiclass]"\\$COMPUTER\${NAMESPACE}:WESL_UserSetting"
    
    $existingShell = Get-WmiObject -namespace $NAMESPACE -computer $COMPUTER -class WESL_UserSetting | Select-Object Sid
    if ($existingShell.Sid -ne $null) {        
        LogWrite("Removing existing custom shell for SID: " + $existingShell.Sid)
        $ShellLauncherClass.RemoveCustomShell($existingShell.Sid)
        }
    else {
        LogWrite("No existing custom shell found")
    }
    
    LogWrite("New settings for custom shells:")
    $shellSetting = Get-WmiObject -namespace $NAMESPACE -computer $COMPUTER -class WESL_UserSetting | Select-Object *
    LogWrite($shellSetting)
    
    $ShellLauncherClass.SetEnabled($FALSE)
    $IsShellLauncherEnabled = $ShellLauncherClass.IsEnabled()
    LogWrite("Shell Launcher Enabled is set to " + $IsShellLauncherEnabled.Enabled)

    Disable-WindowsOptionalFeature -online -FeatureName Client-EmbeddedShellLauncher -NoRestart

    # Reset Autologon registry
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty $RegPath "AutoAdminLogon" -Value "0" -type String  
    Set-ItemProperty $RegPath "DefaultUsername" -Value "" -type String  
    Set-ItemProperty $RegPath "DefaultPassword" -Value "" -type String
    Set-ItemProperty $RegPath "AutoLogonCount" -Value "0" -type DWord

} catch [Exception] {
    LogWrite($_.Exception.Message)
}