require "Object"

require "graphics/Graphics"

character_overlay = Object:new{}

function character_overlay.Draw(character, camera)

  camera:Attach()
  camera:RotateTo(character.body:getAngle())
  Graphics:PushColor({1,1,0})

  love.graphics.points(character:GetPos():unpack())
  love.graphics.circle("line", character:GetPos().x, character:GetPos().y, character.shape:getRadius())
  Graphics:PopColor()
  camera:RotateTo(0)
  camera:Detach()

  Graphics:PushColor({1,0,0, 0.5})
  local character_pos_screen = camera:CameraCoords(character:GetPos())
  Graphics:PrintLeft(string.format("Pos: (%.2f,%.2f)", character:GetPos():unpack()), 
    character_pos_screen.x + 24, character_pos_screen.y - 16)
  Graphics:PrintLeft(string.format("Vel: %.2f (%.2f,%.2f)", character:GetVel():len(),
    character:GetVel():unpack()), character_pos_screen.x + 24, 
  character_pos_screen.y)

  if character.state == DynamicBodyStates.STUNNED then
    Graphics:PrintLeft(string.format("%s: %s s", 
        DynamicBodyStates.tostring(character.state),
        math.floor(character.STUNNED_timer * 100)/100),
      character_pos_screen.x + 24, 
      character_pos_screen.y + 16)
  else
    Graphics:PrintLeft(DynamicBodyStates.tostring(character.state), 
      character_pos_screen.x + 24, 
      character_pos_screen.y + 16)
  end

  Graphics:Print(string.format("Health: %s/%s", 
    character.health, character.max_health), 
    character_pos_screen.x, 
    character_pos_screen.y - 30)

  Graphics:PopColor()

end