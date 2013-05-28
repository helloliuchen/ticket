Image = require('./Image')

class ImageRef
  constructor: (@obj, @left, @top, @width, @height)->
    if (@obj instanceof Image or obj instanceof ImageRef)
      @ref = obj
    else
      console.log "error"

  fit: ()->
    # find left, top,right, bottom
    l = @width
    t = @height
    r = -1
    b = -1
    for y in [0..@height-1]
      for x in [0..@width-1]
        if @value(x,y) is 1
          l = x unless l < x
          t = y unless t < y
          r = x unless r > x
          b = y unless b > y
    @left += l
    @top += t
    @width = r - l + 1
    @height = b - t + 1

  value: (x, y)->
      @ref.value(@left + x, @top + y)


  print: ()->
    #if (@ref instanceof Image)
    for y in [0..@height-1]
      str = ""
      for x in [0..@width-1]
        str += @value(x,y) + ' '
      console.log str
    console.log ""


module.exports = ImageRef
