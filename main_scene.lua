MainScene = {}

function MainScene.load()
   DEBUG = false
   PAUSED = true
   UNPAUSED_TIME = 0
   GAME_OVER = false
   TUTORIAL = true

   -- reset state
   Physics = require("bump").newWorld(64)

   Particles.get_time = function()
      return UNPAUSED_TIME
   end
   Particles.active = {}
   Core.entities = {}
end

function MainScene.draw()
   if GAME_OVER then
      Ui.root = GAME_OVER_UI
   elseif TUTORIAL then
      Ui.root = TUTORIAL_UI
   else
      Ui.root = MAIN_UI
   end

   -- blue base zone
   Utils.graphics.set_color_hex("#0000ff20")
   love.graphics.rectangle("fill", 0, BASE_Y, WINDOW_WIDTH, WINDOW_HEIGHT - BASE_Y)

   Utils.graphics.set_color_hex("#ffffff")
   love.graphics.rectangle("fill", 0, BASE_Y, WINDOW_WIDTH, 1)

   -- time warp
   if love.mouse.isDown(1, 2) and not PAUSED then
      Utils.graphics.set_color_hex("#ffffff")
      local m_pos = Utils.input.mouse_position()
      local v = Vector.new(TIME_WARP_RADIUS, 0)
      if love.mouse.isDown(1) then
         v = Vector.rot(v, UNPAUSED_TIME * TIME_WARP_ACCELERATION)
      else
         v = Vector.rot(v, UNPAUSED_TIME / TIME_WARP_DECELERATION)
      end
      for i = 1, 12, 1 do
         local p = Vector.add(m_pos, v)
         love.graphics.circle("fill", p.x, p.y, 1)
         v = Vector.rot(v, 2 * math.pi / 12)
      end
   end

   Particles.draw()
   Core.remove_destroyed_entities()
   Core.compile_groups()
   Core.draw()

   -- print type
   if not GAME_OVER then
      for _, unit in pairs(Core.get_group("unit")) do
         local pos = unit:get_position()
         if Vector.dist(Utils.input.mouse_position(), pos) < UNIT_SHOW_TYPE_DIST then
            Utils.graphics.set_color_hex("#ffffff")
            love.graphics.setFont(FONT_12)
            love.graphics.print(unit.type, pos.x, pos.y)
            break
         end
      end
   end

   Ui.build()
   Ui.layout()
   Ui.hover()
   Ui.draw()

   -- debug info
   if DEBUG then
      love.graphics.setFont(FONT_12)
      Utils.graphics.set_color_hex("#ffffff")
      love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 10, 10)
      love.graphics.print("Number of Entities:" .. tostring(Core.number_of_entities()), 10, 30)
      love.graphics.print("Game Over:" .. tostring(GAME_OVER), 10, 50)
      love.graphics.print(Core.to_string(), 10, 70)
   end
end

function MainScene.update(dt)
   if PAUSED then
      dt = 0
   else
      UNPAUSED_TIME = UNPAUSED_TIME + dt
   end

   Waves.update()

   Core.remove_destroyed_entities()
   Core.compile_groups()
   Core.update(dt)

   Hand.update()

   if not GAME_OVER and Waves.is_last() then
      local invaders_left = false
      Core.for_each("unit", function(unit)
         if unit:is_invader() then
            invaders_left = true
         end
      end)
      if not invaders_left then
         GAME_OVER = true
         PAUSED = true
         GLASS_006:play()
         Ui.find(GAME_OVER_UI, "game_over_text").text = "YOU WIN"
      end
   end
end

function MainScene.mousepressed(_, _, button)
   local btn_clicked = Ui.click(button)
   local m_pos = Utils.input.mouse_position()
   if not GAME_OVER and not btn_clicked and Hand.selected_card and m_pos.y > BASE_Y then
      Hand.selected_card:use(m_pos)
      Hand.reset()
      PAUSED = false
      DROP_003:play()
   elseif not btn_clicked then
      CLICK_002:play()
   end
end

function MainScene.keypressed(key)
   if key == "d" then
      DEBUG = not DEBUG
   end
   if key == "p" then
      PAUSED = not PAUSED
   end
end
