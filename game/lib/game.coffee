{EventEmitter} = require 'events'

class Game extends EventEmitter
  constructor: ->
    @_turnLimit = 2
    @on 'buttonHold', =>
      @pause()
    @on 'buttonRelease', =>
      @resume()

  _players: []

  _playerOrder: []
  _playerOrderIndex: 0
  _currentPlayer: null
  _round: 0
  _roundLimit: 2
  _totalTurns: 0

  addPlayer: (playerInstance)->
    @_players.push playerInstance

  start: (order)->
    @startRound(order)

  startRound: (order)->
    @_playerOrder = order
    if @_round > @_roundLimit
      @end()
    else
      @_playerOrderIndex = -1
      @_round++
      @_nextTurn()

  _nextTurn: ->
    @_totalTurns++
    @_playerOrderIndex++
    if @_playerOrderIndex > @_playerOrder.length
      @startRound(@_playerOrder)
    else
      @_currentPlayer = @_playerOrder[@_playerOrderIndex]
      @_currentPlayer.startTurn()
      @_currentPlayer.one 'buttonPress', =>
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