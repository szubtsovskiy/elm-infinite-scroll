require('./styles/main.scss');
global.jQuery = require('jquery');
require('bootstrap');

// inject bundled Elm app into div#main
const Direct = require('./Direct').Direct;
const Reversed = require('./Reversed').Reversed;
Direct.embed(document.getElementById('container-direct'), require('./styles/Direct.scss'));
Reversed.embed(document.getElementById('container-reversed'));
