local UI = require("ui")
local Player = require("player")
local Bullet = require("bullet")
local Asteroid = require("asteroid")
local Alien = require("alien")

function love.load()

end

function love.update(dt)
  if UI.isPaused or not UI.isGameStarted then
    return
  end
  Bullet.update(dt)
  Player.move(dt)

  Asteroid.update(dt)
  Asteroid.checkCollisions(Bullet.bullets)

  Alien.updateAll(dt, Player.x, Player.y)


 for i = #Bullet.bullets, 1, -1 do
    local bullet = Bullet.bullets[i]
    local hit = false

    for _, alien in ipairs(Aliens) do
      if alien:checkCollision(bullet.x, bullet.y, 3) then
        table.remove(Bullet.bullets, i)
        hit = true
        UI.set_score(alien.getScore())
        break
      end
    end

    if hit then
      break
    end
  end

 for _, alien in ipairs(Aliens) do
    if alien:checkBulletCollision(Player.x, Player.y, Player.hitRadius or 20) then
      Player.die()
      break
    end
  end

  for _, alien in ipairs(Aliens) do
    if alien:checkCollision(Player.x, Player.y, Player.hitRadius or 20) then
      Player.die()
      break
    end
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
  Alien.drawAll()

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
