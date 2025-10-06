pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- collision game
-- player sprite vs enemy sprite

function _init()
  -- player sprite (controllable)
  player = {
    x = 64,
    y = 64,
    w = 8,
    h = 8,
    spr = 1
  }
  
  -- enemy sprite (moves automatically)
  enemy = {
    x = 32,
    y = 32,
    w = 8,
    h = 8,
    spr = 2,
    dx = 0.5,
    dy = 0.3
  }
  
  collision = false
end

function _update()
  -- player movement
  if btn(0) then player.x -= 1 end  -- left
  if btn(1) then player.x += 1 end  -- right
  if btn(2) then player.y -= 1 end  -- up
  if btn(3) then player.y += 1 end  -- down
  
  -- keep player on screen
  player.x = mid(0, player.x, 120)
  player.y = mid(0, player.y, 120)
  
  -- enemy movement (bouncing)
  enemy.x += enemy.dx
  enemy.y += enemy.dy
  
  -- enemy screen wrapping/bouncing
  if enemy.x <= 0 or enemy.x >= 120 then
    enemy.dx = -enemy.dx
  end
  if enemy.y <= 0 or enemy.y >= 120 then
    enemy.dy = -enemy.dy
  end
  
  -- collision detection
  collision = check_collision(player, enemy)
end

function _draw()
  cls()
  
  -- draw collision status at top
  if collision then
    print("collision: true", 4, 4, 8)  -- red text
  else
    print("collision: false", 4, 4, 5) -- gray text
  end
  
  -- draw sprites
  spr(player.spr, player.x, player.y)
  spr(enemy.spr, enemy.x, enemy.y)
  
  -- draw instructions
  print("use arrow keys to move", 4, 115, 6)
end

function check_collision(a, b)
  return a.x < b.x + b.w and
         a.x + a.w > b.x and
         a.y < b.y + b.h and
         a.y + a.h > b.y
end
__gfx__
00000000888888882222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000800000082000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000800000082000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000800000082000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000800000082000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000800000082000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000800000082000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888882222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
