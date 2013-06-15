PNGReader = require('png.js')
fs = require('fs')

class Image
  constructor: (@filename)->
    return unless @filename? and typeof @filename is 'string'
    @reader = new PNGReader(fs.readFileSync(@filename))

  parse: (callback)=>
    @reader.parse (err, png)=>
      @width = png.getWidth()
      @height = png.getHeight()
      @data ||= []
      for x in [0..@width-1]
        for y in [0..@height-1]
          @data[x] ||= []
          @data[x][y] ||= @_binaryValue(png, x,y)
      callback()

  _binaryValue: (png, x,y)->
    [red, blue, green, alpha] = png.getPixel(x,y)
    if red + blue + green > 300
      return 0
    else
      return 1

  value: (x,y)->
    if x >= @width
      x = @width - 1
    if x <0
      x = 0
    if y >= @height
      y = @height - 1
    if y < 0
      y = 0
    @data[x][y]

  splite: (left, top, width, height)->
    img = new Image()
    img.width = width
    img.height = height
    img.data ||= []
    for x in [left..left + width - 1]
      for y in [top..top + height - 1]
        img.data[x-left] ||= []
        img.data[x-left][y-top] ||= @value(x, y)
    #console.log img.data
    return img

  print: ()->
    #console.log @height
    #console.log @width
    for y in [0..@height-1]
      str = ""
      for x in [0..@width-1]
        str += @value(x,y) + ' '
      console.log str
    console.log ""

module.exports = Image
