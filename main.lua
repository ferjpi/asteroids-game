function love.load()
  Sprites = {}
  Sprites.ship = love.graphics.newImage("sprites/ship.png")
end

function love.update(dt)

end

function love.draw()
  love.graphics.setFont(love.graphics.newFont(64))
  -- love.graphics.printf("Asteroids", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
  
  love.graphics.draw(Sprites.ship, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
end
