Core = {
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
---@param id? any
---@param tags any
---@param options any
---@return any
function Core.new_entity(id, tags, options)
   local entity = {
      id = id or new_unique_id(),
      meta_id = "ENTITY",
      destroyed = false,
      tags = {},
   }
   Core.entities[entity.id] = entity

   for _, tag in pairs(tags) do
      entity.tags[tag] = tag
   end

   for _, system_id in ipairs(Core.setup_order) do
      local system = Core.systems[system_id]
      if entity.tags[system.tag] then
         system.action(entity, options)
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
      return Core.systems[a].priority < Core.systems[b].priority
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
            Core.groups[tag] = { n = 0 }
         end
         table.insert(Core.groups[tag], entity.id)
         Core.groups[tag].n = Core.groups[tag].n + 1
      end
   end
end

function Core.get_group(tag)
   local group = Core.groups[tag]
   if group then
      local entities = {}
      for _, id in ipairs(group) do
         entities[id] = Core.entities[id]
      end
      return entities
   end
   return {}
end

function Core.get_random_entity(tag)
   if not Core.groups[tag] then
      return nil
   end
   local n = Core.groups[tag].n
   local entity_id = Core.groups[tag][math.random(n)]
   return Core.entities[entity_id]
end

function Core.for_each(tag, func)
   local group = Core.groups[tag] or {}
   for _, entity_id in ipairs(group) do
      func(Core.entities[entity_id])
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

function Core.remove_destroyed_entities()
   local destroyed = {}
   for _, entity in pairs(Core.entities) do
      if entity.destroyed then
         table.insert(destroyed, entity)
      end
   end
   for _, entity in pairs(destroyed) do
      Core.entities[entity.id] = nil
      for _, system_id in ipairs(Core.destroy_order) do
         local system = Core.systems[system_id]
         if entity.tags[system.tag] then
            system.action(entity)
         end
      end
   end
end

local function entries_to_string(t)
   local max_length = 10
   local s = {}
   local n = 0
   for _, entry in pairs(t) do
      n = n + 1
      if type(entry) == "table" then
         s[n] = entry.id
      else
         s[n] = entry
      end
      if n == max_length then
         s[n + 1] = "..."
         break
      end
   end
   return table.concat(s, "\n")
end

function Core.number_of_entities()
   local c = 0
   for _, _ in pairs(Core.entities) do
      c = c + 1
   end
   return c
end

function Core.to_string()
   local s = {
      "Entities",
      entries_to_string(Core.entities),
      "---",
      "Systems",
      entries_to_string(Core.systems),
      "---",
      "Update Order",
      entries_to_string(Core.update_order),
      "---",
      "Draw Order",
      entries_to_string(Core.draw_order),
      "---",
      "Setup Order",
      entries_to_string(Core.setup_order),
      "---",
      "Destroy Order",
      entries_to_string(Core.destroy_order),
   }
   return table.concat(s, "\n")
end
