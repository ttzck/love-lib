HAND_SIZE = 2
HAND_REFILL_PERIOD = 8

local function spawn_squad(card, pos)
   local spacing = UNIT_STATS[card.unit_type].size * BASE_UNIT_SIZE * 3
   pos = Vector.add(pos, Vector.new(-(card.columns - 1) * spacing * 0.5, -(card.rows - 1) * spacing * 0.5))
   for i = 1, card.columns do
      for j = 1, card.rows do
         local position = Vector.add(pos, Vector.new((i - 1) * spacing, (j - 1) * spacing))
         SpawnUnit("defender", card.unit_type, position)
      end
   end
end

local function unit_card_description(card)
   local t = card.unit_type
   return table.concat({
      t,
      "",
      "speed: " .. UNIT_STATS[t].speed,
      "range: " .. UNIT_STATS[t].range,
      "damage: " .. UNIT_STATS[t].damage,
      "defense: " .. UNIT_STATS[t].defense,
      "atk freq: " .. UNIT_STATS[t].atk_freq,
   }, "\n")
end

---@alias card { unit_type: string, use : function, description : function }

CARDS = {
   {
      unit_type = "infantry",
      rows = 2,
      columns = 6,
      use = spawn_squad,
      description = unit_card_description,
   },
   {
      unit_type = "tank",
      rows = 1,
      columns = 2,
      use = spawn_squad,
      description = unit_card_description,
   },
   {
      unit_type = "sniper",
      rows = 1,
      columns = 3,
      use = spawn_squad,
      description = unit_card_description,
   },
   {
      unit_type = "cavalry",
      rows = 2,
      columns = 5,
      use = spawn_squad,
      description = unit_card_description,
   },
   {
      unit_type = "machine_gun",
      rows = 1,
      columns = 3,
      use = spawn_squad,
      description = unit_card_description,
   },
}

Hand = {
   cards = {},
   selected_card = nil, ---@type card?
}

local hand_refill_time = -HAND_REFILL_PERIOD * 0.8
function Hand.update()
   if UNPAUSED_TIME - hand_refill_time > HAND_REFILL_PERIOD then
      Hand.refill()
      PAUSED = true
      hand_refill_time = UNPAUSED_TIME
      CONFIRMATION_001:play()
   end
end

local function get_random_card()
   return Utils.table.deepcopy(CARDS[love.math.random(#CARDS)])
end

function Hand.refill()
   Hand.reset()
   for i = 1, HAND_SIZE do
      Hand.cards[i] = get_random_card()
   end
end

function Hand.reset()
   Hand.cards = {}
   Hand.selected_card = nil
end
