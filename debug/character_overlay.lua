require "Object"

require "entities/actor/ActorStates"

require "graphics/Graphics"

character_overlay = Object:new{}

function character_overlay.Draw(actor, camera)

  camera:Attach()
  camera:RotateTo(actor.body:getAngle())
  Graphics:PushColor({1,1,0})

  love.graphics.points(actor:GetPos():unpack())
  love.graphics.circle("line", actor:GetPos().x, actor:GetPos().y, actor.shape:getRadius())
  Graphics:PopColor()
  camera:RotateTo(0)
  camera:Detach()

  Graphics:PushColor({1,0,0, 0.5})
  local character_pos_screen = camera:CameraCoords(actor:GetPos())
  Graphics:PrintLeft(string.format("Pos: (%.2f,%.2f)", actor:GetPos():unpack()), 
    character_pos_screen.x + 24, character_pos_screen.y - 16)
  Graphics:PrintLeft(string.format("Vel: %.2f (%.2f,%.2f)", actor:GetVel():len(),
    actor:GetVel():unpack()), character_pos_screen.x + 24, 
  character_pos_screen.y)

  if actor.state == ActorStates.STUNNED then
    Graphics:PrintLeft(string.format("%s: %s s", 
        ActorStates.tostring(actor.state),
        math.floor(actor.STUNNED_timer * 100)/100),
      character_pos_screen.x + 24, 
      character_pos_screen.y + 16)
  else
    Graphics:PrintLeft(ActorStates.tostring(actor.state), 
      character_pos_screen.x + 24, 
      character_pos_screen.y + 16)
  end

  Graphics:Print(string.format("Health: %s/%s", 
    actor.health, actor.max_health), 
    character_pos_screen.x, 
    character_pos_screen.y - 30)

  Graphics:PopColor()

end