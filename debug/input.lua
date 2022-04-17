require "Object"

dbg_input = Object:new{}

function dbg_input:Command(command, value)
  if type(value) == "boolean" then
    local nstate = value and " pressed" or " released"
    io.write(string.format("dbg_input:Command(%s,%s)\n", command, nstate))
  else
    io.write(string.format("dbg_input:Command(%s,%s)\n", command, value))
  end
  io.flush()
end