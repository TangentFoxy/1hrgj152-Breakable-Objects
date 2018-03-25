math.randomseed os.time!
version = "0.2.0"
latest = "unknown, checking for updates..."

Gamestate = require "lib.gamestate"
pause = require "states.pause"
gameover = require "states.gameover"

import graphics, keyboard, thread from love
import random, cos, sin, atan2, min, max, sqrt, pi, floor, abs from math

versionCheck = thread.newThread "lib/itchy/check.lua"
versionCheckSend = thread.getChannel "send-itchy"
versionCheckReceive = thread.getChannel "receive-itchy"
versionCheck\start!
versionCheckSend\push :version, target: "guard13007/asteroid-dodge", interval: 5*60, send_interval_errors: false -- doesn't actually need to be specified

time, timing = 0, 0
hw, hh = graphics.getWidth! / 2, graphics.getHeight! / 2
spawnDistance = 100 + 2 * max hw, hh
displayDistance = (spawnDistance - 500) / 2
maxAsteroids = 1
tau = pi * 2
heading_variance = pi / 7

local ship, target, objects

distance = (A, B) ->
  dx = A.x - B.x
  dy = A.y - B.y
  return sqrt dx * dx + dy * dy

class Ship
  @acceleration: 50

  new: =>
    @hp = 100
    @r = 10
    @x = 0
    @y = 0
    @vx = 0
    @vy = 0
    @speed = 0
    @total_score = 0

  update: (dt) =>
    @speed = sqrt @vx * @vx + @vy * @vy
    @current_score = max 0, floor @speed / 100 * (@speed / time) * (@hp / 100) * 1.2

    for i = 2, #objects
      object = objects[i]
      object.distance = distance object, @

      if object.r + @r > object.distance
        dvx = @vx - object.vx
        dvy = @vy - object.vy
        @hp -= dt * (object.r / 16) * sqrt(dvx * dvx + dvy * dvy) / 1.2
        Gamestate.switch gameover, @total_score + @current_score
        return

    if keyboard.isDown "w"
      @vy -= @@acceleration * dt
    if keyboard.isDown "a"
      @vx -= @@acceleration * dt
    if keyboard.isDown "s"
      @vy += @@acceleration * dt
    if keyboard.isDown "d"
      @vx += @@acceleration * dt

    @x += @vx * dt
    @y += @vy * dt

  draw: =>
    left = @x - hw + 5
    graphics.setColor 255, 255, 255, 255
    graphics.print "Hull: #{floor @hp}", left, @y + 12
    graphics.print "Score: #{@total_score} (+#{@current_score})", left, @y + 24
    graphics.print "Velocity: #{abs floor @speed}", left, @y + 36
    graphics.print "Pos(x/y): #{floor @x}/#{floor @y}", left, @y + 48

    vectors, boxes = {}, {}
    for i = 2, #objects
      object = objects[i]
      if displayDistance < object.distance
        angle = atan2 object.y - @y, object.x - @x
        x = @x + displayDistance * cos angle
        y = @y + displayDistance * sin angle
        if object.distance > distance { x: @x + @vx, y: @y + @vy }, { x: object.x + object.vx, y: object.y + object.vy }
          table.insert vectors, {
            :x, :y, x2: x + (object.vx - @vx) / 3, y2: y + (object.vy - @vy) / 3
          }
        else
          table.insert boxes, :x, :y

    graphics.setColor 255, 255, 255, 200
    for box in *boxes
      graphics.rectangle "line", box.x - 3, box.y - 3, 6, 6

    graphics.setColor 255, 200, 0, 255
    for vector in *vectors
      graphics.line vector.x, vector.y, vector.x2, vector.y2

    graphics.setColor 0, 0, 0, 255
    for vector in *vectors
      graphics.rectangle "fill", vector.x - 3, vector.y - 3, 6, 6

    graphics.setColor 255, 200, 0, 255
    for vector in *vectors
      graphics.rectangle "line", vector.x - 3, vector.y - 3, 6, 6

    graphics.setColor 0, 255, 0, 255
    angle = atan2 @vy, @vx
    magnitude = min 175, @speed / 3
    graphics.line @x, @y, @x + magnitude * cos(angle), @y + magnitude * sin(angle)
    graphics.setColor 0, 0, 0, 255
    graphics.circle "fill", @x, @y, @r
    graphics.setColor 0, 255, 0, 255
    graphics.circle "line", @x, @y, @r

    debugY = @y - hh - 5
    graphics.setColor 255, 255, 255, 200
    graphics.print "Version: #{version} Latest: #{latest}", left, debugY + 12
    graphics.print "FPS: #{love.timer.getFPS!}", left, debugY + 24
    graphics.print "Asteroids: #{#objects - 1}", left, debugY + 36

class Asteroid
  new: =>
    @r = random! * 8 + 8

    direction = random! * tau
    @x = ship.x + spawnDistance * cos direction
    @y = ship.y + spawnDistance * sin direction
    @distance = distance ship, @

    speed = random! * 100 + 50
    variance = random! * heading_variance - heading_variance / 2
    @vx = ship.vx + speed * cos direction + pi + variance
    @vy = ship.vy + speed * sin direction + pi + variance

  update: (dt) =>
    @x += @vx * dt
    @y += @vy * dt

  draw: =>
    graphics.setColor 255, 0, 0, 255
    graphics.circle "line", @x, @y, @r

class Target
  segment: tau / 40

  new: =>
    @x = random! * 10000
    @y = random! * 10000
    @r = random! * 40 + 80

  update: =>
    if @r > distance ship, @
      ship.total_score += ship.current_score
      time = 0
      target = Target!

  draw: =>
    graphics.setColor 0, 200, 255, 255
    for i = 1, 40
      graphics.arc "line", "open", @x, @y, @r, @segment * i - @segment / 4, @segment * i + @segment / 4

    angle = atan2 @y - ship.y, @x - ship.x
    xn = cos angle
    yn = sin angle
    x = ship.x + 50 * xn
    y = ship.y + 50 * yn
    for i = 1, 25
      x2, y2 = x + 5 * xn, y + 5 * yn
      x += 10 * xn
      y += 10 * yn
      graphics.line x, y, x2, y2

game = {}

game.enter = =>
  ship = Ship!
  target = Target!
  objects = {}

  table.insert objects, ship

  for i = 1, maxAsteroids
    table.insert objects, Asteroid!

game.update = (dt) =>
  if versionCheckReceive\getCount! > 0
    latest = versionCheckReceive\demand!

  time += dt
  timing += dt
  if timing >= 1
    timing -= 1
    maxAsteroids += 1

  for object in *objects
    object\update dt

  target\update!

  i = 2
  while i <= #objects
    object = objects[i]
    if spawnDistance * 2 < object.distance
      table.remove objects, i
    else
      i += 1

  addAsteroids = maxAsteroids - #objects + 1
  if addAsteroids > 0
    for i = 1, maxAsteroids - #objects + 1
      table.insert objects, Asteroid!

game.draw = =>
  graphics.translate hw - ship.x, hh - ship.y

  for object in *objects
    object\draw!

  target\draw!

game.keypressed = (key) =>
  if key == "escape"
    Gamestate.push pause

return game
