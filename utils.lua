Utils = {}

Utils.color = {}
function Utils.color.from_hex(hex)
   local r = tonumber(string.sub(hex, 2, 3), 16) / 256
   local g = tonumber(string.sub(hex, 4, 5), 16) / 256
   local b = tonumber(string.sub(hex, 6, 7), 16) / 256
   if hex:len() < 9 then
      return { r, g, b, 1 }
   end
   local a = tonumber(string.sub(hex, 8, 9), 16) / 256
   return { r, g, b, a }
end

Utils.graphics = {}
function Utils.graphics.set_color_hex(hex)
   love.graphics.setColor(Utils.color.from_hex(hex))
end

Utils.table = {}
---comment
---@param obj any
---@param seen? any
---@return any
function Utils.table.deepcopy(obj, seen)
   seen = seen or {}
   if obj == nil then
      return nil
   end
   if seen[obj] then
      return seen[obj]
   end
   if type(obj) == "table" then
      local deepcopy = Utils.table.deepcopy
      local new_obj = {}
      seen[obj] = new_obj
      for k, v in next, obj, nil do
         new_obj[deepcopy(k, seen)] = deepcopy(v, seen)
      end
      setmetatable(new_obj, deepcopy(getmetatable(obj), seen))
      return new_obj
   else -- number, string, boolean, etc
      return obj
   end
end

function Utils.table.pretty_string(o, depth)
   local pretty_string = Utils.table.pretty_string
   depth = depth or 0
   if type(o) == "table" then
      local s = "{ \n"
      for k, v in pairs(o) do
         if type(k) ~= "number" then
            k = '"' .. k .. '"'
         end
         for _ = 1, depth, 1 do
            s = s .. "   "
         end
         s = s .. "[" .. k .. "] = " .. pretty_string(v, depth + 1) .. ", \n"
      end
      return s .. "}\n"
   else
      return tostring(o)
   end
end

Utils.timer = {}
function Utils.timer.time_since(time, now)
   now = now or love.timer.getTime()
   return now - time
end

function Utils.timer.lerp(a, b, t0, d, now)
   local time_since = Utils.timer.time_since
   local t = time_since(t0, now) / d
   return a * (1 - t) + b * t
end

function Utils.timer.interpolate(a, b, c, t0, d, now)
   local time_since = Utils.timer.time_since
   local t = time_since(t0, now) / d
   return a * (1 - math.pow(t, c)) + b * math.pow(t, c)
end

Utils.math = {}
--- see https://www.youtube.com/watch?v=LSNQuFEDOyQ
function Utils.math.exp_decay(a, b, decay, dt)
   return b + (a - b) * math.exp(-decay * dt)
end

function Utils.math.clamp(value, min, max)
   if value < min then
      return min
   elseif value > max then
      return max
   end
   return value
end

---comment
---@param disk {pos : vector, radius : number}
---@param point vector
---@return boolean
function Utils.math.disk_contains_point(disk, point)
   return Vector.dist(disk.pos, point) <= disk.radius
end

---comment
---@param rect {pos : vector, width : number, height : number}
---@param point vector
---@return boolean
function Utils.math.rect_contains_point(rect, point)
   local min = Vector.new(rect.pos.x, rect.pos.y)
   local max = Vector.new(rect.pos.x + rect.width, rect.pos.y + rect.height)
   return min.x <= point.x and min.y <= point.y and max.x >= point.x and max.y >= point.y
end

---comment
---@param disk {pos : vector, radius : number}
---@param rect {pos : vector, width : number, height : number}
---@return boolean
function Utils.math.disk_rect_overlap(disk, rect)
   local dcp = Utils.math.disk_contains_point
   local rect_offsets = {
      Vector.new(0, 0),
      Vector.new(rect.width, 0),
      Vector.new(0, rect.height),
      Vector.new(rect.width, rect.height),
   }
   for _, offset in ipairs(rect_offsets) do
      if dcp(disk, Vector.add(rect.pos, offset)) then
         return true
      end
   end
   local rcp = Utils.math.rect_contains_point
   local disk_offsets = {
      Vector.new(0, 0),
      Vector.new(-disk.radius, 0),
      Vector.new(disk.radius, 0),
      Vector.new(0, -disk.radius),
      Vector.new(0, disk.radius),
   }
   for _, offset in ipairs(disk_offsets) do
      if rcp(rect, Vector.add(disk.pos, offset)) then
         return true
      end
   end
   return false
end

--- returns closest point to p on segment ab
---@param p vector
---@param a vector
---@param b vector
---@return vector
function Utils.math.closest_point_on_line_segment(p, a, b)
   local l2 = Vector.sqr_dist(a, b)
   if l2 == 0.0 then
      return a
   end
   local t = Utils.math.clamp(Vector.dot(Vector.sub(p, a), Vector.sub(b, a)) / l2, 0, 1)
   return Vector.add(a, Vector.mul(Vector.sub(b, a), t))
end

function Utils.math.sign(x)
   if x < 0 then
      return -1
   end
   return 1
end

---intersections of circle at c with radius r with infinite line through p1 and p2, can be NaN
---https://mathworld.wolfram.com/Circle-LineIntersection.html
---@param c vector
---@param r number
---@param p1 vector
---@param p2 vector
---@return vector
---@return vector
---@return number
function Utils.math.circle_line_intersection(c, r, p1, p2)
   local dx = p2.x - p1.x
   local dy = p2.y - p1.y
   local dr2 = dx * dx + dy * dy
   local det = (p1.x - c.x) * (p2.y - c.y) - (p2.x - c.x) * (p1.y - c.y)
   local delta = r * r * dr2 - (det * det)
   local sqrt_delta = math.sqrt(delta)
   local x1 = (det * dy + Utils.math.sign(dy) * dx * sqrt_delta) / dr2
   local y1 = (-det * dx + math.abs(dy) * sqrt_delta) / dr2
   local x2 = (det * dy - Utils.math.sign(dy) * dx * sqrt_delta) / dr2
   local y2 = (-det * dx - math.abs(dy) * sqrt_delta) / dr2
   return { x = x1 + c.x, y = y1 + c.y }, { x = x2 + c.x, y = y2 + c.y }, delta
end

function Utils.math.circle_line_segment_intersection(c, r, p1, p2)
   local q1, q2, delta = Utils.math.circle_line_intersection(c, r, p1, p2)
   local rect = {
      pos = Vector.new(math.min(p1.x, p2.x), math.min(p1.y, p2.y)),
      width = math.abs(p2.x - p1.x),
      height = math.abs(p2.y - p1.y),
   }
   local qs = {}
   if delta < 0 then
      return qs
   end
   if Utils.math.rect_contains_point(rect, q1) then
      table.insert(qs, q1)
   end
   if Utils.math.rect_contains_point(rect, q2) then
      table.insert(qs, q2)
   end
   return qs
end

---sweep circle with radius r1 from a to b
---and collide with circle at c with radius r2
---@param a any
---@param b any
---@param r1 any
---@param c any
---@param r2 any
---@return vector|nil collision position of the point of collision
---@return vector position position of the sweeped circle
function Utils.math.circle_sweep(a, b, r1, c, r2)
   if Utils.math.disk_contains_point({ pos = c, radius = r1 + r2 }, a) then
      return a, a
   end
   local qs = Utils.math.circle_line_segment_intersection(c, r1 + r2, a, b)
   if #qs == 0 then
      return nil, b
   end
   table.sort(qs, function(p, q)
      return Vector.sqr_dist(p, a) < Vector.sqr_dist(q, a)
   end)
   local q = qs[1]
   return Vector.add(Vector.mul(Vector.sub(c, q), r1 / (r1 + r2)), q), q
end

Utils.random = {}
function Utils.random.radian()
   return love.math.random() * 2.0 * math.pi
end

function Utils.random.on_unit_circle()
   local phi = Utils.random.radian()
   return { x = math.cos(phi), y = math.sin(phi) }
end

function Utils.random.in_unit_square()
   return { x = love.math.random(), y = love.math.random() }
end

function Utils.random.in_rectangle(w, h)
   return { x = love.math.random() * w, y = love.math.random() * h }
end

Utils.input = {}
function Utils.input.mouse_position()
   local x, y = love.mouse.getPosition()
   return Vector.new(x, y)
end
