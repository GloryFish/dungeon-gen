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

scenes.test = Gamestate.new()

local test = scenes.test

function test.enter(self, pre)
 self.rect = Rectangle(vector(20, 40), vector(150, 200))
end

function test.keypressed(self, key, unicode)
  if key == 'escape' then
    self:quit()
  end
end

function test.mousepressed(self, x, y, button)
end

function test.mousereleased(self, x, y, button)
end

function test.update(self, dt)
 
end

function test.draw(self)
  colors.white:set()
  love.graphics.print('Test Scene', 20, 20)
  
  self.rect:draw()
end

function test.quit(self)
  Gamestate.switch(intro)
end

function test.leave(self)
end