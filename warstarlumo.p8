pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--tab 0, main loops
--tab 1, starfield code
--tab 2, ship code
--tab 3, missiles
--tab 4, enemy
--tab 5, collisions
--tab 6, explosions

function _init()
	score=0
	wave=1
	kills_this_wave=0
	init_starfield()
	init_ship()
	init_torpedo()
 init_enemy()
 init_explosions()
end

function _draw()
 cls(0)
	print ('score: '..score..' wave: '..wave)

 draw_starfield()
 draw_ship()
 draw_enemy()
 draw_torpedo()
 draw_explosions()
end

function _update()
 update_starfield()
 update_ship()
 update_enemy()
 update_torpedo()
 update_explosions()
end


-->8
function init_starfield()
 numofstars = 100
 debug = 0
 starcolours = {1,5,6,7,10,9,12}
 starx={}
 stary={}
 starc={}
 starspd={}

 for i=1,numofstars do
  starx[i] = rnd(128)
  stary[i] = rnd(120) + 6
  starspd[i] = rnd(0.7)+0.5
  if (rnd() < 0.4) then 
   starc[i] = 7
   starspd[i] = rnd(1.5)+0.5
  else
   starc[i] = starcolours[flr(rnd(7))]
  end
 end
 
end

function draw_starfield()
-- cls(0)
 starfield()
end

function update_starfield()

end

function starfield()
 for i=1,numofstars do
  pset(starx[i],stary[i],starc[i])
 end
 animatestarfield()
end

function animatestarfield()
 for i=1,numofstars do
  stary[i] = stary[i] + starspd[i]
  if (stary[i]>122) then
   stary[i] = 6
   starx[i] = rnd(128)
  end

 end 
end
-->8
function init_ship()
 ship = {
  sprite = 1,
  x = 64, 
  y = 100,
 }
end

function draw_ship()
 spr(ship.sprite, ship.x, ship.y)
end

function update_ship()
 ship_nomove()
 ship_action()
end

function ship_nomove()
 if ship.sprite==1 then
  ship.sprite = 2
 else
  ship.sprite = 1
 end
end

function ship_action()
 if btn(⬆️) then
   ship_fwd()
 end
 if btn(⬇️) then
  ship_back()
 end
 if btn(⬅️) then
  ship_left()
 end
 if btn(➡️) then
  ship_right()
 end
 if (btn(🅾️) and torpedo.fired==0) then
  fire_torpedo(ship.x,ship.y)
 end
end

function ship_back()
  if (ship.y > 69 and ship.y < 120) then 
   ship.y += 1
  end
end

function ship_fwd()
 if (ship.y < 128 and ship.y > 70) then
  ship.y -= 1
 end
end

function ship_left()
 ship.sprite = 4
 if (ship.x > 0) then
  ship.x -= 1
 end
end

function ship_right()
 ship.sprite = 3
 if (ship.x < 119) then 
  ship.x += 1
 end
end
-->8
function init_torpedo()
 torpedo = {
	 sprite = 5,
	 x = 64,
	 y = 100,
	 w=8,
	 h=8,
	 fired = 0
 }
end

function draw_torpedo()
 if (torpedo.fired == 1) then
  spr(torpedo.sprite, torpedo.x, torpedo.y)
 end 
end

function update_torpedo()
  if (torpedo.fired == 0) then
   return -- don't update if not fired
  end
  
  torpedo.y = torpedo.y - 2
  if (torpedo.y <= 0) then
   torpedo.fired=0
  end

  -- check collision with all enemies
  for e in all(enemies) do
   if e.active and (boolcollision(torpedo,e) == true) then
  		score = score + 1
  		kills_this_wave = kills_this_wave + 1
  		torpedo.fired=0
    create_explosion(e.x+4, e.y+4)
    enemy_hit(e)
    
    -- check for wave progression
    if kills_this_wave >= 1 then
     wave += 1
     kills_this_wave = 0
     spawn_new_wave()
    end
    break
   end
  end

end

function fire_torpedo()
  torpedo.fired=1
  torpedo.x = ship.x
  torpedo.y = ship.y - 7
end
-->8
-->8
function init_enemy()
 enemies = {}
 
 -- spawn initial enemy
 add(enemies, create_enemy())
end

function create_enemy()
 -- determine if this enemy can dive (after wave 10)
 local can_dive = false
 if wave >= 10 then
  local divers_allowed = wave - 9 -- wave 10=1, wave 11=2, etc
  local current_divers = 0
  for e in all(enemies) do
   if e.can_dive then current_divers += 1 end
  end
  if current_divers < divers_allowed then
   can_dive = true
  end
 end
 
 local e = {
  sprite=6,
  x=20 + rnd(88),
  y=-8,
  w=8,
  h=8,
  dx=0.2-rnd(0.4),
  dy=0.5,
  minx=8,
  maxx=112,
  miny=8,
  maxy=can_dive and 80 or 50, -- divers go lower
  active=true,
  respawn_timer=0,
  speed_mult=1 + (wave-1) * 0.2, -- faster based on wave
  can_dive=can_dive
 }
 return e
end

function update_enemy()
 for e in all(enemies) do
  -- handle respawn countdown
  if not e.active then
   e.respawn_timer -= 1
   if e.respawn_timer <= 0 then
    spawn_enemy(e)
   end
  else
   -- update position
   e.x += e.dx * e.speed_mult
   e.y += e.dy * e.speed_mult
   
   -- hard clamp position first
   e.x = mid(e.minx, e.x, e.maxx)
   e.y = mid(e.miny, e.y, e.maxy)
   
   -- if flying in from top, wait until fully in bounds
   if e.y <= e.miny then
    e.y = e.miny
    e.dy = abs(e.dy)
    if e.dy < 0.1 then 
     e.dy = 0.1 * e.speed_mult 
    end
   elseif e.y >= e.miny and e.dy > 0.2 then
    e.dy = (0.1-rnd(0.2)) * e.speed_mult
    e.dx = (0.2-rnd(0.4)) * e.speed_mult
   end
   
   -- bounce off boundaries
   if e.x <= e.minx or e.x >= e.maxx then
    e.dx = -e.dx
    e.dy = (0.1-rnd(0.2)) * e.speed_mult
   end
   
   if e.y >= e.maxy then
    e.dy = -abs(e.dy)
    e.dx = (0.2-rnd(0.4)) * e.speed_mult
   end
   
   -- collision avoidance with other enemies
   avoid_enemies(e)
   
   -- occasionally change direction randomly
   if rnd() < 0.02 then
    e.dx = (0.2-rnd(0.4)) * e.speed_mult
    e.dy = (0.1-rnd(0.2)) * e.speed_mult
   end
  end
 end
end

function avoid_enemies(e)
 for other in all(enemies) do
  if other != e and other.active and e.active then
   local dist = sqrt((e.x-other.x)^2 + (e.y-other.y)^2)
   if dist < 12 then -- collision radius
    -- push away from other enemy
    local push_x = (e.x - other.x) / dist
    local push_y = (e.y - other.y) / dist
    e.dx += push_x * 0.3
    e.dy += push_y * 0.3
    -- clamp speed
    local spd = sqrt(e.dx^2 + e.dy^2)
    if spd > 1 then
     e.dx = e.dx / spd
     e.dy = e.dy / spd
    end
   end
  end
 end
end

function draw_enemy()
 for e in all(enemies) do
  if e.active then
   spr(e.sprite, e.x, e.y)
  end
 end
end

function enemy_hit(e)
 e.active = false
 e.respawn_timer = 150
 e.speed_mult += 0.2
end

function spawn_enemy(e)
 e.active = true
 e.x = 20 + rnd(88)
 e.y = -8
 e.dx = (0.2-rnd(0.4)) * e.speed_mult
 e.dy = 0.5 * e.speed_mult
end

function spawn_new_wave()
 -- add one new enemy per wave (max 15 on screen)
 if #enemies < 15 then
  add(enemies, create_enemy())
 end
end
-->8
function boolcollision(a,b)
  return a.x < b.x + b.w and
         a.x + a.w > b.x and
         a.y < b.y + b.h and
         a.y + a.h > b.y
	
end
-->8
function init_explosions()
 exps={}
 clrs={5,9,10,7}
end

function draw_explosions()
 for p in all(exps) do
  circfill(p.x,p.y,p.scale,clrs[p.c])
 end
end

function update_explosions()
 for p in all(exps) do
  p.x+=p.spdx
  p.y+=p.spdy
  p.scale-=.1
  p.l-=.1
  p.c=flr(p.l)
  if p.l<=0 then del(exps,p) end
 end
end

function create_explosion(xp, yp)
  for i=0,5 do
    add(exps,{
      x=xp,
      y=yp,
      spdx=1-rnd(2),
      spdy=1-rnd(2),
      scale=2+rnd(5),
      l=5,
      c=4
    })
  end
end
__gfx__
00000000000660000006600000066000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000660000006600000066000000660000009000000500500000000000000000000000000000000000000000000000000000000000000000000000000
007007000006600000066000000610000001600000aaa00006566560000000000000000000000000000000000000000000000000000000000000000000000000
00077000000110000001100000061100001160000009000056566565000000000000000000000000000000000000000000000000000000000000000000000000
00077000008118000081180000088800008880000008000066566566000000000000000000000000000000000000000000000000000000000000000000000000
00700700068668600686686000686860068686000008000006511560000000000000000000000000000000000000000000000000000000000000000000000000
00000000068668600686686000686860068686000008000000566500000000000000000000000000000000000000000000000000000000000000000000000000
000000000009a000000a90000000a000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
