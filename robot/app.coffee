Shred = require('shred')
fs = require('fs')
shred = new Shred({logCurl: true})
child = require('child_process')
Image = require('./Image')
ImageRef = require('./ImageRef')
CharFont = require('./CharFont')

matchFontImg = (target, offX, offY, template)->
  result =
    code: '0'
    x: 0
    y: 0
    bb: 0
    bw: 0
    wb: 0
    total: 0
    match: 0

  sx = offX
  sy = offY
  ex = template.width + sx
  ex = target.width if ex > target.width
  ey = template.height + sy
  ey = target.height if ey > target.height

  for y in [sy..ey-1]
    for x in [sx..ex-1]
      dst = template.value(x - sx ,y - sy)
      src = target.value(x,y)
      if dst is 1
        if src is 1
          result.bb++
          result.match++
        else
          result.bw++
      else
        if src is 1
          result.wb++
        else
          result.match++
      result.total++
  #console.log 'in matchFontImg ' + require('util').inspect(result)
  return result

updateBestMatchInChar= (best, result)->
  if result.bb > best.bb
    best = result
  return best

updateBestBetweenChars= (best, result)->
  if result.bb - result.bw > best.bb - best.bw
    best = result
  return best

matchchar= (target, roi, charfonts, i)->
  bestMatch =
      code: '0'
      x: 0
      y: 0
      bb: 0
      bw: 0
      wb: 0
      total: 0
      match: 0
  for charfont in charfonts
    #charfont.img.print()
    localBest = 
      code: '0'
      x: 0
      y: 0
      bb: 0
      bw: 0
      wb: 0
      total: 0
      match: 0
    left = roi[0]
    top = roi[1]
    width = roi[2]
    height = roi[3]

    for y in [top..top + height - charfont.img.height - 1]
      for x in [left..left + width - charfont.img.width - 1]
        result = matchFontImg(target, x, y, charfont.img)
        result.code = charfont.char
        result.x = x + left
        result.y = y + top
        localBest = updateBestMatchInChar(localBest, result)
        #console.log result.x + ',' + result.y
        #console.log localBest
        #console.log '----------'
    #console.log localBest
    bestMatch = updateBestBetweenChars(bestMatch, localBest)
    #console.log bestMatch
    #console.log "======"
  return bestMatch

decode = (target, charfonts, codes)->
  roi = [
    [3,  0, 16, 22]
    [15, 0, 18, 22]
    [23, 0, 20, 22]
    [35, 0, 18, 22]
  ]
  martchCharRet =
    code: '0'
    x: 0
    y: 0
    bb: 0
    bw: 0
    wb: 0
    total: 0
    match: 0
  for i in [0..3]
    result = matchchar(target, roi[i], charfonts, i)
    codes[i] = result.code


loadCharFonts = (filename, chars, charfonts, callback)->
  img = new Image(filename)
  img.parse ()->

    for i, char of chars
      left = i * 18
      imgRef = new ImageRef(img, left, 0, 18, 22)
      imgRef.fit()
      #imgRef.print()
      charfonts.push(new CharFont(char, imgRef))
    callback()




#main
main = (filename)->
  charfonts = []
  loadCharFonts 'font.png', '0123456789ABCDEFGHIJKLMNPQRSTUVWXYZ', charfonts, ()->
    ##test
    #for charfont in charfonts
      #charfont.print()
    target = new Image(filename)
    target.parse ()->
      #target.print()
      # 根据颜色切割
      # 根据颜色去掉横线
      codes = [0,0,0,0]
      decode(target, charfonts, codes)

      console.log codes

main(process.argv[2])
