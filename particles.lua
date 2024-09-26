require("utils")

Particles = { active = {}, get_time = love.timer.getTime, n = 0 }

function Particles.insert(particle)
   Particles.n = Particles.n + 1
   Particles.active[Particles.n] = particle
   particle.t0 = Particles.get_time()
end

local interpolate = Utils.timer.interpolate

function Particles.basic_circle(position, size, color)
   Particles.insert({
      d = 1,
      draw = function(self)
         Utils.graphics.set_color_hex(color or "#ffffff")
         local r = interpolate(size or 8, 0, 1, self.t0, self.d, Particles.get_time())
         love.graphics.circle("fill", position.x, position.y, r)
      end,
      active = function(self)
         return Particles.get_time() <= self.t0 + self.d
      end,
   })
end

function Particles.number(position, n)
   Particles.insert({
      d = 3,
      draw = function(self)
         Utils.graphics.set_color_hex("#ff0000")
         love.graphics.print(tostring(n), position.x, position.y)
      end,
      active = function(self)
         return Particles.get_time() <= self.t0 + self.d
      end,
   })
end

function Particles.draw()
   local m = 0
   local active = {}
   for i = 1, Particles.n do
      local particle = Particles.active[i]
      if particle:active() then
         m = m + 1
         active[m] = particle
         particle:draw()
      end
   end
   Particles.active = active
   Particles.n = m
end
