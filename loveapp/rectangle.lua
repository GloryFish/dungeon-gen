-- 
--  rectangle.lua
--  dungeon-gen
--  
--  Created by Jay Roberts on 2011-08-03.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'middleclass'
require vector

Rectangle = class('Rectangle')
function Rectangle:initialize(position, size)
  assert(isvector(position), 'position must be a vector')
  assert(isvector(size), 'size must be a vector')
  
  self.position = position
  self.size = size
end

function Rectangle:contains(point)
  return point.x >= self.position.x and
         point.y >= self.position.y and
         point.x <= self.position.x + self.size.width and
         point.y <= self.position.y + self.size.height
     
end

function Rectangle:intersects(rect)
  return not (rect.position.x > self.position.x + self.size.width or
              rect.position.x + rect.size.width < self.position.x or
              rect.position.y > self.position.y + self.size.height or
              rect.position.y + rect.size.height < self.position.y)
end