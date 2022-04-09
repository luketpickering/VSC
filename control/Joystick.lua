require "Object"

local vector = require "hump/vector"

Joystick = Object:new{
  buttons = {"a", "b", "x", "y", 
    "start", 
    "dpup", "dpdown", "dpleft", "dpright", 
    "leftshoulder", "rightshoulder"},
  analog2D = {"left", "right"},
  analog2D_axes = { { "leftx", "lefty" }, 
                    { "rightx", "righty" } 
                  },
  analog1D = {"triggerleft", "triggerright"},
  analog_granularity = 20,
  Recievers = {}
}

function Joystick:init()

  print("NJoys: ", love.joystick.getJoystickCount())

  for i=1,love.joystick.getJoystickCount() do
    local j = love.joystick.getJoysticks()[i]
    local guid = j:getGUID()
    local vendorID, productID, productVersion = j:getDeviceInfo()
    local name = j:getName()

    io.write("\tJoy[", i, "] Name: ", name, "\n")
    io.write("\t\tVID: ", vendorID,", PID: ", productID,", PVer: ", productVersion, "\n")
    io.write("\t\tIsGamepad: ", tostring(j:isGamepad()), "\n")
    io.write("\t\tNAxes: ", j:getAxisCount(), "\n")
    io.write("\t\tNButtons: ", j:getButtonCount(), "\n")
    io.write("\t\tNHats: ", j:getHatCount(), "\n")
  end

  if love.joystick.getJoystickCount() < 1 then return end

  self.cjoy = love.joystick.getJoysticks()[1]

  self.button_state = {}
  for i, button in ipairs(self.buttons) do
    self.button_state[i] = self.cjoy:isGamepadDown(button)
  end

  self.analog2D_values = {}
  for i, axis in ipairs(self.analog2D) do
    self.analog2D_values[i] = vector(
      math.floor(self.cjoy:getGamepadAxis(self.analog2D_axes[i][1])
        *self.analog_granularity)/self.analog_granularity,
      math.floor(self.cjoy:getGamepadAxis(self.analog2D_axes[i][2])
        *self.analog_granularity)/self.analog_granularity)
  end

  self.analog1D_value = {}
  for i, axis in ipairs(self.analog1D) do
    self.analog1D_value[i] = math.floor(self.cjoy:getGamepadAxis(axis)
      *self.analog_granularity)/self.analog_granularity
  end
end

function Joystick:RegisterInputtable(obj, commands)
  commands = commands or "all"
  if type(commands) == "string" then
    self.Recievers[commands] = self.Recievers[commands] or {}
    table.insert(self.Recievers[commands],obj)
  elseif type(commands) == "table" then
    for _, c in ipairs(commands) do
      self.Recievers[c] = self.Recievers[c] or {}
      table.insert(self.Recievers[c],obj)
    end
  end
end

function Joystick:SendInput(command, value)
  if self.Recievers["all"] then
    for _, r in ipairs(self.Recievers["all"]) do
      r:Command(command, value)
    end
  end
  if self.Recievers[command] then
    for _, r in ipairs(self.Recievers[command]) do
      r:Command(command, value)
    end
  end
end

function Joystick:Poll()
  if not self.cjoy then return end

  local first = true
  for i, button in ipairs(self.buttons) do
    if self.cjoy:isGamepadDown(button) then
      if not self.button_state[i] then
        self:SendInput(button, true)
        self.button_state[i] = true
      end
    elseif self.button_state[i] then
      self:SendInput(button, false)
      self.button_state[i] = false
    end
  end

  for i, axis in ipairs(self.analog2D) do
    local vec = vector(
      math.floor(self.cjoy:getGamepadAxis(self.analog2D_axes[i][1])
        *self.analog_granularity)/self.analog_granularity,
      math.floor(self.cjoy:getGamepadAxis(self.analog2D_axes[i][2])
        *self.analog_granularity)/self.analog_granularity)

    if not (vec == self.analog2D_values[i]) then
      if vec:len2() < 1.0/(self.analog_granularity*self.analog_granularity) then
        vec = vector(0,0)
      end

      self.analog2D_values[i] = vec
      self:SendInput(axis, vec)
    end
  end

    for i, axis in ipairs(self.analog1D) do
    local x = math.floor(self.cjoy:getGamepadAxis(axis)*self.analog_granularity)/self.analog_granularity
    if not (x == self.analog1D_value[i]) then
      self.analog1D_value[i] = x
      self:SendInput(axis, self.analog1D_value[i])
    end
  end

end