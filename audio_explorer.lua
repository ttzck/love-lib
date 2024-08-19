AudioExplorer = {
   path = "",
}

local audio, n, i, prints
function AudioExplorer.load()
   audio, prints = {}, {}
   n, i = 0, 1
   local files = love.filesystem.getDirectoryItems(AudioExplorer.path)
   for _, file in ipairs(files) do
      n = n + 1
      local info = love.filesystem.getInfo(file)
      local path = AudioExplorer.path .. "/" .. file
      audio[n] = {
         file = file,
         source = love.audio.newSource(path, "static"),
         path = path,
      }
   end
end

function AudioExplorer.draw()
   if n > 0 then
      love.graphics.print(audio[i].path, 10, 10)
   end

   local y = 50
   for k, _ in pairs(prints) do
      love.graphics.print(audio[k].file, 10, y)
      y = y + 20
   end
end

function AudioExplorer.keypressed(key)
   if n > 0 then
      audio[i].source:stop()
      if key == "j" and i < n then
         i = i + 1
      end
      if key == "k" and i > 1 then
         i = i - 1
      end
      if key == "s" then
         prints[i] = not prints[i] or nil
      end
      if key == "q" then
         for k, _ in pairs(prints) do
            print(audio[k].file:sub(1, -5):upper() .. " = love.audio.newSource('" .. audio[k].path .. "', 'static')")
         end
         love.event.quit()
      end
      audio[i].source:play()
   end
end
