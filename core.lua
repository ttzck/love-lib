Core = {
   archetypes = {},
   entities = {},
   systems = {},
   update_order = {},
   draw_order = {},
   setup_order = {},
   destroy_order = {},
}

local unique_id = 0
local function new_unique_id()
   unique_id = unique_id + 1
   return "id" .. unique_id
end

---comment
---@param id string
---@param ... any
---@return string
function Core.new_archetype(id, ...)
   local archetype = {
      id = id or new_unique_id(),
      meta_id = "ARCHETYPE",
      tags = {},
   }
   Core.archetypes[archetype.id] = archetype

   for _, tag in ipairs({ archetype.id, ... }) do
      archetype.tags[tag] = tag
   end

   return archetype.id
end

---comment
---@param id string
---@param archetype_id string
---@return string
function Core.new_entity(id, archetype_id)
   local entity = {
      id = id or new_unique_id(),
      meta_id = "ENTITY",
      destroyed = false,
      tags = {},
   }
   Core.entities[entity.id] = entity

   local archetype = Core.archetypes[archetype_id]
   for _, tag in pairs(archetype.tags) do
      table.insert(entity.tags, tag)
   end

   for _, system_id in ipairs(Core.setup_order) do
      local system = Core.systems[system_id]
      if entity.tags[system.tag] then
         system.action(entity)
      end
   end

   return entity.id
end

---@param tag string
---@param id string
---@param priority integer
---@param action function
---@return string id new system's id
function Core.new_system(tag, id, priority, action)
   local system = {
      id = tag .. "." .. (id or new_unique_id()),
      tag = tag,
      priority = priority,
      action = action,
   }
   Core.systems[system.id] = system

   return system.id
end

local insert_and_sort_system_order = function(order, tag, id, priority, action)
   local sort_by_priority = function(a, b)
      return Core.systems[a].priority <= Core.systems[b].priority
   end
   local system_id = Core.new_system(tag, id, priority, action)
   table.insert(order, system_id)
   table.sort(order, sort_by_priority)
   return system_id
end

function Core.new_setup_system(tag, id, priority, action)
   return insert_and_sort_system_order(Core.setup_order, tag, id, priority, action)
end

function Core.new_destroy_system(tag, id, priority, action)
   return insert_and_sort_system_order(Core.destroy_order, tag, id, priority, action)
end

function Core.new_update_system(tag, id, priority, action)
   return insert_and_sort_system_order(Core.update_order, tag, id, priority, action)
end

function Core.new_draw_system(tag, id, priority, action)
   return insert_and_sort_system_order(Core.draw_order, tag, id, priority, action)
end

function Core.compile_groups()
   Core.groups = {}
   for _, entity in pairs(Core.entities) do
      for _, tag in pairs(entity.tags) do
         if not Core.groups[tag] then
            Core.groups[tag] = {}
         end
         Core.groups[tag][entity.id] = entity.id
      end
   end
end

function Core.for_each(tag, func)
   local group = Core.groups[tag]
   for _, entity_id in pairs(group) do
      func(Core.entity[entity_id])
   end
end

function Core.update(dt)
   for _, system_id in ipairs(Core.update_order) do
      local system = Core.systems[system_id]
      Core.for_each(system.tag, function(entity)
         system.action(entity, dt)
      end)
   end
end

function Core.draw()
   for _, system_id in ipairs(Core.draw_order) do
      local system = Core.systems[system_id]
      Core.for_each(system.tag, system.action)
   end
end

-- Examples
Core.new_setup_system(ID.Tower, "position", 99, function(self)
   self.position = { x = 0, y = 0 }
end)

Core.new_archetype("bombTower", ID.Tower, "hi")

Core.new_setup_system("bombTower", "cooldown", 99, function(self)
   self.cooldown = 3
end)

local tow = Core.new_entity(ID.Singleton, "bombTower")

function dump(o, depth)
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
         s = s .. "[" .. k .. "] = " .. dump(v, depth + 1) .. ", \n"
      end
      return s .. "}\n"
   else
      return tostring(o)
   end
end

print(dump(Core))
