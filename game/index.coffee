Game = require './lib/game'
Player = require './lib/player'
config = require './config'
pinManager = require './lib/pinManager'
Promise = require 'bluebird'
bluetooth = require 'bluetooth'

poll = null

# Setup our cleanup helpers. This is important, so if there is a crash we can try to exit cleanly
cleanup = (err)->
  if err?
    console.log 'Fatal Error', err

  console.log 'Cleaning up..'
  clearTimeout(poll)
  pinManager.cleanup().then (results)->
    console.log results
    console.log 'Cleaned up pins'
    process.exit()


process.on 'uncaughtException', cleanup
process.on 'SIGINT', cleanup

# Now setup all the button and LED pins.

promises = []
buttons = {}
for playerConfig in config.players
  buttons[playerConfig.button] = {}
  promises.push pinManager.openPin(playerConfig.button, 'in down')
  promises.push pinManager.openPin(playerConfig.led, 'out down')


Promise.settle(promises).then (results)->
  console.log 'Setup.'

  ###
    Setup the game itself.

    There are a few steps.
    1. Register players
      a. In order to do that I need to start a loop listening for every player button hit.
      b. On button hit we assign
  ###

  game = new Game()

  ## Begin polling for button presses
  runPoll = ->
    poll = setTimeout ->
      readHandled = []
      # Loop through each button
      for buttonId, buttonStatus of buttons
        do (buttonId, buttonStatus)->
          #Check the status
          readHandled.push pinManager.readPin(buttonId).then (val)->
            # If it's depressed
            if val == 1
              # It's the first depression
              if !buttons[buttonId].timer
                buttons[buttonId].timer = new Date()

              # It's still depressed! Is it long enough to trigger a hold?
              else if !buttons[buttonId].hold and (new Date() - buttons[buttonId].timer) > 1000
                game.emit 'buttonHold', buttonId
                buttons[buttonId].hold = true

            # There is no button press. Was it just released?
            else if buttons[buttonId].timer?
              #Oh, was it held?
              if (new Date() - buttons[buttonId].timer) > 1000
                delete buttons[buttonId].timer
                delete buttons[buttonId].hold
                game.emit 'buttonRelease', buttonId

              # It was not held, just a press!
              else
                delete buttons[buttonId].timer
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

  players = []
  for playerConfig in config.players
    do ->
      player = new Player
        id: playerConfig.id
        button: playerConfig.button
        led: playerConfig.led
        game: game

      players.push player

      player.once 'buttonPress', ->
        game.addPlayer(player)

      player.once 'buttonRelease', -> startGame()

  bluetooth.setup "BGTimer", players



