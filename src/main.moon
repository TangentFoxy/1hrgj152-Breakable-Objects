Gamestate = require "lib.gamestate"
game = require "states.game"

love.load = ->
  Gamestate.registerEvents!
  Gamestate.switch game
