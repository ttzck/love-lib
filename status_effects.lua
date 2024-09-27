Status = {}
function Status.new()
   return {
      active = {},
      add = function(self, effect_name, duration)
         local effect = TimeSpan.new(duration, love.timer.getTime())
         effect.name = effect_name
         table.insert(self.active, effect)
      end,
      clean_up = function(self)
         local active = {}
         for _, effect in ipairs(self.active) do
            if effect:is_ongoing() then
               table.insert(active, effect)
            end
         end
         self.active = active
      end,
      is = function(self, effect_name)
         self:clean_up()
         for _, effect in ipairs(self.active) do
            if effect.name == effect_name then
               return true
            end
         end
      end,
   }
end
