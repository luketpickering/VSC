require "Object"

require "graphics/Graphics"

character_overlay = Object:new{}

function character_overlay.Draw(character, camera)

  camera:Attach()
  Graphics:PushColor({1,1,0})
  love.graphics.points(character:GetPos():unpack())
  love.graphics.rectangle("line",
    character.body:getX() - character.sprite.size/2, 
    character.body:getY() - character.sprite.size/2, 
    character.sprite.size, character.sprite.size)
  Graphics:PopColor()
  camera:Detach()

  Graphics:PushColor({1,0,0, 0.5})
  local character_pos_screen = camera:CameraCoords(character:GetPos())
  Graphics:PrintLeft(string.format("Pos: (%.2f,%.2f)", character:GetPos():unpack()), 
    character_pos_screen.x + 24, character_pos_screen.y - 16)
  Graphics:PrintLeft(string.format("Vel: (%.2f,%.2f)", character:GetVel():unpack()), 
    character_pos_screen.x + 24, character_pos_screen.y)
  Graphics:PopColor()

end