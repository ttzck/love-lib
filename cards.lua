Cards = {}

local function draw_line_to_mouse()
   local mouse = Utils.input.mouse_position()
   local n = Vector.normal(TowerPosition, mouse)
   local p2 = Vector.add(TowerPosition, Vector.mul(n, WINDOW_WIDTH))
   Utils.graphics.dashed_line(TowerPosition, p2, 8, 16, "#333333", 2)
end

function Cards.new_salvo()
   return {
      name = "Salvo",
      type = "",
      description = function(self)
         return "shoots all arrows in draw pile"
      end,
      play = function()
         local arrow_cards = {}
         local other_cards = {}
         for _, card in ipairs(Player.draw_pile) do
            if card.type == "Arrow" then
               table.insert(arrow_cards, card)
            else
               table.insert(other_cards, card)
            end
         end
         local x = -(#arrow_cards - 1) * 16 / 2
         local m = Utils.input.mouse_position()
         local o = Vector.normalize(Vector.between(TowerPosition, m))
         local a = Vector.angle_between(o, Vector.new(0, -1))
         for i, card in ipairs(arrow_cards) do
            local p = Vector.add(TowerPosition, Vector.rot(Vector.new(x + (i - 1) * 16, math.random() * 32 + 32), a))
            card:play(p, o)
            table.insert(Player.discard_pile, card)
         end
         Player.draw_pile = other_cards
      end,
      aim = draw_line_to_mouse,
   }
end

function Cards.new_basic_arrow()
   return {
      name = "Arrow",
      type = "Arrow",
      description = function(_)
         return "deal 1 damage on impact"
      end,
      play = function(_, position, orientation)
         local mouse = Utils.input.mouse_position()
         Core.new_entity(nil, { "arrow" }, {
            position = position or TowerPosition,
            orientation = orientation or Vector.normal(TowerPosition, mouse),
            damage = 1,
            hit = function(self, other, point)
               Enemy.take_damage(other, 1)
               self.destroyed = true
               Particles.basic_circle(point)
            end,
         })
      end,
      aim = draw_line_to_mouse,
   }
end

function Cards.new_poison_arrow()
   return {
      name = "Poison Arrow",
      type = "Arrow",
      description = function(_)
         return "deal 1 damage on impact and apply weak and stun"
      end,
      play = function(_, position, orientation)
         local mouse = Utils.input.mouse_position()
         Core.new_entity(nil, { "arrow" }, {
            position = position or TowerPosition,
            color = "#00ff00",
            orientation = orientation or Vector.normal(TowerPosition, mouse),
            damage = 1,
            hit = function(self, other, point)
               Enemy.take_damage(other, 1)
               other.status:add("weak", 10)
               other.status:add("stun", 10)
               self.destroyed = true
               Particles.basic_circle(point)
            end,
         })
      end,
      aim = draw_line_to_mouse,
   }
end

function Cards.new_golden_arrow()
   return {
      name = "Golden Arrow",
      type = "Arrow",
      description = function(self)
         return "deal " .. self.damage .. " damage on impact, icrease damage by one if lethal"
      end,
      play = function(card, position, orientation)
         local mouse = Utils.input.mouse_position()
         Core.new_entity(nil, { "arrow" }, {
            position = position or TowerPosition,
            orientation = orientation or Vector.normal(TowerPosition, mouse),
            color = "#daa520",
            hit = function(self, other, point)
               Enemy.take_damage(other, card.damage)
               self.destroyed = true
               Particles.basic_circle(point)
               if other.destroyed then
                  card.damage = card.damage + 1
               end
            end,
         })
      end,
      aim = draw_line_to_mouse,
      damage = 1,
   }
end

function Cards.new_bomb_arrow()
   return {
      name = "Bomb Arrow",
      type = "Arrow",
      description = function(self)
         return "explodes on impact"
      end,
      play = function(_, position, orientation)
         local mouse = Utils.input.mouse_position()
         Core.new_entity(nil, { "arrow" }, {
            position = position or TowerPosition,
            orientation = orientation or Vector.normal(TowerPosition, mouse),
            color = "#ff0000",
            hit = function(self, other, point)
               local query = EnemyGrid:query_radius(point, 32)
               for _, value in ipairs(query) do
                  Enemy.take_damage(value, 1)
               end
               self.destroyed = true
               Particles.basic_circle(point, 32)
            end,
         })
      end,
      aim = draw_line_to_mouse,
   }
end

function Cards.new_dud()
   return {
      name = "Dud",
      type = "",
      description = function(self)
         return "does nothing"
      end,
      play = function() end,
      aim = function()
         Utils.graphics.dashed_circle(Utils.input.mouse_position(), 32, "#333333", 2, 8)
      end,
   }
end

function Cards.new_sacrifice()
   return {
      name = "Sacrifice",
      type = "",
      description = function(self)
         return "draw 3 cards, lose one hp"
      end,
      play = function()
         for _ = 1, 3, 1 do
            Player.draw_card()
         end
         Player.hp = Player.hp - 1
      end,
      aim = function() end,
   }
end

function Cards.new_fairy_dust()
   return {
      name = "Fiary Dust",
      type = "",
      description = function(self)
         return "arrows are homing"
      end,
      play = function()
         Player.status:add("homing", 20)
      end,
      aim = function() end,
   }
end
