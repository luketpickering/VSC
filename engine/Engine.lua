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
}

function Engine:init()
  
  self.sprite_scale = 2
  self.world_scale = 16 --px/m

  love.physics.setMeter(Engine.world_scale)

  self.World = love.physics.newWorld()

  self.window = {}
  self.window.width, self.window.height, self.window.flags = love.window.getMode()

  Control:init()
  Graphics:init()
  Background:init()

  if Control.itype == "joystick" then
    self.left_stick_overlay = Radial:new{
      x = 50, 
      y = self.window.height-70,
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
      y = self.window.height-70,
      r = 30,
      v = {r=0, th=0},
      bc = {1,1,1,0.4}, 
      fc = {0,0,1,0.7},
      Command = function(self, command, value)
        self:Set(value)
      end
    }

    Control:Register(self.left_stick_overlay, "left")
    Control:Register(self.right_stick_overlay, "right")
  end

  Wizard:init(self.World)
  Camera:init(Wizard:GetPos(), self.sprite_scale)

  Control:Register(Wizard, {"move", "rewind"} )

  Control:Register(Camera, {"move_camera", "zoom"})
  Control:Register(Control_Print, "all")

  Baddie:init(self.World, vector(50,50))
end

function love.update(dt)
  Engine.World:update(dt)

  Baddie:Command()
  Baddie:Update()

  Control:Poll()
  Wizard:Update(dt)
  Camera:Update(dt, Wizard:GetPos())

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
  Baddie:Draw()

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

  Graphics:PrintRight(string.format("Input: %s", Control.itype), 
    Engine.window.width - 20, 20)

end