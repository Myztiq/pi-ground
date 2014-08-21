bleno = require 'bleno'

class Characteristic extends bleno.Characteristic
  constructor: (options)->

    config =
      uuid: 'fffffffffffffffffffffffffffffff1', # or 'fff1' for 16-bit
      properties: [ 'read', 'notify' ]
      value: @value # optional static value, must be of type Buffer
      descriptors: [
        # see Descriptor for data type
      ],
      onReadRequest: (offset, cb)=>
        cb?(new Buffer @value)

      onSubscribe: (maxValueSize, updateValueCallback)->
        @set 'notifyOnChange', updateValueCallback

        updateValueCallback(new Buffer(value))
    @_super(config)

  value: false
