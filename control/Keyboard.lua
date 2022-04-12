require "Object"

local vector = require "hump/vector"

Keyboard = Object:new{
  move_keys = {"w", "a", "s", "d"},
  move_vec = {
    vector(0,-1),
    vector(-1,0),
    vector(0,1),
    vector(1,0)
  },
  move_key_state = {},

  move_camera_keys = {"i", "j", "k", "l"},
  move_camera_vec = {
    vector(0,-1),
    vector(-1,0),
    vector(0,1),
    vector(1,0)
  },
  move_camera_key_state = {},

  cmd_keys = {"z", "r"},
  cmd_key_state = {},
}

function Keyboard:init()
  self:Poll()
end

function Keyboard:Poll()

  local state_changes = {}

  local move_vec = vector(0,0)
  local move_state_change = false

  for i, key in ipairs(self.move_keys) do
    local key_state = love.keyboard.isDown(key) and 1 or 0
    if not (key_state == self.move_key_state[i]) then
      move_state_change = true
      self.move_key_state[i] = key_state
    end
    
    -- append the relevant movement delta for this key
    if self.move_key_state[i] > 0 then
      move_vec = move_vec + self.move_vec[i] 
    end
  end

  if move_state_change then
    table.insert(state_changes, {"move", move_vec:normalized()})
  end

  local move_camera_vec = vector(0,0)
  local move_camera_state_change = false

  for i, key in ipairs(self.move_camera_keys) do
    local key_state = love.keyboard.isDown(key) and 1 or 0
    if not (key_state == self.move_camera_key_state[i]) then
      move_camera_state_change = true
      self.move_camera_key_state[i] = key_state
    end
    
    -- append the relevant movement delta for this key
    if self.move_camera_key_state[i] > 0 then 
      move_camera_vec = move_camera_vec + self.move_camera_vec[i] 
    end
  end

  if move_camera_state_change then
    table.insert(state_changes, {"move_camera", move_camera_vec:normalized()})
  end

  for i, key in ipairs(self.cmd_keys) do
    local key_state = love.keyboard.isDown(key) and 1 or 0
    if not (key_state == self.cmd_key_state[i]) then
      self.cmd_key_state[i] = key_state
      table.insert(state_changes, {key, key_state})
    end
  end

  return state_changes
end