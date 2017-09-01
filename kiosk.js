const kioskManager = require('./kiosk-manager')(window);

const express = require('express')
const serveStatic = require('serve-static')
const path = require('path');

const app = express()

app.use(serveStatic(path.join(__dirname, 'content-package'), {'index': false}));
app.listen(3000)

const content = [
    'http://localhost:3000/sale.html',
    'http://localhost:3000/burgers.html',
    'http://localhost:3000/shoes.html'
];

for (let index=0; index < kioskManager.allScreenDimensions.length; index++) {
    let newWindow = kioskManager.openWindowForScreenIndex(content[index], index);
    newWindow.onbeforeunload = function () {
        return false;
    }
}