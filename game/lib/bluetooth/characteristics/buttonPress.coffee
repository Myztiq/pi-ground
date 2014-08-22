bleno = require 'bleno'
Descriptor = bleno.Descriptor;

class Characteristic extends bleno.Characteristic
  constructor: (options)->
    player = options.player

    config =
      uuid: options.prefix + "01"
      properties: [ 'notify', 'writeWithoutResponse' ]
      descriptors: [
        new Descriptor
          uuid: options.prefix + "11"
          value: 'buttonPress'
      ],
      onSubscribe: (maxValueSize, updateValueCallback)->
        player.on 'buttonPress', ->
          updateValueCallback(new Buffer("#{true}"))

      onWriteRequest: (data, offset, withoutResponse, callback)=>
        player.emit 'buttonPress'
        callback?(bleno.Characteristic.RESULT_SUCCESS)

    super(config)

  value: false

module.exports = Characteristic