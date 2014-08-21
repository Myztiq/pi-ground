{EventEmitter} = require 'events'

class Game extends EventEmitter
  constructor: (options)->
    @_turnLimit = 2

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
    @_currentPlayer.pause()

  resume: ->
    @_currentPlayer.resume()

  end: ->
    @_currentPlayer.cancelTurn()
    console.log 'Game END!'

module.exports = Game