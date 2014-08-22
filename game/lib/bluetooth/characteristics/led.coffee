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
          updateValueCallback(new Buffer("#{val}"))

      onWriteRequest: (data, offset, withoutResponse, callback)=>
        data = data.toString()
        if data == 'true'
          data = true
        else if data == 'false'
          data = false

        console.log 'Setting LED to: ', data

        player.setLED(data)
        callback?(bleno.Characteristic.RESULT_SUCCESS)

      onReadRequest: (offset, callback)->
        console.log 'READ REQUEST!', bleno.Characteristic.RESULT_SUCCESS
        callback(bleno.Characteristic.RESULT_SUCCESS, new Buffer("#{player.ledStatus}"))

    super(config)

  value: false

module.exports = Characteristic