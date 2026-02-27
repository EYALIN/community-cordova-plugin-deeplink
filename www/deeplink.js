var PLUGIN_NAME = 'DeeplinkPlugin';

var DeeplinkPlugin = {
    getLastDeepLink: function () {
        return new Promise(function (resolve, reject) {
            cordova.exec(resolve, reject, PLUGIN_NAME, 'getLastDeepLink', []);
        });
    },

    onDeepLink: function (callback) {
        cordova.exec(callback, function (err) {
            console.error('DeeplinkPlugin onDeepLink error:', err);
        }, PLUGIN_NAME, 'onDeepLink', []);
    },

    launchApp: function (url) {
        return new Promise(function (resolve, reject) {
            cordova.exec(resolve, reject, PLUGIN_NAME, 'launchApp', [url]);
        });
    }
};

module.exports = DeeplinkPlugin;
