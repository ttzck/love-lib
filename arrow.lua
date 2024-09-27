Core.new_setup_system("arrow", "setup", 0, function(arrow, options)
   arrow.position = options.position
   arrow.orientation = options.orientation
   arrow.damage = options.damage
   arrow.radius = 1
   arrow.color = options.color or "#ffffff"
   arrow.speed = 360
   arrow.hit = options.hit
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
   -- homing
   local homing = EnemyGrid:query_radius(arrow.position, 256)
   local target = nil
   for index, other in ipairs(homing) do
      if
         not target
         or Vector.sqr_dist(arrow.position, other.position) < Vector.sqr_dist(arrow.position, target.position)
      then
         target = other
      end
   end
   if target then
      local right = Vector.rot_90(arrow.orientation)
      local t = Vector.normal(arrow.position, target.position)
      local dot = Vector.dot(right, t)
      if dot > 0 then
         arrow.orientation = Vector.rot(arrow.orientation, 1 * dt)
      elseif dot < 0 then
         arrow.orientation = Vector.rot(arrow.orientation, -1 * dt)
      end
   end

   local movement = Vector.set_mag(arrow.orientation, arrow.speed * dt)
   local new_position = Vector.add(arrow.position, movement)
   local query = EnemyGrid:query_circle_sweep(arrow.position, arrow.radius, new_position)
   if query.other then
      arrow:hit(query.other, query.collision_point)
   else
      arrow.position = query.position
   end
end)
