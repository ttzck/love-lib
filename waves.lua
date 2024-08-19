local function spawn_squad(wave)
   local spacing = UNIT_STATS[wave.unit_type].size * BASE_UNIT_SIZE * 3
   local pos = Vector.add(
      Vector.new(wave.x, 8),
      Vector.new(-(wave.columns - 1) * spacing * 0.5, -(wave.rows - 1) * spacing * 0.5)
   )
   for i = 1, wave.columns do
      for j = 1, wave.rows do
         local position = Vector.add(pos, Vector.new((i - 1) * spacing, (j - 1) * spacing))
         SpawnUnit("invader", wave.unit_type, position)
      end
   end
end

Waves = {
   {
      unit_type = "infantry",
      x = WINDOW_WIDTH / 2,
      rows = 1,
      columns = 6,
   },
   {
      unit_type = "infantry",
      x = WINDOW_WIDTH / 3,
      rows = 2,
      columns = 6,
   },
   {
      unit_type = "infantry",
      x = 2 * WINDOW_WIDTH / 3,
      rows = 3,
      columns = 6,
   },
   {
      unit_type = "cavalry",
      x = WINDOW_WIDTH / 6,
      rows = 12,
      columns = 2,
   },
   {
      unit_type = "sniper",
      x = WINDOW_WIDTH / 2,
      rows = 1,
      columns = 8,
   },
   {
      unit_type = "cavalry",
      x = 5 * WINDOW_WIDTH / 6,
      rows = 12,
      columns = 2,
   },
   {
      unit_type = "tank",
      x = WINDOW_WIDTH / 3,
      rows = 1,
      columns = 5,
   },
   {
      unit_type = "machine_gun",
      x = 2 * WINDOW_WIDTH / 3,
      rows = 1,
      columns = 5,
   },
   {
      unit_type = "infantry",
      x = WINDOW_WIDTH / 2,
      rows = 6,
      columns = 12,
   },
   {
      unit_type = "sniper",
      x = WINDOW_WIDTH / 2,
      rows = 1,
      columns = 16,
   },
}

local i = 1
local t = 0
function Waves.update()
   if UNPAUSED_TIME > t then
      if Waves[i] then
         spawn_squad(Waves[i])
         i = i + 1
         t = t + HAND_REFILL_PERIOD
      end
   end
end

function Waves.is_last()
   return Waves[i] == nil
end
