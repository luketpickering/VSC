require "Object"
require "utils/ringbuffer"

local vector = require "hump/vector"

Player = Object:new {
}

function Player:init()

  self.last_vel = vector(0,0)

  self.fine_displacement_history = RingBuffer:new{}
  self.fine_displacement_history:init(120)

  self.coarse_displacement_history = RingBuffer:new{}
  self.coarse_displacement_history:init(240)

  self.rewind_speed = 1
  self.rewind_tick = 0

  self.coarse_step = 0.5

  self.state = "play"
  self.next_state = nil
end

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

function Player:PushCoarseDisplacement(displacement_history)

  if self.coarse_displacement_history:Size() == 0 then
    self.coarse_displacement_history:Prepend({0, vector(0,0)})
  end

  local recent_history = self.coarse_displacement_history:PeekFront()

  recent_history[1] = recent_history[1] + displacement_history[1]
  recent_history[2] = recent_history[2] + displacement_history[2]

  if recent_history[1] >= self.coarse_step then -- need a new front element
    self.coarse_displacement_history:Prepend({0, vector(0,0)})
  end
end

function Player:PushFineDisplacement(dt, disp)

  local popped = self.fine_displacement_history:Prepend({dt, disp})
  if popped then
    self:PushCoarseDisplacement(popped)
  end
end

function Player:RewindCoarseDisplacement(dt)
  local delta_disp = vector(0,0)
  local delta_remaining = dt 

  while (self.coarse_displacement_history:Size() > 0) do
    local rewind_step = self.coarse_displacement_history:PeekFront()
    local scaled_step_time = rewind_step[1] / self.rewind_speed

    -- The + 1/100 fudge means we won't leave less than about a frames worth
    if scaled_step_time >= (delta_remaining + (1/100)) then 
      local step_delta_disp = 
        rewind_step[2] * (delta_remaining / scaled_step_time)
      
      delta_disp = delta_disp - step_delta_disp

      rewind_step[1] = rewind_step[1] - (delta_remaining * self.rewind_speed)
      rewind_step[2] = rewind_step[2] - step_delta_disp

      delta_remaining = delta_remaining - scaled_step_time

      break
    else -- consume the whole step
      delta_disp = delta_disp - rewind_step[2]
      delta_remaining = delta_remaining - scaled_step_time

      self.coarse_displacement_history:PopFront()
    end
  end

  -- io.write(string.format("Undoing coarse move: %s over %s(x%s)\n", 
    -- delta_disp, dt, self.rewind_speed))
  self:SetPos(self:GetPos() + delta_disp)
end

function Player:RewindFineDisplacement(dt)
  local delta_disp = vector(0,0)
  local delta_remaining = dt

  while (self.fine_displacement_history:Size() > 0) do
    local rewind_step = self.fine_displacement_history:PopFront()
    local scaled_step_time = rewind_step[1] / self.rewind_speed

    delta_remaining = delta_remaining - scaled_step_time
    delta_disp = delta_disp - rewind_step[2]

    if delta_remaining <= 0 then
      break
    end
  end

  self:SetPos(self:GetPos() + delta_disp)

  --don't bother if we have less than a frames worth
  if delta_remaining > (1/100) then
    self:RewindCoarseDisplacement(delta_remaining)
  end
end

function Player:Update(dt)
  if self.state == "play" then
    self:PushFineDisplacement(dt, self.last_vel * dt)
  elseif self.state == "rewind" then
    self:RewindFineDisplacement(dt)
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

function Player:Transition()
  io.write(
    string.format("Player is changing state: %s -> %s\n", 
      self.state, self.next_state))

  if self.next_state == "rewind" then
    console.print(self.fine_displacement_history)
    self.rewind_speed = 1
    self.rewind_tick = 0
  end

  self.state = self.next_state
  self.next_state = nil
end

function Player:StoreMove(move)
  self.last_vel = move
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