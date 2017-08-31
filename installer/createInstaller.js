const electronInstaller = require('electron-winstaller')
const config = require('../package.json')
const format = require('string-template')
const fs = require('fs')
const path = require('path')

const outputDirectory = './dist'
const appName = 'KioskDemoElectron'

let resultPromise = electronInstaller.createWindowsInstaller({
    appDirectory: path.join(outputDirectory, `${appName}-win32-x64`), 
    outputDirectory: outputDirectory,
    authors: config.author,
    noMsi: true //we'll do it with msi wrapper
  })

resultPromise.then(() => {
  const setupName = `${appName}Setup`
  const setupExePath = path.resolve(path.join(outputDirectory, `${setupName}.exe`))

  const encoding = 'utf-8'
  const msiTemplate = fs.readFileSync('./installer/msi-wrapper-template.xml', encoding)

  const finalMsiXml = format(msiTemplate, {
    msiOutputPath: path.resolve(path.join(outputDirectory, `${setupName}.msi`)),
    setupExePath: setupExePath,
    author: config.author,
    appVersion: config.version,
    productName: config.productName
  })

  console.log(finalMsiXml)

  fs.writeFileSync(path.join(outputDirectory, 'msi-wrapper.xml'), finalMsiXml, encoding)

}, (e) => console.log(`Error: ${e.message}`))