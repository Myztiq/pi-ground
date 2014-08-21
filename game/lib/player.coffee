{EventEmitter} = require 'events'
pinManager = require './pinManager.coffee'

class Player extends EventEmitter
  constructor: (options)->
    @_id = options.id
    @_ledPin = options.led
    @_buttonPin = options.button
    @_game = options.game

    @_game.on 'buttonPress', (pin)=>
      if pin == "#{@_buttonPin}"
        console.log "Player #{@_id}'s button pressed!"
        @emit 'buttonPress'

    @on 'buttonPress', =>
      @setLED !@ledStatus

  _turns: []
  ledStatus: false
  _running: false
  _gameTimer: null

  _currentTurn: null

  start: ->
    @_running = true
    @_gameTimer = new Date()

  end: ->
    console.log 'Game Ended!'
    console.log new Date() - @_gameTimer

  startTurn: ()->
    @_currentTurn =
      start: new Date()
      end: null
    @setLED(true)

  endTurn: ()->
    @_currentTurn.end = new Date()
    @_turns.push @_currentTurn
    console.log "Player #{@_id}'s turn length: #{@_currentTurn.end - @_currentTurn.start}ms"
    @setLED(false)
    @_currentTurn = null

  setLED: (val)->
    @ledStatus = val
    pinManager.writePin(@_ledPin, !val)
    @emit 'ledChange', @ledStatus

  cancelTurn: ()->
    delete @_turns[@_turns.length-1]

module.exports = Player