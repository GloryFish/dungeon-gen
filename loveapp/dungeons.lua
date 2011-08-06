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
  self.rect = rect -- A rect representing the BSP division for this node
  self.room = nil -- A rect that is a sub region of rect. The actual room.
  self.corridor = nil -- A rect representing a corridor connecting the rooms of the children
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

function DungeonGenerator:generate(seed, size, maxDepth, minRoomSize, minCorridorWidth, maxCorridorWidth)
  math.randomseed(seed);
  math.random(); math.random(); math.random()
    
  assert(size ~= nil, "size must not be nil")
  assert(vector.isvector(size), "size must be a vector")
  
  self.size = size
  self.maxDepth = maxDepth
  self.minRoomSize = minRoomSize
  self.minCorridorWidth = minCorridorWidth
  self.maxCorridorWidth = maxCorridorWidth
  
  self.rootNode = DungeonNode(nil, Rectangle(vector(0, 0), size))
  
  self:split(self.rootNode)
  return self:renderBSP(self.rootNode)
end

-- Traverse a BSP and render it's contents to a 2D array
function DungeonGenerator:renderBSP(node)
  -- Create a blank array of solid tiles
 self.tiles = {}
 for x = 1, self.size.x + 1 do
   for y = 1, self.size.y + 1 do
     if self.tiles[x] == nil then
       self.tiles[x] = {}
     end
     self.tiles[x][y] = '#'
   end
 end
 
 self:createRooms(node)
 self:createCorridors(node)
 
 return self.tiles
end

-- Adds a room, to a node. If the node is not a leaf node, it tries to add rooms to the node's children.
function DungeonGenerator:createRooms(node)
  assert(node ~= nil, "node must not be nil")
  assert(node.rect ~= nil, "node must have a rect")
  
  if #node.children == 0 then
    node.room = self:roomForNode(node)
    
    -- Draw containing rect
    for x = node.rect.position.x, node.rect.position.x + node.rect.size.x do
      for y = node.rect.position.y, node.rect.position.y + node.rect.size.y do
        self.tiles[x + 1][y + 1] = '-'
      end
    end
    
    -- Draw room
    for x = node.room.position.x, node.room.position.x + node.room.size.x do
      for y = node.room.position.y, node.room.position.y + node.room.size.y do
        self.tiles[x + 1][y + 1] = ' '
      end
    end
    return
  end
  
  if node.children[1] ~= nil then
    self:createRooms(node.children[1])
  end  
  if node.children[2] ~= nil then
    self:createRooms(node.children[2])
  end  
end

function DungeonGenerator:roomForNode(node)
  assert(node ~= nil, 'node is nil')
  assert(node.rect ~= nil, 'node.rect is nil')

  local size = vector(math.random(self.minRoomSize.x, node.rect.size.x - 2), math.random(self.minRoomSize.y, node.rect.size.y - 2))
  -- local size = vector(math.floor(node.rect.size.x / 2), math.floor(node.rect.size.y / 2))

  local position = vector(math.random(node.rect.position.x + 1, node.rect.position.x + node.rect.size.x - size.x - 1),
                          math.random(node.rect.position.y + 1, node.rect.position.y + node.rect.size.y - size.y - 1))

  return Rectangle(position, size)
end

-- Adds a corridor connecting two nodes
function DungeonGenerator:createCorridors(node)
  assert(node ~= nil, "node must not be nil")
  assert(#node.children == 2, "node must have two children")


  local firstRoom = self:getRandomRoomForNode(node.children[1])
  local secondRoom = self:getRandomRoomForNode(node.children[2])

  node.corridor = self:generateCorridor(firstRoom, secondRoom, self.minCorridorWidth, self.maxCorridorWidth)

  -- Draw corridor
  if node.corridor ~= nil then
    for x = node.corridor.position.x, node.corridor.position.x + node.corridor.size.x do
      for y = node.corridor.position.y, node.corridor.position.y + node.corridor.size.y do
        self.tiles[x + 1][y + 1] = ' '
      end
    end
  end

  if #node.children[1].children == 2 then
    self:createCorridors(node.children[1])
  end
  
  if #node.children[2].children == 2 then
    self:createCorridors(node.children[2])
  end
end

function DungeonGenerator:getRandomRoomForNode(node)
  if #node.children == 0 then
    return node.room
  else
    return self:getRandomRoomForNode(node.children[math.random(1, 2)])
  end
end

function DungeonGenerator:generateCorridor(firstRect, secondRect, minWidth, maxWidth)
  if firstRect:intersects(secondRect) then
    assert(false, string.format('intersect: %s, %s - %s, %s', tostring(firstRect.position), tostring(firstRect.size), tostring(secondRect.position), tostring(secondRect.size)))
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
  
  -- Ensure that the node can fit two minSized rooms
  if node.rect.size.x < self.minRoomSize.x * 2 or 
     node.rect.size.y < self.minRoomSize.y then
     return
  end

  -- Split into two rectangles
  local firstRect = {}
  local secondRect = {}

  local direction = math.random()
  if direction < 0.5 then -- Horizontal
    -- local splitY = math.random(0.4 * node.rect.size.y, 0.6 * node.rect.size.y)
    local splitY = math.floor(node.rect.size.y / 2)
    
    firstRect = Rectangle(vector(node.rect.position.x, 
                                 node.rect.position.y), 
                          vector(node.rect.size.x, 
                                 splitY))

    secondRect = Rectangle(vector(node.rect.position.x, 
                                  node.rect.position.y + splitY), 
                           vector(node.rect.size.x , 
                                  node.rect.size.y - splitY))
  else
    -- local splitX = math.random(0.4 * node.rect.size.x, 0.6 * node.rect.size.x)
    local splitX = math.floor(node.rect.size.x / 2)
    
    firstRect = Rectangle(vector(node.rect.position.x , 
                                 node.rect.position.y), 
                          vector(splitX, 
                                 node.rect.size.y))

    secondRect = Rectangle(vector(node.rect.position.x + splitX, 
                                  node.rect.position.y), 
                           vector(node.rect.size.x - splitX, 
                                  node.rect.size.y))
  end

  
  if firstRect.size.x > self.minRoomSize.x and firstRect.size.y > self.minRoomSize.y then
    node.children[1] = DungeonNode(node, firstRect)
    self:split(node.children[1], depth)
  end
  
  if secondRect.size.x > self.minRoomSize.x and secondRect.size.y > self.minRoomSize.y then
    node.children[2] = DungeonNode(node, secondRect)
    self:split(node.children[2], depth)
  end
end

function DungeonGenerator:draw()
  if self.rootNode ~= nil then
    self.rootNode:draw()
  end
end