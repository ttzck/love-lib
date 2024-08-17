Core.new_archetype("projectile", "physics_object")

local function projectile_setup(projectile, options)
   projectile.collision_filter = function(_, other)
      if other.tags[options.target] then
         return "touch"
      else
         return nil
      end
   end
   projectile.velocity = options.velocity or Vector.new()
   projectile.size = options.width
end

Core.new_setup_system("projectile", "projectile_setup", 0, projectile_setup)

Core.new_draw_system("projectile", "projectile_draw", 0, function(projectile)
   local pos = projectile:get_centered_position()
   Utils.graphics.set_color_hex("#ffffff")
   love.graphics.circle("fill", pos.x, pos.y, projectile.size / 2)
end)

Core.new_update_system("projectile", "projectile_update", 0, function(projectile, dt)
   local pos = projectile:get_position()
   local target_pos = Vector.add(pos, Vector.mul(projectile.velocity, dt))
   local _, _, cols, len = Physics:move(projectile, target_pos.x, target_pos.y, projectile.collision_filter)
   Particles.new({ size = 1, color = "#ffffff55", position = projectile:get_centered_position() })
   if len > 0 then
      cols[1].other.destroyed = true
      projectile.destroyed = true
      Particles.new({ color = "#ffffffaa", position = projectile:get_centered_position() })
   end
end)
