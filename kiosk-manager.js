const electron = require('electron');

function KioskManager (window) {
    this.window = window;
    this.allScreenDimensions = electron.screen.getAllDisplays();
    this.screenWindows = new Array(this.allScreenDimensions.length);

    this.getWindowForScreenIndex = (screnIndex) => {
        return this.screenWindows(screenIndex);
    };

    this.openWindowForScreenIndex = (url, screenIndex) => {
        let dimensions = this.allScreenDimensions[screenIndex];
        let featureString = this._buildFeatureString(dimensions);

        console.log(dimensions);
        console.log(featureString);

        let newWindow = this.window.open(url, '', featureString);
        this.screenWindows[screenIndex] = newWindow;
    };

    this.closeWindowForScreenIndex = (screenIndex) => {
        let closingWindow = this.getWindowForScreenIndex(screenIndex);
        closingWindow.close();

        this.screenWindows[screenIndex] = undefined;
    };

    this._buildFeatureString = (dimensions) => {
        return `x=${dimensions.bounds.x},y=${dimensions.bounds.y}`
    };
};

const bindModule = (window) => {
    return new KioskManager(window);
}

module.exports = bindModule;