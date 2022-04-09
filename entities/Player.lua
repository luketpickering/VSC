require "Object"

local vector = require "hump/vector"

Player = Object:new{}

function Player:Command()
  io.write("Base class Player:Command called")
  os.exit()
end

function Player:GetPos()
  return vector(self.body:getX(), 
    self.body:getY())
end

function Player:Draw()
  io.write("Base class Player:Draw called")
  os.exit()
end