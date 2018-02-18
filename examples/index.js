'use strict';

require('../styles/table.scss')

global.$ = require('jquery')
global.Popper = require('popper.js')

require('bootstrap')


const ex1 = require('./src/Example1')
  .Example1.embed(document.getElementById('example1'))

ex1.ports.toggleModal.subscribe((id) => {
  $(`#${id}`).modal('toggle')
})

require('./src/Example2')
  .Example2
  .embed(document.getElementById('example2'))


require('./src/Example3')
  .Example3
  .embed(document.getElementById('example3'))

