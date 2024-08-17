require("utils")
require("ui")
require("core")
require("particles")
require("vector")
local bump = require("bump")
require("physics_object")
require("unit")
require("projectile")

function love.load()
   WindowWidth, WindowHeight = 800, 600
   love.window.setMode(WindowWidth, WindowHeight, { msaa = 0 })
   love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

   Physics = bump.newWorld(64)

   for i = 1, 10, 1 do
      local rand_pos = Utils.random.in_rectangle(WindowWidth / 2, WindowHeight)
      Core.new_entity(nil, "defender", {
         position = rand_pos,
         width = 8,
         height = 8,
         color = "#ff0000",
         speed = 32,
         range = 128,
         attack_period = 3,
      })
      local rand_pos = Utils.random.in_rectangle(WindowWidth / 2, WindowHeight)
      Core.new_entity(nil, "invader", {
         position = Vector.add(rand_pos, Vector.new(WindowWidth / 2)),
         width = 8,
         height = 8,
         color = "#0000ff",
         speed = 32,
         range = 128,
         attack_period = 3,
      })
   end
end

function love.keypressed(key) end

function love.draw()
   Particles.draw()
   Core.remove_destroyed_entities()
   Core.compile_groups()
   Core.draw()

   Utils.graphics.set_color_hex("#ffffff")
   love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 10, 10)
   love.graphics.print("Number of Entities:" .. tostring(Core.number_of_entities()), 10, 20)
end

function love.update(dt)
   Core.remove_destroyed_entities()
   Core.compile_groups()
   Core.update(dt)
end

function love.mousepressed(_, _, button) end
