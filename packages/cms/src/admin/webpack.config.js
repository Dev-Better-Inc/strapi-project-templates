"use strict";
exports.__esModule = true;
exports["default"] = (function (config) {
    // Note: we provide webpack above so you should not `require` it
    // Perform customizations to webpack config
    // Important: return the modified config
    config.output.hashFunction = 'sha256';
    return config;
});
