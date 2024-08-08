require("utils")
require("ui")

function love.load()
   WindowWidth, WindowHeight = 800, 600
   love.window.setMode(WindowWidth, WindowHeight, { msaa = 2 })
   love.graphics.setBackgroundColor(1, 1, 1)

   Ubuntu_font = love.graphics.newFont("ubuntu-regular.ttf", 18)
   test_button_style = {
      width = 100,
      height = 100,
      radius = 4,
      padding = { left = 10, right = 10, up = 100, down = 0 },
      align = "left",
      fill = "#333333",
      fill_hover = "#111111",
      text = { color = "#ffffff", font = Ubuntu_font, align = "center" },
   }

   test_data = {}

   test_ui = {
      style = {
         width = WindowWidth,
         height = WindowHeight,
         align = "horizontal",
      },
      factory = {
         input = function(_)
            return test_data
         end,
         output = function(input, output, _, last_seen)
            if love.timer.getTime() - last_seen > .5 then
               return nil
            end
            output = output
               or {
                  style = Utils.table.deepcopy(test_button_style),
                  draw = Ui.draw_functions.compose(Ui.draw_functions.rectangle, Ui.draw_functions.printf),
                  text = input,
               }
            output.style.draw_width = 100 - (love.timer.getTime() - last_seen) * 200
            output.style.draw_height = 100 - (love.timer.getTime() - last_seen) * 200
            return output
         end,
      },
   }
end

function love.keypressed(key)
   if test_data[key] then
      test_data[key] = nil
   else
      test_data[key] = key .. " 󱡁  " .. "Lorem ipsum dolor sit amet"
   end
end

function love.draw()
   Ui.build(test_ui)
   Ui.layout(test_ui)
   Ui.hover(test_ui)
   Ui.draw(test_ui)
end
