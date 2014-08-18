bleno = require 'bleno'

class Characteristic extends bleno.Characteristic
  constructor: (options)->

    config =
      uuid: 'fffffffffffffffffffffffffffffff1', # or 'fff1' for 16-bit
      properties: [ 'read' ]
      value: null, # optional static value, must be of type Buffer
      descriptors: [
        # see Descriptor for data type
      ],
      onReadRequest: (offset, cb)-> # optional read request handler, function(offset, callback) { ... }
        console.log offset
        cb?(true)

#      onWriteRequest: null, # optional write request handler, function(data, offset, withoutResponse, callback) { ...}
#      onSubscribe: null, # optional notify subscribe handler, function(maxValueSize, updateValueCallback) { ...}
#      onUnsubscribe: null, # optional notify unsubscribe handler, function() { ...}
#      onNotify: null # optional notify sent handler, function() { ...}

    
    @_super(config)
