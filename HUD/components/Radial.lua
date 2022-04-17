require "graphics/UI/UI"

require "graphics/Graphics"

Radial = UI:new{ 
  x = 0, 
  y = 0,
  r = 0,
  v = {r=0, th=0},
  bc = {0,0,0}, 
  fc = {0,0,0}, 
}

function Radial:Draw()
  local gx = love.graphics
  gx.push()
  gx.translate(self.x + self.r, self.y + self.r)

  Graphics:PushColor(self.bc)
  gx.circle("fill", 0, 0, self.r)

  gx.push()
  gx.rotate(self.v.th)
  gx.translate(self.v.r*self.r,0)
  Graphics:PushColor(self.fc)
  gx.circle("fill", 0, 0, self.r/3)

  Graphics:PopColor()
  Graphics:PopColor()

  gx.pop()

  local x = self.v.r * math.cos(self.v.th)
  local y = self.v.r * math.sin(self.v.th)

  Graphics:Print(string.format("(%.2f,%.2f)", 
    x, y), 0, -self.r - 12)

  gx.pop()

end

function Radial:Set(v)

  local th = math.atan2(v.y, v.x)
  local th_deg = math.deg(th)

  local maxr = math.sqrt(2)
  if ((th_deg > 315) or (th_deg < 45)) or ((th_deg > 135) and (th_deg < 225)) then
    maxr = math.sqrt(1 + math.pow(math.sin(th),2))
  elseif ((th_deg > 45) and (th_deg < 135)) or ((th_deg > 225) and (th_deg < 315)) then
    maxr = math.sqrt(1 + math.pow(math.cos(th),2))
  end

  self.v = { r=math.sqrt(v.x*v.x + v.y*v.y)/maxr, th=th}
end