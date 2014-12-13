gpio = require 'pi-gpio'

players = require('../game/config').players

pins = []
for player in players
  pins.push player.led


openPins = (cb)->
  count = pins.length
  pins.forEach (pin, idx)->
    gpio.open pin, 'out up', (err)->
      if err
        console.log 'Error setting up pin', err
      count--
      if count == 0
        cb()


setPins = (value, cb)->
  count = pins.length

  pins.forEach (pin, idx)->
    gpio.write pin, value, (err)->
      if err
        console.log 'Error changing value of pin', err
      count--
      if count == 0
        cb()

canToggle = true
openPins ->
  pinStatus = true
  togglePins = ->
    pinStatus = !pinStatus
    setPins pinStatus, ->
      if canToggle
        setTimeout ->
          togglePins()
        , 10

  togglePins()


process.on 'SIGINT', ->
  canToggle = false
  setTimeout ->
    count = pins.length
    pins.forEach (pin)->
      gpio.write pin, true, (err)->
        if err
          console.log 'Error writing pin', err
        gpio.close pin, (err)->
          if err
            console.log 'Error closing pin', err
          count--
          if count == 0
            console.log 'Cleaned up all pins. Closing.'
            process.exit()
  , 100