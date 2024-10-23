Core.new_setup_system("arrow", "setup", 0, function(arrow, options)
   arrow.position = options.position
   arrow.orientation = options.orientation
   arrow.damage = options.damage
   arrow.radius = 1
   arrow.color = options.color or "#ffffff"
   arrow.speed = 260
   arrow.hit = options.hit
   arrow.target = options.target
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
   if Player.status:is("homing") then
      Particles.basic_circle(Vector.add(p, Vector.mul(Utils.random.on_unit_circle(), 3)), 1, "#800080")
   end
end)

Core.new_update_system("arrow", "move", 1, function(arrow, dt)
   local movement = Vector.set_mag(arrow.orientation, arrow.speed * dt)
   local new_position = Vector.add(arrow.position, movement)
   local query = Grids[arrow.target.team]:query_circle_sweep(arrow.position, arrow.radius, new_position)
   if query.other then
      arrow:hit(query.other, query.collision_point)
   else
      arrow.position = query.position
   end
end)
