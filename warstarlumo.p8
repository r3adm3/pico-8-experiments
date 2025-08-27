pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--tab 0, main loops
--tab 1, starfield code
--tab 2, ship code
--tab 3, missiles

function _init()
	init_starfield()
	init_ship()
	init_torpedo()
end

function _draw()
 draw_starfield()
 draw_ship()
 draw_torpedo()
end

function _update()
 update_starfield()
 update_ship()
 update_torpedo()
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
 cls(0)
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
end

function ship_back()
 ship.y += 1
end

function ship_fwd()
 ship.y -= 1
end

function ship_left()
 ship.sprite = 4
 ship.x -= 1
end

function ship_right()
 ship.sprite = 3
 ship.x += 1
end
-->8
function init_torpedo()
 torpx={}
 torpy={}
 torpspr={} 
 
 torpx[1]=64
 torpy[1]=120
 torpspr[1]=1
 debug=torpy[1]
end

function draw_torpedo()
 print(debug)
 spr(5,torpx[1],torpy[1])
end

function update_torpedo()
 if (torpspr[1] < 3) then 
  torpspr[1]=torpspr[1]+1
 else
  torpspr[1]=1
 end
 
 if (torpy[1] < 121 and torpy[1] > 10 ) then
 	torpy[1] = torpy[1] - 3
 else 
  torpy[1] = 120
 end
end

__gfx__
00000000000660000006600000066000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000660000006600000066000000660000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000006600000066000000610000001600000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000110000001100000061100001160000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000005115000051150000055500005550000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700065665600656656000656560065656000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000065665600656656000656560065656000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000009a000000a90000000a000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
