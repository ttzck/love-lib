local function physics_object_setup(physics_object, options)
   Physics:add(physics_object, options.position.x, options.position.y, options.width, options.height)

   function physics_object:get_position()
      local x, y = Physics:getRect(self)
      return Vector.new(x, y)
   end

   function physics_object:get_centered_position()
      local x, y, w, h = Physics:getRect(self)
      return Vector.new(x + w / 2, y + h / 2)
   end
end

Core.new_setup_system("physics_object", "physics_object_setup", 0, physics_object_setup)

Core.new_destroy_system("physics_object", "physics_object_destroy", 0, function(projectile)
   Physics:remove(projectile)
end)
