Game = require './lib/game'
Player = require './lib/player'
config = require './config'
pinManager = require './lib/pinManager'
Promise = require 'bluebird'

poll = null

# Setup our cleanup helpers. This is important, so if there is a crash we can try to exit cleanly
exit = (err)->
  if err?
    console.log 'Fatal Error', err

  console.log 'Cleaning up..'
  clearTimeout(poll)
  pinManager.cleanup().then (results)->
    console.log results
    console.log 'Cleaned up pins'
    process.exit()

process.on 'uncaughtException', exit
process.on 'SIGINT', exit

# Now setup all the button and LED pins.

promises = []
buttons = {}
for playerConfig in config.players
  buttons[playerConfig.button] = {}
  promises.push pinManager.openPin(playerConfig.button, 'in down')
  promises.push pinManager.openPin(playerConfig.led, 'out up')

Promise.settle(promises).then (results)->
  console.log 'Setup. ', results

  ###
    Setup the game itself.

    There are a few steps.
    1. Register players
      a. In order to do that I need to start a loop listening for every player button hit.
      b. On button hit we assign
  ###

  game = new Game()

  ## Begin polling for button presses
  runPoll: ->
    poll = setTimeout ->
      readHandled = []
      for buttonId, buttonStatus of buttons
        do (buttonId, buttonStatus)->
          readHandled.push pinManager.readPin(buttonId).then (val)->
            if val == 1
              if !buttons[buttonId].timer
                buttons[buttonId].timer = new Date()
              else if !buttons[buttonId].hold and (new Date() - buttons[buttonId].timer) > 1000
                game.emit 'buttonHold', buttonId
                buttons[buttonId].hold = true

            else if buttons[buttonId].timer?
              if (new Date() - buttons[buttonId].timer) > 1000
                delete buttons[buttonId].timer
                delete buttons[buttonId].hold
                game.emit 'buttonRelease', buttonId
              else
                game.emit 'buttonPress', buttonId

      Promise.all(readHandled).then (->
        runPoll()
      ), (err)->
        console.log 'Error checking status', err
    , 100

  runPoll()

  gameStarted = false
  startGame = ->
    if !gameStarted
      gameStarted = true
      game.start()

  for playerConfig in config.players
    do ->
      player = new Player playerConfig
      player.once 'buttonPress', ->
        game.addPlayer(player)

      player.once 'buttonRelease', -> startGame()



