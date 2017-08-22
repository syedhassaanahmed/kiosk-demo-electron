# kiosk-demo-electron
This Electron App demonstrates Kiosk mode and creates .msi package which executes a PowerShell script to enable [Windows 10 Shell Launcher](https://docs.microsoft.com/en-us/windows-hardware/customize/enterprise/shell-launcher#a-href-idcustom-shellaset-your-custom-shell) and set the app executable as custom shell.

Creating an msi makes sure we can distribute our app to multiple kiosks via MDM (e.g Microsoft Intune).

`npm run dist` will create the msi in the `dist` folder.
