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

