bleno = require 'bleno'
ButtonCharacteristic = require './buttonCharacteristic'

class ButtonService extends bleno.PrimaryService
  uuid: 'FFF0'
  characteristics: [
    new ButtonCharacteristic
      player: 1
      pin: 2
  ]


