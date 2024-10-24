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

function Unit.spawn_knight(team, position)
   Core.new_entity(nil, { "knight", "attacker", "move_to_opponent", "unit", team }, {
      position = position,
   })
end

function Unit.spawn_ninja(team, position)
   Core.new_entity(nil, { "ninja", "attacker", "move_to_opponent", "unit", team }, {
      position = position,
   })
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
   unit.radius = 4
   unit.attack = archer_attack
end)

local function knight_attack(self)
   Unit.take_damage(self.closest_opponent, 5)
end

Core.new_setup_system("knight", "setup", 0, function(unit, options)
   unit.attack_radius = 20
   unit.attack_rate = 1
   unit.radius = 6
   unit.attack = knight_attack
end)

Core.new_setup_system("ninja", "setup", 1, function(unit, options)
   unit.attack_radius = 20
   unit.attack_rate = 25
   unit.radius = 3
   unit.speed = 200
   unit.attack = knight_attack
end)

Core.new_setup_system("creep", "setup", 0, function(unit, options)
   unit.attack_radius = 20
   unit.attack_rate = 1
   unit.radius = 4
   unit.attack = knight_attack
end)

Core.new_setup_system("defender", "setup", 0, function(unit, options)
   unit.color = "#0000ff"
   unit.team = "defender"
   unit.opponent = "invader"
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

Core.new_update_system("unit", "insert_in_grid", 0, function(unit, _)
   Grids.unit:insert(unit, unit.position, unit.radius)
   Grids[unit.team]:insert(unit, unit.position, unit.radius)
end)

Core.new_update_system("unit", "update_delayed_hp", 0, function(unit, dt)
   unit.delayed_hp = Utils.math.exp_decay(unit.delayed_hp, unit.hp, 2, dt)
end)

local function is_in_range(unit)
   if not unit.closest_opponent then
      return false
   end
   return Vector.sqr_dist(unit.position, unit.closest_opponent.position) < unit.attack_radius * unit.attack_radius
end

Core.new_update_system("attacker", "attack", 2, function(unit, dt)
   if not is_in_range(unit) then
      unit.attack_charge = nil
   elseif not unit.attack_charge then
      unit.attack_charge = TimeSpan.new(1.0 / unit.attack_rate, love.timer.getTime())
   end
   if unit.attack_charge and unit.attack_charge:is_over() then
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

Core.new_update_system("unit", "find_closest_ally", 0, function(unit, dt)
   local allies = Core.get_group(unit.team)
   unit.closest_ally = Utils.table.arg_min(allies, function(ally)
      return Vector.sqr_dist(unit.position, ally.position)
   end)
end)

Core.new_update_system("move_to_opponent", "update_movement_target", 3, function(unit, dt)
   unit.movement_target = nil
   if unit.closest_opponent and not is_in_range(unit) then
      unit.movement_target = unit.closest_opponent.position
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

