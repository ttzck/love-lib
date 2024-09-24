local active_scene = {}

function SetActiveScene(scene)
   active_scene = scene
   if active_scene.load then
      active_scene.load()
   end
end

function love.load()
   WINDOW_WIDTH, WINDOW_HEIGHT = 1200, 800
   love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { msaa = 4 })
   love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
   FONT_8 = love.graphics.newFont("ubuntu-regular.ttf", 8)
   FONT_12 = love.graphics.newFont("ubuntu-regular.ttf", 12)
   FONT_16 = love.graphics.newFont("ubuntu-regular.ttf", 16)
   FONT_32 = love.graphics.newFont("ubuntu-regular.ttf", 32)
   FONT_64 = love.graphics.newFont("ubuntu-bold.ttf", 64)
   PERSON = love.graphics.newImage("person-solid.png")
   TOWER = love.graphics.newImage("chess-rook-solid.png")
   SKULL = love.graphics.newImage("skull-solid.png")

   require("utils")
   require("ui")
   require("core")
   require("particles")
   require("vector")
   require("audio_explorer")
   require("grid_test_scene")
   require("collision_test_scene")
   require("space_partitioning")
   require("main_scene")
   require("enemy")
   require("arrow")
   require("cards")
   require("player")
   SetActiveScene(MainScene)
end

function love.draw()
   if active_scene.draw then
      active_scene.draw()
   end
end

function love.update(dt)
   if active_scene.update then
      active_scene.update(dt)
   end
end

function love.mousepressed(_, _, button)
   if active_scene.mousepressed then
      active_scene.mousepressed(_, _, button)
   end
end

function love.keypressed(key)
   if active_scene.keypressed then
      active_scene.keypressed(key)
   end
end

function love.mousereleased(x, y, button, istouch, presses)
   if active_scene.mousereleased then
      active_scene.mousereleased(x, y, button, istouch, presses)
   end
end
