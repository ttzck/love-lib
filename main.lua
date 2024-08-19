local active_scene = {}

function SetActiveScene(scene)
   active_scene = scene
   if active_scene.load then
      active_scene.load()
   end
end

function love.load()
   WINDOW_WIDTH, WINDOW_HEIGHT = 1200, 800
   love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { msaa = 2 })
   love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
   FONT_8 = love.graphics.newFont("ubuntu-regular.ttf", 8)
   FONT_12 = love.graphics.newFont("ubuntu-regular.ttf", 12)
   FONT_16 = love.graphics.newFont("ubuntu-regular.ttf", 16)
   FONT_32 = love.graphics.newFont("ubuntu-regular.ttf", 32)
   FONT_64 = love.graphics.newFont("ubuntu-bold.ttf", 64)
   BASE_Y = 7 * WINDOW_HEIGHT / 8
   BONG_001 = love.audio.newSource("kenney_interface-sounds/Audio/bong_001.ogg", "static")
   CLICK_002 = love.audio.newSource("kenney_interface-sounds/Audio/click_002.ogg", "static")
   CLICK_003 = love.audio.newSource("kenney_interface-sounds/Audio/click_003.ogg", "static")
   QUESTION_001 = love.audio.newSource("kenney_interface-sounds/Audio/question_001.ogg", "static")
   DROP_003 = love.audio.newSource("kenney_interface-sounds/Audio/drop_003.ogg", "static")
   DROP_001 = love.audio.newSource("kenney_interface-sounds/Audio/drop_001.ogg", "static")
   TICK_001 = love.audio.newSource("kenney_interface-sounds/Audio/tick_001.ogg", "static")
   SELECT_001 = love.audio.newSource("kenney_interface-sounds/Audio/select_001.ogg", "static")
   CONFIRMATION_001 = love.audio.newSource("kenney_interface-sounds/Audio/confirmation_001.ogg", "static")
   GLASS_006 = love.audio.newSource("kenney_interface-sounds/Audio/glass_006.ogg", "static")

   require("utils")
   require("hand")
   require("ui")
   require("core")
   require("particles")
   require("vector")
   require("physics_object")
   require("time_object")
   require("unit")
   require("projectile")
   require("main_ui")
   require("waves")
   require("main_scene")
   require("audio_explorer")

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
