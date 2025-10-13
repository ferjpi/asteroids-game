local Asteroid = {}
Asteroid.__index = Asteroid

local asteroids = {}
local asteroidImage = love.graphics.newImage("sprites/asteroid.png")

function Asteroid.spawn(x, y, size)
  local sreenW, screenH = 
    love.graphics.getWidth(), love.graphics.getHeight()

  
  if not x or not y then
    local edge = math.random(1, 4)
    if edge == 1 then
      x = math.random(0, sreenW)
      y = -50
    elseif edge == 2 then
      x = math.random(0, sreenW)
      y = screenH + 50
    elseif edge == 3 then
      x = -50
      y = math.random(0, screenH)
    else
      x = sreenW + 50
      y = math.random(0, screenH)
    end
  end

  size = size or 3

  local angle = math.atan2(screenH / 2 - y, sreenW / 2 - x)
  local baseSpeed = 40
  local speed = baseSpeed * (4 - size) + math.random(0, 20)

  local asteroid = {
    x = x,
    y = y,
    dx = math.cos(angle) * speed,
    dy = math.sin(angle) * speed,
    rotation = math.random(0, 360),
    rotationSpeed = math.random(-40, 40),
    size = size,
    radius = (asteroidImage:getWidth() / 2) * (size / 3)
  }

  table.insert(asteroids, asteroid)
end

function Asteroid.update(dt)
  local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()

  for _, a in ipairs(asteroids) do
    a.x = a.x + a.dx * dt
    a.y = a.y + a.dy * dt
    a.rotation = a.rotation + a.rotationSpeed * dt

    -- Wrap around horizontally
    if a.x < -50 then
      a.x = screenW + 50
    elseif a.x > screenW + 50 then
      a.x = -50
    end

    -- Wrap around vertically
    if a.y < -50 then
      a.y = screenH + 50
    elseif a.y > screenH + 50 then
      a.y = -50
    end
  end
end

function Asteroid.checkCollisions(bullets)
  for ai = #asteroids, 1, -1 do
    local a = asteroids[ai]
    for bi = #bullets, 1, -1 do
      local b = bullets[bi]
      local dx = a.x - b.x
      local dy = a.y - b.y
      local dist = math.sqrt(dx * dx + dy * dy)

      if dist < a.radius + b.radius then
        table.remove(bullets, bi)

        if a.size > 1 then
          for i = 1, 2 do
            local angleOffset = math.random() * math.pi * 2
            local newX = a.x + math.cos(angleOffset) * a.radius / 2
            local newY = a.y + math.sin(angleOffset) * a.radius / 2
            Asteroid.spawn(newX, newY, a.size - 1)
          end
        end

        table.remove(asteroids, ai)
        break
      end
    end
  end
end

function Asteroid.draw()
  for _, a in ipairs(asteroids) do
    local scale = a.size / 3
    love.graphics.draw(
      asteroidImage,
      a.x,
      a.y,
      math.rad(a.rotation),
      scale,
      scale,
      asteroidImage:getWidth() / 2,
      asteroidImage:getHeight() / 2)
  end
end

function Asteroid.spawnWave(count)
  for i = 1, count do
    Asteroid.spawn()
  end
end

return Asteroid
