bleno = require 'bleno'
Characteristic = bleno.Characteristic

class GameService extends bleno.PrimaryService

  constructor: (game) ->
    configuration =
      uuid: "3000"
      characteristics: [
        new Characteristic # Start Add Player Mode
          uuid: "3001"
          properties: [ 'write' ]
          onWriteRequest: (data) ->
            data = data.toString()
            if data == 'true'
              game.emit('startAddPlayers')
        new Characteristic # Start Pick Order
          uuid: "3002"
          properties: [ 'write' ]
          onWriteRequest: (data) ->
            data = data.toString()
            if data == 'true'
              game.emit('startPickOrder')
        new Characteristic # Start Game
          uuid: "3003"
          properties: [ 'write' ]
          onWriteRequest: (data) ->
            data = data.toString()
            if data == 'true'
              game.emit('startGame')
        new Characteristic # Add Player
          uuid: "3004"
          properties: [ 'write' ]
          onWriteRequest: (data) ->
            game.emit('addPlayer', data)
      ]
    super configuration

module.exports = GameService