Cards = {}

function Cards.new_arrow()
   return {
      name = "Arrow",
      play = function()
         local mouse = Utils.input.mouse_position()
         Core.new_entity(nil, { "arrow" }, {
            position = TowerPosition,
            orientation = Vector.normal(TowerPosition, mouse),
            damage = 1,
         })
      end,
      aim = function()
         local mouse = Utils.input.mouse_position()
         local n = Vector.normal(TowerPosition, mouse)
         local p2 = Vector.add(TowerPosition, Vector.mul(n, WINDOW_WIDTH))
         Utils.graphics.dashed_line(TowerPosition, p2, 8, 16, "#333333", 2)
      end,
   }
end

function Cards.new_dud()
   return {
      name = "Dud",
      play = function() end,
      aim = function()
         Utils.graphics.dashed_circle(Utils.input.mouse_position(), 32, "#333333", 2, 8)
      end,
   }
end

function Cards.new_sacrifice()
   return {
      name = "Sacrifice",
      play = function()
         for _ = 1, 3, 1 do
            Player.draw_card()
         end
         Player.hp = Player.hp - 1
      end,
      aim = function() end,
   }
end
