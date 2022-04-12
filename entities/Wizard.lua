require "entities/Player"

local vector = require "hump/vector"

require "graphics/Graphics"

require "utils/console"

Wizard = Player:new { 
  maxVel = 50,

  last_vel = vector(0,0),
  fine_displacements = { },
  coarse_displacements = { },
  rewind_speed = 1,
  rewind_tick = 0,

  ncoarse = 240,
  coarse_step = 0.5,
  nfine = 120,

  state = nil,
  next_state = nil
}

function Wizard:init(world, pos)
  pos = pos or vector(0,0)
  self.quad = Graphics:GetTilesetQuad(24, 1)
  self.body = love.physics.newBody(world, pos.x, pos.y, "dynamic")
  self.shape = love.physics.newRectangleShape(Assets.size, Assets.size)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)

  self.state = "play"
end

function Wizard:PushCoarseMove(dt, disp)
  -- io.write(string.format("Wizard: Pushing coarse move %s, %s.\n",dt,disp))

  if not self.coarse_displacements[1] then
    table.insert(self.coarse_displacements, {0, vector(0,0)})
  end

  self.coarse_displacements[1][1] = self.coarse_displacements[1][1] + dt

  -- console.print({"self.coarse_displacements[1][2]", self.coarse_displacements[1][2]})
  -- console.print({"disp", disp})
  self.coarse_displacements[1][2] = self.coarse_displacements[1][2] + disp

  if self.coarse_displacements[1][1] >= self.coarse_step then -- need a new front element
    if table.getn(self.coarse_displacements) == self.ncoarse then -- need to pop the end element
      table.remove(self.coarse_displacements)
    end    
    table.insert(self.coarse_displacements, 1, {0, vector(0,0)})
  end
end

function Wizard:PushFineMove(dt, disp)

  -- io.write(string.format("Wizard: Pushing fine move %s, %s.\n",dt,disp))
  table.insert(self.fine_displacements, 1, {dt, disp})

  if table.getn(self.fine_displacements) == self.nfine then
    self:PushCoarseMove(unpack(table.remove(self.fine_displacements)))
  end
end

function Wizard:RewindCoarseMove(dt)
  local delta_disp = vector(0,0)
  local delta_remaining = dt 

  while (table.getn(self.coarse_displacements) > 0) do
    local rewind_step = self.coarse_displacements[1]
    local scaled_step_time = rewind_step[1] / self.rewind_speed

    -- The + 1/100 fudge means we won't leave less than about a frames worth
    if scaled_step_time >= (delta_remaining + (1/100)) then 
      local step_delta_disp = 
        rewind_step[2] * (delta_remaining / scaled_step_time)
      
      delta_disp = delta_disp - step_delta_disp

      self.coarse_displacements[1][1] = 
        rewind_step[1] - (delta_remaining * self.rewind_speed)
      self.coarse_displacements[1][2] = rewind_step[2] - step_delta_disp

      delta_remaining = delta_remaining - scaled_step_time

      io.write(string.format("Undoing coarse move: %s over %s(x%s)\n", 
        rewind_step[2], rewind_step[1], self.rewind_speed))

      break
    else -- consume the whole step
      delta_disp = delta_disp - rewind_step[2]
      delta_remaining = delta_remaining - scaled_step_time

      io.write(string.format("Undoing coarse move: %s over %s(x%s)\n", 
        rewind_step[2], rewind_step[1], self.rewind_speed))

      table.remove(self.coarse_displacements, 1)
    end
  end

  -- io.write(string.format("Undoing coarse move: %s over %s(x%s)\n", 
    -- delta_disp, dt, self.rewind_speed))
  self:SetPos(self:GetPos() + delta_disp)
end

function Wizard:RewindFineMove(dt)
  local delta_disp = vector(0,0)
  local delta_remaining = dt

  while (table.getn(self.fine_displacements) > 0) do
    local rewind_step = table.remove(self.fine_displacements, 1)
    local scaled_step_time = rewind_step[1] / self.rewind_speed

    delta_remaining = delta_remaining - scaled_step_time
    delta_disp = delta_disp - rewind_step[2]

    io.write(string.format("Undoing fine move: %s over %s(x%s)\n", 
      rewind_step[2], rewind_step[1], self.rewind_speed))

    if delta_remaining <= 0 then
      break
    end
  end

  self:SetPos(self:GetPos() + delta_disp)

  --don't bother if we have less than a frames worth
  if delta_remaining > (1/100) then
    self:RewindCoarseMove(delta_remaining)
  end
end

function Wizard:Update(dt)
  if self.state == "play" then
    self:PushFineMove(dt, self.last_vel * dt)
  elseif self.state == "rewind" then
    self:RewindFineMove(dt)
    self.rewind_tick = self.rewind_tick + dt
    if self.rewind_tick > 0.2 then
      self.rewind_tick = 0
      self.rewind_speed = math.min(self.rewind_speed + 1, 5)
    end
  end

  if self.next_state then
    self:Transition()
    self:SetVel()
  end
end

function Wizard:Transition()
  io.write(
    string.format("Wizard is changing state: %s -> %s\n", 
      self.state, self.next_state))

  if self.next_state == "rewind" then
    console.print(self.fine_displacements)
    console.print(self.coarse_displacements)
  end

  self.state = self.next_state
  self.next_state = nil
end

function Wizard:StoreMove(move)
  self.last_vel = move
end

function Wizard:Command(command, value)
  io.write(string.format("Wizard Recieving: %s, %s", command, value), "\n")
  if command == "move" and self.state == "play" then
    self.body:setLinearVelocity( (value * self.maxVel):unpack() )

    self:StoreMove(value * self.maxVel)
  elseif command == "rewind" then
    self.next_state = value > 0 and "rewind" or "play"
  end
end

function Wizard:Draw()
  Graphics:DrawTilesetQuad(self.quad, self:GetPos():unpack())

  Graphics:PushColor({1,1,0})
  love.graphics.points(self.body:getX(), self.body:getY())
  love.graphics.rectangle("line",
    self.body:getX() - Assets.size/2, self.body:getY() - Assets.size/2, 
    Assets.size, Assets.size)
  Graphics:PopColor()
end 