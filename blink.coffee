gpio = require 'pi-gpio'

pin = 7

gpio.open pin, 'out up', (err)->
  console.log 'Error setting up pin'

  count = 0

  setInterval ->
    count++
    if count % 2 == 0
      gpio.write pin, true, (err)->
        console.log 'On'
        if err
          console.log 'Error turning pin on', err
    else
      gpio.write pin, false, (err)->
        console.log 'Off'
        if err
          console.log 'Error turning pin off', err
  , 100

process.on 'SIGINT', ->
  gpio.close(pin) ->
    console.log 'Cleaned up pins';
    process.exit();