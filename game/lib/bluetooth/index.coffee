bleno = require('bleno')
PlayerService = require './services/player'

process.on 'exit', -> bleno.stopAdvertising()


module.exports =
  setup: (name, players)->
    serviceUuids = []
    services = []
    for player in players
      serviceUuids.push "1#{player.id}00"
      services.push new PlayerService
        player: player
        prefix: "2#{player.id}"
        serviceId: "1#{player.id}00"

    bleno.on 'advertisingStart', (err)->
      bleno.setServices services, (err)->
        if err
          console.log 'Error setting services', err
        else
          console.log 'Set Services'

    bleno.startAdvertising name, serviceUuids, (err)->
      if err
        console.log err
      else
        console.log 'Started Advertising'

bleno.on 'stateChange', (state)->
  console.log 'State changed to: ' + state

bleno.on 'accept', (clientAddr)->
  console.log 'Accepted connection from ', clientAddr

bleno.on 'disconnect', (clientAddr)->
  console.log 'Client disconnected', clientAddr

bleno.on 'rssiUpdate', (rssi)->
  console.log 'RSSI Updated', rssi

bleno.on 'servicesSet', (err)->
  if err
    console.log 'Error setting services', err
  else
    console.log 'Services Set'
