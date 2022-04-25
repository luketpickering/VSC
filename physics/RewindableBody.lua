require "Object"
require "utils/ringbuffer"

local vector = require "hump/vector"

RewindableBody = Object:new{}

function RewindableBody:init(body)
  assert(body)
  self.body = body

  -- Subclasses must define TakeSnapshot and RevertToSnapshot member functions
  assert(self.TakeSnapshot)
  assert(self.RevertToSnapshot)

  self.fine_snap_history = RingBuffer:new{}
  self.fine_snap_history:init(120)

  self.coarse_time_step = 0.5 --seconds
  self.coarse_snap_history = RingBuffer:new{}
  self.coarse_snap_history:init(240)
end

function RewindableBody:RecordCoarseState(snap_history)

  if self.coarse_snap_history:Size() == 0 then
    self.coarse_snap_history:Prepend(snap_history)
    return
  end

  local recent_history = self.coarse_snap_history:PeekFront()

  if (recent_history.dt + snap_history.dt) < self.coarse_time_step then
    --if we don't want to save this fine snapshot, increment the timer
    recent_history.dt = recent_history.dt + snap_history.dt
  else
    --we want to save this one
    self.coarse_snap_history:Prepend(snap_history)
  end
end

function RewindableBody:RecordUpdate(dt)

  local popped = self.fine_snap_history:Prepend({ 
    dt=dt, 
    snap=self:TakeSnapshot() 
  })

  if popped then
    self:RecordCoarseState(popped)
  end
end

local DT_FUDGE_FACTOR = (1/100)

function RewindableBody:RewindCoarseUpdate(dt)

  local time_snap = nil
  while self.coarse_snap_history:Size() > 0 do
    local rewind_step = self.coarse_snap_history:PeekFront()

    if rewind_step.dt >= (dt + DT_FUDGE_FACTOR) then
      -- interpolate partial step

      local step_fraction = dt/rewind_step.dt

      rewind_step.dt = rewind_step.dt - dt

      return { snap = self:TakeSnapshot():Interpolate(step_fraction, 
                                                       rewind_step.snap) }
    else -- consume the whole step
      time_snap = self.coarse_snap_history:PopFront()
    end
  end

  return time_snap
end

function RewindableBody:RewindUpdate(dt)

  local time_snap = nil
  while self.fine_snap_history:Size() > 0 do
    time_snap = self.fine_snap_history:PopFront()
    dt = dt - time_snap.dt

    if dt <= DT_FUDGE_FACTOR then
      break
    end
  end

  if time_snap then -- have to set it here incase we need to further interpolate 
                    -- in RewindUpdate.
    self:RevertToSnapshot(time_snap.snap)
  end

  --don't bother if we have less than a frames worth
  if dt > DT_FUDGE_FACTOR then
    time_snap = self:RewindCoarseUpdate(dt)
  end

  if time_snap then
    self:RevertToSnapshot(time_snap.snap)
  end
end

function RewindableBody:GetPos()
  return vector(self.body:getX(), 
    self.body:getY())
end

function RewindableBody:SetPos(pos)
  self.body:setPosition(pos.x, pos.y)
end

function RewindableBody:GetVel()
  return vector(self.body:getLinearVelocity())
end

function RewindableBody:SetVel(vel)
  vel = vel or vector()
  self.body:setLinearVelocity(vel:unpack())
end

function RewindableBody:GetBody()
  return self.body
end

function RewindableBody:PeekSnap()
  if self.coarse_snap_history:Size() > 0 then
    return self.coarse_snap_history:Peek().snap
  elseif self.fine_snap_history:Size() > 0 then
    return self.fine_snap_history:Peek().snap
  end

  return nil
end

function RewindableBody:GetNSnaps()
  return self.coarse_snap_history:Size() + self.fine_snap_history:Size()
end