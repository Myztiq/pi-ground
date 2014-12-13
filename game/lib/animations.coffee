Promise = require 'bluebird'

module.exports =
  blink: (players, animationSpeed = 500)->
    blink = (value)->
      # We need a promise to chain for timing
      animationPromise = Promise.resolve().cancellable()
      players.forEach (player)->
        animationPromise = animationPromise.then ->
          player.setLED(value)

      return animationPromise.delay(animationSpeed).then -> blink(!value)

    return blink(true)

  rotate: (players, animationSpeed = 100)->
    animate = ->
      # We need a promise to chain for timing
      animationPromise = Promise.resolve().cancellable()
      players.forEach (player)->
        animationPromise = animationPromise.delay(animationSpeed).then ->
          player.setLED(true)

      players.forEach (player)->
        animationPromise = animationPromise.delay(animationSpeed).then ->
          player.setLED(false)
      return animationPromise.then -> animate()

    return animate()