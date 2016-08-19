require('../styles/main.scss');
global.jQuery = require('jquery');
require('bootstrap');

// inject bundled Elm app into div#main
const Direct = require('./features/Direct').Direct;
const Reversed = require('./features/Reversed').Reversed;
Direct.embed(document.getElementById('container-direct'), require('./features/Direct.scss'));
global.jQuery('a[href="#reversed"]').on('shown.bs.tab', function () {
  let app = Reversed.embed(document.getElementById('container-reversed'), require('./features/Reversed.scss'));
  app.ports.scroll.subscribe(function(cmd) {
    let containerId = cmd[0];
    let scrollTop = cmd[1];
    setTimeout(function() {
      var container = document.getElementById(containerId);
      container.scrollTop = scrollTop;
    }, 50);
  })
});
