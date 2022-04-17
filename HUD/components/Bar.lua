require "graphics/UI/UI"

Bar = UI:new{ 
  x = 0, 
  y = 0,
  w = 0,
  h = 0,
  v = 0,
  bc = {0,0,0}, 
  fc = {0,0,0}, 
}

function Bar:Draw()
  local gx = love.graphics
  gx.push()
  gx.translate(self.x - self.w/2, self.y - self.h/2)

  local r, g, b, a = gx.getColor()
  gx.setColor(self.bc)
  gx.rectangle("fill", 0, 0, self.w, self.h, self.w/5, self.w/5)

  if self.v > 0 then
    gx.push()
    gx.translate(1,1)
    gx.setColor(self.fc)
    gx.rectangle("fill", 0, 0, self.w-2, (self.h-2)*self.v, self.w/5, self.w/5)
    gx.pop()
  end

  gx.setColor(r, g, b, a)
  gx.pop()
end

function Bar:Set(v)
  self.v = v
end