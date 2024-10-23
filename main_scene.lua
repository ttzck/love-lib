MainScene = {}

TowerPosition = Vector.new(WINDOW_WIDTH / 2, 13 * WINDOW_HEIGHT / 16)

function MainScene.load() end

function MainScene.update(dt)
   Grids = {
      unit = SpacePartitioning.new(32),
      defender = SpacePartitioning.new(32),
      invader = SpacePartitioning.new(32),
   }
   Core.remove_destroyed_entities()
   Core.compile_groups()
   Core.update(dt)

   if love.math.random() < 0.03 then
      local p = Utils.random.on_unit_circle()
      p = Vector.mul(p, 100 * love.math.random())
      local m = Vector.new(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)
      p = Vector.add(p, m)
      Utils.table.random({Unit.spawn_archer, Unit.spawn_shield_carrier})("defender", p)
   end
   if love.math.random() < 0.03 then
      local p = Vector.new(love.math.random() * WINDOW_WIDTH, love.math.random() * WINDOW_HEIGHT)
      Unit.spawn_archer("invader", p)
   end
end

function MainScene.draw()
   Core.remove_destroyed_entities()
   Core.compile_groups()
   Core.draw()
   Particles.draw()

end

function MainScene.keypressed(key)
   if key == "space" then
      Player.play_card()
   end
   if key == "c" then
      Player.draw_card()
   end
   if key == "v" then
      Player.restock_draw_pile()
   end
end

function MainScene.mousereleased(x, y, button)
   if button == 1 then
      Player.play_card()
   end
end
