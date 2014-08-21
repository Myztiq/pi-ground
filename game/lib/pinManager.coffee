Promise = require 'bluebird'
gpio = require 'pi-gpio'

taskRunner = new Promise (resolve)-> resolve()

openedPins = {}

module.exports =
  openPin: (pin, val)->
    return new Promise (resolve, reject)->
      taskRunner = taskRunner.then ->
        Promise.promisify(gpio.open)(pin, val).then (->
          openedPins[pin] = true
          console.log 'Opened pin', pin, val
          resolve()
        ), (err)->
          openedPins[pin] = true
          console.log 'Error opening pin ', pin, val
          resolve(err)

  closePin: (pin)->
    return new Promise (resolve, reject)->
      taskRunner = taskRunner.then ->
        if !openedPins[pin]?
          console.warn 'Trying to close pin that was never properly opened. ', pin

        setTimeout ->
          Promise.promisify(gpio.close)(pin).then (->
            delete openedPins[pin]
            console.log 'Closed pin', pin
            resolve()
          ), (err)->
            console.log 'Error closing pin ', pin
            resolve(err)
        , 100

  writePin: (pin, val)->
    return new Promise (resolve, reject)->
      console.log 'Write Pin', pin, val
      Promise.promisify(gpio.write)(pin, val).then resolve, (err)->
        console.log 'Error writing pin ', pin, val
        reject(err)

  readPin: (pin)->
    return new Promise (resolve, reject)->
      Promise.promisify(gpio.read)(pin).then resolve, (err)->
        console.log 'Error reading pin ', pin
        reject(err)

  cleanup: ->
    return new Promise (resolve, reject)=>
      taskRunner = taskRunner.then =>
        promises = []
        for pin, val of openedPins
          promises.push @closePin(pin)

        Promise.settle(promises).then resolve, resolve