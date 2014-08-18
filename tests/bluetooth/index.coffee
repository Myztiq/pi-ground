bleno = require('bleno')

name = 'BGTimer';
serviceUuids = ['FFF0']

bleno.on 'stateChange', (state)->
  console.log 'on -> stateChange: ' + state
  bleno.startAdvertising name, serviceUuids, (err)->
    console.log err if err

bleno.on 'advertisingStart', (err)->
  if err
    console.log err
  else
    console.log 'Adversiting Start'
    PrimaryService = bleno.PrimaryService;
    primaryService = new PrimaryService
      uuid: 'FFF0'
      characteristics: [
        new bleno.Characteristic
          uuid: 'FF10'
          properties: [ 'read' ]
      ]
    bleno.setServices [primaryService], (err)->
      console.log 'Set Services'
      console.log 'Error setting services', err if err


bleno.on 'advertisingStartError', (err)->

process.on 'SIGINT', ->
  bleno.stopAdvertising()
  process.exit()