require "Object"

local vector = require "hump/vector"

Joystick = Object:new{
  buttons = {"a", "b", "x", "y", 
    "start", 
    "dpup", "dpdown", "dpleft", "dpright", 
    "leftshoulder", "rightshoulder"},
  button_state = {},

  analog2D = {"left", "right"},
  analog2D_axes = { { "leftx", "lefty" }, 
                    { "rightx", "righty" } 
                  },
  analog2D_state = {},

  analog1D = {"triggerleft", "triggerright"},
  analog1D_state = {},

  analog_granularity = 20,
  analog2D_deadzone = 0.2,
}

function Joystick:init()
  if love.joystick.getJoystickCount() < 1 then return end

  self:Select(1)
end

function Joystick:GetJoystickCount()
  return love.joystick.getJoystickCount()
end

function Joystick:Select(i)
  i = i or 1

  if i >= 1 and i <= self:getJoystickCount() then
    self.joy = love.joystick.getJoysticks()[i]
  else
    self.joy = nil
  end

  self:Poll() -- set the initial state
end

function Joystick:Info()
  print(io.write("Found %d joysticks:", love.joystick.getJoystickCount()))

  for i=1,love.joystick.getJoystickCount() do
    local j = love.joystick.getJoysticks()[i]
    local guid = j:getGUID()
    local vendorID, productID, productVersion = j:getDeviceInfo()
    local name = j:getName()

    io.write("\tJoystick[", i, "] Name: ", name, "\n")
    io.write("\t\tVID: ", vendorID,", PID: ", productID,", PVer: ", productVersion, "\n")
    io.write("\t\tIsGamepad: ", tostring(j:isGamepad()), "\n")
    io.write("\t\tNAxes: ", j:getAxisCount(), "\n")
    io.write("\t\tNButtons: ", j:getButtonCount(), "\n")
    io.write("\t\tNHats: ", j:getHatCount(), "\n")
  end
end

function Joystick:Poll()
  if not self.joy then return end

  local state_changes = {}

  for i, button in ipairs(self.buttons) do
    local button_state = self.joy:isGamepadDown(button) and 1 or 0
    if not (button_state == self.button_state[i]) then
      table.insert(state_changes, {button, button_state})
      self.button_state[i] = button_state
    end
  end

  for i, axis in ipairs(self.analog2D) do
    local vec_raw = vector(
      self.joy:getGamepadAxis(self.analog2D_axes[i][1]),
      self.joy:getGamepadAxis(self.analog2D_axes[i][2]))

    if vec_raw:len() < self.analog2D_deadzone then
      vec_raw = vector(0,0)
    end

    local vec = (vec_raw * self.analog_granularity):floor()/self.analog_granularity

    if not (vec == self.analog2D_state[i]) then
      table.insert(state_changes, {axis, vec:clone()})
      self.analog2D_state[i] = vec
    end
  end

    for i, axis in ipairs(self.analog1D) do
    local axis_state = math.floor(self.joy:getGamepadAxis(axis)*self.analog_granularity)/self.analog_granularity
    if not (axis_state == self.analog1D_state[i]) then
      table.insert(state_changes, {axis, axis_state})
      self.analog1D_state[i] = axis_state
    end
  end

  return state_changes
end