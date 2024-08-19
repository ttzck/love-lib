Core.new_setup_system("physics_object", "physics_object_setup", 0, function(physics_object, options)
   local rect_x = options.position.x - options.width / 2
   local rect_y = options.position.y - options.height / 2
   Physics:add(physics_object, rect_x, rect_y, options.width, options.height)

   function physics_object:get_position()
      local x, y, w, h = Physics:getRect(self)
      return Vector.new(x + w / 2, y + h / 2)
   end

   function physics_object:get_size()
      local _, _, w, h = Physics:getRect(self)
      return w, h
   end

   function physics_object:move(movement, filter)
      local x, y = Physics:getRect(self)
      local t_x, t_y = x + movement.x, y + movement.y
      return Physics:move(self, t_x, t_y, filter)
   end
end)

Core.new_destroy_system("physics_object", "physics_object_destroy", 0, function(projectile)
   Physics:remove(projectile)
end)
