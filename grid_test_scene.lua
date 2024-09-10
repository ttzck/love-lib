GridTestScene = {}

local radius = 50
local size = 32

function GridTestScene.draw()
   local m = Utils.input.mouse_position()
   Utils.graphics.set_color_hex("#00ff00")
   local grid = SpacePartitioning.new(size)
   grid:insert({}, m, radius)
   for x = 0, WINDOW_WIDTH / size do
      for y = 0, WINDOW_HEIGHT / size do
         love.graphics.rectangle("line", x * size, y * size, size, size)
         if grid[x] and grid[x][y] then
            love.graphics.rectangle("fill", x * size, y * size, size, size)
         end
      end
   end

   Utils.graphics.set_color_hex("#ff0000")
   love.graphics.circle("line", m.x, m.y, radius)
end

function GridTestScene.mousepressed(_, _, button)
   if button == 2 then
      radius = radius / 2
   end
   if button == 1 then
      radius = radius * 2
   end
end
