require "Object"
require "utils/ringbuffer"

local vector = require "hump/vector"

DynamicBodyStates = {
  UNITINIALIZED = 0,
  ALIVE_RECORDING = 1,
  REWINDING = 2,
  DEAD = 3,
  READY_FOR_GC = 4,
}

local DynamicBodySnapshot = Object:new{
  state = DynamicBodyStates.UNITINIALIZED,
  pos = vector(),
  vel = vector()
}

function DynamicBodySnapshot:Interpolate(fraction, other_state)
  local interpolated = DynamicBodySnapshot:new{}

  interpolated.state = self.state
  interpolated.pos = self.pos + ((other_state.pos - self.pos) * fraction)
  interpolated.vel = self.vel + ((other_state.vel - self.vel) * fraction)

  return interpolated
end

local MAX_REWIND_SPEED = 5

DynamicBody = Object:new{}

function DynamicBody:init(body)
  assert(body)
  self.body = body

  self.state = DynamicBodyStates.UNITINIALIZED
  self.next_state = nil
  self.post_rewind_state = nil

  self.rewind_speed = 1
  self.rewind_tick = 0
  self.coarse_step_time = 0.5 --seconds
  self.dead_time = 0

  self.fine_state_history = RingBuffer:new{}
  self.fine_state_history:init(120)

  self.coarse_state_history = RingBuffer:new{}
  self.coarse_state_history:init(240)
end

function DynamicBody:RevertToSnapshot(state)
  if not state then return end

  self:SetPos(state.pos)
  self:SetVel(state.vel)
  self.post_rewind_state = state.state
end

function DynamicBody:TakeSnapshot()
  local ss = DynamicBodySnapshot:new{}
  ss.pos = self:GetPos()
  ss.vel = self:GetVel()
  ss.state = self.state
  return ss
end

function DynamicBody:RecordCoarseState(state_history)

  if self.coarse_state_history:Size() == 0 then
    self.coarse_state_history:Prepend(state_history)
    return
  end

  local recent_history = self.coarse_state_history:PeekFront()

  if (recent_history.dt + state_history.dt) < self.coarse_step_time then
    --if we don't want to save this fine snapshot, increment the timer
    recent_history.dt = recent_history.dt + state_history.dt
  else
    --we want to save this one
    self.coarse_state_history:Prepend(state_history)
  end
end

function DynamicBody:RecordFineState(dt)

  local popped = self.fine_state_history:Prepend({ 
    dt=dt, 
    state=self:TakeSnapshot() 
  })

  if popped then
    self:RecordCoarseState(popped)
  end
end

local DT_FUDGE_FACTOR = (1/100)

function DynamicBody:RewindCoarseState(dt)

  local statetime = nil
  while self.coarse_state_history:Size() > 0 do
    local rewind_step = self.coarse_state_history:PeekFront()

    if rewind_step.dt >= (dt + DT_FUDGE_FACTOR) then
      -- interpolate partial step

      local step_fraction = dt/rewind_step.dt

      rewind_step.dt = rewind_step.dt - dt

      return { state = self:TakeSnapshot():Interpolate(step_fraction, 
                                                       rewind_step.state) }
    else -- consume the whole step
      statetime = self.coarse_state_history:PopFront()
    end
  end

  return statetime
end

function DynamicBody:RewindFineState(dt)

  local statetime = nil
  while self.fine_state_history:Size() > 0 do
    statetime = self.fine_state_history:PopFront()
    dt = dt - statetime.dt

    if dt <= DT_FUDGE_FACTOR then
      break
    end
  end

  if statetime then -- have to set it here incase we need to further interpolate 
                    -- in RewindCoarseState.
    self:RevertToSnapshot(statetime.state)
  end

  --don't bother if we have less than a frames worth
  if dt > DT_FUDGE_FACTOR then
    statetime = self:RewindCoarseState(dt)
  end

  if statetime then
    self:RevertToSnapshot(statetime.state)
  end
end

function DynamicBody:Update(dt)
  if self.state == DynamicBodyStates.ALIVE_RECORDING then
    self:RecordFineState(dt)
  elseif self.state == DynamicBodyStates.REWINDING then

    local rewind_dt = dt * self.rewind_speed

    if self.dead_time > 0 then
      self.dead_time = self.dead_time - rewind_dt
    end

    if self.dead_time <= 0 then
      self:RewindFineState(rewind_dt)
    end

    self.rewind_tick = self.rewind_tick + dt
    if self.rewind_tick > 0.2 then
      self.rewind_tick = 0
      self.rewind_speed = math.min(self.rewind_speed + 1, MAX_REWIND_SPEED)
    end

  elseif self.state == DynamicBodyStates.DEAD then
    self.dead_time = self.dead_time + dt

    if self.dead_time > DEAD_TIME_LIMIT then
      self.next_state = DynamicBody.READY_FOR_GC
    end
  end

  self:TransitionState()
end

function DynamicBody:TransitionState()
  if not self.next_state then return end

  --if we are coming out of a REWINDING state then the next state should be 
  -- replaced with post_rewind_state
  if self.state == DynamicBodyStates.REWINDING then
    self.next_state = self.post_rewind_state
    self.post_rewind_state = nil
  end

  if self.next_state == DynamicBodyStates.REWINDING then
    self.rewind_speed = 1
    self.rewind_tick = 0

    --disable the physics engine for rewinding bodies
    self.body:setActive(false)
  end

  if self.next_state == DynamicBodyStates.ALIVE_RECORDING then
    self.body:setActive(true)
  end

  if self.next_state == DynamicBodyStates.DEAD then
    self.dead_time = 0
    self.body:setActive(false)
  end

  self.state = self.next_state
  self.next_state = nil
end

function DynamicBody:GetPos()
  return vector(self.body:getX(), 
    self.body:getY())
end

function DynamicBody:SetPos(pos)
  self.body:setPosition(pos.x, pos.y)
end

function DynamicBody:GetVel()
  return vector(self.body:getLinearVelocity())
end

function DynamicBody:SetVel(vel)
  vel = vel or vector()
  self.body:setLinearVelocity(vel:unpack())
end