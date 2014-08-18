gpio = require 'pi-gpio'

pin = 23

gpio.open pin, 'out up', (err)->
  if err
    console.log 'Error setting up pin', err

  count = 0

  setInterval ->
    count++
    value = count % 2 == 0
    console.log 'Set to ', value
    gpio.write pin, value, (err)->
      console.log 'Error turning pin on', err if err
  , 1000

process.on 'SIGINT', ->
  gpio.write pin, true, (err)->
    gpio.close(pin) ->
      console.log 'Cleaned up pins';
      process.exit();