
local UI = {}
UI.__index = UI

UI.score = 0

function UI.get_score()
  return UI.score
end

function UI.set_score(score)
  UI.score = score
end

function UI.draw()
  love.graphics.setFont(love.graphics.newFont(24))
  love.graphics.printf("Score: " .. UI.score, 10, 5, love.graphics.getWidth(), "left")
end

return UI
