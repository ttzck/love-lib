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

Ui = { root = {} }

local default_padding = { left = 0, right = 0, up = 0, down = 0 }
local set_color_hex = Utils.graphics.set_color_hex

Ui.draw_functions = {}

function Ui.draw_functions.rectangle(element)
   local style = element.style
   if element.mouse_inside and style.fill_hover then
      set_color_hex(style.fill_hover)
   else
      set_color_hex(style.fill)
   end
   local width = style.draw_width or style.width
   local height = style.draw_height or style.height
   local x = element.x + style.width / 2 - width / 2
   local y = element.y + style.height / 2 - height / 2
   if element.mouse_inside then
      x = x + (style.hover_offset_x or 0)
      y = y + (style.hover_offset_y or 0)
   end
   love.graphics.rectangle("fill", x, y, width, height, style.radius)
end

-- TODO: use coloredtext
function Ui.draw_functions.printf(element)
   local style = element.style
   local font = style.text.font or love.graphics.getFont()
   local _, lines = font:getWrap(element.text, style.width)
   local lineHeight = font:getLineHeight() * font:getHeight()
   local totalHeight = #lines * lineHeight
   local x = element.x
   local y = element.y + (style.height - totalHeight) / 2
   if element.mouse_inside then
      x = x + (style.hover_offset_x or 0)
      y = y + (style.hover_offset_y or 0)
   end
   set_color_hex(style.text.color)
   love.graphics.setFont(font)
   love.graphics.printf(element.text, x, y, style.width, style.text.align)
end

function Ui.draw_functions.image(element)
   local style = element.style
   local width = style.draw_width or style.width
   local height = style.draw_height or style.height
   local x = element.x + style.width / 2 - width / 2
   local y = element.y + style.height / 2 - height / 2
   if element.mouse_inside then
      x = x + (style.hover_offset_x or 0)
      y = y + (style.hover_offset_y or 0)
   end
   local image = element.image
   Utils.graphics.set_color_hex("#ffffff")
   love.graphics.draw(image, x, y, 0, width / image:getPixelWidth(), height / image:getPixelHeight())
end

function Ui.draw_functions.progress_bar(element)
   local x = element.x
   local y = element.y
   local style = element.style
   if style.highlight and style.delayed_ratio then
      Utils.graphics.set_color_hex(style.highlight)
      love.graphics.rectangle(
         "fill",
         x,
         y,
         style.width * style.delayed_ratio,
         style.height,
         math.min(style.radius, style.width * style.delayed_ratio)
      )
   end
   Utils.graphics.set_color_hex(style.progress)
   love.graphics.rectangle(
      "fill",
      x,
      y,
      style.width * style.ratio,
      style.height,
      math.min(style.radius, style.width * style.ratio)
   )
end

-- this will replace draw_functions
Ui.utils = {}

---draws a progress bar
---@param options {x : number, y : number, width : number, height : number, primary_color : color, secondary_color : color?, background_color : color, radius : number, primary_ratio : number, secondary_ratio : number}
function Ui.utils.progress_bar(options)
   Utils.graphics.set_color_hex(options.background_color)
   love.graphics.rectangle(
      "fill",
      options.x,
      options.y,
      options.width * options.primary_ratio,
      options.height,
      math.min(options.radius, options.width)
   )
   if options.secondary_color and options.secondary_ratio then
      Utils.graphics.set_color_hex(options.secondary_color)
      love.graphics.rectangle(
         "fill",
         options.x,
         options.y,
         options.width * options.secondary_ratio,
         options.height,
         math.min(options.radius, options.width * options.secondary_ratio)
      )
   end
   Utils.graphics.set_color_hex(options.primary_color)
   love.graphics.rectangle(
      "fill",
      options.x,
      options.y,
      options.width * options.primary_ratio,
      options.height,
      math.min(options.radius, options.width * options.primary_ratio)
   )
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
   element = element or Ui.root
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
   local cache = factory.cache
   for id, _ in pairs(cache) do
      cache[id].live = false
   end
   local input = factory.input(element)
   for id, obj in pairs(input) do
      if cache[id] == nil then
         cache[id] = { first_seen = love.timer.getTime() }
      end
      cache[id].input = obj
      cache[id].live = true
      cache[id].last_seen = love.timer.getTime()
   end
   -- update chache with output
   local nil_outputs = {}
   for id, entry in pairs(cache) do
      local output = factory.output(entry.input, entry.output, entry.live, entry.first_seen, entry.last_seen)
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
   for id, entry in pairs(cache) do
      element.children[id] = entry.output
   end
end

function Ui.build(element)
   element = element or Ui.root
   if element.factory then
      run_factory(element)
   end
   if element.children then
      for _, child in pairs(element.children) do
         Ui.build(child)
      end
   end
end

function Ui.layout(element)
   element = element or Ui.root
   if element.x == nil then
      element.x = 0
   end
   if element.y == nil then
      element.y = 0
   end
   if not element.children then
      return
   end
   local children = {}
   for _, child in pairs(element.children) do
      table.insert(children, child)
   end
   table.sort(children, function(a, b)
      return (a.order or 0) < (b.order or 0)
   end)
   local align = element.style.align or "left"
   local x, y = "x", "y"
   local width, height = "width", "height"
   local left, right = "left", "right"
   local up, down = "up", "down"
   if align == "up" or align == "vertical" or align == "down" then
      x, y = "y", "x"
      width, height = "height", "width"
      left, right = "up", "down"
      up, down = "left", "right"
   end
   -- get total width of children or
   local children_width = 0
   for _, child in ipairs(children) do
      local style = child.style
      local padding = style.padding or default_padding
      children_width = children_width + padding[left] + style[width] + padding[right]
   end
   -- initialize offset
   local offset = 0
   if align == "left" or align == "up" then
      offset = element[x]
   elseif align == "horizontal" or align == "vertical" then
      offset = element[x] + (element.style[width] - children_width) / 2
   elseif align == "right" or align == "down" then
      offset = element[x] + (element.style[width] - children_width)
   end
   -- place children
   for _, child in ipairs(children) do
      local style = child.style
      local padding = style.padding or default_padding
      offset = offset + padding[left]
      child[x] = offset
      offset = offset + style[width] + padding[right]
      -- TODO: alingment option for secondary axis
      child[y] = element[y] + padding[up]
   end
   for _, child in ipairs(children) do
      Ui.layout(child)
   end
end

local function recurse(func, element)
   local children = element.children or {}
   for _, child in pairs(children) do
      func(child)
   end
end

local function is_mouse_inside(element)
   local x1, y1 = element.x, element.y
   local x2, y2 = x1 + element.style.width, y1 + element.style.height
   local mouse_x, mouse_y = love.mouse.getX(), love.mouse.getY()
   return x1 <= mouse_x and mouse_x <= x2 and y1 <= mouse_y and mouse_y <= y2
end

function Ui.hover(element)
   element = element or Ui.root
   local mouse_was_inside = element.mouse_inside
   local mouse_is_inside = is_mouse_inside(element)
   if not mouse_was_inside and mouse_is_inside and element.hover then
      element:hover()
   end
   element.mouse_inside = mouse_is_inside
   recurse(Ui.hover, element)
end

function Ui.find_deepest_element(element, pred)
   local deepest_element
   if pred(element) then
      deepest_element = element
   end
   local children = element.children or {}
   for _, child in pairs(children) do
      deepest_element = Ui.find_deepest_element(child, pred) or deepest_element
   end
   return deepest_element
end

function Ui.find(element, id)
   return Ui.find_deepest_element(element, function(e)
      return e.id == id
   end)
end

function Ui.click(button, element)
   element = element or Ui.root
   local deepest_element = Ui.find_deepest_element(element, function(e)
      return e.click and is_mouse_inside(e)
   end)
   if deepest_element then
      deepest_element:click(button)
      return true
   end
   return false
end
