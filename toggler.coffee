gpio = require 'pi-gpio'
Promise = require 'bluebird'

players =
  1:
    led: 3
    button: 5
  2:
    led: 7
    button: 11
  3:
    led: 13
    button: 15
  4:
    led: 19
    button: 21
  5:
    led: 23
    button: 8
  6:
    led: 10
    button: 12

openPin = Promise.promisify(gpio.open)
closePin = Promise.promisify(gpio.close)
writePin = Promise.promisify(gpio.write)
readPin = Promise.promisify(gpio.read)

buttonPlayerMapping = {}
buttonSetup = []
ledSetup = []
for player of player
  buttonPlayerMapping[player.button] = player.id
  buttonSetup.push openPin(player.button, 'in down')
  ledSetup.push openPin(player.led, 'in down')
  player.active = false
  player.buttonStatus = 0

setupPromise = Promise.all(ledSetup).then ->
  Promise.all(buttonSetup).then ->
  , (e)->
    console.log 'Failed setting up Button', e
, (e)->
  console.log 'Failed setting up LED', e

poll = null
setupPromise.then ->
  poll = setInterval ->
    readHandled = []
    for player of player
      readHandled.push readPin(player.button).then (val)->
        if val != player.buttonStatus
          player.buttonStatus = val
          if player.buttonStatus == 0
            player.active = !player.active
            return writePin player.led, player.active

    Promise.all(readHandled).then ->
    , (err)->
      console.log 'Error checking status', err

  , 10

process.on 'SIGINT', ->
  console.log 'Cleaning up..'
  clearInterval(poll)
  cleaned = []
  for player of player
    cleaned.push writePin(player.led, true).then ->
      closePin player.led
    cleaned.push closePin player.button

  Promise.all(cleaned).then ->
    console.log 'Cleaned up pins';
  , (err)->
    console.log 'Failure cleaning up pins', err

  process.exit()