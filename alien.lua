local Alien = {}
Alien.__index = Alien

-- Class-level constants
Alien.spriteImage = love.graphics.newImage("sprites/alien-ship.png")
Alien.speed = 40
Alien.rotateSpeed = 180
Alien.gridSize = 32
Alien.pathUpdateInterval = 2
Alien.shootInterval = 2
Alien.bulletSpeed = 200
Alien.hitRadius = 20

-- Global aliens list
Aliens = {}

-- Spawn timer
local spawnTimer = 0
local spawnInterval = 30

-- Score
local score = 100

-- A* implementation
local function heuristic(x1, y1, x2, y2)
  return math.abs(x1 - x2) + math.abs(y1 - y2)
end

local function getNeighbors(x, y, gridSize, width, height)
  local neighbors = {}
  local directions = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}, {-1, -1}, {1, -1}, {-1, 1}, {1, 1}}

  for _, dir in ipairs(directions) do
    local nx, ny = x + dir[1] * gridSize, y + dir[2] * gridSize
    if nx >= 0 and nx < width and ny >= 0 and ny < height then
      table.insert(neighbors, {x = nx, y = ny})
    end
  end
  return neighbors
end

local function reconstructPath(cameFrom, current)
  local path = {current}
  while cameFrom[current.x .. "," .. current.y] do
    current = cameFrom[current.x .. "," .. current.y]
    table.insert(path, 1, current)
  end
  return path
end

local function findPath(startX, startY, goalX, goalY)
  local start = {x = math.floor(startX / Alien.gridSize) * Alien.gridSize,
                 y = math.floor(startY / Alien.gridSize) * Alien.gridSize}
  local goal = {x = math.floor(goalX / Alien.gridSize) * Alien.gridSize,
                y = math.floor(goalY / Alien.gridSize) * Alien.gridSize}

  local openSet = {start}
  local cameFrom = {}
  local gScore = {[start.x .. "," .. start.y] = 0}
  local fScore = {[start.x .. "," .. start.y] = heuristic(start.x, start.y, goal.x, goal.y)}

  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()

  while #openSet > 0 do
    local current = openSet[1]
    local currentIdx = 1
    for i, node in ipairs(openSet) do
      if fScore[node.x .. "," .. node.y] < fScore[current.x .. "," .. current.y] then
        current = node
        currentIdx = i
      end
    end

    if current.x == goal.x and current.y == goal.y then
      return reconstructPath(cameFrom, current)
    end

    table.remove(openSet, currentIdx)

    for _, neighbor in ipairs(getNeighbors(current.x, current.y, Alien.gridSize, width, height)) do
      local tentativeGScore = gScore[current.x .. "," .. current.y] + Alien.gridSize
      local neighborKey = neighbor.x .. "," .. neighbor.y

      if not gScore[neighborKey] or tentativeGScore < gScore[neighborKey] then
        cameFrom[neighborKey] = current
        gScore[neighborKey] = tentativeGScore
        fScore[neighborKey] = tentativeGScore + heuristic(neighbor.x, neighbor.y, goal.x, goal.y)

        local inOpenSet = false
        for _, node in ipairs(openSet) do
          if node.x == neighbor.x and node.y == neighbor.y then
            inOpenSet = true
            break
          end
        end
        if not inOpenSet then
          table.insert(openSet, neighbor)
        end
      end
    end
  end

  return {}
end

-- Constructor
function Alien.new(x, y)
  local self = setmetatable({}, Alien)

  self.x = x or love.graphics.getWidth() / 2
  self.y = y or 0
  self.rotate = 0
  self.rotationOffset = 90
  self.sprite = Alien.spriteImage

  self.path = {}
  self.currentPathIndex = 1
  self.pathTimer = 0

  self.shootTimer = 0
  self.isAlive = true
  self.bullets = {}

  return self
end

-- Instance methods
function Alien:update(dt, playerX, playerY)
  if not self.isAlive then
    return
  end

  self.pathTimer = self.pathTimer + dt
  if self.pathTimer >= Alien.pathUpdateInterval then
    self.pathTimer = 0
    self.path = findPath(self.x, self.y, playerX, playerY)
    self.currentPathIndex = 1
  end

  if #self.path > 0 and self.currentPathIndex <= #self.path then
    local target = self.path[self.currentPathIndex]
    local dx = target.x - self.x
    local dy = target.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 5 then
      local moveX = (dx / distance) * Alien.speed * dt
      local moveY = (dy / distance) * Alien.speed * dt
      self.x = self.x + moveX
      self.y = self.y + moveY
    else
      self.currentPathIndex = self.currentPathIndex + 1
    end
  end

  self.shootTimer = self.shootTimer + dt
  if self.shootTimer >= Alien.shootInterval then
    self.shootTimer = 0
    self:shoot(playerX, playerY)
  end

  for i = #self.bullets, 1, -1 do
    local bullet = self.bullets[i]
    bullet.x = bullet.x + bullet.vx * dt
    bullet.y = bullet.y + bullet.vy * dt

    if bullet.x < 0 or bullet.x > love.graphics.getWidth() or
       bullet.y < 0 or bullet.y > love.graphics.getHeight() then
      table.remove(self.bullets, i)
    end
  end
end

function Alien:shoot(playerX, playerY)
  local dx = playerX - self.x
  local dy = playerY - self.y
  local distance = math.sqrt(dx * dx + dy * dy)

  if distance > 0 then
    table.insert(self.bullets, {
      x = self.x,
      y = self.y,
      vx = (dx / distance) * Alien.bulletSpeed,
      vy = (dy / distance) * Alien.bulletSpeed
    })
  end
end

function Alien:checkCollision(x, y, radius)
  if not self.isAlive then
    return false
  end

  local dx = self.x - x
  local dy = self.y - y
  local distance = math.sqrt(dx * dx + dy * dy)

  if distance < Alien.hitRadius + radius then
    self.isAlive = false
    return true
  end
  return false
end

function Alien:checkBulletCollision(x, y, radius)
  for i = #self.bullets, 1, -1 do
    local bullet = self.bullets[i]
    local dx = bullet.x - x
    local dy = bullet.y - y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance < radius + 3 then
      table.remove(self.bullets, i)
      return true
    end
  end
  return false
end

function Alien.spawn()
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()
  local side = math.random(1, 4)
  local x, y

  if side == 1 then
    x = 0
    y = math.random(0, height)
  elseif side == 2 then
    x = width
    y = math.random(0, height)
  elseif side == 3 then
    x = math.random(0, width)
    y = 0
  else
    x = math.random(0, width)
    y = height
  end

  local newAlien = Alien.new(x, y)
  table.insert(Aliens, newAlien)
  return newAlien
end

function Alien.updateAll(dt, playerX, playerY)
  spawnTimer = spawnTimer + dt
  if spawnTimer >= spawnInterval then
    spawnTimer = 0
    Alien.spawn()
  end

  for i = #Aliens, 1, -1 do
    local alien = Aliens[i]
    alien:update(dt, playerX, playerY)

    if not alien.isAlive then
      table.remove(Aliens, i)
    end
  end
end

function Alien.drawAll()
  for _, alien in ipairs(Aliens) do
    if alien.isAlive then
      love.graphics.draw(
        alien.sprite,
        alien.x,
        alien.y,
        math.rad(0),
        1,
        1,
        alien.sprite:getWidth() / 2,
        alien.sprite:getHeight() / 2
      )

      -- Draw path for debugging
      -- if #alien.path > 1 then
      --   love.graphics.setColor(0, 1, 0, 0.5)
      --   for i = 1, #alien.path - 1 do
      --     love.graphics.line(alien.path[i].x, alien.path[i].y,
      --                       alien.path[i + 1].x, alien.path[i + 1].y)
      --   end
      --   love.graphics.setColor(1, 1, 1, 1)
      -- end
    end
  end

  -- Draw all bullets
  love.graphics.setColor(1, 1, 1, 1)
  for _, alien in ipairs(Aliens) do
    for _, bullet in ipairs(alien.bullets) do
      love.graphics.circle("fill", bullet.x, bullet.y, 3)
    end
  end
  love.graphics.setColor(1, 1, 1, 1)
end

-- Clear all aliens
function Alien.clearAll()
  Aliens = {}
  spawnTimer = 0
end

function Alien.getScore()
  return score
end

return Alien
