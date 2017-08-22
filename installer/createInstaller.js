const electronInstaller = require('electron-winstaller')
const format = require('string-template')
const fs = require('fs')
const path = require('path')

const outputDirectory = './dist'

let resultPromise = electronInstaller.createWindowsInstaller({
    appDirectory: path.join(outputDirectory, 'KioskDemoElectron-win32-x64'), 
    outputDirectory: outputDirectory,
    authors: 'Syed Hassaan Ahmed',
    noMsi: true //we'll do it with msi wrapper
  })

resultPromise.then(() => {
  const setupName = 'KioskDemoElectronSetup'
  const setupExePath = path.resolve(path.join(outputDirectory, `${setupName}.exe`))

  const encoding = 'utf-8'
  const msiTemplate = fs.readFileSync('./installer/msi-wrapper-template.xml', encoding)
  const finalMsiXml = format(msiTemplate, {
    msiOutputPath: path.join(outputDirectory, `${setupName}.msi`),
    setupExePath: setupExePath
  })

  console.log(finalMsiXml)

  fs.writeFileSync(path.join(outputDirectory, 'msi-wrapper.xml'), finalMsiXml, encoding)

}, (e) => console.log(`Error: ${e.message}`))