# kiosk-demo-electron
This Electron App demonstrates Kiosk mode and creates .msi package which executes a [PowerShell script](https://github.com/syedhassaanahmed/kiosk-demo-electron/blob/master/installer/Install-ShellLauncher.ps1) to enable [Windows 10 Shell Launcher](https://docs.microsoft.com/en-us/windows-hardware/customize/enterprise/shell-launcher) and set the app executable as custom shell.

Creating an .msi makes sure we can distribute our app to multiple kiosks via MDM e.g [Microsoft Intune](https://docs.microsoft.com/en-us/intune/apps-add).

## Create Installer
`npm run dist` will build everything and create the .msi in `dist` folder.

## Description
- First we package the app using [electron-packager](https://github.com/electron-userland/electron-packager)
- Then we create a [squirrel installer (.exe)](https://github.com/Squirrel/Squirrel.Windows) using [electron-winstaller](https://github.com/electron/windows-installer)
- Squirrel package is then wrapped in an .msi using [MSI Wrapper](http://www.exemsi.com/documentation/msi-build-scripts) which makes sure we don't end up with double entries in `Add or remove programs` as well as execute the inside PowerShell script in an elevated way. 
- Script is actually executed from squirrel [post-install events](https://github.com/syedhassaanahmed/kiosk-demo-electron/blob/master/installer/setupEvents.js) via [node-powershell](https://github.com/rannn505/node-powershell).

## Troubleshoot
All logs (Squirrel setup, install events as well as PowerShell) will be located at `%userprofile%\AppData\Local\SquirrelTemp`

## Limitation
Currently, the user for which custom shell will be enabled, is hardcoded inside Squirrel events (`kioskelectron`). Reason for that is because Squirrel doesn't yet support [passing arguments to Setup.exe](https://github.com/Squirrel/Squirrel.Windows/issues/839).