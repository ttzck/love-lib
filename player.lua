Player = {
   hp = 10,
   max_hp = 10,
   mana = 20,
   max_mana = 20,
   slots = { "a", "s", "d", "f", "q", "w", "e", "r" },
   hand = {},
   draw_pile = {
      Cards.new_basic_arrow(),
      Cards.new_basic_arrow(),
      Cards.new_golden_arrow(),
      Cards.new_bomb_arrow(),
      Cards.new_poison_arrow(),
      Cards.new_sacrifice(),
      Cards.new_basic_arrow(),
      Cards.new_basic_arrow(),
      Cards.new_basic_arrow(),
      Cards.new_basic_arrow(),
      Cards.new_basic_arrow(),
      Cards.new_basic_arrow(),
      Cards.new_basic_arrow(),
      Cards.new_fairy_dust(),
      Cards.new_salvo(),
   },
   discard_pile = {},
   selected_slot = nil,
   card_play_cooldown = TimeSpan.new(0.5),
   mana_regen_cooldown = TimeSpan.new(5, love.timer.getTime()),
   status = Status.new(),
}

function Player.restock_draw_pile()
   if #Player.discard_pile == 0 then
      return
   end
   if Player.mana == 0 then
      return
   end
   Utils.table.shuffle(Player.discard_pile)
   for _, card in ipairs(Player.discard_pile) do
      table.insert(Player.draw_pile, card)
   end
   Player.discard_pile = {}
   Player.mana = Player.mana - 1
end

local function first_free_slot()
   for _, slot in ipairs(Player.slots) do
      if not Player.hand[slot] then
         return slot
      end
   end
end

function Player.draw_card()
   if #Player.draw_pile == 0 then
      return
   end
   if Player.mana == 0 then
      return
   end
   local free_slot = first_free_slot()
   if free_slot then
      Player.hand[free_slot] = table.remove(Player.draw_pile)
      Player.mana = Player.mana - 1
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
   Utils.graphics.draw_cenetered(
      TOWER,
      TowerPosition.x,
      TowerPosition.y,
      0,
      16 / TOWER:getHeight(),
      16 / TOWER:getHeight()
   )
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
   love.graphics.print("Mana: " .. Player.mana .. "/" .. Player.max_mana, 16, WINDOW_HEIGHT - 32)
   love.graphics.print("HP: " .. Player.hp .. "/" .. Player.max_hp, 16, WINDOW_HEIGHT - 16)
   if Player.selected_card() then
      Player.selected_card():aim()
   end
   if not Player.card_play_cooldown:is_over() then
      Ui.utils.progress_bar({
         x = TowerPosition.x - 32 / 2,
         y = TowerPosition.y + 16,
         width = 32,
         height = 4,
         primary_color = "#ffffff",
         background_color = "#000000",
         radius = 2,
         primary_ratio = Player.card_play_cooldown:time_left() / Player.card_play_cooldown.duration,
      })
   end
   if Player.selected_card() and love.keyboard.isDown("lshift") then
      local desc = Player.selected_card():description()
      Utils.graphics.set_color_hex("#ffffff")
      love.graphics.print(desc, WINDOW_WIDTH / 3, WINDOW_HEIGHT / 3)
   end
end

function Player.update(dt)
   Player.selected_slot = nil
   for _, slot in ipairs(Player.slots) do
      if love.keyboard.isDown(slot) then
         Player.selected_slot = slot
      end
   end
   if Player.mana_regen_cooldown:is_over() then
      if Player.mana < Player.max_mana then
         if not Player.mana_regen_cooldown.flag then
            Player.mana = Player.mana + 1
         end
         Player.mana_regen_cooldown:reset()
         Player.mana_regen_cooldown.flag = false
      else
         Player.mana_regen_cooldown.flag = true
      end
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
   if card and Player.card_play_cooldown:is_over() then
      card:play()
      remove_selected_card()
      table.insert(Player.discard_pile, card)
      Player.card_play_cooldown:reset()
   end
end
