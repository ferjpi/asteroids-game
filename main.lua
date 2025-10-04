function love.load()
  Sprites = {}
  Sprites.ship = love.graphics.newImage("sprites/ship.png")

  ship = { x= love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, rotate = 0 }
  ship.speed = 100
end

function love.update(dt)
  Move_player( dt)

end

function love.draw()
  love.graphics.setFont(love.graphics.newFont(64))
  -- love.graphics.printf("Asteroids", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
  
  love.graphics.draw(Sprites.ship, ship.x, ship.y, math.rad(ship.rotate), 1, 1, Sprites.ship:getWidth() / 2, Sprites.ship:getHeight() / 2)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end


function Move_player( dt)
  local isScancode = love.keyboard.isScancodeDown
  if isScancode("a") then
    -- rotate left
    ship.rotate = ship.rotate - 180 * dt
  elseif isScancode("d") then
    -- move right
    ship.rotate = ship.rotate + 180 * dt
  end

    -- Move forward/backward using vector math
  local angle = math.rad(ship.rotate)
  if isScancode("w") then
    ship.x = ship.x + math.cos(angle) * ship.speed * dt
    ship.y = ship.y + math.sin(angle) * ship.speed * dt
  elseif isScancode("s") then
    ship.x = ship.x - math.cos(angle) * ship.speed * dt
    ship.y = ship.y - math.sin(angle) * ship.speed * dt
  end

end
