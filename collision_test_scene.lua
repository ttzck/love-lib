CollisionTestScene = {}

local a = { x = 800, y = 100 }
local b = { x = 100, y = 300 }
local r1, r2 = 20, 50

function CollisionTestScene.draw()
   local m = Utils.input.mouse_position()
   Utils.graphics.set_color_hex("#ffffff")
   love.graphics.line(a.x, a.y, b.x, b.y)
   love.graphics.circle("line", a.x, a.y, r1)
   love.graphics.circle("line", m.x, m.y, r2)
   local coll, q = Utils.math.circle_sweep(a, b, r1, m, r2)
   if coll ~= nil then
      Utils.graphics.set_color_hex("#00ff00")
      love.graphics.circle("fill", coll.x, coll.y, 3)
   end
   Utils.graphics.set_color_hex("#ffffff")
   love.graphics.circle("line", q.x, q.y, r1)
end

function CollisionTestScene.mousepressed()
   a = { x = love.math.random() * WINDOW_WIDTH, y = love.math.random() * WINDOW_HEIGHT }
   b = { x = love.math.random() * WINDOW_WIDTH, y = love.math.random() * WINDOW_HEIGHT }
end
