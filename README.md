# kiosk-demo-electron
[![Build status](https://ci.appveyor.com/api/projects/status/um6ul6dbwjrw913m/branch/master?svg=true)](https://ci.appveyor.com/project/syedhassaanahmed/kiosk-demo-electron/branch/master)

This Electron App demonstrates multi-screen Kiosk mode experience by creating an .msi package which executes a [PowerShell script](https://github.com/syedhassaanahmed/kiosk-demo-electron/blob/master/src/installer/Install-ShellLauncher.ps1). Script enables [Windows 10 Shell Launcher](https://docs.microsoft.com/en-us/windows-hardware/customize/enterprise/shell-launcher) as well as set the kiosk user to [AutoLogon](https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon). Creating an .msi makes sure we can distribute our app to multiple kiosks via MDM e.g [Microsoft Intune](https://docs.microsoft.com/en-us/intune/apps-add).

## Configure
Kiosk parameters are read from `config.json` inside [Squirrel events](https://github.com/syedhassaanahmed/kiosk-demo-electron/blob/master/src/installer/setupEvents.js). That's because Squirrel doesn't support [passing arguments to Setup.exe](https://github.com/Squirrel/Squirrel.Windows/issues/839) yet. Please create a config file in `src` folder with the following content; 
```json
{ 
    "kioskUserName": "<put your username here>",
    "kioskPassword": "<put your kiosk password>",
    "autoLogonCount": "<number of times system would reboot without asking for credentials>"
}
```

## Caveats
- electron-packager had an [issue with npm v5.3.0](https://github.com/electron-userland/electron-packager/issues/686), so please use an updated version of npm (`npm update -g npm`).
- Due to an [electron-winstaller limitation](https://github.com/syedhassaanahmed/kiosk-demo-electron/blob/fcddc95c542f43141e1bee073837b26b2b6991d1/package.json#L2), `name` and `productName` fields in `src/package.json` must not contain special characters. e.g `"-"`.
- `productName`, `description` and `author` fields are [required in src/package.json](https://github.com/electron-userland/electron-forge/issues/207#issuecomment-297192973) for electron-winstaller to work.
- In order for node-powershell to execute the PowerShell script successfully, please make sure that you're **NOT using** [asar](https://electron.atom.io/docs/tutorial/application-packaging/), i.e remove `--asar=true` from electron-packager.
- [MSI Wrapper](http://www.exemsi.com/download) **must be installed** on your machine in order to create the .msi, otherwise you'll get 

`Retrieving the COM class factory for component with CLSID {06983BA0-AE1E-43B4-83B6-8D6D5DFA5CEB} failed due to the following error: 80040154 Class not registered (Exception from HRESULT: 0x80040154 (REGDB_E_CLASSNOTREG)).`

## Create Installer
`npm run dist` will build everything and create the .msi in `dist` folder.

## How it works
- First we package the app using [electron-packager](https://github.com/electron-userland/electron-packager)
- Then we create a [squirrel installer (.exe)](https://github.com/Squirrel/Squirrel.Windows) using [electron-winstaller](https://github.com/electron/windows-installer)
- Squirrel package is then wrapped in an .msi using [MSI Wrapper script](http://www.exemsi.com/documentation/msi-build-scripts) which makes sure we don't end up with double entries in `Add or remove programs` as well as execute the inside PowerShell script in an elevated way. 
- Script is actually executed from squirrel [post-install events](https://github.com/Squirrel/Squirrel.Windows/blob/master/docs/using/custom-squirrel-events-non-cs.md) via [node-powershell](https://github.com/rannn505/node-powershell).

## Telemetry
The solution uses [Application Insights](https://docs.microsoft.com/en-us/azure/application-insights/app-insights-nodejs) to collect basic telemetry data from the app. To enable it, please add a key named `appInsightsInstrumentationKey` in `src/config.json` and set it to the Instrumentation Key obtained from Azure portal.

## Troubleshoot
All logs (Squirrel setup, install events as well as PowerShell) will be located at `%localappdata%\SquirrelTemp`