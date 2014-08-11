gpio = require 'rpi-gpio'

pin = 7

gpio.setup pin, gpio.DIR_OUT, ->
  gpio.write pin, true, (err)->
    if err
      console.log "ERROR: ", err

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
, 1000

process.on 'SIGINT', ->
  gpio.destroy ->
    console.log 'Cleaned up pins';
    process.exit();