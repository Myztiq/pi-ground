bleno = require 'bleno'

class Characteristic extends bleno.Characteristic
  constructor: (options)->
    player = options.player

    config =
      uuid: options.prefix + "02"
      properties: [ 'notify', 'write', 'read', 'writeWithoutResponse' ]
      value: player.ledStatus
      descriptors: [
        # see Descriptor for data type
      ],
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