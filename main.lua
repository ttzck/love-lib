require("utils")
require("ui")
require("core")

function love.load()
   WindowWidth, WindowHeight = 800, 600
   love.window.setMode(WindowWidth, WindowHeight, { msaa = 2 })
   love.graphics.setBackgroundColor(1, 1, 1)

   Ubuntu_font = love.graphics.newFont("ubuntu-regular.ttf", 18)
   Click1_sound = love.audio.newSource("kenney_interface-sounds/Audio/click_001.ogg", "static")
   Click2_sound = love.audio.newSource("kenney_interface-sounds/Audio/click_002.ogg", "static")
   Eye_image = love.graphics.newImage("kenney_googly-eyes/PNG/googly-c.png")

   test_button_style = {
      width = 100,
      height = 100,
      radius = 4,
      padding = { left = 10, right = 10, up = 10, down = 10 },
      align = "left",
      fill = "#333333",
      fill_hover = "#111111",
      hover_offset_x = 10,
      hover_offset_y = 10,
      text = { color = "#ffffff", font = Ubuntu_font, align = "center" },
   }

   test_bar_style = {
      width = 300,
      height = 10,
      radius = 6,
      padding = { left = 10, right = 10, up = 10, down = 10 },
      align = "left",
      fill = "#111111",
      progress = "#00ff00",
      highlight = "#ffffff",
      ratio = 0.7,
      delayed_ratio = 0.9,
   }

   test_data = {}

   test_bar_ui = {
      id = "canvas",
      style = {
         width = WindowWidth,
         height = WindowHeight,
         align = "horizontal",
      },
      children = {
         {
            style = test_bar_style,
            draw = Ui.draw_functions.compose(Ui.draw_functions.rectangle, Ui.draw_functions.progress_bar),
            click = function(self)
               self.style.ratio = self.style.ratio * 0.9
            end,
         },
      },
   }

   test_ui = {
      id = "canvas",
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
            if love.timer.getTime() - last_seen > 0.5 then
               return nil
            end
            output = output
               or {
                  id = "button " .. input,
                  order = input,
                  style = Utils.table.deepcopy(test_button_style),
                  draw = Ui.draw_functions.compose(Ui.draw_functions.rectangle, Ui.draw_functions.draw_image),
                  text = input,
                  image = Eye_image,
                  click = function(self, button)
                     if button == 1 then
                        test_data[input] = nil
                        love.audio.play(Click2_sound)
                     end
                  end,
                  hover = function(self)
                     love.audio.play(Click1_sound)
                  end,
               }
            output.style.draw_width = Utils.timer.lerp(100, 0, last_seen, 0.5)
            output.style.draw_height = Utils.timer.lerp(100, 0, last_seen, 0.5)
            return output
         end,
      },
   }

   Ui.root = test_ui
end

function love.keypressed(key)
   if key == "d" then
      debug.debug()
   end
   test_data[key] = key
end

function love.draw()
   Ui.build()
   Ui.layout()
   Ui.hover()
   Ui.draw()
end

function love.mousepressed(_, _, button)
   Ui.click(button)
end
