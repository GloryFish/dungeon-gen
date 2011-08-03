-- 
--  main.lua
--  xenofarm
--  
--  Created by Jay Roberts on 2011-01-20.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'middleclass'
require 'middleclass-extras'

require 'gamestate'
require 'input'
require 'logger'

scenes = {}
require 'scenes/test'

function love.load()
  debug = true
  
  love.graphics.setCaption('Dungeon')
  love.filesystem.setIdentity('DUngeon')
  
  -- Seed random
  local seed = os.time()
  math.randomseed(seed);
  math.random(); math.random(); math.random()  

  fonts = {
    default        = love.graphics.newFont('resources/fonts/silkscreen.ttf', 24),
    small          = love.graphics.newFont('resources/fonts/silkscreen.ttf', 20),
    tiny           = love.graphics.newFont('resources/fonts/silkscreen.ttf', 14),
    button         = love.graphics.newFont('resources/fonts/silkscreen.ttf', 18),
    buttonSelected = love.graphics.newFont('resources/fonts/silkscreen.ttf', 20),
  }

  music = {
  }
  
  
  sounds = {
    menumove = love.audio.newSource('resources/sounds/menu_move.mp3', 'static'),
    menuselect = love.audio.newSource('resources/sounds/menu_select.mp3', 'static'),
  }
  
  input = Input()
  
  soundOn = true
  love.audio.setVolume(1)

  Gamestate.registerEvents()
  Gamestate.switch(scenes.test)
end

function love.update(dt)
end
