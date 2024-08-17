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
---@param id string?
---@param archetype_id string
---@return string
function Core.new_entity(id, archetype_id, options)
   local entity = {
      id = id or new_unique_id(),
      meta_id = "ENTITY",
      destroyed = false,
      tags = {},
   }
   Core.entities[entity.id] = entity

   local archetype = Core.archetypes[archetype_id]
   for _, tag in pairs(archetype.tags) do
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
      for _, id in pairs(group) do
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

local function print_entries(table)
   for _, entry in pairs(table) do
      print(entry.id)
   end
end

local function print_system_order(table)
   for i, entry in ipairs(table) do
      print(i, entry)
   end
end

local function print_groups() end

function Core.number_of_entities()
   local c = 0
   for _, _ in pairs(Core.entities) do
      c = c + 1
   end
   return c
end

function Core.print()
   print("Archetypes")
   print_entries(Core.archetypes)
   print("---")
   print("Entities")
   print_entries(Core.entities)
   print("---")
   print("Systems")
   print_entries(Core.systems)
   print("---")
   print("Update Order")
   print_system_order(Core.update_order)
   print("---")
   print("Draw Order")
   print_system_order(Core.draw_order)
   print("---")
   print("Setup Order")
   print_system_order(Core.setup_order)
   print("---")
   print("Destroy Order")
   print_system_order(Core.destroy_order)
   print("---")
   print("Groups")
   print()
end
