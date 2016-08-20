require('../styles/main.scss');
global.jQuery = require('jquery');
require('bootstrap');

// inject bundled Elm app into div#main
const Direct = require('./elm/Direct').Direct;
const Reversed = require('./elm/Reversed').Reversed;
Direct.embed(document.getElementById('container-direct'), require('./elm/Direct.scss'));
global.jQuery('a[href="#reversed"]').on('shown.bs.tab', function () {
  Reversed.embed(document.getElementById('container-reversed'), require('./elm/Reversed.scss'));
});
