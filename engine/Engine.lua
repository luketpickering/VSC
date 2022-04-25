require "Object"

local vector = require "hump/vector"

require "graphics/Graphics"
require "graphics/Camera"
require "graphics/Background"

require "control/Control"
require "AI/AI"

require "entities/Wizard"
require "entities/Baddie"

require "HUD/kb"

require "debug/debug"

Engine = Object:new{
  sprite_scale = 2,
  world_scale = 16 --px/m
}

function NotifyBeginContact(a,b,c)
  local achar = a:getUserData()
  local bchar = b:getUserData()

  print(string.format("Begin new contact between %s and %s in frame %s", 
    achar.name, bchar.name, framectr))

  achar:Hurt(10)
  bchar:Hurt(10)
  achar:Stun(5)
  bchar:Stun(5)
  achar:Shove(vector(c:getNormal())*-200)
  bchar:Shove(vector(c:getNormal())*200)
end

framectr = 0

function Engine:init()

  love.physics.setMeter(Engine.world_scale)

  self.World = love.physics.newWorld()

  self.World:setCallbacks(NotifyBeginContact)

  self.window = {}
  self.window.width, self.window.height, self.window.flags = love.window.getMode()

  Control:init()
  Graphics:init()
  Background:init()
  kb:init(self.window)

  self.Baddies = {}

  for i = 1, 1 do
    self.Baddies[i] = Baddie:new{}
    self.Baddies[i]:init(
      Assets:GetSprite("KENNEY_SPRITES", 25, 0),
      self.World, 
      vector.randomDirection(100,200))
    AI:Attach(self.Baddies[i])
  end 

  Wizard:init(Assets:GetSprite("KENNEY_SPRITES",25, 4), self.World)

  Camera:init(Wizard:GetPos(), self.sprite_scale)

  Control:Register(Wizard, {Commands.MOVE, Commands.REWIND} )
  Control:Register(kb, {Commands.MOVE, Commands.REWIND,
                        Commands.MOVE_CAMERA, Commands.ZOOM} )

  Control:Register(Camera, {Commands.MOVE_CAMERA, Commands.ZOOM})
  Control:Register(dbg.input, Commands.ANY)
end

function Engine:Update(dt)
  self.World:update(dt)

  Control:Poll()

  Wizard:Update(dt)

  Camera:Update(dt, Wizard:GetPos())

  AI:Update(Wizard)
  for _,b in ipairs(self.Baddies) do
    -- we force other actors to rewind if the player is
    if Wizard.BeganRewind then
      b.next_state = ActorStates.REWINDING
    elseif Wizard.FinishedRewind then
      b.next_state = ActorStates.POST_REWIND
    end
    b:Update(dt)
  end
end

function love.update(dt)
  Engine:Update(dt)
  framectr = framectr + 1
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

  for _,b in ipairs(Engine.Baddies) do
    b:Draw()
  end

  -- Draw the origin
  Graphics:PushColor({1,0,0})
  love.graphics.rectangle("line", -5, -5, 10, 10)
  Graphics:PopColor()

  Camera:Detach()

  -- Draw IMGUI
  kb:Draw()

  dbg.character.Draw(Wizard, Camera)

  for _,b in ipairs(Engine.Baddies) do
    dbg.character.Draw(b, Camera)
  end

  dbg.camera.Draw(Camera)

  Graphics:PrintRight(string.format("Input: %s", ControlTypes.tostring(Control.itype)), 
    Engine.window.width - 20, 20)

  Graphics:PushColor({1,0,0})
  love.graphics.rectangle("line", 20, Engine.window.height - 40, 
    Engine.window.width * 0.8 , 5)

  love.graphics.rectangle("fill", 20, Engine.window.height - 40, 
    (Engine.window.width * 0.8) * 
      Wizard.fine_snap_history:Size() /
        Wizard.fine_snap_history.capacity, 
    5)

  Graphics:PopColor()
  Graphics:PushColor({0,0,1})
  love.graphics.rectangle("line", 20, Engine.window.height - 20, 
    Engine.window.width * 0.8 , 5)

  love.graphics.rectangle("fill", 20, Engine.window.height - 20, 
    (Engine.window.width * 0.8) * 
      Wizard.coarse_snap_history:Size() /
        Wizard.coarse_snap_history.capacity, 
    5)
  Graphics:PopColor()

end