require "graphics/UI/UI"

Button = UI:new{ 
  x = 0, 
  y = 0, 
  bc = {0,0,0}, 
  fc = {0,0,0},
  ispressed = false
}

function Button:Press()
  self.ispressed = true
end

function Button:Release()
  self.ispressed = false
end

Button_circ = Button:new{
  r = 0
}

function Button_circ:Draw()
  local gx = love.graphics
  gx.push()
  gx.translate(self.x + self.r, self.y + self.r)

  local r, g, b, a = gx.getColor()
  gx.setColor(self.bc)
  gx.circle("fill", 0, 0, self.r)

  if self.ispressed then
    gx.setColor(self.fc)
    gx.circle("fill", 0, 0, math.floor(self.r*0.95))
  end

  gx.setColor(r, g, b, a)
  gx.pop()
end

Button_rect = Button:new{
  w = 0,
  h = 0
}

function Button_rect:Draw()
  local gx = love.graphics
  gx.push()
  gx.translate(self.x - self.w/2, self.y - self.h/2)

  local r, g, b, a = gx.getColor()
  gx.setColor(self.bc)

  local minax = math.min(self.w, self.h)
  gx.rectangle("fill", 0, 0, self.w, self.h, minax/5,minax/5)

  if self.ispressed then
    gx.push()
    gx.translate(1,1)
    gx.setColor(self.fc)
    gx.rectangle("fill", 0, 0, self.w - 2, self.h - 2, minax/5,minax/5)
    gx.pop()
  end

  gx.setColor(r, g, b, a)
  gx.pop()
end