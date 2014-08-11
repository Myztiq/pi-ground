gpio = require 'pi-gpio'

pin = 7

gpio.open pin, 'out up', (err)->
  console.log 'Error setting up pin'

  count = 0

  setInterval ->
    count++
    value = count % 2 == 0
    gpio.write pin, value, (err)->
      console.log 'Error turning pin on', err if err
  , 50

process.on 'SIGINT', ->
  gpio.write pin, true, (err)->
    gpio.close(pin) ->
      console.log 'Cleaned up pins';
      process.exit();