gpio = require 'rpi-gpio'

ledPin = 7
buttonPin = 11

ledStatus = false

gpio.setup ledPin, gpio.DIR_OUT, ->

  gpio.on 'change', (channel, value)->
    console.log('Channel ' + channel + ' value is now ' + value);
    if channel == buttonPin
      ledStatus = !ledStatus
      gpio.write ledPin, ledStatus, (err)->
        console.log 'On'
        if err
          console.log 'Error turning pin on', err

  gpio.setup(buttonPin, gpio.DIR_IN, ->);

  gpio.write ledPin, true, (err)->
    console.log 'On'
    if err
      console.log 'Error turning pin on', err


process.on 'SIGINT', ->
  gpio.destroy ->
    console.log 'Cleaned up pins';
    process.exit();