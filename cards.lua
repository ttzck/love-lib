Cards = {}

local function draw_line_to_mouse()
   local mouse = Utils.input.mouse_position()
   local n = Vector.normal(TowerPosition, mouse)
   local p2 = Vector.add(TowerPosition, Vector.mul(n, WINDOW_WIDTH))
   Utils.graphics.dashed_line(TowerPosition, p2, 8, 16, "#333333", 2)
end

function Cards.new_basic_arrow()
   return {
      name = "Arrow",
      description = function(self)
         return "deal 1 damage on impact"
      end,
      play = function()
         local mouse = Utils.input.mouse_position()
         Core.new_entity(nil, { "arrow" }, {
            position = TowerPosition,
            orientation = Vector.normal(TowerPosition, mouse),
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
      description = function(self)
         return "deal 1 damage on impact and apply weak and stun"
      end,
      play = function()
         local mouse = Utils.input.mouse_position()
         Core.new_entity(nil, { "arrow" }, {
            position = TowerPosition,
            color = "#00ff00",
            orientation = Vector.normal(TowerPosition, mouse),
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
      description = function(self)
         return "deal " .. self.damage .. " damage on impact, icrease damage by one if lethal"
      end,
      play = function(card)
         local mouse = Utils.input.mouse_position()
         Core.new_entity(nil, { "arrow" }, {
            position = TowerPosition,
            orientation = Vector.normal(TowerPosition, mouse),
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
      description = function(self)
         return "explodes on impact"
      end,
      play = function()
         local mouse = Utils.input.mouse_position()
         Core.new_entity(nil, { "arrow" }, {
            position = TowerPosition,
            orientation = Vector.normal(TowerPosition, mouse),
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
