
local Alien = {}
Alien.__index = Alien
Alien.sprite = love.graphics.newImage("sprites/alien-ship.png")
Alien.speed = 40
Alien.rotateSpeed = 180
Alien.x = love.graphics.getWidth() / 2
Alien.y =  0
Alien.rotate = 0
Alien.rotationOffset = 90

-- A* pathfinding variables
Alien.path = {}
Alien.currentPathIndex = 1
Alien.gridSize = 32  -- Size of grid cells for pathfinding
Alien.pathUpdateInterval = 2  -- Recalculate path every 2 seconds
Alien.pathTimer = 0

-- Shooting variables
Alien.shootInterval = 2  -- Shoot every 2 seconds
Alien.shootTimer = 0
Alien.isAlive = true
Alien.bullets = {}
Alien.bulletSpeed = 200
Alien.hitRadius = 20  -- Collision radius

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

function Alien.findPath(startX, startY, goalX, goalY)
  -- Snap to grid
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
    -- Find node with lowest fScore
    local current = openSet[1]
    local currentIdx = 1
    for i, node in ipairs(openSet) do
      if fScore[node.x .. "," .. node.y] < fScore[current.x .. "," .. current.y] then
        current = node
        currentIdx = i
      end
    end

    -- Goal reached
    if current.x == goal.x and current.y == goal.y then
      return reconstructPath(cameFrom, current)
    end

    table.remove(openSet, currentIdx)

    -- Check neighbors
    for _, neighbor in ipairs(getNeighbors(current.x, current.y, Alien.gridSize, width, height)) do
      local tentativeGScore = gScore[current.x .. "," .. current.y] + Alien.gridSize
      local neighborKey = neighbor.x .. "," .. neighbor.y

      if not gScore[neighborKey] or tentativeGScore < gScore[neighborKey] then
        cameFrom[neighborKey] = current
        gScore[neighborKey] = tentativeGScore
        fScore[neighborKey] = tentativeGScore + heuristic(neighbor.x, neighbor.y, goal.x, goal.y)

        -- Add to openSet if not already there
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

  return {}  -- No path found
end

function Alien.update(dt, playerX, playerY)
  if not Alien.isAlive then
    return
  end

  -- Update path periodically
  Alien.pathTimer = Alien.pathTimer + dt
  if Alien.pathTimer >= Alien.pathUpdateInterval then
    Alien.pathTimer = 0
    Alien.path = Alien.findPath(Alien.x, Alien.y, playerX, playerY)
    Alien.currentPathIndex = 1
  end

  -- Follow the path
  if #Alien.path > 0 and Alien.currentPathIndex <= #Alien.path then
    local target = Alien.path[Alien.currentPathIndex]
    local dx = target.x - Alien.x
    local dy = target.y - Alien.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 5 then
      -- Move towards target
      local moveX = (dx / distance) * Alien.speed * dt
      local moveY = (dy / distance) * Alien.speed * dt
      Alien.x = Alien.x + moveX
      Alien.y = Alien.y + moveY
    else
      -- Reached waypoint, move to next
      Alien.currentPathIndex = Alien.currentPathIndex + 1
    end
  end

  -- Shooting logic
  Alien.shootTimer = Alien.shootTimer + dt
  if Alien.shootTimer >= Alien.shootInterval then
    Alien.shootTimer = 0
    Alien.shoot(playerX, playerY)
  end

  -- Update alien bullets
  for i = #Alien.bullets, 1, -1 do
    local bullet = Alien.bullets[i]
    bullet.x = bullet.x + bullet.vx * dt
    bullet.y = bullet.y + bullet.vy * dt

    -- Remove bullets that go off screen
    if bullet.x < 0 or bullet.x > love.graphics.getWidth() or
       bullet.y < 0 or bullet.y > love.graphics.getHeight() then
      table.remove(Alien.bullets, i)
    end
  end
end

function Alien.draw()
  if not Alien.isAlive then
    return
  end

  love.graphics.draw(
    Alien.sprite,
    Alien.x,
    Alien.y,
    math.rad(0),
    1,
    1,
    Alien.sprite:getWidth() / 2,
    Alien.sprite:getHeight() / 2
  )

  -- Optional: Draw path for debugging
  if #Alien.path > 1 then
    love.graphics.setColor(0, 1, 0, 0.5)
    for i = 1, #Alien.path - 1 do
      love.graphics.line(Alien.path[i].x, Alien.path[i].y,
                        Alien.path[i + 1].x, Alien.path[i + 1].y)
    end
    love.graphics.setColor(1, 1, 1, 1)
  end

  -- Draw alien bullets
  love.graphics.setColor(1, 1, 1, 1)
  for _, bullet in ipairs(Alien.bullets) do
    love.graphics.circle("fill", bullet.x, bullet.y, 3)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

function Alien.shoot(playerX, playerY)
  local dx = playerX - Alien.x
  local dy = playerY - Alien.y
  local distance = math.sqrt(dx * dx + dy * dy)

  if distance > 0 then
    table.insert(Alien.bullets, {
      x = Alien.x,
      y = Alien.y,
      vx = (dx / distance) * Alien.bulletSpeed,
      vy = (dy / distance) * Alien.bulletSpeed
    })
  end
end

function Alien.checkCollision(x, y, radius)
  if not Alien.isAlive then
    return false
  end

  local dx = Alien.x - x
  local dy = Alien.y - y
  local distance = math.sqrt(dx * dx + dy * dy)

  if distance < Alien.hitRadius + radius then
    Alien.isAlive = false
    return true
  end
  return false
end

function Alien.checkBulletCollision(x, y, radius)
  for i = #Alien.bullets, 1, -1 do
    local bullet = Alien.bullets[i]
    local dx = bullet.x - x
    local dy = bullet.y - y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance < radius + 3 then  -- 3 is bullet radius
      table.remove(Alien.bullets, i)
      return true
    end
  end
  return false
end

function Alien.reset()
  Alien.x = 0
  Alien.y = love.graphics.getHeight() / 2
  Alien.rotate = 0
  Alien.isAlive = true
  Alien.bullets = {}
  Alien.path = {}
  Alien.currentPathIndex = 1
  Alien.pathTimer = 0
  Alien.shootTimer = 0
end

return Alien
