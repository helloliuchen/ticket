class CharFont
  constructor: (@char, @img)->

  print: ()->
    console.log @char
    @img.print()
    console.log "---"
module.exports = CharFont
