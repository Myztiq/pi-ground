{EventEmitter} = require 'events'
pinManager = require './pinManager.coffee'
winston = require 'winston'

class Player extends EventEmitter
  constructor: (options)->
    @id = options.id
    @_ledPin = options.led
    @_buttonPin = options.button
    @_game = options.game

    @_game.on 'buttonPress', (pin)=>
      if pin == "#{@_buttonPin}"
        winston.log 'debug', "Player #{@id}'s button pressed!"
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
    winston.log 'debug', 'Game Ended!'
    winston.log 'debug', new Date() - @_gameTimer

  startTurn: ()->
    @_currentTurn =
      start: new Date()
      end: null
    @setLED(true)

  endTurn: ()->
    @_currentTurn.end = new Date()
    @_turns.push @_currentTurn
    winston.log 'debug', "Player #{@id}'s turn length: #{@_currentTurn.end - @_currentTurn.start}ms"
    @setLED(false)
    @_currentTurn = null

  setLED: (val)->
    winston.log 'debug', 'Set LED to ', val
    @ledStatus = val
    pinManager.writePin(@_ledPin, !val)
    @emit 'ledChange', @ledStatus

  cancelTurn: ()->
    delete @_turns[@_turns.length-1]

module.exports = Player