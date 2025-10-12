local Player = {}
Player.__index = Player

Player.sprite = love.graphics.newImage("sprites/ship.png")
Player.speed = 100
Player.rotateSpeed = 180
Player.x = love.graphics.getWidth() / 2
Player.y = love.graphics.getHeight() / 2
Player.rotate = 0
Player.rotationOffset = 90

Player.isAlive = true
Player.hitRadius = Player.sprite:getWidth() / 2


function Player.draw()
  if not Player.isAlive then
    return
  end

  love.graphics.draw(
    Player.sprite,
    Player.x,
    Player.y,
    math.rad(Player.rotate),
    1,
    1,
    Player.sprite:getWidth() / 2,
    Player.sprite:getHeight() / 2
  )
end

function Player.move(dt)
  if not Player.isAlive then
    return
  end

  local isScancode = love.keyboard.isScancodeDown
  if isScancode("a") then
    -- rotate left
    Player.rotate = Player.rotate - Player.rotateSpeed * dt
  elseif isScancode("d") then
    -- move right
    Player.rotate = Player.rotate + Player.rotateSpeed * dt
  end

  -- Move forward/backward using vector math
  local angle = math.rad(Player.rotate - Player.rotationOffset)
  if isScancode("w") then
    Player.x = Player.x + math.cos(angle) * Player.speed * dt
    Player.y = Player.y + math.sin(angle) * Player.speed * dt
  elseif isScancode("s") then
    Player.x = Player.x - math.cos(angle) * Player.speed * dt
    Player.y = Player.y - math.sin(angle) * Player.speed * dt
  end
end

function Player.constrain_to_screen()
  local halfW = Player.sprite:getWidth() / 2
  local halfH = Player.sprite:getHeight() / 2
  local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()

  if Player.x < halfW then
    Player.x = halfW
  elseif Player.x > screenW - halfW then
    Player.x = screenW - halfW
  end

  if Player.y < halfH then
    Player.y = halfH
  elseif Player.y > screenH - halfH then
    Player.y = screenH - halfH
  end
end

function Player.checkCollision(x, y, radius)
  local dx = Player.x - x
  local dy = Player.y - y
  local distance = math.sqrt(dx * dx + dy * dy)

  if distance <= Player.radius + radius then
    Player.isAlive = false
    return true
  end

  return false

end

function Player.die()
  Player.isAlive = false
end

return Player
