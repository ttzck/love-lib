BASE_UNIT_SPEED = 6
BASE_UNIT_RANGE = 32
BASE_UNIT_ATK_PERIOD = 10
BASE_UNIT_SIZE = 4
BASE_UNIT_DEFENSE = 3
BASE_UNIT_ACCURACY = math.pi / 4

UNIT_SHOW_TYPE_DIST = 12
UNIT_BOP_AMP = 2
UNIT_BOP_SPEED = 3

UNIT_STATS = {
   infantry = {
      speed = 2,
      range = 2,
      damage = 1,
      defense = 1,
      atk_freq = 2,
      size = 1,
      accuracy = 2,
   },
   tank = {
      speed = 2,
      range = 1,
      damage = 2,
      defense = 5,
      atk_freq = 1,
      size = 3,
      accuracy = 2,
   },
   sniper = {
      speed = 2,
      range = 5,
      damage = 3,
      defense = 1,
      atk_freq = 1,
      size = 1,
      accuracy = 5,
   },
   cavalry = {
      speed = 5,
      range = 1,
      damage = 1,
      defense = 1,
      atk_freq = 2,
      size = 1,
      accuracy = 1,
   },
   machine_gun = {
      speed = 1,
      range = 2,
      damage = 3,
      defense = 1,
      atk_freq = 8,
      size = 2,
      accuracy = 1,
   },
}

function SpawnUnit(team, type, pos)
   Core.new_entity(nil, { team, "unit", "physics_object", "time_object" }, {
      position = pos,
      width = UNIT_STATS[type].size * BASE_UNIT_SIZE,
      height = UNIT_STATS[type].size * BASE_UNIT_SIZE,
      type = type,
   })
end

Core.new_setup_system("unit", "unit_setup", 1, function(unit, options)
   unit.type = options.type

   unit.speed = UNIT_STATS[unit.type].speed
   unit.range = UNIT_STATS[unit.type].range
   unit.damage = UNIT_STATS[unit.type].damage
   unit.defense = UNIT_STATS[unit.type].defense
   unit.atk_freq = UNIT_STATS[unit.type].atk_freq
   unit.accuracy = UNIT_STATS[unit.type].accuracy

   unit.closest_enemy = nil
   unit.last_attack = 0
   unit.start_pos = unit:get_position()

   function unit:is_defender()
      return self.tags["defender"] ~= nil
   end

   function unit:is_invader()
      return self.tags["invader"] ~= nil
   end
end)

Core.new_setup_system("defender", "defender_setup", 0, function(unit)
   unit.color = "#0000ff"
end)

Core.new_setup_system("invader", "invader_setup", 0, function(unit)
   unit.color = "#ff0000"
end)

local function distance_between(unit1, unit2)
   local p1, p2 = unit1:get_position(), unit2:get_position()
   return Vector.dist(p1, p2)
end

local function is_closer_than_closest(unit, enemy)
   return distance_between(unit, enemy) < distance_between(unit, unit.closest_enemy)
end

local function get_enemy_tag(unit)
   if unit:is_defender() then
      return "invader"
   elseif unit:is_invader() then
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

local function is_enemy_in_range(unit)
   local dist = Vector.dist(unit:get_position(), unit.closest_enemy:get_position())
   return dist <= unit.range * BASE_UNIT_RANGE
end

Core.new_draw_system("unit", "unit_draw_shadow", 0, function(unit)
   local pos = unit:get_position()
   local size = unit:get_size()
   local bop = math.abs(math.sin(unit.lifetime * UNIT_BOP_SPEED * unit.speed)) * UNIT_BOP_AMP
   Utils.graphics.set_color_hex("#00000080")
   love.graphics.ellipse("fill", pos.x + bop, pos.y + size / 2 + bop, size / 2 + bop, size / 2)
end)

Core.new_draw_system("unit", "unit_draw", 1, function(unit)
   local pos = unit:get_position()
   local size = unit:get_size()
   local bop = math.abs(math.sin(unit.lifetime * UNIT_BOP_SPEED * unit.speed)) * UNIT_BOP_AMP
   Utils.graphics.set_color_hex(unit.color)
   love.graphics.circle("fill", pos.x, pos.y - bop, size / 2)
end)

local function shoot(unit)
   local velocity = get_vector_to_enemy_of_length(unit, PROJECTILE_SPEED)
   local r = (love.math.random() - 0.5) * BASE_UNIT_ACCURACY / unit.accuracy
   velocity = Vector.rot(velocity, r)
   Core.new_entity(nil, { "projectile", "physics_object", "time_object" }, {
      position = unit:get_position(),
      width = 2,
      height = 2,
      target = get_enemy_tag(unit),
      velocity = velocity,
      damage = unit.damage,
      range = unit.range * BASE_UNIT_RANGE * 1.5,
   })
   unit.last_attack = unit.lifetime
   BONG_001:stop()
   BONG_001:play()
end

local function is_ready_to_shoot(unit)
   return unit.lifetime - unit.last_attack > BASE_UNIT_ATK_PERIOD / unit.atk_freq
end

local col_filter = function(_, other)
   if other.tags["unit"] then
      return "slide"
   else
      return nil
   end
end

local function max_movement_mag(unit)
   return unit.speed * BASE_UNIT_SPEED * unit.delta_time
end

local function move_towards_base(unit)
   local movement = Vector.new(0, max_movement_mag(unit))
   unit:move(movement, col_filter)
end

local function move_towards_enemy(unit)
   local vec_to_enemy = get_vector_to_enemy(unit)
   local movement = Vector.clamp(vec_to_enemy, max_movement_mag(unit))
   unit:move(movement, col_filter)
end

local function move_towards_start_pos(unit)
   local vec_to_start_pos = Vector.between(unit:get_position(), unit.start_pos)
   local movement = Vector.clamp(vec_to_start_pos, max_movement_mag(unit))
   unit:move(movement, col_filter)
end

local function is_base_closer_than_enemy(unit)
   local vec_to_enemy = get_vector_to_enemy(unit)
   local dist_to_enemy = Vector.mag(vec_to_enemy)
   local dist_to_base = BASE_Y - unit:get_position().y
   return dist_to_base < dist_to_enemy * 2
end

local function move_or_shoot(unit)
   if unit.closest_enemy == nil then
      if unit:is_invader() then
         move_towards_base(unit)
      end
      if unit:is_defender() then
         move_towards_start_pos(unit)
      end
      return
   end

   if is_enemy_in_range(unit) then
      if is_ready_to_shoot(unit) then
         shoot(unit)
      end
      return
   end

   if unit:is_defender() then
      move_towards_enemy(unit)
      return
   end

   if unit:is_invader() then
      if is_base_closer_than_enemy(unit) then
         move_towards_base(unit)
      else
         move_towards_enemy(unit)
      end
      return
   end
end

local function unit_update(unit)
   update_closest_enemy(unit)
   move_or_shoot(unit)
   if unit:is_invader() and unit:get_position().y > BASE_Y and not GAME_OVER then
      GAME_OVER = true
      PAUSED = true
      QUESTION_001:play()
   end
end

Core.new_update_system("unit", "unit_update", 0, unit_update)
