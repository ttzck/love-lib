SpacePartitioning = {}

local grid_meta_table = {}

function grid_meta_table:get(x, y)
   if self[x] and self[x][y] then
      return self[x][y]
   else
      return {}
   end
end

function grid_meta_table:to_cell_coordinate(pos)
   local x = math.floor(pos.x / self.cell_size)
   local y = math.floor(pos.y / self.cell_size)
   return x, y
end

function grid_meta_table:to_grid_index(x)
   return math.floor(x / self.cell_size)
end

function grid_meta_table:insert_into_cell(item, pos, radius, x, y)
   if not self[x] then
      self[x] = {}
   end
   if not self[x][y] then
      self[x][y] = {}
   end
   table.insert(self[x][y], { item = item, pos = pos, radius = radius })
end

---comment
---@param item any
---@param pos {x: number, y : number}
---@param radius number
function grid_meta_table:insert(item, pos, radius)
   local r = Vector.new(radius, radius)
   local min_x, min_y = self:to_cell_coordinate(Vector.sub(pos, r))
   local max_x, max_y = self:to_cell_coordinate(Vector.add(pos, r))
   local disk = { pos = pos, radius = radius }
   for x = min_x, max_x do
      for y = min_y, max_y do
         local rect = {
            pos = Vector.new(x * self.cell_size, y * self.cell_size),
            width = self.cell_size,
            height = self.cell_size,
         }
         if Utils.math.disk_rect_overlap(disk, rect) then
            self:insert_into_cell(item, pos, radius, x, y)
         end
      end
   end
end

function grid_meta_table:get_entries_in_cells(min_x, min_y, max_x, max_y)
   local seen = {}
   local entries = {}
   for x = min_x, max_x do
      for y = min_y, max_y do
         for _, entry in ipairs(self:get(x, y)) do
            if not seen[entry.item] then
               table.insert(entries, entry)
               seen[entry.item] = true
            end
         end
      end
   end
   return entries
end

function grid_meta_table:query_radius(pos, radius)
   local r = Vector.new(radius, radius)
   local min_x, min_y = self:to_cell_coordinate(Vector.sub(pos, r))
   local max_x, max_y = self:to_cell_coordinate(Vector.add(pos, r))
   local entries = self:get_entries_in_cells(min_x, min_y, max_x, max_y)
   local result = {}
   for _, entry in ipairs(entries) do
      if Vector.dist(entry.pos, pos) <= radius + entry.radius then
         table.insert(result, entry.item)
      end
   end
   return result
end

function grid_meta_table:query_full_circle_sweep(start_pos, radius, end_pos)
   local sweep = Utils.math.circle_sweep
   local min_x = self:to_grid_index(math.min(start_pos.x, end_pos.x) - radius)
   local min_y = self:to_grid_index(math.min(start_pos.y, end_pos.y) - radius)
   local max_x = self:to_grid_index(math.max(start_pos.x, end_pos.x) + radius)
   local max_y = self:to_grid_index(math.max(start_pos.y, end_pos.y) + radius)
   local entries = self:get_entries_in_cells(min_x, min_y, max_x, max_y)
   local result = {}
   for _, entry in ipairs(entries) do
      local col, pos = sweep(start_pos, end_pos, radius, entry.pos, entry.radius)
      if col then
         local data = { position = pos, other = entry.item, collision_point = col }
         table.insert(result, data)
      end
   end
   return result
end

function grid_meta_table:query_circle_sweep(start_pos, radius, end_pos)
   local full = self:query_full_circle_sweep(start_pos, radius, end_pos)
   local closest = { position = end_pos, other = nil, collision_point = nil }
   local is_closer = function(other)
      local closest_dist = Vector.sqr_dist(closest.position, start_pos)
      local other_dist = Vector.sqr_dist(other.position, start_pos)
      return other_dist < closest_dist
   end
   for _, col in ipairs(full) do
      if is_closer(col) then
         closest = col
      end
   end
   return closest
end

---for debug
function grid_meta_table:draw()
   Utils.graphics.set_color_hex("#ffffff10")
   for x, _ in pairs(self) do
      if x ~= "cell_size" and self[x] then
         for y, _ in pairs(self[x]) do
            love.graphics.rectangle("line", x * self.cell_size, y * self.cell_size, self.cell_size, self.cell_size)
         end
      end
   end
end

function SpacePartitioning.new(cell_size)
   return setmetatable({ cell_size = cell_size }, { __index = grid_meta_table })
end
