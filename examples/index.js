
import './styles/style.scss'

require('./src/Static').Elm.Static.init({
  node: document.getElementById('static')
})


require('./src/Dynamic').Elm.Dynamic.init({
  node: document.getElementById('dynamic')
})


require('./src/Subtable').Elm.Subtable.init({
  node: document.getElementById('subtable')
})
