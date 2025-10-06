
local Bullet = {}
Bullet.__index = Bullet

local bullets = {}
local bulletSpeed = 400
local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()


-- Create and add a new bullet
function Bullet.shoot(x, y, angle)
  local bx = x + math.cos(angle) * 20
  local by = y + math.sin(angle) * 20
  local b = {
    x = bx,
    y = by,
    dx = math.cos(angle) * bulletSpeed,
    dy = math.sin(angle) * bulletSpeed,
  }
  table.insert(bullets, b)
end

-- Update bullet positions and remove off-screen bullets
function Bullet.update(dt)
  for i = #bullets, 1, -1 do
    local b = bullets[i]
    b.x = b.x + b.dx * dt
    b.y = b.y + b.dy * dt

    if b.x < 0 or b.x > screenW or b.y < 0 or b.y > screenH then
      table.remove(bullets, i)
    end
  end
end

-- Draw all bullets
function Bullet.draw()
  for _, b in ipairs(bullets) do
    love.graphics.circle("fill", b.x, b.y, 4)
  end
end

return Bullet
