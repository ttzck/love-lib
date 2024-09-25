MainScene = {}

TowerPosition = Vector.new(WINDOW_WIDTH / 2, 13 * WINDOW_HEIGHT / 16)

function MainScene.load()
   for _ = 1, 5, 1 do
      Core.new_entity(nil, { "enemy" }, {
         position = Vector.new(love.math.random() * WINDOW_WIDTH, love.math.random() * WINDOW_HEIGHT / 64),
         hp = 3,
      })
   end
end

function MainScene.update(dt)
   EnemyGrid = SpacePartitioning.new(32)
   Core.remove_destroyed_entities()
   Core.compile_groups()
   Core.update(dt)
   Player.update(dt)

   if love.math.random() < 0.01 then
      Core.new_entity(nil, { "enemy" }, {
         position = Vector.new(love.math.random() * WINDOW_WIDTH, love.math.random() * WINDOW_HEIGHT / 64),
         hp = 3,
      })
   end
end

function MainScene.draw()
   Particles.draw()
   Core.remove_destroyed_entities()
   Core.compile_groups()
   Core.draw()
   Player.draw()

   --EnemyGrid:draw()
end

function MainScene.keypressed(key)
   if key == "space" then
      Player.play_card()
   end
end

function MainScene.mousereleased(x, y, button)
   if button == 1 then
      Player.play_card()
   end
end
