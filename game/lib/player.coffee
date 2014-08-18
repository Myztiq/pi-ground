class Player
  constructor: (options)->
    @id = options.id
    @led = options.led
    @button = options.button
    @game = options.game

    @game.on 'buttonPress', (pin)->
      if pin == @button
        @buttonPress()

  buttonPress: ->
    console.log "Player #{id} button toggled"



module.exports = Player