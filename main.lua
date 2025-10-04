local Player = require("player")

function love.load()
  Sprites = {}
end

function love.update(dt)
  Player.move(dt)
end

function love.draw()
  love.graphics.setFont(love.graphics.newFont(64))
  -- love.graphics.printf("Asteroids", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")

  -- Draw player
  Player.draw()
  Player.constrain_to_screen()
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
