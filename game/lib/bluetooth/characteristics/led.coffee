bleno = require 'bleno'
Descriptor = bleno.Descriptor;

class Characteristic extends bleno.Characteristic
  constructor: (options)->
    player = options.player

    config =
      uuid: options.prefix + "02"
      properties: [ 'notify', 'write', 'read', 'writeWithoutResponse' ]
      value: player.ledStatus
      descriptors: [
        new Descriptor
          uuid: options.prefix + "12"
          value: 'LED'
      ]
      onSubscribe: (maxValueSize, updateValueCallback)->
        player.on 'ledChange', (val)->
          updateValueCallback(new Buffer(val))

      onWriteRequest: (data, offset, withoutResponse, callback)->
        player.setLED(data)
        callback?()

      onReadRequest: (offset, callback)->
        callback(new Buffer(player.ledStatus))

    super(config)

  value: false

module.exports = Characteristic