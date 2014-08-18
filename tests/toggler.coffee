gpio = require 'pi-gpio'
Promise = require 'bluebird'

players =
  1:
    led: 23
    button: 24
  2:
    led: 11
    button: 10
  3:
    led: 15
    button: 16
  4:
    led: 21
    button: 22
  5:
    led: 7
    button: 8
  6:
    led: 13
    button: 12


exit = (err)->
  if err?
    console.log 'Fatal Error', err

  console.log 'Cleaning up..'
  clearInterval(poll)
  cleaned = []
  for id, player of players
    do (id, player)->
      cleaned.push writePin(player.led, true).then ->
        closePin player.led
      cleaned.push closePin player.button

  Promise.settle(cleaned).then (results)->
    console.log results
    console.log 'Cleaned up pins'
    process.exit()

process.on 'uncaughtException', exit
process.on 'SIGINT', exit

taskRunner = new Promise (resolve)-> resolve()

openPin = (args...)->
  taskRunner = taskRunner.then ->
    return new Promise (resolve, reject)->
      console.log 'Open Pin', args
      Promise.promisify(gpio.open)(args...).then resolve, (err)->
        console.log 'Error opening pin ', args
        resolve(err)

closePin = (args...)->
  taskRunner = taskRunner.then ->
    return new Promise (resolve, reject)->
      setTimeout ->
        console.log 'Close Pin', args
        Promise.promisify(gpio.close)(args...).then resolve, (err)->
          console.log 'Error opening pin ', args
          resolve(err)
      , 100

writePin = (args...)->
  taskRunner = taskRunner.then ->
    return new Promise (resolve, reject)->
      console.log 'Write Pin', args
      Promise.promisify(gpio.write)(args...).then resolve, (err)->
        console.log 'Error writing pin ', args
        reject(err)

readPin = (args...)->
  taskRunner = taskRunner.then ->
    return new Promise (resolve, reject)->
#      console.log 'Read Pin', args
      Promise.promisify(gpio.read)(args...).then resolve, (err)->
        console.log 'Error reading pin ', args
        reject(err)

buttonSetup = []
ledSetup = []
for id, player of players
  do (id, player)->
    buttonSetup.push openPin(player.button, 'in down')
    ledSetup.push openPin(player.led, 'out up')
    player.active = false
    player.buttonStatus = 0

setupPromise = Promise.all(ledSetup).then (->
  Promise.all(buttonSetup).then (->
  ), (e)->
    console.log 'Failed setting up Button', e
), (e)->
  console.log 'Failed setting up LED', e
  throw e

poll = null
setupPromise.then ->
  runPoll = ->
    poll = setTimeout ->
      readHandled = []
      for id, player of players
        do (id, player)->
          readHandled.push readPin(player.button).then (val)->
            if val != player.buttonStatus
              player.buttonStatus = val
              if player.buttonStatus == 0
                player.active = !player.active
                console.log "Toggling Players #{id}'s LED to ", player.active
                return writePin player.led, player.active

      Promise.all(readHandled).then (->
        runPoll()
      ), (err)->
        console.log 'Error checking status', err
    , 100
  runPoll()
  console.log 'Setup'