bleno = require 'bleno'

ButtonPressCharacteristic = require '../characteristics/buttonPress'
LEDCharacteristic = require '../characteristics/led'

class PlayerService extends bleno.PrimaryService

  constructor: (options)->
    configuration =
      uuid: options.serviceId
      characteristics: [
        new ButtonPressCharacteristic
          player: options.player
          prefix: options.prefix
        new LEDCharacteristic
          player: options.player
          prefix: options.prefix
      ]
    super configuration

module.exports = PlayerService