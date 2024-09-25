Cooldown = {}
function Cooldown.new(duration)
   return {
      timestamp = -math.huge,
      duration = duration,
      time_left = function(self)
         return math.max(0, self.duration - Utils.timer.time_since(self.timestamp))
      end,
      is_over = function(self)
         return self:time_left() == 0
      end,
      reset = function(self)
         self.timestamp = love.timer.getTime()
      end,
   }
end
