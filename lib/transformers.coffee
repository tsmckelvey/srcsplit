_ = require 'lodash'

Util = {
  RemoveBlankLines: (inArr) -> _.filter inArr, (line) -> line.trim() isnt ''
}

ReactCompat = {
  ConvertClassToClassName: (inArr) -> _.map inArr, (line) -> line.replace /class=/g, 'className=', 'gi'
}

module.exports = {
  Util
  ReactCompat
}