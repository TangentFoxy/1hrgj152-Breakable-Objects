Gamestate = require "lib.gamestate"

import graphics, keyboard from love

w, h = graphics.getWidth!, graphics.getHeight!

pause = {
  init: =>
    @font = graphics.newFont 32
    @title = "Paused"
    @x = w / 2 - @font\getWidth(@title) / 2
    @y = h / 2 - @font\getHeight! / 2

  enter: (previous_state) =>
    @background = previous_state

  draw: =>
    @background\draw!
    graphics.origin!
    graphics.setColor 0, 0, 0, 150
    graphics.rectangle "fill", 0, 0, w, h

    previous_font = graphics.getFont!
    graphics.setFont @font
    graphics.setColor 255, 255, 255, 255
    graphics.print @title, @x, @y
    graphics.setFont previous_font

  keypressed: (key) =>
    Gamestate.pop!
}

return pause
