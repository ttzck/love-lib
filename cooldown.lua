TimeSpan = {}
function TimeSpan.new(duration, start, time)
   return {
      duration = duration,
      timestamp = start or -math.huge,
      time = time or love.timer.getTime,
      time_left = function(self)
         return math.max(0, self.duration - Utils.timer.time_since(self.timestamp, self:time()))
      end,
      is_ongoing = function(self)
         return self:time() > self.timestamp and self:time() < self.timestamp + self.duration
      end,
      is_over = function(self)
         return self:time_left() == 0
      end,
      reset = function(self)
         self.timestamp = self:time()
      end,
   }
end
