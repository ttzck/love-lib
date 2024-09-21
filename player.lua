Player = {
   hp = 10,
   max_hp = 10,
   slots = { "a", "s", "d", "f", "q", "w", "e", "r" },
   hand = {},
   draw_pile = {
      Cards.new_arrow(),
      Cards.new_arrow(),
      Cards.new_dud(),
      Cards.new_arrow(),
      Cards.new_dud(),
      Cards.new_arrow(),
      Cards.new_arrow(),
      Cards.new_sacrifice(),
   },
   discard_pile = {},
   selected_slot = nil,
   last_card_draw = 0,
   card_draw_cooldown = 5,
}

local function cycle_piles()
   Utils.table.shuffle(Player.discard_pile)
   Player.draw_pile = Player.discard_pile
   Player.discard_pile = {}
end

local function first_free_slot()
   for _, slot in ipairs(Player.slots) do
      if not Player.hand[slot] then
         return slot
      end
   end
end

function Player.draw_card()
   if #Player.discard_pile == 0 and #Player.draw_pile == 0 then
      return
   end
   if #Player.draw_pile == 0 then
      cycle_piles()
   end
   local free_slot = first_free_slot()
   if free_slot then
      Player.hand[free_slot] = table.remove(Player.draw_pile)
   end
end

local function pile_to_string(pile)
   local cards = {}
   for _, card in ipairs(pile) do
      table.insert(cards, card.name)
   end
   return table.concat(cards, ", ")
end

function Player.draw()
   Utils.graphics.set_color_hex("#ffffff")
   love.graphics.circle("fill", TowerPosition.x, TowerPosition.y, 6)
   for i, slot in ipairs(Player.slots) do
      local x = 16
      if slot == Player.selected_slot then
         x = 32
      end
      local card = ""
      if Player.hand[slot] then
         card = Player.hand[slot].name
      end
      love.graphics.print(slot .. " " .. card, x, 16 + i * 16)
   end
   love.graphics.print("Draw Pile: " .. pile_to_string(Player.draw_pile), 16, WINDOW_HEIGHT - 64)
   love.graphics.print("Discard Pile: " .. pile_to_string(Player.discard_pile), 16, WINDOW_HEIGHT - 48)
   love.graphics.print(
      "Card Draw: " .. math.ceil(Player.card_draw_cooldown - Utils.timer.time_since(Player.last_card_draw)),
      16,
      WINDOW_HEIGHT - 32
   )
   love.graphics.print("HP: " .. Player.hp .. "/" .. Player.max_hp, 16, WINDOW_HEIGHT - 16)
   if Player.selected_card() then
      Player.selected_card():aim()
   end
end

function Player.update(dt)
   Player.selected_slot = nil
   for _, slot in ipairs(Player.slots) do
      if love.keyboard.isDown(slot) then
         Player.selected_slot = slot
      end
   end
   if Utils.timer.time_since(Player.last_card_draw) > Player.card_draw_cooldown then
      Player.draw_card()
      Player.last_card_draw = love.timer.getTime()
   end
end

function Player.selected_card()
   return Player.hand[Player.selected_slot]
end

local function remove_selected_card()
   Player.hand[Player.selected_slot] = nil
end

function Player.play_card()
   local card = Player.selected_card()
   if card then
      card:play()
      remove_selected_card()
      table.insert(Player.discard_pile, card)
   end
end
