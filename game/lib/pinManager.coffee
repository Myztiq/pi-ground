Promise = require 'bluebird'
gpio = require 'pi-gpio'
winston = require 'winston'

taskRunner = new Promise (resolve)-> resolve().cancellable()

openedPins = {}

module.exports =
  openPin: (pin, val)->
    return new Promise (resolve, reject)->
      taskRunner = taskRunner.then ->
        Promise.promisify(gpio.open)(pin, val).then (->
          openedPins[pin] = true
          winston.log 'debug', 'Opened pin', pin, val
          resolve()
        ), (err)->
          openedPins[pin] = false
          winston.log 'debug', 'Error opening pin ', pin, val
          resolve(err)

  closePin: (pin)->
    return new Promise (resolve, reject)->
      taskRunner = taskRunner.then ->
        winston.log 'debug', 'Actually closing pin', pin
        if !openedPins[pin]
          console.warn 'Trying to close pin that was never properly opened. ', pin

        Promise.promisify(gpio.close)(pin).then (->
          winston.log 'debug', 'Closed pin', pin
          resolve()
        ), (err)->
          winston.log 'debug', 'Error closing pin ', pin
          resolve(err)

  writePin: (pin, val)->
    return new Promise (resolve, reject)->
      winston.log 'debug', 'Write Pin', pin, val
      Promise.promisify(gpio.write)(pin, val).then resolve, (err)->
        winston.log 'debug', 'Error writing pin ', pin, val
        reject(err)

  readPin: (pin)->
    return new Promise (resolve, reject)->
      taskRunner = taskRunner.then ->
        Promise.promisify(gpio.read)(pin).then resolve, (err)->
          winston.log 'debug', 'Error reading pin ', pin
          reject(err)

  cleanup: ->
    return new Promise (resolve, reject)=>
      taskRunner.cancel()
      promises = []
      for pin, val of openedPins
        do (pin)=>
          promises.push @writePin(pin, true).then =>
            @closePin(pin)

      Promise.settle(promises).then resolve, resolve