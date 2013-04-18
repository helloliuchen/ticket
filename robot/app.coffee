Shred = require('shred')
fs = require('fs')
shred = new Shred({logCurl: true})

req = shred.get({
  url: 'http://cgs1.stc.gov.cn/ValidateCode_SANXUE.aspx'
  headers: {
    'User-Agent': 'Safari'
  },
  on: {
    200:(resp)->
      temp = resp.content.body
      pos = temp.search('<!DOCTYPE html')
      img = temp.substr(0, pos)
      console.log temp
      fs.writeFileSync('temp.png', img)
      #console.log resp
      #console.log resp.content.body
  }
}
)

