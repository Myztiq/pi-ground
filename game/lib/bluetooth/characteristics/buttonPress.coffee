bleno = require 'bleno'

class Characteristic extends bleno.Characteristic
  constructor: (options)->
    player = options.player

    config =
      uuid: options.prefix + "01"
      properties: [ 'notify', 'writeWithoutResponse' ]
      descriptors: [
        # see Descriptor for data type
      ],
      onSubscribe: (maxValueSize, updateValueCallback)->
        player.on 'buttonPress', ->
          updateValueCallback(new Buffer(true))

      onWriteRequest: ->
        player.emit 'buttonPress'

    @_super(config)

  value: false
