noble = require('noble')

noble.startScanning()

noble.on 'discover', (data)->
  console.log 'Found new bluetooth device!', data

noble.on 'stateChange', (state)->
  console.log 'State Changed', state

process.on 'SIGINT', ->
  noble.stopScanning()
  process.exit()