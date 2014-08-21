game = require './lib/game'
player = require './lib/player'
config = require './config'
pinManager = require './lib/pinManager'
Promise = require 'bluebird'

# Setup our cleanup helpers. This is important, so if there is a crash we can try to exit cleanly
exit = (err)->
  if err?
    console.log 'Fatal Error', err

  console.log 'Cleaning up..'
  clearInterval(poll)
  pinManager.cleanup().then (results)->
    console.log results
    console.log 'Cleaned up pins'
    process.exit()

process.on 'uncaughtException', exit
process.on 'SIGINT', exit

# Now setup all the button and LED pins.

promises = []
for playerConfig in config.players
  promises.push pinManager.openPin(playerConfig.button, 'in down')
  promises.push pinManager.openPin(playerConfig.led, 'out up')

Promise.settled(promises).then (results)->
  console.log 'Setup. ', results

  ###
    Setup the game itself.

    There are a few steps.
    1. Register players
      a. In order to do that I need to start a loop listening for every player button hit.
      b. On button hit we assign
  ###

  game = new Game()

  for playerConfig in config.players
    game.addPlayer new Player playerConfig

  game.start()