require('../styles/main.scss');
global.jQuery = require('jquery');
require('bootstrap');

// inject bundled Elm app into div#main
const Direct = require('./features/Direct').Direct;
const Reversed = require('./features/Reversed').Reversed;
Direct.embed(document.getElementById('container-direct'), require('./features/Direct.scss'));
global.jQuery('a[href="#reversed"]').on('shown.bs.tab', function () {
  Reversed.embed(document.getElementById('container-reversed'), require('./features/Reversed.scss'));
});
