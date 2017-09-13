# kiosk-demo-electron
[![Build status](https://ci.appveyor.com/api/projects/status/um6ul6dbwjrw913m/branch/master?svg=true)](https://ci.appveyor.com/project/syedhassaanahmed/kiosk-demo-electron/branch/master)

This Electron App demonstrates multi-screen Kiosk mode experience by creating an MSI package which executes [PowerShell scripts](https://github.com/syedhassaanahmed/kiosk-demo-electron/blob/master/tools/scripts/Install-ShellLauncher.ps1). Scripts toggle [Windows 10 Shell Launcher](https://docs.microsoft.com/en-us/windows-hardware/customize/enterprise/shell-launcher) as well as set the kiosk user to [AutoLogon](https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon). Creating an MSI makes sure we can distribute our app to multiple kiosks via MDM e.g [Microsoft Intune](https://docs.microsoft.com/en-us/intune/apps-add).

## Create Installer
- On Windows `npm run dist` will build everything and create the MSI in `dist` folder.
- On Linux use `npm run dist:wine`. Script assumes that Wine is installed and properly configured. Pay attention to long file paths otherwise you might run into [error LGHT0103 : The system cannot find the file](https://github.com/wixtoolset/issues/issues/5314#issuecomment-329188877). **Note:** `Light.exe` has a [known issue with MSI validation on Wine](https://appdb.winehq.org/objectManager.php?sClass=version&iId=16248&iTestingId=39182) so it had to be turned off with `-sval` flag.
- If you'd like to use Docker, `npm run dist:docker` will spin up an instance of [this image](https://hub.docker.com/r/syedhassaanahmed/wix-node/), execute the above wine script and then copy artifacts back to host's `dist` folder. Script assumes that Docker daemon is running on host.

## Configure
Kiosk parameters are passed to the installer like this: `KioskDemoElectron.msi KIOSK_USERNAME=<kiosk user> KIOSK_PASSWORD=<kiosk password>`. All params have a default value as can be seen in [product.wxs](https://github.com/syedhassaanahmed/kiosk-demo-electron/blob/master/tools/product.wxs).

## How it works
- First we package the app using [electron-packager](https://github.com/electron-userland/electron-packager)
- Then we harvest binaries produced by electron-packager using WiX's [Heat tool](http://wixtoolset.org/documentation/manual/v3/overview/heat.html).
- We also copy our PowerShell script into the root of electron-packager output. We could let the harvester take care of PowerShell files as well, but we wanted to explicitly specify them in `product.wxs` with [Custom Actions](http://wixtoolset.org/documentation/manual/v3/wixdev/extensions/authoring_custom_actions.html).
- Output of harvest tool is `heat.wxs` which contains a [Fragment](https://www.firegiant.com/wix/tutorial/upgrades-and-modularization/fragments/) with list of files. We take that as well as `product.wxs` and pass it to the [Candle tool](http://wixtoolset.org/documentation/manual/v3/overview/candle.html). Candle is responsible for preprocessing .wxs files and generates compiled `.wixobj` files.
- Finally we use the [Light tool](http://wixtoolset.org/documentation/manual/v3/overview/light.html) to generate MSI from .wixobj.
- PowerShell Scripts are executed from [WiX Custom Actions](https://damienbod.com/2013/09/01/wix-installer-with-powershell-scripts/).

## Why WiX instead of electron-winstaller (Squirrel.Windows)?
In our case, WiX provides lot of flexibility in terms of configuring the installer;
- Passing params to the setup
- Executing elevated PowerShell during install/uninstall events
- Modifying config files based on setup params

## Troubleshoot
MSI logging can be enabled by executing the installer like this: `msiexec /i "setup.msi" /l*v "msi.log" PARAM=VALUE`. PowerShell log will be located at `C:\Windows\SysWOW64\powershell.log`.

## Telemetry
The solution uses [Application Insights](https://docs.microsoft.com/en-us/azure/application-insights/app-insights-nodejs) to collect basic telemetry data from the app. To enable it, please create an environment variable named `APPINSIGHTS_INSTRUMENTATIONKEY` and set it to the Instrumentation Key obtained from Azure portal.