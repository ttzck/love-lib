require("utils")

Particles = { active = {}, get_time = love.timer.getTime }

local id = 1

function Particles.new(template)
   Particles.active[id] = {
      position = template.position or { x = 0, y = 0 },
      velocity = template.velocity or { x = 0, y = 0 },
      velocity_decay = template.velocity_decay or 1,
      size = template.size or 8,
      size_decay = template.size_decay or 1,
      color = template.color or "#ffffff",
      duration = template.duration or 1,
      creation_time = Particles.get_time(),
      id = id,
   }
   id = id + 1
end

local interpolate = Utils.timer.interpolate

function Particles.draw()
   local destroyed = {}
   for _, particle in pairs(Particles.active) do
      if Particles.get_time() > particle.creation_time + particle.duration then
         table.insert(destroyed, particle)
      else
         Utils.graphics.set_color_hex(particle.color)
         local pos1 = particle.position
         local pos2 = Vector.add(pos1, Vector.mul(particle.velocity, particle.duration))
         local t0 = particle.creation_time
         local d = particle.duration
         local x = interpolate(pos1.x, pos2.x, particle.velocity_decay, t0, d, Particles.get_time())
         local y = interpolate(pos1.y, pos2.y, particle.velocity_decay, t0, d, Particles.get_time())
         local size = interpolate(particle.size, 0, particle.size_decay, t0, d, Particles.get_time())
         love.graphics.circle("fill", x, y, size)
      end
   end
   for _, particle in pairs(destroyed) do
      Particles.active[particle.id] = nil
   end
end
