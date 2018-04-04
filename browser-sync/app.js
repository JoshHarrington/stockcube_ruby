/**
 * Require Browsersync
 */
var browserSync = require('browser-sync');

/**
 * Run Browsersync with server config
 */
browserSync({
    proxy: "localhost:3000",
    files: ['app/assets, app/views'],
    snippetOptions: {
        rule: {
            match: /<\/head>/i,
            fn: function (snippet, match) {
            return snippet + match;
            }
        }
    }
});