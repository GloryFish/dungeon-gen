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

scenes.rect = Gamestate.new()

local rect = scenes.rect

function rect.enter(self, pre)
  self.rects = {
    Rectangle(vector(100, 100), vector(150, 250)),
    Rectangle(vector(400, 300), vector(150, 150)),
  }
  
  self.corridor = nil
  
  self.corridorWidth = 20
  
  self.corridor = self:generateCorridor(self.rects[1], self.rects[2], self.corridorWidth, self.corridorWidth + 20)
end

function rect.keypressed(self, key, unicode)
  if key == 'escape' then
    self:quit()
  end
  
  if key == 'c' then
    self:generateCorridor()
  end
end

function rect:generateCorridor(firstRect, secondRect, minWidth, maxWidth)
  if firstRect:intersects(secondRect) then
    return nil
  end

  local normal = secondRect:center() - firstRect:center()


  local left = math.max(firstRect.position.x, secondRect.position.x)
  local right = math.min(firstRect.position.x + firstRect.size.x, secondRect.position.x + secondRect.size.x)
  
  if left < right then
    local maxPossibleCorridorWidth = math.abs(left - right)
    
    if maxPossibleCorridorWidth >= minWidth then
      -- Choose a random corridor size between min and max
      local corridorWidth = minWidth
      if maxPossibleCorridorWidth > minWidth then
        corridorWidth = math.random(minWidth, maxPossibleCorridorWidth)
      end
      
      -- Select a random horizontal position on the first rects wall between the rightmost possible and leftmost possible positions
      local posX = math.random(left, right - corridorWidth)
      
      if normal.y < 0 then -- Up
        return Rectangle(vector(posX, secondRect.position.y + secondRect.size.y), 
                         vector(corridorWidth, firstRect.position.y - (secondRect.position.y + secondRect.size.y)))
      else -- Down
        return Rectangle(vector(posX, firstRect.position.y + firstRect.size.y), 
                         vector(corridorWidth, secondRect.position.y - (firstRect.position.y + firstRect.size.y)))
      end
      
    end
  end


  local top = math.max(firstRect.position.y, secondRect.position.y)
  local bottom = math.min(firstRect.position.y + firstRect.size.y, secondRect.position.y + secondRect.size.y)

  if top < bottom then
    local maxPossibleCorridorWidth = math.abs(top - bottom)

    if maxPossibleCorridorWidth >= minWidth then
      -- Choose a random corridor size between min and max
      local corridorWidth = minWidth
      if maxPossibleCorridorWidth > minWidth then
        corridorWidth = math.random(minWidth, maxPossibleCorridorWidth)
      end

      -- Select a random vertical position on the first rects wall between the highest possible and lowest possible positions
      local posY = math.random(top, bottom - corridorWidth)
      
      if normal.x < 0 then -- Left
        return Rectangle(vector(secondRect.position.x + secondRect.size.x, posY), 
                         vector(firstRect.position.x - (secondRect.position.x + secondRect.size.x), corridorWidth))
      else -- Right
        return Rectangle(vector(firstRect.position.x + firstRect.size.x, posY), 
                         vector(secondRect.position.x - (firstRect.position.x + firstRect.size.x), corridorWidth))
      end
    end
  end -- top < bottom


  -- At this point we can try more creative ways of making a corridor...
  
  return nil
end

function rect.mousepressed(self, x, y, button)
end

function rect.mousereleased(self, x, y, button)
end

function rect.update(self, dt)
  if love.mouse.isDown('l') then
    self.rects[1].position = vector(love.mouse.getX(), love.mouse.getY())
    self.corridor = self:generateCorridor(self.rects[1], self.rects[2], self.corridorWidth, self.corridorWidth + 20)
  end
end

function rect.draw(self)
  colors.blue:set()
  self.rects[1]:draw()
  colors.red:set()
  self.rects[2]:draw()
  
  if self.corridor ~= nil then
    colors.green:set()
    self.corridor:draw()
  else
    colors.red:set()
    love.graphics.print('No corridor', 20, 60)

    colors.gray:set()
    local firstCenter = self.rects[1]:center()
    local secondCenter = self.rects[2]:center()
    love.graphics.line(firstCenter.x, firstCenter.y, secondCenter.x, secondCenter.y)
  end
  
  colors.white:set()
  love.graphics.print('Rect Scene', 20, 20)
  local direction = self.rects[2]:center() - self.rects[1]:center()
  love.graphics.print(string.format('Direction: %s', tostring(direction)), 20, 40)
  
end

function rect.quit(self)
  Gamestate.switch(intro)
end

function rect.leave(self)
  
end