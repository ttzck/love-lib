Core.new_archetype("invader", "unit", "physics_object")
Core.new_archetype("defender", "unit", "physics_object")

local function unit_setup(unit, options)
   unit.size = options.width
   unit.color = options.color
   unit.speed = options.speed
   unit.range = options.range
   unit.attack_period = options.attack_period

   unit.closest_enemy = nil
   unit.last_attack = 0
end

Core.new_setup_system("unit", "unit_setup", 0, unit_setup)

local function unit_draw(unit)
   local pos = unit:get_centered_position()
   local size = unit.size
   Utils.graphics.set_color_hex(unit.color)
   love.graphics.circle("fill", pos.x, pos.y, size / 2)
end

local function distance_between(unit1, unit2)
   local p1, p2 = unit1:get_position(), unit2:get_position()
   return Vector.dist(p1, p2)
end

local function is_closer_than_closest(unit, enemy)
   return distance_between(unit, enemy) < distance_between(unit, unit.closest_enemy)
end

local function get_enemy_tag(unit)
   if unit.tags["defender"] then
      return "invader"
   else
      return "defender"
   end
end

local function get_random_enemy(unit)
   return Core.get_random_entity(get_enemy_tag(unit))
end

local function update_closest_enemy(unit)
   if unit.closest_enemy and unit.closest_enemy.destroyed then
      unit.closest_enemy = nil
   end
   local enemy = get_random_enemy(unit)
   if unit.closest_enemy == nil or is_closer_than_closest(unit, enemy) then
      unit.closest_enemy = enemy
   end
end

local function get_vector_to_enemy(unit)
   local p1, p2 = unit:get_position(), unit.closest_enemy:get_position()
   return Vector.between(p1, p2)
end

local function get_vector_to_enemy_of_length(unit, l)
   local v = get_vector_to_enemy(unit)
   return Vector.mul(Vector.normalize(v), l)
end

local function get_movement_to_enemy(unit, dt)
   local v = get_vector_to_enemy(unit)
   return Vector.clamp(v, unit.speed * dt)
end

local function is_enemy_in_range(unit)
   local dist = Vector.dist(unit:get_position(), unit.closest_enemy:get_position())
   return dist <= unit.range
end

Core.new_draw_system("unit", "unit_draw", 0, unit_draw)

local function unit_update(unit, dt)
   update_closest_enemy(unit)
   if unit.closest_enemy then
      local movement
      if is_enemy_in_range(unit) then
         movement = Vector.new()
         if Utils.timer.time_since(unit.last_attack) > unit.attack_period then
            Core.new_entity(nil, "projectile", {
               position = unit:get_centered_position(),
               width = 2,
               height = 2,
               target = get_enemy_tag(unit),
               velocity = get_vector_to_enemy_of_length(unit, 128),
            })
            unit.last_attack = love.timer.getTime()
         end
      else
         movement = get_movement_to_enemy(unit, dt)
      end
      local target_pos = Vector.add(unit:get_position(), movement)
      Physics:move(unit, target_pos.x, target_pos.y, function(item, other)
         if other.tags["unit"] then
            return "slide"
         else
            return nil
         end
      end)
   end
end

Core.new_update_system("unit", "unit_update", 0, unit_update)
