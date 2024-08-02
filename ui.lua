--- element : {
---   id : string
---   children : table
---   factory : {
---      input : function # takes the element, returns a table with stable ids as keys and the input objects as values
---      output : function # takes input object, the time when it was first added to cache, and the time when it was last seen, returns an element that will be a child or nil (then the input object will be removed from cache)
---   }
---   draw : function
---   click : function
---   hover: function
---}

--- style : {
---   width : [0..]
---   height : [0..]
---   radius: [0..]
---   padding : {
---      left : [0..]
---      right : [0..]
---      bottom : [0..]
---      top : [0..]
---   }
---   align : left | right| bottom | top | horizontal | vertical
---   fill : color
---   text : {
---      color : color
---      font : font
---   }
--- }

Ui = { draw = {} }

function Ui.draw.rectangle(element, style)
   love.graphics.rectangle("fill", element.x, element.y, style.width, style.height)
end

local function run_factory(element)
   local factory = element.factory
   if factory.cache == nil then
      factory.cache = {}
   end
   -- collect inputs
   local input = element.factory.input(element)
   local cache = factory.cache
   for id, obj in pairs(input) do
      if cache[id] == nil then
         cache[id] = { first_seen = love.timer.getTime() }
      end
      cache[id].obj = obj
      cache[id].last_seen = love.timer.getTime()
   end
   -- create children
   element.children = {}
   local children = element.children
   local nil_ids = {}
   for id, cache_obj in pairs(cache) do
      local output = factory.output(cache_obj)
      if output then
         children[id] = output
      else
         nil_ids[id] = true
      end
   end
   -- clean-up
   for id, _ in pairs(nil_ids) do
      cache[id] = nil
   end
end

function Ui.layout(element) end
