const kioskManager = require('./kiosk-manager')(window);

const express = require('express')
const serveStatic = require('serve-static')

const app = express()

app.use(serveStatic('content-package/', {'index': false}))
app.listen(3000)

const content = [
    'http://localhost:3000/sale.html',
    'http://localhost:3000/burgers.html',
    'http://localhost:3000/shoes.html'
];

for (let index=0; index < kioskManager.allScreenDimensions.length; index++) {
    kioskManager.openWindowForScreenIndex(content[index], index);
}