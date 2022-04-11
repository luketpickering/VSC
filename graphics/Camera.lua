require "Object"

require "utils/math"
require "utils/console"

local camera = require "hump/camera"
local vector = require "hump/vector"

Camera = Object:new{
  max_displacement = 200,
  max_velocity = 200
}

function Camera:init(pos, zoom)
  self.cam = camera(pos:unpack())
  self.target_displacement = vector(0,0)

  self.zoom = zoom
  self.target_zoom = zoom
  self.max_zps = 1
end

function Camera:Command(command, value)
  if command == "right" then
    self.target_displacement = value * self.max_displacement
  elseif command == "triggerright" then
    self.target_zoom = 2 - 1.2*value
  end
end

function Camera:GetPos()
  return vector(self.cam:position())
end

function Camera:WorldCoords(v)
  return vector(self.cam:worldCoords(v:unpack()))
end

function Camera:CameraCoords(v)
  return vector(self.cam:cameraCoords(v:unpack()))
end

function Camera:Update(dt, anchor_pos)
  
  -- Make sure we aren't too far from the player
  local anchor_displacement = (anchor_pos - self:GetPos())
  if anchor_displacement:len() > self.max_displacement then
    local anchor_dir = anchor_displacement:normalized()
    self.cam:lookAt((anchor_pos - anchor_dir*self.max_displacement):unpack())
  end

  -- Move towards the current target displacement which is set by the right stick
  local target = anchor_pos + self.target_displacement
  local curr_target_displacement = target - self:GetPos()
  local tomove = curr_target_displacement:len()
  tomove = math.min(dt*self.max_velocity, tomove)
  if tomove > 0.1 then
    curr_target_displacement:normalizeInplace()
    self.cam:move((curr_target_displacement * tomove):unpack())
  end

  if not (self.zoom == self.target_zoom) then
    local czoom = self.target_zoom - self.zoom
    self.zoom = self.zoom + sign(czoom) * math.min(math.abs(czoom),self.max_zps * dt) 
  end

  self.cam:zoomTo(self.zoom)
end

function Camera:Attach()
  self.cam:attach()
end

function Camera:Detach()
  self.cam:detach()
end