-- TODO: turn this into proper documentation

--- element : {
---   x : number,
---   y: number,
---   id : string
---   text : string
---   style :
---   children : table
---   factory : {
---      input : function # takes the element, returns a table with stable ids as keys and the input objects as values
---      output : function # takes input object, the corresponding ui element (nil if first added to cache), the time when it was first added to cache, and the time when it was last seen. returns an element that will be a child or nil (then the input object will be removed from cache)
---   }
---   draw : function
---   click : function
---   hover: boolean
---}

--- style : {
---   width : number
---   height : number
---   radius: number
---   padding : {
---      left : number
---      right : number
---      up : number
---      down : number
---   }
---   align : Ui.alignment
---   fill : color
---   text : {
---      color : color
---      font : font
---      align : love.AlignMode
---   }
--- }

--- @alias Ui.alignment
---| "left"
---| "right"
---| "up"
---| "down"
---| "horizontal"
---| "vertical"

Ui = {}

local default_padding = { left = 0, right = 0, up = 0, down = 0 }
local set_color_hex = Utils.graphics.set_color_hex

Ui.draw_functions = {}

function Ui.draw_functions.rectangle(element)
   local style = element.style
   if element.hover and style.fill_hover then
      set_color_hex(style.fill_hover)
   else
      set_color_hex(style.fill)
   end
   local width = style.draw_width or style.width
   local height = style.draw_height or style.height
   local x = element.x + style.width / 2 - width / 2
   local y = element.y + style.height / 2 - height / 2
   love.graphics.rectangle("fill", x, y, width, height, style.radius)
end

-- TODO: use coloredtext
function Ui.draw_functions.printf(element)
   local style = element.style
   local font = style.text.font or love.graphics.getFont()
   local _, lines = font:getWrap(element.text, style.width)
   local lineHeight = font:getLineHeight() * font:getHeight()
   local totalHeight = #lines * lineHeight
   local y = element.y + (style.height - totalHeight) / 2
   set_color_hex(style.text.color)
   love.graphics.setFont(font)
   love.graphics.printf(element.text, element.x, y, style.width, style.text.align)
end

function Ui.draw_functions.compose(...)
   local funcs = { ... }
   return function(element)
      for _, func in ipairs(funcs) do
         func(element)
      end
   end
end

function Ui.draw(element)
   if element.draw then
      element:draw()
   end
   if element.children then
      for _, child in pairs(element.children) do
         Ui.draw(child)
      end
   end
end

local function run_factory(element)
   local factory = element.factory
   if factory.cache == nil then
      factory.cache = {}
   end
   -- update cache with input
   local input = factory.input(element)
   local cache = factory.cache
   for id, obj in pairs(input) do
      if cache[id] == nil then
         cache[id] = { first_seen = love.timer.getTime() }
      end
      cache[id].input = obj
      cache[id].last_seen = love.timer.getTime()
   end
   -- update chache with output
   local nil_outputs = {}
   for id, entry in pairs(cache) do
      local output = factory.output(entry.input, entry.output, entry.first_seen, entry.last_seen)
      cache[id].output = output
      if output == nil then
         nil_outputs[id] = true
      end
   end
   -- chache clean-up
   for id, _ in pairs(nil_outputs) do
      cache[id] = nil
   end
   -- create children
   element.children = {}
   local children = element.children
   -- TODO: sort children by a order defined by output
   for id, entry in pairs(cache) do
      element.children[id] = entry.output
   end
end

function Ui.build(element)
   if element.factory then
      run_factory(element)
      for _, child in pairs(element.children) do
         Ui.build(child)
      end
   end
end

-- TODO: align up, down, vertical (generalize x, y to axis1, axis2)
function Ui.layout(element)
   if element.x == nil then
      element.x = 0
   end
   if element.y == nil then
      element.y = 0
   end
   local children = element.children or {}
   -- get total width of children
   local total_width = 0
   for _, child in pairs(children) do
      local style = child.style
      local padding = style.padding or default_padding
      total_width = total_width + padding.left + style.width + padding.right
   end
   -- initialize offset
   local align = element.style.align
   local x_offset = 0
   if align == "left" then
      x_offset = element.x
   elseif align == "horizontal" then
      x_offset = element.x + (element.style.width - total_width) / 2
   elseif align == "right" then
      x_offset = element.x + (element.style.width - total_width)
   end
   -- place children
   for _, child in pairs(children) do
      local style = child.style
      local padding = style.padding or default_padding
      x_offset = x_offset + padding.left
      child.x = x_offset
      x_offset = x_offset + style.width + padding.right
      child.y = element.y + padding.up
   end
   for _, child in pairs(children) do
      Ui.layout(child)
   end
end

local function recurse(func, element)
   local children = element.children or {}
   for _, child in pairs(children) do
      func(child)
   end
end

function Ui.hover(element)
   local x1, y1 = element.x, element.y
   local x2, y2 = x1 + element.style.width, y1 + element.style.height
   local mouse_x, mouse_y = love.mouse.getX(), love.mouse.getY()
   element.hover = x1 <= mouse_x and mouse_x <= x2 and y1 <= mouse_y and mouse_y <= y2
   recurse(Ui.hover, element)
end
