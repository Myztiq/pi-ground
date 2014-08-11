gpio = require 'pi-gpio'

pin = 7
buttonPin = 11

poll = null

current = true
status = true

gpio.open pin, 'out up', (err)->
  console.log 'Error setting up led pin', err if err

  gpio.open buttonPin, 'in down', (err)->
    console.log 'Error setting up button pin', err if err


    poll = setInterval ->
      gpio.read buttonPin, (err, val)->
        console.log "error reading button pin", err if err

        if val != current
          current = val
          console.log 'Button status', val
          if val == 0
            status = !status
            console.log 'Status Changed to ', status
            gpio.write pin, status, (err)->
              console.log 'Error', err if err

    , 10

process.on 'SIGINT', ->
  console.log 'Cleaing up..'
  clearInterval(poll)
  gpio.write pin, true, (err)->
    console.log err if err
    gpio.close pin, ->
      gpio.close buttonPin, ->
        console.log 'Cleaned up pins';
        process.exit()