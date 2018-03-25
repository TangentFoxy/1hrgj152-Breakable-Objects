math.randomseed os.time!
version = "0.1.0"
latest = "unknown, checking for updates..."

import graphics, keyboard, thread from love
import random, cos, sin, atan2, min, max, sqrt, pi, floor, abs from math

versionCheck = thread.newThread "lib/itchy/check.lua"
versionCheckSend = thread.getChannel "send-itchy"
versionCheckReceive = thread.getChannel "receive-itchy"
versionCheck\start!
versionCheckSend\push :version, target: "guard13007/asteroid-dodge", interval: 5*60, send_interval_errors: false -- doesn't actually need to be specified

hw, hh = graphics.getWidth! / 2, graphics.getHeight! / 2
spawnDistance = 100 + 2 * max hw, hh
displayDistance = (spawnDistance - 500) / 2
maxAsteroids = 1
tau = pi * 2
heading_variance = pi / 7

objects = {}

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

  update: (dt) =>
    for i = 2, #objects
      object = objects[i]
      object.distance = distance object, @

      if object.r + @r > object.distance
        @hp -= dt

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
    graphics.setColor 0, 255, 0, 255
    graphics.circle "line", @x, @y, @r
    angle = atan2 @vy, @vx
    magnitude = min 175, sqrt(@vx * @vx + @vy * @vy) / 3
    graphics.line @x, @y, @x + magnitude * cos(angle), @y + magnitude * sin(angle)

    left = @x - hw + 5
    graphics.setColor 255, 255, 255, 255
    graphics.print "Hull: #{floor @hp}", left, @y + 11
    graphics.print "Velocity: #{abs floor sqrt @vx * @vx + @vy * @vy}", left, @y + 22

    vectors = {}
    for i = 2, #objects
      object = objects[i]
      if displayDistance < object.distance
        angle = atan2 object.y - @y, object.x - @x
        x = @x + displayDistance * cos angle
        y = @y + displayDistance * sin angle
        table.insert vectors, {
          :angle, :x, :y, x2: x + (object.vx - @vx) / 3, y2: y + (object.vy - @vy) / 3
        }

    graphics.setColor 255, 200, 0, 255
    for vector in *vectors
      graphics.line vector.x, vector.y, vector.x2, vector.y2

    graphics.setColor 0, 0, 0, 255
    for vector in *vectors
      graphics.rectangle "fill", vector.x - 3, vector.y - 3, 6, 6

    graphics.setColor 255, 200, 0, 255
    for vector in *vectors
      graphics.rectangle "line", vector.x - 3, vector.y - 3, 6, 6

    debugY = @y - hh - 5
    graphics.setColor 255, 255, 255, 200
    graphics.print "Version: #{version} Latest: #{latest}", left, debugY + 11
    graphics.print "FPS: #{love.timer.getFPS!}", left, debugY + 22
    graphics.print "Asteroids: #{#objects - 1}", left, debugY + 33

ship = Ship!

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

love.load = ->
  table.insert objects, ship

  for i = 1, maxAsteroids
    table.insert objects, Asteroid!

timing = 0
love.update = (dt) ->
  if versionCheckReceive\getCount! > 0
    latest = versionCheckReceive\demand!

  timing += dt
  if timing >= 1
    timing -= 1
    maxAsteroids += 1

  for object in *objects
    object\update dt

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

love.draw = ->
  graphics.translate hw - ship.x, hh - ship.y

  for object in *objects
    object\draw!

love.keypressed = (key) ->
  if key == "escape"
    love.event.quit!
