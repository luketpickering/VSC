require "Object"

require "graphics/Graphics"

camera_overlay = Object:new{}

function camera_overlay.Draw(camera)
  local vstart_cam = vector(100 ,10)
  local vworld_start = camera:WorldCoords(vstart_cam)
  local vworld_end = vworld_start:clone()
  vworld_end.x = vworld_end.x + Engine:mtopx(10) --m
  local vend_cam = camera:CameraCoords(vworld_end)

  love.graphics.line(vstart_cam.x, vstart_cam.y, vend_cam.x, vend_cam.y)
  love.graphics.line(vstart_cam.x, vstart_cam.y-2, vstart_cam.x, vstart_cam.y+2)
  love.graphics.line(vend_cam.x, vend_cam.y-2, vend_cam.x, vend_cam.y+2)

  local midline = (vstart_cam + vend_cam)/2
  midline.y = midline.y + 10
  Graphics:Print(string.format("10m = %spx", 
    math.floor(vend_cam.x - vstart_cam.x + 0.5)), midline:unpack())
end