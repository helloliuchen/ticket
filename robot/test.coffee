Shred = require('shred')
fs = require('fs')
shred = new Shred({logCurl: true})
child = require('child_process')
Image = require('./Image')
CharFont = require('./CharFont')
quest= (i)->
  console.log 'process ' + i + ' .... '
  postfixt = ""
  for t in [0..i]
    postfixt += '?'
  shred.get({
    url: 'http://cgs1.stc.gov.cn/ValidateCode_SANXUE.aspx' + postfixt,
    headers: {
      'User-Agent': 'Safari'
    },
    on: {
      200: (resp)->
        filename = 'img/letter.' + i
        #console.log resp
        #console.log resp.content._body
        #console.log resp.content._body
        fs.writeFile filename + '.jpg' , resp.content._body, ()->
          #if i < 10
            #quest( i+1, filename)
          child.exec './textcleaner -g -f 30 -o 20 -t 30 -s 10 ' + filename + '.jpg ' + filename + '.png', ()->
            if i < 300
              quest( i+1, filename)
            else
              child.exec 'convert -append img/*.png img/eng.lc.exp1.png'
    }
  })


quest(0)
#reader = new ImageReader('font.png')

#parsed = ()->
  #console.log reader.getWidth()
#reader.parse(parsed)

#img = new Image('font.png')
#img.parse ()->
  #cf = [new CharFont('7', img.splite(0,0,12,22)),
        #new CharFont('8', img.splite(12,0,12,22)),
        #new CharFont('9', img.splite(24,0,12,22)),
        #new CharFont('S', img.splite(36,0,12,22)),
      #]
  #cf[0].print()
  #cf[1].print()
  #cf[2].print()
  #cf[3].print()
