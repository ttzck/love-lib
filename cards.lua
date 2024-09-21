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
         Utils.graphics.set_color_hex("#ffffff")
         love.graphics.setLineWidth(1)
         love.graphics.setLineStyle("smooth")
         love.graphics.line(TowerPosition.x, TowerPosition.y, mouse.x, mouse.y)
      end,
   }
end

function Cards.new_dud()
   return {
      name = "Dud",
      play = function() end,
      aim = function() end,
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
