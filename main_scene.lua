MainScene = {}

MainScene.trees = {}
MainScene.spawn_timer = TimeSpan.new(20)

function MainScene.load()
   CENTER = Vector.new(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)

   local j = 1
   for _ = 1, 300 do
      local p = Utils.random.in_rectangle(WINDOW_WIDTH, WINDOW_HEIGHT)
      if Vector.dist(p, CENTER) > 380 then
         MainScene.trees[j] = { p, Utils.table.random({ "#003300", "#004400", "#002200" }) }
         j = j + 1
      end
   end
   table.sort(MainScene.trees, function(a, b)
      return a[1].y < b[1].y
   end)
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

   if MainScene.spawn_timer:is_over() then
      local p = random_invader_spawn_position()
      for _ = 1, 10 do
         Unit.spawn_creep("invader", p)
      end
      MainScene.spawn_timer:reset()
   end
end

function MainScene.draw()
   if love.mouse.isDown(1) then
      local p = Utils.input.mouse_position()
      love.graphics.translate(-p.x, -p.y)
      love.graphics.scale(2, 2)
   end

   Utils.graphics.checkerboard_pattern(
      Vector.new(0, 0),
      64,
      64,
      WINDOW_WIDTH / 64 + 1,
      WINDOW_HEIGHT / 64 + 1,
      "#111111",
      "#121212"
   )
   Utils.graphics.dashed_circle(CENTER, 20, "#000099", 2, 6)
   Utils.graphics.dashed_circle(CENTER, 380, "#990000", 2, 64)

   Core.remove_destroyed_entities()
   Core.compile_groups()
   Core.draw()
   Particles.draw()

   for _, tree in pairs(MainScene.trees) do
      Utils.graphics.set_color_hex(tree[2])
      Utils.graphics.draw_centered(TREE, tree[1].x, tree[1].y, 0, 0.2, 0.2)
   end

   Utils.graphics.set_color_hex("#ffffff")
   love.graphics.print("1: Archer", FONT_16, 10, WINDOW_HEIGHT - 50)
   love.graphics.print("2: Knight", FONT_16, 10, WINDOW_HEIGHT - 30)
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
