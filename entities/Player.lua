require "Object"

local vector = require "hump/vector"

Player = Object:new{
}

function Player:Command()
  io.write("Base class Player:Command called")
  os.exit()
end

function Player:GetPos()
  return vector(self.body:getX(), 
    self.body:getY())
end

function Player:SetPos(pos)
  self.body:setPosition(pos.x, pos.y)
end

function Player:GetVel()
  return vector(self.body:getLinearVelocity())
end

function Player:SetVel(vel)
  vel = vel or vector(0,0)
  self.body:setLinearVelocity(vel:unpack())
end

function Player:Draw()
  io.write("Base class Player:Draw called")
  os.exit()
end