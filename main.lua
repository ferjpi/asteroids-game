local Player = require("player")

local Bullet = require("bullet")

function love.load()
  Sprites = {}

end

function love.update(dt)

  Bullet.update(dt)
  Player.move(dt)
end

function love.draw()
  love.graphics.setFont(love.graphics.newFont(64))
  -- love.graphics.printf("Asteroids", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")

  -- Draw player
  Player.draw()
  Player.constrain_to_screen()


  -- Draw bullets
  Bullet.draw()
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "space" then
    local angle = math.rad(Player.rotate - Player.rotationOffset)
    Bullet.shoot(Player.x, Player.y, angle)
  end
end
