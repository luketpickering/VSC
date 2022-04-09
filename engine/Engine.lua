require "Object"

local vector = require "hump/vector"

require "graphics/Graphics"
require "graphics/Camera"

require "control/Joystick"

require "entities/Control_Print"
require "entities/Control_Draw"
require "entities/Wizard"
require "entities/Baddie"

Engine = Object:new{
  sprite_scale = 4,
  world_scale = 16*4 --px/m
}

function Engine:init()
  
  love.physics.setMeter(Engine.world_scale)

  self.World = love.physics.newWorld()

  Joystick:init()
  Graphics:init()

  Wizard:init(self.World, vector(40,40))
  Camera:init(Wizard:GetPos(), 4)

  Joystick:RegisterInputtable(Wizard, "left")
  Joystick:RegisterInputtable(Camera, "right")
  Joystick:RegisterInputtable(Control_Print, "all")
  Joystick:RegisterInputtable(Control_Draw, "all")

  Baddie:init(self.World, vector(10,10))
end

function love.update(dt)
  Engine.World:update(dt)

  Baddie:Command()
  Baddie:Update()

  Joystick:Poll()
  Wizard:Update()
  Camera:Update(dt, Wizard:GetPos())

end

function love.draw()
  Camera:Attach()
  -- Control_Draw:Draw()
  Wizard:Draw()
  Baddie:Draw()
  Camera:Detach()
end