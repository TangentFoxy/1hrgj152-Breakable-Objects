KeyConstants = require "lib.KeyConstants"
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
    @timer = 0
    @allow_keypress = false

  update: (dt) =>
    @timer += dt
    if @timer > 0.05
      @allow_keypress = true

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

    if @allow_keypress
      str = "(press any key to unpause)"
      graphics.print str, w / 2 - graphics.getFont!\getWidth(str) / 2, h / 2 + 96

  keypressed: (key) =>
    if @allow_keypress
      accept_input = false
      if key == "escape" or key == "pause"
        accept_input = true
      else
        for keytype in *{"character", "numpad", "navigation", "editing"}
          if KeyConstants[keytype][key]
            accept_input = true
            break
      if accept_input
        Gamestate.pop!
}

return pause
