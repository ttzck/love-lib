Enemy = {}

Core.new_setup_system("enemy", "setup", 0, function(enemy, options)
   enemy.position = options.position
   enemy.radius = 8
   enemy.color = "#ffffff"
   enemy.speed = 16
   enemy.hp = options.hp
   enemy.delayed_hp = options.hp
   enemy.max_hp = options.max_hp or options.hp
end)

Core.new_draw_system("enemy", "draw_body", 0, function(enemy)
   Utils.graphics.set_color_hex(enemy.color)
   Utils.graphics.draw_cenetered(
      SKULL,
      enemy.position.x,
      enemy.position.y,
      0,
      enemy.radius * 2 / SKULL:getHeight(),
      enemy.radius * 2 / SKULL:getHeight()
   )
end)

Core.new_draw_system("enemy", "draw_hp_bar", 1, function(enemy)
   local width = 24
   local height = 2
   Ui.utils.progress_bar({
      x = enemy.position.x - width / 2,
      y = enemy.position.y - enemy.radius - height * 2,
      width = width,
      height = height,
      primary_color = "#00ff00",
      secondary_color = "#ff0000",
      background_color = "#000000",
      radius = 2,
      primary_ratio = enemy.hp / enemy.max_hp,
      secondary_ratio = enemy.delayed_hp / enemy.max_hp,
   })
end)

Core.new_update_system("enemy", "insert_in_grid", 0, function(enemy, _)
   EnemyGrid:insert(enemy, enemy.position, enemy.radius)
end)

Core.new_update_system("enemy", "misc", 0, function(enemy, dt)
   enemy.delayed_hp = Utils.math.exp_decay(enemy.delayed_hp, enemy.hp, 2, dt)
end)

Core.new_update_system("enemy", "calculate_movement", 2, function(enemy, dt)
   local force = Vector.new()
   local query = EnemyGrid:query_radius(enemy.position, enemy.radius * 2)
   for _, other in ipairs(query) do
      if other ~= enemy then
         force = Vector.sub(force, Vector.set_mag(Vector.between(enemy.position, other.position), dt * 100))
      end
   end
   if force.x ~= 0 or force.y ~= 0 then
      enemy.movement = force
   else
      local movement = Vector.between(enemy.position, TowerPosition)
      movement = Vector.set_mag(movement, enemy.speed * dt)
      enemy.movement = movement
   end
end)

Core.new_update_system("enemy", "move", 3, function(enemy, dt)
   enemy.position = Vector.add(enemy.position, enemy.movement)
end)

function Enemy.take_damage(enemy, value)
   enemy.hp = math.max(enemy.hp - value, 0)
   if enemy.hp == 0 then
      enemy.destroyed = true
   end
end
