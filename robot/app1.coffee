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

  t = new ImageRef(target, offX, offY, template.width, template.height)
  for y in [0..template.height-1]
    for x in [0..template.width-1]
      dst = template.value(x,y)
      src = t.value(x,y)
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

  #sx = offX
  #sy = offY
  #ex = template.width + sx
  #ex = target.width if ex > target.width
  #ey = template.height + sy
  #ey = target.height if ey > target.height

  #for y in [sy..ey-1]
    #for x in [sx..ex-1]
      #dst = template.value(x - sx ,y - sy)
      #src = target.value(x,y)
      #if dst is 1
        #if src is 1
          #result.bb++
          #result.match++
        #else
          #result.bw++
      #else
        #if src is 1
          #result.wb++
        #else
          #result.match++
      #result.total++
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

    #if i is 2 and charfont.char is 'n'
      #t = new ImageRef(target, left, top, width, height)
      #t.print()
    for y in [top..top + height - charfont.img.height]
      for x in [left..left + width - charfont.img.width]
        result = matchFontImg(target, x, y, charfont.img)
        result.code = charfont.char
        result.x = x + left
        result.y = y + top
        localBest = updateBestMatchInChar(localBest, result)
        #console.log result.x + ',' + result.y if i is 2 and (charfont.char is 'p' or charfont.char is 'n')
        #console.log localBest if i is 2  and (charfont.char is 'p' or charfont.char is 'n')
        #console.log '----------' if i is 2  and (charfont.char is 'p' or charfont.char is 'n')

    #console.log localBest if i is 2  and (charfont.char is 'p' or charfont.char is 'n')

    bestMatch = updateBestBetweenChars(bestMatch, localBest)
    #console.log bestMatch if i is 2  and (charfont.char is 'p' or charfont.char is 'n')

    #console.log "======" if i is 2  and (charfont.char is 'p' or charfont.char is 'n')

  return bestMatch

decode = (target, splts, charfonts, codes)->
  roi = [
    [splts[0],  0, splts[1], target.height]
    [splts[1], 0, splts[2]-splts[1], target.height]
    [splts[2], 0, splts[3]-splts[2], target.height]
    [splts[3], 0, target.width-splts[3], target.height]
  ]
  #roi = [
    #[0,0,13,16]
    #[9,0,10,16]
    #[19,0,11,16]
    #[27,0,16,16]
  #]
  for i in [0..3]
    t = new ImageRef(target, roi[i][0], roi[i][1], roi[i][2], roi[i][3])
    t.print()
  #console.log roi
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
      left = i * 16
      imgRef = new ImageRef(img, left, 0, 16, 16)
      imgRef.fit()
      #imgRef.print()
      charfonts.push(new CharFont(char, imgRef))
    callback()

splt2 = (height, start, end)->
  console.log "liuchen" + start + "," + end
  for needle in [0..1]
    guaidian = 0
    for x in [start..end-2]
      if (height[x] - needle) * (height[x+1] - needle) <= 0 and height[x] isnt height[x+1]
        guaidian++
    if guaidian > 4
      break
  needle = needle-1
  guaidian = []
  for x in [start..end-2]
    if (height[x] - needle) * (height[x+1] - needle) <= 0 and height[x] isnt height[x+1]
      guaidian.push(x)
  console.log guaidian
  if guaidian.length > 1
    return guaidian[1] + 1
  else
    return parseInt((start+end)/2)
    #console.log parseInt(((start+end)/2))
    #console.log start + ', ' + end + '.....'
  console.log 'splt2 ' + needle

split = (targetRef)->
  height = []
  for x in [0..targetRef.width-1]
    height[x] = 0 unless height[x]?
    for y in [0..targetRef.height-1]
      if targetRef.value(x,y) is 1
        height[x]++

  str = ''
  for x in height
    str += ',' + x

  #console.log str
  needle = 0
  guaidian = []
  for x in [0..targetRef.width-3]
    if height[x] * height[x+1] <= 0 and height[x] isnt height[x+1]
      #console.log x
      guaidian.push(x)

  if guaidian.length >= 5
    return [0, guaidian[0]+1, guaidian[2]+1, guaidian[4]+1]
  else if guaidian.length = 4
    parts = [guaidian[0], guaidian[2] - guaidian[1] , targetRef.width-guaidian[3]]
    #console.log parts

    max = -1
    needSplit = -1
    for x in [0..parts.length-1]
      if parts[x] > max
        max = parts[x]
        needSplit = x

    console.log guaidian
    console.log needSplit
    switch needSplit
      when 0
        return [0, splt2(height, 0, guaidian[0]), guaidian[1]+1 , guaidian[3]+1]
      when 1
        return [0, guaidian[1]+1, splt2(height, guaidian[1]+1, guaidian[2]), guaidian[3]]
      when 2
        return [0, guaidian[0]+1 , guaidian[2]+1, splt2(height, guaidian[3] + 1, targetRef.width-1)]




#main
main = (filename)->
  charfonts = []
  loadCharFonts 'font2.png', '23456789abcdefghjkmnpqrstuvwxyz', charfonts, ()->
    ##test
    #for charfont in charfonts
      #charfont.print() if charfont.char is 'n' or charfont.char is 'p'
    target = new Image(filename)
    target.parse ()->
      #target.print()

      targetRef = new ImageRef(target, 0, 0, target.width, target.height)
      targetRef.fit()
      #targetRef.print()
      #left = target.width
      #top = target.height
      #right = -1
      #bottom = -1

      #for x in [0..target.width-1]
        #for y in [0..target.height-1]
          #if target.value(x,y) is 1
            #left = x if x < left
            #right = x if x > right
            #top = y if y < top
            #bottom = y if y > bottom

      #targetRef = new ImageRef(target, left, top, right - left, bottom - top)
      targetRef.print()

      splts = split(targetRef)
      #console.log splts



      # 根据颜色切割
      # 根据颜色去掉横线
      codes = [0,0,0,0]
      decode(targetRef, splts, charfonts, codes)

      console.log codes

main(process.argv[2])
