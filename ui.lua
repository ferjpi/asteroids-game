
local UI = {}
UI.__index = UI

UI.score = 0
UI.isMenuOpen = true
UI.isPaused = false
UI.isGameStarted = false

function UI.get_score()
  return UI.score
end

function UI.set_score(score)
  UI.score = UI.score + score
end

function UI.draw()
  if UI.isGameStarted then
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("Score: " .. UI.score, 10, 5, love.graphics.getWidth(), "left")
  end

  UI.menu()
end

function UI.menu()
  love.graphics.setFont(love.graphics.newFont(64))
  if not UI.isGameStarted then
    love.graphics.printf("Asteroids", 0, (love.graphics.getHeight() / 2) - 50, love.graphics.getWidth(), "center")
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("Press Enter to Start", 0, (love.graphics.getHeight() / 2) + 40, love.graphics.getWidth(), "center")
  elseif UI.isPaused and UI.isGameStarted then
    love.graphics.printf("Paused", 0, (love.graphics.getHeight() / 2) - 50, love.graphics.getWidth(), "center")
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("Press Q to Quit game", 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), "center")
  end
end

function UI.toggle_menu()
  UI.isMenuOpen = not UI.isMenuOpen
end


return UI
