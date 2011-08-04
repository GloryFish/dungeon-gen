-- 
--  dungeons.lua
--  dungeon-gen
--  
--  Created by Jay Roberts on 2011-08-03.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 


require 'vector'
require 'middleclass'
require 'rectangle'


DungeonNode = class('DungeonNode')
function DungeonNode:initialize(parent, rect)
  self.parent = parent
  self.rect = rect
  self.children = {}
end

function DungeonNode:draw()
  self.rect:draw()
  if self.children[1] ~= nil then
    self.children[1]:draw()
  end
  if self.children[2] ~= nil then
    self.children[2]:draw()
  end
end


DungeonGenerator = class('DungeonGenerator')
function DungeonGenerator:initialize()
end

function DungeonGenerator:generate(seed, size, maxDepth, minRoomSize)
  math.randomseed(seed);
  math.random(); math.random(); math.random()
    
  self.size = size
  self.maxDepth = maxDepth
  self.minRoomSize = minRoomSize
  
  self.rootNode = DungeonNode(nil, Rectangle(vector(0, 0), size))
  
  self:split(self.rootNode)
end

function DungeonGenerator:split(node, currentDepth)
  local depth = currentDepth
  if depth == nil then
    depth = 1
  else
    depth = depth + 1
  end
  
  assert(depth ~= nil, 'depth is nil')
  assert(self.maxDepth ~= nil, 'maxDepth is nil')
  
  if depth > self.maxDepth then
    return
  end
  

  -- Split into two rectangles
  local firstRect = {}
  local secondRect = {}

  local direction = math.random()
  if direction < 0.5 then -- Horizontal
    local splitY = math.random(0.2 * node.rect.size.y, 0.8 * node.rect.size.y)
    -- local splitY = node.rect.size.y / 2
    
    firstRect = Rectangle(vector(node.rect.position.x + 1, 
                                 node.rect.position.y + 1), 
                          vector(node.rect.size.x - 2, 
                                 splitY - 2))

    secondRect = Rectangle(vector(node.rect.position.x + 1, 
                                  node.rect.position.y + splitY + 1), 
                           vector(node.rect.size.x - 2, 
                                  node.rect.size.y - splitY - 2))
  else
    local splitX = math.random(0.2 * node.rect.size.x, 0.8 * node.rect.size.x)
    -- local splitX = node.rect.size.x / 2
    
    firstRect = Rectangle(vector(node.rect.position.x + 1, 
                                 node.rect.position.y + 1), 
                          vector(splitX - 1, 
                                 node.rect.size.y - 2))

    secondRect = Rectangle(vector(node.rect.position.x + splitX + 1, 
                                  node.rect.position.y + 1), 
                           vector(node.rect.size.x - splitX - 2, 
                                  node.rect.size.y - 2))
  end

  -- create nodes for them, add them as children
  node.children[1] = DungeonNode(node, firstRect)
  node.children[2] = DungeonNode(node, secondRect)
  
  -- split the children
  self:split(node.children[1], depth)
  self:split(node.children[2], depth)
end

function DungeonGenerator:draw()
  if self.rootNode ~= nil then
    self.rootNode:draw()
  end
end