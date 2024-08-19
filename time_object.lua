TIME_WARP_RADIUS = 64
TIME_WARP_ACCELERATION = 4
TIME_WARP_DECELERATION = 4

Core.new_setup_system("time_object", "time_object_setup", -1, function(time_object)
   time_object.lifetime = 0
end)

Core.new_update_system("time_object", "time_object_update", -1, function(time_object, dt)
   local d = Vector.dist(time_object:get_position(), Utils.input.mouse_position())
   if d < TIME_WARP_RADIUS then
      if love.mouse.isDown(1) then
         dt = dt * TIME_WARP_ACCELERATION
      end
      if love.mouse.isDown(2) then
         dt = dt / TIME_WARP_DECELERATION
      end
   end

   time_object.delta_time = dt
   time_object.lifetime = time_object.lifetime + dt
end)
