-- 
--  scene_itemviewer.lua
--  desert
--  
--  Created by Jay Roberts on 2011-03-18.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'logger'
require 'vector'
require 'colors'
require 'rectangle'
require 'dungeons'

scenes.test = Gamestate.new()

local test = scenes.test

function test.enter(self, pre)
  self.generator = DungeonGenerator()
  
  self.tiles = nil
  self.offset = vector(0, 0)
  self.cameraSpeed = 40
  self.scale = 1
end

function test.keypressed(self, key, unicode)
  if key == 'escape' then
    self:quit()
  end
  
  if key == 'g' then
    self:generate()
  end

  if key == 'up' then
    self.offset.y = self.offset.y - self.cameraSpeed
  end
  if key == 'down' then
    self.offset.y = self.offset.y + self.cameraSpeed
  end
  if key == 'left' then
    self.offset.x = self.offset.x - self.cameraSpeed
  end
  if key == 'right' then
    self.offset.x = self.offset.x + self.cameraSpeed
  end

end

function test:generate()
  self.tiles = self.generator:generate(os.time() + math.random(), vector(100, 100), 3, vector(10, 10))
end

function test.mousepressed(self, x, y, button)
  if button == 'wu' then
    self.scale = self.scale + 0.1
    if self.scale > 3 then
      self.scale = 3
    end
  end

  if button == 'wd' then
    self.scale = self.scale - 0.1
    if self.scale < 0.5 then
      self.scale = 0.5
    end
  end  
end

function test.mousereleased(self, x, y, button)
end

function test.update(self, dt)
 
end

function test.draw(self)
  colors.white:set()
  love.graphics.print('Test Scene', 20, 20)
  
  
  love.graphics.push()
  
  love.graphics.translate(self.offset.x, self.offset.y)
  love.graphics.scale(self.scale, self.scale)
  
  love.graphics.setLineWidth(1)

  local tileSize = 16
  if self.tiles ~= nil then
    for x = 0, #self.tiles - 1 do
      for y = 0, #self.tiles[1] - 1 do
        if self.tiles[x + 1][y + 1] == '#' then
          colors.green:set()
        elseif self.tiles[x + 1][y + 1] == '-' then
          colors.red:set()
        else
          colors.grey:set()
        end
        love.graphics.rectangle('line', x * tileSize, y * tileSize, tileSize, tileSize)
      end
    end
  end
  
  love.graphics.push()
  love.graphics.scale(tileSize, tileSize)
  colors.red:set()
  love.graphics.pop()
  
  love.graphics.pop()
  
end

function test.quit(self)
  Gamestate.switch(intro)
end

function test.leave(self)
end