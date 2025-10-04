local Bullet = require("bullet")

function love.load()
  Sprites = {}
  Sprites.ship = love.graphics.newImage("sprites/ship.png")

  ship = { x= love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, rotate = 0 }
  ship.speed = 100
  ship.rotateSpeed = 180

  rotationOffset = 90

end

function love.update(dt)
  Move_player( dt)

  Bullet.update(dt)
end

function love.draw()
  love.graphics.setFont(love.graphics.newFont(64))
  -- love.graphics.printf("Asteroids", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
  
  love.graphics.draw(Sprites.ship, ship.x, ship.y, math.rad(ship.rotate), 1, 1, Sprites.ship:getWidth() / 2, Sprites.ship:getHeight() / 2)
   -- debug: draw forward vector so you can see direction
  local angleForMovement = math.rad(ship.rotate - 90) -- offset
  local fx = ship.x + math.cos(angleForMovement) * 40
  local fy = ship.y + math.sin(angleForMovement) * 40
  love.graphics.setColor(1, 0, 0) -- red
  love.graphics.line(ship.x, ship.y, fx, fy)
  love.graphics.setColor(1, 1, 1) -- reset



  -- Draw bullets
  Bullet.draw()
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "space" then
    local angle = math.rad(ship.rotate - rotationOffset)
    Bullet.shoot(ship.x, ship.y, angle)
  end
end


function Move_player( dt)
  local isScancode = love.keyboard.isScancodeDown
  if isScancode("a") then
    -- rotate left
    ship.rotate = ship.rotate - ship.rotateSpeed * dt
  elseif isScancode("d") then
    -- move right
    ship.rotate = ship.rotate + ship.rotateSpeed * dt
  end

    -- Move forward/backward using vector math
  local angle = math.rad(ship.rotate - rotationOffset)
  if isScancode("w") then
    ship.x = ship.x + math.cos(angle) * ship.speed * dt
    ship.y = ship.y + math.sin(angle) * ship.speed * dt
  elseif isScancode("s") then
    ship.x = ship.x - math.cos(angle) * ship.speed * dt
    ship.y = ship.y - math.sin(angle) * ship.speed * dt
  end
end


