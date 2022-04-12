require "Object"

require "assets/Assets"

require "utils/console"

Graphics = Object:new{}

function Graphics:init()
  Assets:init()
  self.color_stack = {}
end

function Graphics:GetTilesetQuad(x, y)
  return Assets:GetTilesetQuad(x, y)
end

function Graphics:DrawTilesetQuad(Q, x, y)
  love.graphics.draw(Assets.ts, Q, x - Assets.size/2, y - Assets.size/2)
end

function Graphics:PushColor(ctable)
  table.insert(self.color_stack, {love.graphics.getColor()})
  love.graphics.setColor(ctable)
end

function Graphics:PopColor()
  love.graphics.setColor(table.remove(self.color_stack))
end

function Graphics:Print(t, x, y, s)
  s = s and s or 12
  local f = Assets.Font[s]

  if f then
    love.graphics.setFont(f)

    local textWidth = f:getWidth(t)
    local textHeight = f:getHeight()

    love.graphics.print(t, x - textWidth/2, y - textHeight/2)
  else
    io.write("[ERROR]: No font in size ", s)
    abort()
  end
end

function Graphics:PrintLeft(t, x, y, s)
  s = s and s or 12
  local f = Assets.Font[s]

  if f then
    local textWidth = f:getWidth(t)
    self:Print(t, x + textWidth/2, y, s)
  else
    io.write("[ERROR]: No font in size ", s)
    abort()
  end
end

function Graphics:PrintRight(t, x, y, s)
  s = s and s or 12
  local f = Assets.Font[s]

  if f then
    local textWidth = f:getWidth(t)
    self:Print(t, x - textWidth/2, y, s)
  else
    io.write("[ERROR]: No font in size ", s)
    abort()
  end
end