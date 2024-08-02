Core = {
   archetypes = {},
   entities = {},
   systems = {},
   updateOrder = {},
   drawOrder = {},
   setupOrder = {},
   destroyOrder = {},
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
function Core.newArchetype(id, ...)
   local archetype = {
      id = id or new_unique_id(),
      metaId = "ARCHETYPE",
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
function Core.newEntity(id, archetype_id)
   local entity = {
      id = id or new_unique_id(),
      metaId = "ENTITY",
      destroyed = false,
      tags = {},
   }
   Core.entities[entity.id] = entity

   local archetype = Core.archetypes[archetype_id]
   for _, tag in pairs(archetype.tags) do
      table.insert(entity.tags, tag)
   end

   for _, system_id in ipairs(Core.setupOrder) do
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
function Core.newSystem(tag, id, priority, action)
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
   local system_id = Core.newSystem(tag, id, priority, action)
   table.insert(order, system_id)
   table.sort(order, sort_by_priority)
   return system_id
end

function Core.newSetupSystem(tag, id, priority, action)
   return insert_and_sort_system_order(Core.setupOrder, tag, id, priority, action)
end

function Core.newDestroySystem(tag, id, priority, action)
   return insert_and_sort_system_order(Core.destroyOrder, tag, id, priority, action)
end

function Core.newUpdateSystem(tag, id, priority, action)
   return insert_and_sort_system_order(Core.updateOrder, tag, id, priority, action)
end

function Core.newDrawSystem(tag, id, priority, action)
   return insert_and_sort_system_order(Core.drawOrder, tag, id, priority, action)
end

function Core.compileGroups()
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

function Core.forEach(tag, func)
   local group = Core.groups[tag]
   for _, entity_id in pairs(group) do
      func(Core.entity[entity_id])
   end
end

function Core.update(dt)
   for _, system_id in ipairs(Core.updateOrder) do
      local system = Core.systems[system_id]
      Core.forEach(system.tag, function(entity)
         system.action(entity, dt)
      end)
   end
end

function Core.draw()
   for _, system_id in ipairs(Core.drawOrder) do
      local system = Core.systems[system_id]
      Core.forEach(system.tag, system.action)
   end
end

-- Examples

ID = {
   Tower = "",
   Singleton = "",
}

for key, _ in pairs(ID) do
   ID[key] = key
end

Core.newSetupSystem(ID.Tower, "position", 99, function(self)
   self.position = { x = 0, y = 0 }
end)

Core.newArchetype("bombTower", ID.Tower, "hi")

Core.newSetupSystem("bombTower", "cooldown", 99, function(self)
   self.cooldown = 3
end)

local tow = Core.newEntity(ID.Singleton, "bombTower")

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
