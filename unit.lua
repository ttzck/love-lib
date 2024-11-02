Unit = {}

Core.new_setup_system("unit", "setup", 0, function(unit, options)
   unit.position = options.position
   unit.hp = 100
   unit.speed = 10
   unit.delayed_hp = unit.hp
   unit.max_hp = unit.hp
   unit.status = Status.new()
end)

function Unit.spawn_creep(team, position)
   Core.new_entity(nil, { "creep", "attacker", "move_to_opponent", "unit", team }, {
      position = position,
   })
end

function Unit.spawn_archer(team, position)
   Core.new_entity(nil, { "archer", "attacker", "move_to_opponent", "unit", team }, {
      position = position,
   })
end

function Unit.spawn_healer(team, position) -- TODO
   Core.new_entity(nil, { "healer", "unit", team }, {
      position = position,
   })
end

function Unit.spawn_knight(team, position)
   Core.new_entity(nil, { "knight", "attacker", "move_to_opponent", "unit", team }, {
      position = position,
   })
end

function Unit.spawn_cavalry(team, position)
   Core.new_entity(nil, { "cavalry", "attacker", "hit_and_run", "unit", team }, {
      position = position,
   })
end

local function is_in_range(unit)
   if not unit.closest_opponent then
      return false
   end
   return Vector.sqr_dist(unit.position, unit.closest_opponent.position) < unit.attack_radius * unit.attack_radius
end

local function charge_in_range(unit)
   if not is_in_range(unit) then
      unit.attack_charge = nil
   elseif not unit.attack_charge then
      unit.attack_charge = TimeSpan.new(1.0 / unit.attack_rate, love.timer.getTime())
   end
end

local function always_charge(unit)
   if not unit.attack_charge then
      unit.attack_charge = TimeSpan.new(1.0 / unit.attack_rate, love.timer.getTime())
   end
end

local function archer_attack(self)
   local target = self.closest_opponent
   Core.new_entity(nil, { "arrow" }, {
      position = self.position,
      target = target,
      color = "#ffffff",
      orientation = Vector.normal(self.position, target.position),
      damage = 15,
      hit = function(arrow, other, point)
         Unit.take_damage(other, arrow.damage)
         arrow.destroyed = true
         Particles.basic_circle(point, 4)
      end,
   })
end

Core.new_setup_system("archer", "setup", 0, function(unit, options)
   unit.attack_radius = 100
   unit.attack_rate = 0.3
   unit.radius = 3
   unit.attack = archer_attack
   unit.update_charge = always_charge
end)

Core.new_setup_system("healer", "setup", 0, function(unit, options)
   unit.range = 100
   unit.attack_rate = 0.3
   unit.radius = 3
   unit.update_charge = always_charge
end)

local function melee_attack(self)
   Unit.take_damage(self.closest_opponent, 5)
end

Core.new_setup_system("knight", "setup", 0, function(unit, options)
   unit.attack_radius = 20
   unit.attack_rate = 1
   unit.radius = 4
   unit.attack = melee_attack
   unit.update_charge = charge_in_range
end)

Core.new_setup_system("cavalry", "setup", 1, function(unit, options)
   unit.attack_radius = 20
   unit.attack_rate = 0.1
   unit.radius = 3
   unit.speed = 30
   unit.attack = melee_attack
   unit.update_charge = always_charge
end)

Core.new_setup_system("creep", "setup", 0, function(unit, options)
   unit.attack_radius = 20
   unit.attack_rate = 1
   unit.radius = 3
   unit.attack = melee_attack
   unit.update_charge = charge_in_range
end)

Core.new_setup_system("defender", "setup", 0, function(unit, options)
   unit.color = "#0000ff"
   unit.team = "defender"
   unit.opponent = "invader"
   unit.life = TimeSpan.new(60, love.timer.getTime())
end)

Core.new_setup_system("invader", "setup", 0, function(unit, options)
   unit.color = "#ff0000"
   unit.team = "invader"
   unit.opponent = "defender"
end)

Core.new_draw_system("unit", "draw_body", 0, function(unit)
   Utils.graphics.set_color_hex(unit.color)
   if unit.status:is("weak") and math.random() < 0.5 then
      Utils.graphics.set_color_hex("#00ff00")
   end
   love.graphics.circle("fill", unit.position.x, unit.position.y, unit.radius)
end)

Core.new_draw_system("unit", "draw_hp_bar", 1, function(unit)
   local width = 12
   local height = 2
   Ui.utils.progress_bar({
      x = unit.position.x - width / 2,
      y = unit.position.y - unit.radius - height * 2,
      width = width,
      height = height,
      primary_color = "#00ff00",
      secondary_color = "#ff0000",
      background_color = "#000000",
      radius = 2,
      primary_ratio = unit.hp / unit.max_hp,
      secondary_ratio = unit.delayed_hp / unit.max_hp,
   })
end)

Core.new_draw_system("defender", "draw_age", 1, function(unit)
   local width = 12
   local height = 1
   Ui.utils.progress_bar({
      x = unit.position.x - width / 2,
      y = unit.position.y - unit.radius - height * 2,
      width = width,
      height = height,
      primary_color = "#ffffff",
      background_color = "#000000",
      radius = 2,
      primary_ratio = unit.life:time_left() / unit.life.duration,
   })
end)

Core.new_update_system("defender", "die_of_high_age", 0, function(unit, _)
   if unit.life:is_over() then
      unit.destroyed = true
   end
end)

Core.new_update_system("unit", "insert_in_grid", 0, function(unit, _)
   Grids.unit:insert(unit, unit.position, unit.radius)
   Grids[unit.team]:insert(unit, unit.position, unit.radius)
end)

Core.new_update_system("unit", "update_delayed_hp", 0, function(unit, dt)
   unit.delayed_hp = Utils.math.exp_decay(unit.delayed_hp, unit.hp, 2, dt)
end)

Core.new_update_system("attacker", "attack", 2, function(unit, dt)
   unit:update_charge()
   if unit.attack_charge and unit.attack_charge:is_over() and is_in_range(unit) then
      unit:attack()
      unit.attack_charge = TimeSpan.new(1.0 / unit.attack_rate, love.timer.getTime())
   end
end)

Core.new_update_system("unit", "find_closest_opponent", 0, function(unit, dt)
   local opponents = Core.get_group(unit.opponent)
   unit.closest_opponent = Utils.table.arg_min(opponents, function(opp)
      return Vector.sqr_dist(unit.position, opp.position)
   end)
end)

local function sqr_dist(unit)
   return function (other)
      return Vector.sqr_dist(unit.position, other.position)
   end
end

Core.new_update_system("unit", "find_closest_ally", 0, function(unit, dt)
   local allies = Core.get_group(unit.team)
   unit.closest_ally = Utils.table.arg_min(allies, sqr_dist(unit))
end)

Core.new_update_system("move_to_opponent", "update_movement_target", 3, function(unit, dt)
   unit.movement_target = nil
   if unit.closest_opponent and not is_in_range(unit) then
      unit.movement_target = unit.closest_opponent.position
   end
end)

local function wounded(unit)
   return unit.hp < unit.max_hp
end

Core.new_update_system("healer", "move_to_wounded_ally", 3, function(unit, dt)
   local t = Utils.table
   local allies = Core.get_group(unit.team)
   local target = t.arg_min(t.filter(allies, wounded), sqr_dist(unit))
   local sqr_range = unit.range * unit.range

   unit.movement_target = nil
   if target and sqr_dist(unit)(target) > sqr_range  then
      unit.movement_target = target.position
   end
end)

Core.new_update_system("hit_and_run", "update_movement_target", 3, function(unit, dt)
   if unit.attack_charge:is_over() then
      unit.movement_target = unit.closest_opponent.position
   else
      local dist_to_opponent = Vector.dist(unit.closest_opponent.position, unit.position)
      local dist_to_outside = OUTER_RADIUS - Vector.dist(CENTER, unit.position)
      if dist_to_opponent < dist_to_outside then
         local n = Vector.normal(unit.closest_opponent.position, unit.position)
         local p = Vector.add(unit.position, Vector.mul(n, unit.speed))
         unit.movement_target = p
      else
         unit.movement_target = CENTER
      end
   end
end)

Core.new_update_system("unit", "move", 4, function(unit, dt)
   if unit.movement_target and not unit.status:is("stun") then
      local movement = Vector.between(unit.position, unit.movement_target)
      movement = Vector.set_mag(movement, unit.speed * dt)
      unit.position = Vector.add(unit.position, movement)
   end
end)

Core.new_update_system("unit", "resolve_collisions", 101, function(unit, dt)
   unit.new_position = unit.position
   local query = Grids.unit:query_radius(unit.position, unit.radius)
   for _, other in ipairs(query) do
      if other ~= unit then
         local n = Vector.normal(other.position, unit.position)
         if Vector.equals(other.position, unit.position) then
            n = Utils.random.on_unit_circle()
         end
         local t = Vector.mul(n, unit.radius + other.radius)
         unit.new_position = Vector.add(other.position, t)
         return
      end
   end
end)

Core.new_update_system("unit", "update_position", 102, function(unit, dt)
   unit.position = unit.new_position
end)

function Unit.take_damage(unit, value)
   if unit.status:is("weak") then
      value = value * 2
   end
   unit.hp = math.max(unit.hp - value, 0)
   Particles.number(Vector.add(unit.position, Utils.random.on_circle(love.math.random() * 5)), value)
   if unit.hp == 0 then
      unit.destroyed = true
   end
end
