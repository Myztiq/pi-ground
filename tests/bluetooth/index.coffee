bleno = require('bleno')

name = 'BGTimer';
serviceUuids = ['FFF0']

bleno.on 'stateChange', (state)->
  console.log 'State changed to: ' + state
  bleno.startAdvertising name, serviceUuids, (err)->
    console.log err if err

bleno.on 'accept', (clientAddr)->
  console.log 'Accepted connection from ', clientAddr

bleno.on 'disconnect', (clientAddr)->
  console.log 'Client disconnected', clientAddr

bleno.on 'rssiUpdate', (rssi)->
  console.log 'RSSI Updated', rssi

bleno.on 'servicesSet', (err)->
  console.log 'Services Set'
  console.log err if err

value = false

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
          properties: [ 'read', 'notify' ]
          value: value
          onSubscribe: (maxValueSize, updateValueCallback)->
            # TODO - Get this moved out into separate files, and hooked up into the button/LED info. Perhaps even start figuring out users
            console.log 'maxValueSize', maxValueSize
            value = 'foo+' + Math.random()
            updateValueCallback(new Buffer(value))
      ]
    bleno.setServices [primaryService], (err)->
      console.log 'Error setting services', err if err

bleno.on 'advertisingStartError', (err)->

process.on 'SIGINT', ->
  bleno.stopAdvertising ()->
    console.log ''
    console.log 'Stopped Advertising'
    process.exit()