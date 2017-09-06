const { app } = require('electron')
const path = require('path')
const shell = require('node-powershell')

let winston = require('winston')
winston.add(winston.transports.File, {
    filename: 'squirrel-events.log',
    handleExceptions: true,
    humanReadableUnhandledException: true
})

function runPowerShell(command, args = []) {
    winston.info(`Executing PowerShell Command: ${command}`)

    let ps = new shell({
        executionPolicy: 'Bypass',
        noProfile: true,
        debugMsg: true        
    })

    ps.addCommand(command, args)
    ps.invoke()
        .then(output => {
            winston.info('Powershell Output: ' + output)
            app.quit()
        })
        .catch(err => {
            winston.info('Powershell Errors: ' + err)
            ps.dispose()
            app.quit()
        })
}

module.exports = {
    handleSquirrelEvent: function () {
        if (process.argv.length === 1) {
            return false
        }

        winston.info('Squirrel arguments: ' + process.argv)

        const exeName = process.argv[0]
        const installerFolder = path.join(path.dirname(exeName), 'resources', 'app', 'installer')

        winston.info('PowerShell Script folder: ' + installerFolder)

        const squirrelEvent = process.argv[1]
        switch (squirrelEvent) {
            case '--squirrel-install':
            case '--squirrel-updated':
                winston.info('Squirrel Install/Update')

                const installCommand = path.join(installerFolder, 'Install-ShellLauncher.ps1')
                runPowerShell(installCommand, [
                    { userName: process.env.KIOSK_USER_NAME }, 
                    { exeName: exeName }
                ])

                return true

            case '--squirrel-uninstall':
                winston.info('Squirrel Uninstall')

                const uninstallCommand = path.join(installerFolder, 'Uninstall-ShellLauncher.ps1')
                runPowerShell(uninstallCommand, [{ userName: userName }])

                return true

            case '--squirrel-obsolete':
                app.quit()
                return true

        }
    }
}