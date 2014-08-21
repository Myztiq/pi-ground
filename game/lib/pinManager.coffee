Promise = require 'bluebird'
gpio = require 'pi-gpio'

taskRunner = new Promise (resolve)-> resolve()

openedPins = {}

module.exports =
  openPin: (pin, val)->
    taskRunner = taskRunner.then ->
      return new Promise (resolve, reject)->
        console.log 'Open Pin', pin, val
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
          console.log 'Close Pin', pin
          Promise.promisify(gpio.close)(pin).then (->
            delete openedPins[pin]
            resolve()
          ), (err)->
            console.log 'Error opening pin ', pin
            resolve(err)
        , 100

  writePin: (pin, val)->
    taskRunner = taskRunner.then ->
      return new Promise (resolve, reject)->
        console.log 'Write Pin', pin, val
        Promise.promisify(gpio.write)(pin, val).then resolve, (err)->
          console.log 'Error writing pin ', pin, val
          reject(err)

  readPin: (pin)->
    taskRunner = taskRunner.then ->
      return new Promise (resolve, reject)->
        Promise.promisify(gpio.read)(pin).then resolve, (err)->
          console.log 'Error reading pin ', pin
          reject(err)

  cleanup: ->
    taskRunner = taskRunner.then =>
      promises = []
      for pin, val of openedPins
        promises.push @closePin(pin)
      return Promise.settle(promises)