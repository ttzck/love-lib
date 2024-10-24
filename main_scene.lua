MainScene = {}

function MainScene.load()
   CENTER = Vector.new(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)
end

local function random_invader_spawn_position()
   local p = Utils.random.on_circle(380)
   local m = Vector.new(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)
   return Vector.add(p, m)
end

local function random_defender_spawn_position()
   local p = Utils.random.on_circle(love.math.random() * 20)
   local m = Vector.new(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)
   return Vector.add(p, m)
end

function MainScene.update(dt)
   Grids = {
      unit = SpacePartitioning.new(32),
      defender = SpacePartitioning.new(32),
      invader = SpacePartitioning.new(32),
   }
   Core.remove_destroyed_entities()
   Core.compile_groups()
   Core.update(dt)

   if love.math.random() < 0.1 then
      Unit.spawn_creep("invader", random_invader_spawn_position())
   end
end

function MainScene.draw()
   Utils.graphics.checkerboard_pattern(
      Vector.new(0, 0),
      32,
      32,
      WINDOW_WIDTH / 32 + 1,
      WINDOW_HEIGHT / 32,
      "#111111",
      "#121212"
   )
   Utils.graphics.dashed_circle(CENTER, 20, "#000099", 2, 6)
   Utils.graphics.dashed_circle(CENTER, 380, "#990000", 2, 64)
   Utils.graphics.set_color_hex("#ffffff")
   love.graphics.print("1: Archer", FONT_16, 10, WINDOW_HEIGHT - 50)
   love.graphics.print("2: Knight", FONT_16, 10, WINDOW_HEIGHT - 30)

   Core.remove_destroyed_entities()
   Core.compile_groups()
   Core.draw()
   Particles.draw()
end

function MainScene.keypressed(key)
   if key == "1" then
      Unit.spawn_archer("defender", random_defender_spawn_position())
   end
   if key == "2" then
      Unit.spawn_knight("defender", random_defender_spawn_position())
   end
   if key == "3" then
      Unit.spawn_ninja("defender", random_defender_spawn_position())
   end
end

function MainScene.mousereleased(x, y, button) end
