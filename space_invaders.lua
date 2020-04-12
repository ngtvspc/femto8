function _init()
 heart={}
 heart.x=64
 heart.y=64
 t=0
 bullets={}
end

function _update()
 if (btn(0)) and heart.x>2 then
  heart.x=heart.x-2
 end
 if (btn(1)) and heart.x<120 then
  heart.x=heart.x+2
 end
 if (btn(2)) and heart.y>2 then
  heart.y=heart.y-2
 end
 if (btn(3)) and heart.y<120 then
  heart.y=heart.y+2
 end
 if (btn(4)) then
  shoot()
 end
end

function _draw()
 t+=1
 t%=30
 rectfill(0,0,127,127,0)
 beat_heart(t)
end

function shoot()
 local bullet = {}
 spr(1, heart.x, heart.y)
end

function beat_heart(t)
 if (t>22) then spr(7,heart.x,heart.y)
 else spr(6,heart.x,heart.y)
 end
end
