local compose = Ui.draw_functions.compose
local rectangle = Ui.draw_functions.rectangle

MAIN_UI = {
   id = "canvas",
   style = {
      width = WINDOW_WIDTH,
      height = WINDOW_HEIGHT,
      align = "horizontal",
   },
   children = {
      {
         id = "hand_canvas",
         style = {
            width = WINDOW_WIDTH,
            height = 100,
            align = "horizontal",
            padding = {
               left = 0,
               right = 0,
               up = 2 * WINDOW_HEIGHT / 3 - 32,
               down = 0,
            },
         },
         factory = {
            input = function(_)
               return Hand.cards
            end,
            output = function(input, output, live)
               if not live then
                  return nil
               end
               return output
                  or {
                     card = input,
                     style = {
                        width = 120,
                        height = 168,
                        radius = 4,
                        hover_offset_y = -6,
                        fill = "#33333350",
                        fill_hover = "#333333",
                        padding = { left = 5, right = 5, up = 0, down = 0 },
                        text = {
                           color = "#ffffff",
                           align = "center",
                           font = FONT_16,
                        },
                     },
                     text = input:description(),
                     draw = compose(rectangle, Ui.draw_functions.printf, function(element)
                        if Hand.selected_card == element.card then
                           Utils.graphics.set_color_hex("#ffffff")
                           local y = element.y
                           if element.mouse_inside then
                              y = y + element.style.hover_offset_y
                           end
                           love.graphics.rectangle(
                              "line",
                              element.x,
                              y,
                              element.style.width,
                              element.style.height,
                              element.style.radius
                           )
                        end
                     end),
                     click = function(self, button)
                        SELECT_001:stop()
                        SELECT_001:play()
                        Hand.selected_card = self.card
                     end,
                     hover = function()
                        TICK_001:stop()
                        TICK_001:play()
                     end,
                  }
            end,
         },
      },
   },
}

local big_text = {
   width = WINDOW_WIDTH,
   height = 200,
   text = {
      color = "#ffffff",
      align = "center",
      font = FONT_64,
   },
}

local small_text = {
   width = WINDOW_WIDTH,
   height = 100,
   text = {
      color = "#ffffff",
      align = "center",
      font = FONT_16,
   },
}

GAME_OVER_UI = {
   id = "canvas",
   style = {
      width = WINDOW_WIDTH,
      height = WINDOW_HEIGHT,
      align = "vertical",
   },
   children = {
      {
         id = "game_over_text",
         style = big_text,
         text = "GAME OVER",
         draw = Ui.draw_functions.printf,
      },
      {
         style = small_text,
         text = [[
made with LÖVE
assets by KENNEY.nl

inspired by the novella 
"This Is How You Lose the Time War" 
by Amal El-Mohtar and Max Gladstone
				]],
         draw = Ui.draw_functions.printf,
      },
      {
         style = {
            width = 90,
            height = 28,
            radius = 4,
            hover_offset_y = -6,
            fill = "#33333350",
            fill_hover = "#333333",
            padding = { left = WINDOW_WIDTH / 2 - 90 / 2, right = 0, up = 40, down = 0 },
            text = {
               color = "#ffffff",
               align = "center",
               font = FONT_16,
            },
         },
         text = "Quit Game",
         draw = compose(rectangle, Ui.draw_functions.printf),
         click = function()
            love.event.quit()
         end,
         hover = function()
            TICK_001:stop()
            TICK_001:play()
         end,
      },
   },
}

TUTORIAL_UI = {
   id = "canvas",
   style = {
      width = WINDOW_WIDTH,
      height = WINDOW_HEIGHT,
      align = "vertical",
   },
   children = {
      {
         style = big_text,
         text = "How To Play",
         draw = Ui.draw_functions.printf,
      },
      {
         style = {
            width = WINDOW_WIDTH / 3,
            height = 200,
            text = {
               color = "#ffffff",
               align = "center",
               font = FONT_16,
            },
            padding = { left = 1 * WINDOW_WIDTH / 3, right = 0, up = 0, down = 0 },
         },
         text = [[
Hello Agent Blue,

Defend your base from waves of enemies by strategically deploying your troops in the blue zone.
Though you may be outnumbered, you have a unique advantage: your left and right mouse buttons allow you to manipulate the local time scale.

Good Luck!
				]],
         draw = Ui.draw_functions.printf,
      },
      {
         style = {
            width = 60,
            height = 28,
            radius = 4,
            hover_offset_y = -6,
            fill = "#33333350",
            fill_hover = "#333333",
            padding = { left = WINDOW_WIDTH / 2 - 60 / 2, right = 0, up = 80, down = 0 },
            text = {
               color = "#ffffff",
               align = "center",
               font = FONT_16,
            },
         },
         text = "Go",
         draw = compose(rectangle, Ui.draw_functions.printf),
         click = function()
            TUTORIAL = false
            PAUSED = false
         end,
         hover = function()
            TICK_001:stop()
            TICK_001:play()
         end,
      },
   },
}
