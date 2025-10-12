local UI = require("ui")
local Player = require("player")
local Bullet = require("bullet")
local Asteroid = require("asteroid")
local Alien = require("alien")

function love.load()
  Sprites = {}

end

function love.update(dt)
  if UI.isPaused or not UI.isGameStarted then
    return
  end
  Bullet.update(dt)
  Player.move(dt)

  Asteroid.update(dt)
  Asteroid.checkCollisions(Bullet.bullets)

  Alien.update(dt, Player.x, Player.y)


  -- Check if player bullets hit alien
  -- Assuming your Bullet module has a way to get player bullets
  -- You'll need to implement this based on your Bullet structure
  for i = #Bullet.bullets, 1, -1 do  -- Adjust based on your Bullet module
    local bullet = Bullet.bullets[i]
    if Alien.checkCollision(bullet.x, bullet.y, 3) then  -- 3 is bullet radius
      table.remove(Bullet.bullets, i)
      -- Alien is now dead (Alien.isAlive = false)
    end
   end

  -- Check if alien bullets hit player
  -- Assuming Player has x, y, and a hitRadius property
  if Alien.checkBulletCollision(Player.x, Player.y, Player.hitRadius or 20) then
    -- Handle player being hit (reduce health, game over, etc.)
    print("Player hit!")
    Player.die()
  end

  -- Check collision between alien and player
  if Alien.checkCollision(Player.x, Player.y, Player.hitRadius or 20) then
    -- Both alien and player should die or take damage
    print("Collision!")
    Player.die()
  end
end

function love.draw()


  -- Draw UI
  UI.draw()

  if UI.isPaused or not UI.isGameStarted then
    return
  end


  -- Draw player
  Player.draw()
  Player.constrain_to_screen()

  -- Draw alien
  Alien.draw()

  -- Draw bullets
  Bullet.draw()

  -- Draw asteroids
  Asteroid.draw()
end

function love.keypressed(key)
  if key == "escape" then

    if not UI.isPaused then
      UI.isPaused = true
    else
      UI.isPaused = false
    end

  elseif key == "q" then
    if UI.isPaused then
      love.event.quit()
    end
  elseif key == "return" then

    if UI.isMenuOpen and not UI.isGameStarted then
      UI.isMenuOpen = false
      UI.isGameStarted = true
      Asteroid.spawnWave(5)
    end

  elseif key == "space" and UI.isGameStarted then
    local angle = math.rad(Player.rotate - Player.rotationOffset)
    Bullet.shoot(Player.x, Player.y, angle)
  end
end
