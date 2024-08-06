require("ui")
require("utils")

function love.load()
    WindowWidth, WindowHeight = love.window.getMode();
    love.graphics.setBackgroundColor(1, 1, 1)
end

local test_button_style = { 
    width = 100, 
    height = 100, 
    radius = 4, 
    padding = {left = 10, right = 10, up = 100, down = 0},
    align = "left",
    fill = "#333333",
    text = { color = "#ffff00", font = nil, align = "center" }
}

local test_data = {} 

local test_ui = {
    style = {
        width = WindowWidth,
        height = WindowHeight,
        align = "left"
    },
    factory = {
        input = function(element)
            return test_data 
        end,
        output = function(input, output, first_seen, last_seen)
            if love.timer.getTime() - last_seen > 1 then return nil end
            return output or {
                style = test_button_style,
                draw = Ui.draw_functions.compose(
                    Ui.draw_functions.rectangle,
                    Ui.draw_functions.printf),
                text = input
            }
        end
    }
}

function love.keypressed( key )
    if test_data[key] then
        test_data[key] = nil
    else
        test_data[key] = key
    end
end

function love.draw()
    Ui.build(test_ui)
    Ui.layout(test_ui)
    Ui.draw(test_ui)
end