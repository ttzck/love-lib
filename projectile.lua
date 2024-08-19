PROJECTILE_SPEED = 256

Core.new_setup_system("projectile", "projectile_setup", 0, function(projectile, options)
   projectile.collision_filter = function(_, other)
      if other.tags[options.target] then
         return "touch"
      else
         return nil
      end
   end
   projectile.velocity = options.velocity or Vector.new()
   projectile.size = options.width
   projectile.damage = options.damage
   projectile.start_position = options.position
   projectile.range = options.range
end)

Core.new_draw_system("projectile", "projectile_draw", 0, function(projectile)
   local pos = projectile:get_position()
   Utils.graphics.set_color_hex("#ffffff")
   love.graphics.circle("fill", pos.x, pos.y, projectile.size / 2)
end)

Core.new_update_system("projectile", "projectile_update", 0, function(projectile, _)
   local movement = Vector.mul(projectile.velocity, projectile.delta_time)
   local _, _, cols, len = projectile:move(movement, projectile.collision_filter)
   Particles.new({
      size = 1 + love.math.random(),
      color = "#ffffff55",
      position = projectile:get_position(),
   })
   if len > 0 then
      local target = cols[1].other
      for _ = 1, projectile.damage do
         if love.math.random(target.defense * BASE_UNIT_DEFENSE) == 1 then
            cols[1].other.destroyed = true
         end
      end
      projectile.destroyed = true
      Particles.new({ color = "#ffffffaa", position = projectile:get_position() })
      DROP_003:stop()
      DROP_003:play()
   end
   if Vector.dist(projectile.start_position, projectile:get_position()) > projectile.range then
      projectile.destroyed = true
   end
end)
