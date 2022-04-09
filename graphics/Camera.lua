require "Object"

local camera = require "hump/camera"
local vector = require "hump/vector"

Camera = Object:new{
  max_displacement = 200,
  max_velocity = 50
}

function Camera:init(pos, zoom)
  self.c = camera(pos:unpack())
  self.target_displacement = vector(0,0)
end

function Camera:Command(command, value)
  self.target_displacement = value * self.max_displacement
end

function Camera:GetPos()
  return vector(self.c:position())
end

function Camera:Update(dt, anchor_pos)
  
  local anchor_displacement = (anchor_pos - self:GetPos())

  if anchor_displacement:len() > self.max_displacement then
    local anchor_dir = anchor_displacement:normalized()
    self.c:lookAt((anchor_pos + anchor_dir*self.max_displacement):unpack())
  end

  local target = anchor_pos + self.target_displacement
  local curr_target_displacement = target - self:GetPos()
  local tomove = curr_target_displacement:len()
  tomove = math.min(dt*self.max_velocity, tomove)
  if tomove > 0.1 then
    curr_target_displacement:normalizeInplace()
    self.c:move((curr_target_displacement * tomove):unpack())
  end
end

function Camera:Attach()
  self.c:attach()
end

function Camera:Detach()
  self.c:detach()
end