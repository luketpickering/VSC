require "Object"

Control_Print = Object:new{}

function Control_Print:Command(command, value)
  if type(value) == "boolean" then
    local nstate = value and " pressed" or " released"
    io.write(string.format("Control_Print:Command(%s,%s)\n", command, nstate))
  else
    io.write(string.format("Control_Print:Command(%s,%s)\n", command, value))
  end
  io.flush()
end