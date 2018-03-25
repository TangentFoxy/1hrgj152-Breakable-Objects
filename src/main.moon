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

time, timing = 0, 0
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
    @speed = 0

  update: (dt) =>
    @speed = sqrt @vx * @vx + @vy * @vy

    for i = 2, #objects
      object = objects[i]
      object.distance = distance object, @

      if object.r + @r > object.distance
        dvx = @vx - object.vx
        dvy = @vy - object.vy
        @hp -= dt * (object.r / 16) * sqrt(dvx * dvx + dvy * dvy) / 1.2

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
    graphics.print "Velocity: #{abs floor @speed}", left, @y + 24
    graphics.print "Score: #{floor @speed / 100 * (@speed / time) * (@hp / 100) * 1.2}", left, @y + 36

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
    graphics.circle "line", @x, @y, @r
    angle = atan2 @vy, @vx
    magnitude = min 175, @speed / 3
    graphics.line @x, @y, @x + magnitude * cos(angle), @y + magnitude * sin(angle)

    debugY = @y - hh - 5
    graphics.setColor 255, 255, 255, 200
    graphics.print "Version: #{version} Latest: #{latest}", left, debugY + 12
    graphics.print "FPS: #{love.timer.getFPS!}", left, debugY + 24
    graphics.print "Asteroids: #{#objects - 1}", left, debugY + 36

ship = Ship!
camera = { x: ship.x, y: ship.y }

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

love.update = (dt) ->
  if versionCheckReceive\getCount! > 0
    latest = versionCheckReceive\demand!

  time += dt
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

  camera.x += (ship.x - camera.x) / 2
  camera.y += (ship.y - camera.y) / 2

love.draw = ->
  graphics.translate hw - camera.x, hh - camera.y

  for object in *objects
    object\draw!

love.keypressed = (key) ->
  if key == "escape"
    love.event.quit!
