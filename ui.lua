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
---   hover: function
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
---| "horizontal" -- not supported
---| "vertical" -- not supported

Ui = {}

local default_padding = { left = 0, right = 0, up = 0, down = 0 }

Ui.draw_functions = {}

function Ui.draw_functions.rectangle(element)
   local style = element.style
   Utils.graphics.set_color_hex(style.fill)
   love.graphics.rectangle("fill", element.x, element.y, style.width, style.height, style.radius)
end

-- TODO: use coloredtext
function Ui.draw_functions.printf(element)
   local style = element.style
   Utils.graphics.set_color_hex(style.text.color)
   love.graphics.printf(element.text, element.x, element.y, style.width, style.align)
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

function Ui.layout(element)
   if element.x == nil then
      element.x = 0
   end
   if element.y == nil then
      element.y = 0
   end
   local children = element.children or {}
   if element.style.align == "left" then
      local x_offset = element.x
      for _, child in pairs(children) do
         local style = child.style
         local padding = style.padding or default_padding
         x_offset = x_offset + padding.left
         child.x = x_offset
         x_offset = x_offset + style.width + padding.right
         child.y = element.y + padding.up
      end
   end
   if element.style.align == "horizontal" then
      local total_width = 0
      for _, child in pairs(children) do
         local style = child.style
         local padding = style.padding or default_padding
         total_width = total_width + padding.left + style.width + padding.right
      end
      local x_offset = element.x + (element.style.width - total_width) / 2
      for _, child in pairs(children) do
         local style = child.style
         local padding = style.padding or default_padding
         x_offset = x_offset + padding.left
         child.x = x_offset
         x_offset = x_offset + style.width + padding.right
         child.y = element.y + padding.up
      end
   end
   for _, child in pairs(children) do
      Ui.layout(child)
   end
end
