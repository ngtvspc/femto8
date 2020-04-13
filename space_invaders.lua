function _init()
 t=0
 heart={}
 heart.x=64
 heart.y=120
 bullets={}
 bombs={}
 enemies={}
 _spawn_enemies()
end

function _spawn_enemies()
 local spr=0
 local x=0
 local y=0
 for x=1,16 do
  if (x<=4) then y=1
  elseif (x<=8) then y=2
  elseif (x<=12) then y=3
  elseif (x<=16) then y=4 end
  if (x<=8) then spr=10
  elseif (x<=16) then spr=9 end
  local enemy={
   x=(x%4) * 32 + 16,
   y=y*16,
   spr=spr,
  }
  add(enemies, enemy)
 end
end

function _update()
 if (btn(0)) and heart.x>2 then
  heart.x=heart.x-2
 end
 if (btn(1)) and heart.x<120 then
  heart.x=heart.x+2
 end
 if (btn(2)) and heart.y>80 then
  heart.y=heart.y-2
 end
 if (btn(3)) and heart.y<120 then
  heart.y=heart.y+2
 end
 if (btnp(4)) then
  shoot()
 end
 if (btnp(5)) then
  bomb()
 end
 bandit_shoot()
 bandit_move()
end

function _printh(value)
 printh(value, "space_invaders")
end

function bandit_shoot()
 local bandit=_pick_rand_bandit(.08)
 if bandit then
  local dagger={
   x=bandit.x,
   y=bandit.y,
   step=2,
   spr=11,
  }
  add(bullets,dagger)
 end
end

function bandit_move()
 local bandit=_pick_rand_bandit(1)
 if bandit.x>=128 then
  bandit.y+=8
  bandit.x=4
 end
 if bandit then
  bandit.x+=4
 end
end

function _pick_rand_bandit(rate)
 local _range=16/rate
 local _rand_val = flr(rnd(_range))
 if _rand_val < 16 then
  local bandit_idx=(_rand_val%16)+1
  return enemies[bandit_idx]
 end
 return false
end

function _draw()
 t+=1
 t%=30
 rectfill(0,0,127,127,0)
 beat_heart(t)
 draw_attacks()
 draw_enemies()
end

function draw_attacks()

 for bullet in all(bullets) do
  spr(bullet.spr,bullet.x,bullet.y)
  bullet.y+=bullet.step
  if bullet.y > 128  then
   del(bullets, bullet)
  end
 end

 for bomb in all(bombs) do
  spr(0, bomb.x, bomb.y)
  bomb.y+=bomb.step
  bomb.fuse-=1
  if bomb.fuse==0 then
   del(bombs,bomb)
  end
 end

end

function shoot()
 local bullet={
  x=heart.x,
  y=heart.y,
  step=-2,
  spr=8,
 }
 add(bullets,bullet)
end

function bomb()
 local bomb={
  x=heart.x,
  y=heart.y,
  step=-4,
  fuse=20,
 }
 add(bombs,bomb)
end

function draw_enemies()
 for enem in all(enemies) do
  spr(enem.spr,enem.x, enem.y)
 end
end

function beat_heart(t)
 if (t>22) then spr(7,heart.x,heart.y)
 else spr(6,heart.x,heart.y)
 end
end
