{EventEmitter} = require 'events'

class Player extends EventEmitter
  constructor: (options)->
    @_id = options.id
    @_ledPin = options.led
    @_buttonPin = options.button
    @_game = options.game

    @_game.on 'buttonPress', (pin)=>
      if pin == @_buttonPin
        console.log "Player #{@_id}'s button pressed!"
        @emit 'buttonPress'

    @on 'buttonPress', =>
      @setLED !@_ledStatus

  _turns: []
  _ledStatus: false

  _currentTurn: null

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
    console.log 'Setting LED to ', val, 'on pin', @_ledPin

  cancelTurn: ()->
    delete @_turns[@_turns.length-1]

module.exports = Player