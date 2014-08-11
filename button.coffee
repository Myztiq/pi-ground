gpio = require 'rpi-gpio'

pin = 7

gpio.setup pin, gpio.DIR_OUT, ->
  gpio.write pin, true, (err)->
    if err
      console.log "ERROR: ", err

gpio.write pin, true, (err)->
  console.log 'On'
  if err
    console.log 'Error turning pin on', err


process.on 'SIGINT', ->
  gpio.destroy ->
    console.log 'Cleaned up pins';
    process.exit();