require "Object"

local vector = require "hump/vector"

require "graphics/Graphics"
require "graphics/Camera"
require "graphics/Background"

require "graphics/UI/Radial"

require "control/Control"

require "entities/Control_Print"
require "entities/Wizard"
require "entities/Baddie"

Engine = Object:new{
  sprite_scale = 2,
  world_scale = 16 --px/m
}

function Engine:init()

  love.physics.setMeter(Engine.world_scale)

  self.World = love.physics.newWorld()

  self.window = {}
  self.window.width, self.window.height, self.window.flags = love.window.getMode()

  Control:init()
  Graphics:init()
  Background:init()

  if Control.itype == ControlTypes.JOYSTICK then
    self.left_stick_overlay = Radial:new{
      x = 50, 
      y = self.window.height - 70,
      r = 30,
      v = {r=0, th=0},
      bc = {1,1,1,0.4}, 
      fc = {1,0,0,0.7},
      Command = function(self, command, value)
        self:Set(value)
      end
    }

    self.right_stick_overlay = Radial:new{
      x = self.window.width - 70, 
      y = self.window.height - 70,
      r = 30,
      v = {r=0, th=0},
      bc = {1,1,1,0.4}, 
      fc = {0,0,1,0.7},
      Command = function(self, command, value)
        self:Set(value)
      end
    }

    Control:Register(self.left_stick_overlay, Commands.MOVE)
    Control:Register(self.right_stick_overlay, Commands.MOVE_CAMERA)
  end

  self.Baddies = {}

  for i = 1, 10 do
    self.Baddies[i] = Baddie:new{}
    self.Baddies[i]:init(self.World, 
      Assets:GetCharacterAssets(25, 3),
      vector.randomDirection(100,200))
    self.Baddies[i].next_state = DynamicBodyStates.ALIVE_RECORDING
    AI:Attach(self.Baddies[i])
  end 

  Wizard:init(self.World, Assets:GetCharacterAssets(25, 4))
  Wizard.next_state = DynamicBodyStates.ALIVE_RECORDING

  Camera:init(Wizard:GetPos(), self.sprite_scale)

  Control:Register(Wizard, {Commands.MOVE, Commands.REWIND} )
  Control:Register(AI, {Commands.REWIND} )

  Control:Register(Camera, {Commands.MOVE_CAMERA, Commands.ZOOM})
  Control:Register(Control_Print, Commands.ANY)
end

function Engine:Update(dt)
  self.World:update(dt)

  Control:Poll()

  Wizard:Update(dt)

  Camera:Update(dt, Wizard:GetPos())

  AI:Update(Wizard)
  for i = 1, 10 do
    self.Baddies[i]:Update(dt)
  end
end

function love.update(dt)
  Engine:Update(dt)
end

function Engine:pxtom(px)
  return px / self.world_scale
end

function Engine:mtopx(m)
  return m * self.world_scale
end

function love.draw()
  Camera:Attach()
  Background:Draw(Wizard:GetPos(), 
    Wizard:GetPos() - vector(Engine.window.width/(2*Engine.sprite_scale),
    Engine.window.height/(2*Engine.sprite_scale)))

  Wizard:Draw()

  for _,b in pairs(Engine.Baddies) do
    b:Draw()
  end

  -- Draw the origin
  Graphics:PushColor({1,0,0})
  love.graphics.rectangle("line", -5, -5, 10, 10)
  Graphics:PopColor()

  Camera:Detach()

  Graphics:PushColor({1,0,0, 0.5})
  local Wizard_pos_screen = Camera:CameraCoords(Wizard:GetPos())
  Graphics:PrintLeft(string.format("Pos: (%.2f,%.2f)", Wizard:GetPos():unpack()), 
    Wizard_pos_screen.x + 24, Wizard_pos_screen.y - 16)
  Graphics:PrintLeft(string.format("Vel: (%.2f,%.2f)", Wizard:GetVel():unpack()), 
    Wizard_pos_screen.x + 24, Wizard_pos_screen.y)
  Graphics:PopColor()

  if Engine.left_stick_overlay then
    Engine.left_stick_overlay:Draw()
    Engine.right_stick_overlay:Draw()
  end

  local vstart_cam = vector(100 ,10)
  local vworld_start = Camera:WorldCoords(vstart_cam)
  local vworld_end = vworld_start:clone()
  vworld_end.x = vworld_end.x + Engine:mtopx(10) --m
  local vend_cam = Camera:CameraCoords(vworld_end)

  love.graphics.line(vstart_cam.x, vstart_cam.y, vend_cam.x, vend_cam.y)
  love.graphics.line(vstart_cam.x, vstart_cam.y-2, vstart_cam.x, vstart_cam.y+2)
  love.graphics.line(vend_cam.x, vend_cam.y-2, vend_cam.x, vend_cam.y+2)

  local midline = (vstart_cam + vend_cam)/2
  midline.y = midline.y + 10
  Graphics:Print(string.format("10m = %spx", 
    math.floor(vend_cam.x - vstart_cam.x + 0.5)), midline:unpack())

  Graphics:PrintRight(string.format("Input: %s", ControlTypes.tostring(Control.itype)), 
    Engine.window.width - 20, 20)

  Graphics:PushColor({1,0,0})
  love.graphics.rectangle("line", 20, Engine.window.height - 40, 
    Engine.window.width * 0.8 , 5)

  love.graphics.rectangle("fill", 20, Engine.window.height - 40, 
    (Engine.window.width * 0.8) * 
      Wizard.fine_state_history:Size() /
        Wizard.fine_state_history.capacity, 
    5)

  Graphics:PopColor()
  Graphics:PushColor({0,0,1})
  love.graphics.rectangle("line", 20, Engine.window.height - 20, 
    Engine.window.width * 0.8 , 5)

  love.graphics.rectangle("fill", 20, Engine.window.height - 20, 
    (Engine.window.width * 0.8) * 
      Wizard.coarse_state_history:Size() /
        Wizard.coarse_state_history.capacity, 
    5)
  Graphics:PopColor()

end