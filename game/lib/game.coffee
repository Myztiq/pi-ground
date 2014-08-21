{EventEmitter} = require 'events'

class Game extends EventEmitter
  constructor: (options)->
    @_turnLimit = 2
    @on 'buttonHold', =>
      @pause()
    @on 'buttonRelease', =>
      @resume()

  _players: []
  _currentPlayer: null
  _totalTurns: 0
  _turnLimit: -1

  addPlayer: (playerInstance)->
    @_players.push playerInstance

  start: ->
    @_currentPlayer = 0
    @_nextTurn()

  _nextTurn: ->
    @_totalTurns++
    @_currentPlayer = @_players[@_currentPlayer % @_players.length]
    @_currentPlayer.startTurn()
    @_currentPlayer.one 'buttonPress', =>
      if @_turnLimit > 0 and @_turnLimit > @_totalTurns
        @end()
      else
        @_currentPlayer.stopTurn()
        @_currentPlayer++
        @_nextTurn()

  pause: ->
    @_currentPlayer?.pause()
    leds = off
    @blinky = setInterval =>
      leds = !leds
      for player in @_players
        player.setLED(leds)
    , 100

  resume: ->
    clearInterval @blinky
    for player in @_players
      player.setLED(false)
    @_currentPlayer?.setLED true
    @_currentPlayer?.resume()

  end: ->
    @_currentPlayer.cancelTurn()
    console.log 'Game END!'

module.exports = Game