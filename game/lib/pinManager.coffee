Promise = require 'bluebird'
gpio = require 'pi-gpio'

taskRunner = new Promise (resolve)-> resolve()

openedPins = {}

module.exports =
  openPin: (pin, val)->
    taskRunner = taskRunner.then ->
      return new Promise (resolve, reject)->
        console.log 'Open Pin', args
        Promise.promisify(gpio.open)(pin, val).then (->
          openedPins[pin] = true
          resolve()
        ), (err)->
          console.log 'Error opening pin ', pin, val
          resolve(err)

  closePin: (pin)->
    taskRunner = taskRunner.then ->
      if !openedPins[pin]
        console.warn 'Trying to close pin that was never properly opened. ', pin

      return new Promise (resolve, reject)->
        setTimeout ->
          console.log 'Close Pin', args
          Promise.promisify(gpio.close)(args...).then (->
            delete openedPins[pin]
            resolve()
          ), (err)->
            console.log 'Error opening pin ', args
            resolve(err)
        , 100

  writePin: (args...)->
    taskRunner = taskRunner.then ->
      return new Promise (resolve, reject)->
        console.log 'Write Pin', args
        Promise.promisify(gpio.write)(args...).then resolve, (err)->
          console.log 'Error writing pin ', args
          reject(err)

  readPin: (args...)->
    taskRunner = taskRunner.then ->
      return new Promise (resolve, reject)->
        Promise.promisify(gpio.read)(args...).then resolve, (err)->
          console.log 'Error reading pin ', args
          reject(err)

  cleanup: ->
    taskRunner = taskRunner.then =>
      promises = []
      for pin, val of openedPins
        promises.push @closePin(pin)
      return Promise.settle(promises)