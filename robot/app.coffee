Shred = require('shred')
fs = require('fs')
shred = new Shred({logCurl: true})
child = require('child_process')

#req = shred.get({
  #url: 'http://cgs1.stc.gov.cn/ValidateCode_SANXUE.aspx',
  #headers: {
    #'User-Agent': 'Safari'
  #},
  #on: {
    #200:(resp)->
      #fs.writeFile()
  #}
#}
#)

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
        filename = 'img/' + i + '.jpg'
        #console.log resp
        #console.log resp.content._body
        #console.log resp.content._body
        fs.writeFile filename, resp.content._body, ()->
          if i < 10
            quest( i+1, filename)
          #child.exec './textcleaner -g -f 30 -o 20 -t 30 -s 10 ' + filename + ' ' + filename, ()->
            #if i < 10
              #quest( i+1, filename)
    }
  })


quest(0)
