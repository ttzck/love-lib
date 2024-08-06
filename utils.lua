Utils = {}

Utils.color = {}
function Utils.color.from_hex(hex)
    local r = tonumber(string.sub(hex, 2, 3), 16) / 256 
    local g = tonumber(string.sub(hex, 4, 5), 16) / 256 
    local b = tonumber(string.sub(hex, 6, 7), 16) / 256 
    if hex:len() < 9 then
        return { r, g, b, 1 }
    end
    local a = tonumber(string.sub(hex, 8, 9), 16) / 256 
    return { r, g, b, a }
end

Utils.graphics = {}
function Utils.graphics.set_color_hex(hex)
    love.graphics.setColor(Utils.color.from_hex(hex))
end