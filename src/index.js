const appInsights = require("applicationinsights")
if (process.env.APPINSIGHTS_INSTRUMENTATIONKEY !== undefined)
    appInsights.setup()
        .setAutoDependencyCorrelation(true)
        .setAutoCollectRequests(true)
        .setAutoCollectPerformance(true)
        .setAutoCollectExceptions(true)
        .setAutoCollectDependencies(true)
        .start()

const { app, BrowserWindow} = require('electron')

let mainWindow = null

app.on('ready', _ => {
    mainWindow = new BrowserWindow({
        kiosk: true,
        autoHideMenuBar: true
    })

    mainWindow.loadURL(`file://${__dirname}/kiosk.html`)

    mainWindow.on('close', _ => {
        mainWindow = null
        app.quit()
    })
})