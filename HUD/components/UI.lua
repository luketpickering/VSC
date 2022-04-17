require "Object"

UI = Object:new{}

function UI:Draw()
  io.write("Base class UI:Draw called")
  os.exit()
end