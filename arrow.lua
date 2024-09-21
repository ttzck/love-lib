Core.new_setup_system("arrow", "setup", 0, function(arrow, options)
   arrow.position = options.position
   arrow.orientation = options.orientation
   arrow.damage = options.damage
   arrow.radius = 1
   arrow.color = "#ffffff"
   arrow.speed = 360
end)

Core.new_draw_system("arrow", "draw", 0, function(arrow)
   Utils.graphics.set_color_hex(arrow.color)
   local p = arrow.position
   local r = arrow.radius
   for _ = 1, 12 do
      love.graphics.circle("fill", p.x, p.y, r)
      p = Vector.sub(p, Vector.mul(arrow.orientation, r))
      r = r * 0.9
   end
end)

Core.new_update_system("arrow", "move", 1, function(arrow, dt)
   local movement = Vector.set_mag(arrow.orientation, arrow.speed * dt)
   local new_position = Vector.add(arrow.position, movement)
   local query = EnemyGrid:query_circle_sweep(arrow.position, arrow.radius, new_position)
   if query.other then
      Enemy.take_damage(query.other, arrow.damage)
      arrow.destroyed = true
      Particles.new({ position = query.collision_point })
   else
      arrow.position = query.position
   end
end)
