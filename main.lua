local UI = require("ui")
local Player = require("player")
local Bullet = require("bullet")
local Asteroid = require("asteroid")

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
  
  Asteroid.checkCollisions(Bullet.list)
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
