Gamestate = require "lib.gamestate"

import graphics, keyboard from love
import floor from math

w, h = graphics.getWidth!, graphics.getHeight!

gameover = {
  init: =>
    @font = graphics.newFont 32
    @title = "Game Over"
    @x = w / 2 - @font\getWidth(@title) / 2
    @y = h / 2 - @font\getHeight! / 2 - 32

  enter: (previous_state, score) =>
    @previous_state = previous_state
    @score = score
    @timer = 0
    @allow_keypress = false

  update: (dt) =>
    @timer += dt
    if @timer > 0.5
      @allow_keypress = true

  draw: =>
    @previous_state\draw!
    graphics.origin!
    graphics.setColor 0, 0, 0, 150
    graphics.rectangle "fill", 0, 0, w, h

    previous_font = graphics.getFont!
    graphics.setFont @font
    graphics.setColor 255, 255, 255, 255
    graphics.print @title, @x, @y
    score_str = "Score: #{floor @score}"
    graphics.print score_str, w / 2 - @font\getWidth(score_str) / 2, @y + 48

    graphics.setFont previous_font
    if @allow_keypress
      str = "Press any key to restart..."
      graphics.print str, w / 2 - previous_font\getWidth(str) / 2, @y + 96

  keypressed: (key) =>
    if @allow_keypress
      Gamestate.switch @previous_state
}

return gameover
