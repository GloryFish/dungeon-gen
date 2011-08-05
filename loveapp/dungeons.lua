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
    
  assert(size ~= nil, "size must not be nil")
  assert(vector.isvector(size), "size must be a vector")
  
  self.size = size
  self.maxDepth = maxDepth
  self.minRoomSize = minRoomSize
  
  self.rootNode = DungeonNode(nil, Rectangle(vector(1, 1), size))
  
  self:split(self.rootNode)
  return self:renderBSP(self.rootNode)
end

-- Traverse a BSP and render it's contents to a 2D array
function DungeonGenerator:renderBSP(node)
  -- Create a blank array of solid tiles
 self.tiles = {}
 for x = 1, self.size.x do
   for y = 1, self.size.y do
     if self.tiles[x] == nil then
       self.tiles[x] = {}
     end
     self.tiles[x][y] = '#'
   end
 end
 
 self:createRoom(node)
 
 return self.tiles
end

-- Adds a room, to a node. If the nod eis not a leaf node, it tries to add a room to the node's children.
function DungeonGenerator:createRoom(node)
  assert(node ~= nil, "node must not be nil")
  assert(node.rect ~= nil, "node must have a rect")
  
  if #node.children == 0 then
    local roomRect = self:getSmallerRect(node.rect, self.minRoomSize)
    assert(roomRect.position.x < roomRect.position.x + roomRect.size.x)
    assert(roomRect.position.y < roomRect.position.y + roomRect.size.y)
    
    
    for x = roomRect.position.x, roomRect.position.x + roomRect.size.x do
      for y = roomRect.position.y, roomRect.position.y + roomRect.size.y do
        assert(x ~= 0, string.format('x: %i, %s, %s', x, tostring(roomRect.position), tostring(roomRect.size)))
        assert(y ~= 0, string.format('y: %i, %s, %s', y, tostring(roomRect.position), tostring(roomRect.size)))
        self.tiles[x][y] = ' '
      end
    end
    return
  end
  
  if node.children[1] ~= nil then
    self:createRoom(node.children[1])
  end  
  if node.children[2] ~= nil then
    self:createRoom(node.children[2])
  end  
end

function DungeonGenerator:getSmallerRect(rect, minSize)
  local newSize = vector(0, 0)
  if minSize.x >= rect.size.x then
    newSize.x = minSize.x
  else
    newSize.x = math.random(minSize.x, rect.size.x)
  end
  if minSize.y >= rect.size.y then
    newSize.y = minSize.y
  else
    newSize.y = math.random(minSize.y, rect.size.y)
  end


  local newPosition = vector(0, 0)

  if rect.position.x + 1 >= rect.position.x + rect.size.x - newSize.x - 1 then
    newPosition.x = rect.position.x + 1
  else
    newPosition.x = math.random(rect.position.x + 1, rect.position.x + rect.size.x - newSize.x - 1)
  end

  if rect.position.y + 1 >= rect.position.y + rect.size.y - newSize.y - 1 then
    newPosition.y = rect.position.y + 1
  else
    newPosition.y = math.random(rect.position.y + 1, rect.position.y + rect.size.y - newSize.y - 1)
  end
  
  return Rectangle(newPosition, newSize)
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
    local splitY = math.random(0.3 * node.rect.size.y, 0.7 * node.rect.size.y)
    -- local splitY = node.rect.size.y / 2
    
    firstRect = Rectangle(vector(node.rect.position.x, 
                                 node.rect.position.y), 
                          vector(node.rect.size.x, 
                                 splitY))

    secondRect = Rectangle(vector(node.rect.position.x, 
                                  node.rect.position.y + splitY), 
                           vector(node.rect.size.x , 
                                  node.rect.size.y - splitY))
  else
    local splitX = math.random(0.3 * node.rect.size.x, 0.7 * node.rect.size.x)
    -- local splitX = node.rect.size.x / 2
    
    firstRect = Rectangle(vector(node.rect.position.x , 
                                 node.rect.position.y), 
                          vector(splitX, 
                                 node.rect.size.y))

    secondRect = Rectangle(vector(node.rect.position.x + splitX, 
                                  node.rect.position.y), 
                           vector(node.rect.size.x - splitX, 
                                  node.rect.size.y))
  end

  -- create nodes for them, add them as children
  node.children[1] = DungeonNode(node, firstRect)
  node.children[2] = DungeonNode(node, secondRect)
  
  -- split the children if they are big enough
  if firstRect.size.x > self.minRoomSize.x + 2 and firstRect.size.y > self.minRoomSize.y + 2 then
    self:split(node.children[1], depth)
  end
  
  if secondRect.size.x > self.minRoomSize.x + 2 and secondRect.size.y > self.minRoomSize.y + 2 then
    self:split(node.children[2], depth)
  end
end

function DungeonGenerator:draw()
  if self.rootNode ~= nil then
    self.rootNode:draw()
  end
end