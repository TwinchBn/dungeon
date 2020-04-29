pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--dungeon
--by ben + jeffu warmouth

function _init()
	log={}
	make_ui()
	make_items()
	--make_map()
	gravity=.2
	make_player()
end --_init()

function _update()
 update_player()
 update_items()
 update_ui()
end --_update()

function _draw()
	cls()
	camera(p.x-64,p.y-64)
	map(0,0)
	--camera(0,0)
 --draw_items()
 --camera(64,64)
 draw_player()
 --debug()
 --if (log) debug()
 camera(0,0)
 draw_ui()
end --_draw()
 
function lerp(a,b,t)
	return a + t * (b-a)
end --lerp()

-----ui-----
function make_ui()
	set_ipanel({"< > move","🅾️ jump"},300)
end --make_ui()

function update_ui()
	if ipanel_timer then
		ipanel_timer -= 1
		if ipanel_timer <=0 then
			ipanel=nil
			ipanel_timer=nil
		end
	end
end --update_ui()

function set_ipanel(msg,t)
	ipanel=msg
 if (t==nil) ipanel_timer=30
end

function draw_ui()
	--foreach (ui,draw_panel)
	--draw_panel(cpanel,"l","b",1,8)
	if (ipanel) then
		draw_panel(ipanel,"c","m",1,8,true)
	end
end

function draw_panel(panel,horz,vert,fill,outline,centered)
	local x,y,w,h,gap = 0,0,0,0,3
	h = #panel*(5+gap)+gap --height
	--line width
	for i=1,#panel do
		local w2 = #(panel[i])*4 + gap*3
		if (w2>w) w=w2
	end --line length
	--panel width
	if (horz=="l") x=0
	if (horz=="r") x=127-w
	if (horz=="c") x=64-w/2
	--panel height
	if (vert=="t") y=0
	if (vert=="b") y=127-h
	if (vert=="c") y=64-h/2
	if (vert=="m") y=84
	rectfill(x,y,x+w,y+h,1)
	rect(x,y,x+w,y+h,8)
	for i = 1,#panel do
		local ln=panel[i]
		local mod=0
		if (centered) mod=(w-#ln*4)/2-gap
		
		print(ln,x+gap+mod,y+gap+(i-1)*(5+gap),6)
	end --for
end

--[[
function debug()
	local x,y,w,h,gap = 0,0,0,0,3
	h = #log*(5+gap)+gap --height
	for i=1,#log do --line width
		local w2 = #(log[i])*4 + gap*2
		if (w2>w) w=w2
	end --line length
	x,y = 127-w,127-h
	rectfill(x,y,x+w,y+h,1)
	rect(x,y,x+w,y+h,8)
	for i = 1,#log do
		print(log[i],x+gap,y+gap+(i-1)*(5+gap),6)
	end --for
end --debug()
--]]
-->8
--player
function make_player()
	p={     --attributes
		x=8,y=48,--pos
		speed=1,--walk speed
		jforce=-3,--jump force
		jumps=0,maxjumps=2,--jumps
		
		--temp stuff
		tx=0,ty=8,--temp x,y
		sp=3,w=4,h=8,--start sprite
		cell=0,--map cell sprite
		dy=0,--for gravity
 		gnd=false,--on ground?
 		xscale=1,flip=false,--flip
 		frame=0,--current anim frame
 		keys=0,

 		anim={
 			stand={sp={3},x=0,y=1,w=4,h=8,name="stand"},
				walk={sp={3,7,3,8},x=0,y=1,w=4,h=8,name="walk"},
				crouch={sp={2},x=0,y=2,w=4,h=8,name="crouch"},
				jump={sp={1},x=0,y=1,w=4,h=8,name="jump"},
				climb={sp={4,5},x=1,y=1,w=4,h=8,	name="climb"}
			}, --end anim
		inventory={},
		weapons={},
	} --end p
	p.state=p.anim.stand
	p.tx,p.ty=p.x,p.y
end

function update_player()
	p.cell=mget(p.tx/8,p.ty/8)
	
 	move() --includes climb
 	jump()
 	fall()

 	p.cell=mget(p.x/8,p.y/8)

 	--update animation
 	p.frame+=1
 	local index=(p.frame%#p.state.sp)+1
	p.sp=p.state.sp[index]
	--log_player()
end


--[[
function log_player()
	log={}
	add(log,"x,y: "..p.x..","..p.y)
	add(log,"w,h: "..p.state.w..","..p.state.h)
	add(log,"sprite: "..p.state.sp[1])
	add(log,"state: "..p.state.name)
	add(log,"xscale: "..p.xscale)
	add(log,"map cell: "..p.cell)
end
--]]


function move()
	--walking
	local speed=p.speed
	if (groundis(75)) speed/=2
		
	if btn(0) then
		p.flip=true
		p.xscale = -1
		p.tx-=speed
		--p.state=p.anim.walk
	end
	if btn(1) then
		p.flip=false
		p.xscale = 1
		p.tx+=speed
		--p.state=p.anim.walk
	end
	
	--climbing
	if onladder() then
		if (btn(2)) p.ty -= p.speed
		if (btn(3)) p.ty += p.speed
	end
	
	if not trymove() then
		p.tx,p.ty=p.x,p.y
	end
	
	--setting animation states
	if (p.y != p.ty) then
		p.y = p.ty
		p.state=p.anim.climb
	elseif (p.x != p.tx) then	
		p.x = p.tx
		p.state = p.anim.walk
	elseif btn(3) and not onladder() then
		p.state=p.anim.crouch
	else
		p.state = p.anim.stand
	end
end --move()


function jump()
	if (onladder()) return
	if (btnp(🅾️) and
					p.jumps<p.maxjumps) then
		--local up=mget(p.x/8,p.y/8)
		--if not fget(up,0) then
			--p.falling=true
			p.dy=p.jforce
			--p.y-=4
			p.jumps += 1
			--p.y+=p.jforce
		--end
	end
end --jump()

function onladder()
	if (touching(83)) return true
end --onladder()


function fall()
	if (onladder()) return
	if not p.gnd then
		p.dy+=gravity
		p.ty+=p.dy
		if hitground() then
			p.jumps=0
			p.dy=0
			p.gnd=true
			p.y=flr(p.y/8)*8+p.state.y
		elseif hithead() then
			p.dy=0
		else
			p.y+=p.dy
		end
	else -- if not falling
		if not hitground() then
			p.gnd=false
		end
	end
end --fall()

function trymove()
 	p.w=(p.state.w-p.state.x-1)*p.xscale
 	p.h=p.state.h-p.state.y-1
 	--[[
 	log={}
 	add(log,"player: "..p.x..","..p.y)
 	add(log,"anim x,y: "..p.state.x..","..p.state.y)
 	add(log,"anim w,h: "..p.state.w..","..p.state.h)
 	add(log,"xmod: "..p.w..","..p.h)

 	--]]
 	local hit = hithead() or	
 		 hitground() or hitbounds()
 	return not hit

 end --trymove()
 
 function bonk(x,y)
 	add(log,"bonk: "..x..","..y)
 	--add(log,"bonk: "..x..","..y)
 	return fget(mget(x/8,y/8),0)
 end --bonk

function hithead()
	if bonk(p.tx,p.ty) or
				bonk(p.tx+p.w,p.ty) then
		return true
	end
end --hithead()

function hitbounds()
	if p.tx<0 or p.tx+p.w<0 or
				p.tx>127*8 or p.tx+p.w>127*8 or
				p.ty<0 or p.ty+p.h<0 or
				p.ty>63*8 or p.ty+p.h>63*8 then
		return true
	end
end --hitbounds()

function hitground()
--one point only
	if (bonk(p.tx,p.ty+p.h)) return true
	
	--[[
	local x1,y1,x2,y2 = box(p,true)
	--local x1,y1,x2,y2 = pbox(p.tx,p.ty)
	if (bonk(x1,y2) or 
					bonk(x2,y2)) then
		return true
	end --if
	--]]
	
	--[[
	--local x1,y1,x2,y2 = pbox(p.tx,p.ty)
	if bonk(p.tx,p.ty+p.h) or
				bonk(p.tx+p.w,p.ty+p.h) then
		return true
	end
	--]]
end --hitground()

function groundis(sp)
 if mget(p.tx/8,p.ty+10/8) == sp then
 	return true
 end
end


function pbox(x,y)
	--return player hit box
	local x1=x-p.state.w/2
	local x2=x+p.state.w/2
	local y1=y+7-p.state.h
	local y2=y+7
 	return x1,y1,x2,y2
 end --pbox()

 function box(obj,temp) --return box
 	local x,y = obj.x,obj.y
 	if (temp) x,y=obj.tx,obj.ty
 	local x1=x-obj.w/2
 	local x2=x+obj.w/2
 	local y1=y+7-obj.h
 	local y2=y+obj.h
 	return x1,y1,x2,y2
 end --box()


function draw_player(outline)
	--p.sp=p.state.sp[]
	
 --local x1,y1,x2,y2 = box(p)
	local x1,y1,x2,y2 = pbox(p.x,p.y)
	local xsp=x1-p.state.x
	if (p.flip) xsp=x1-8+p.state.w+p.state.x
	spr(p.sp,xsp,y1,1,1,p.flip)
	
-- bounding box
	if outline then
		rect(x1,y1,x2,y2,6)
		rectfill(p.x,p.y,p.x,p.y,9)
	end
end --draw_player()
	
--[[
function climb()
	local y=p.y
	if fget(mget(p.x/8,p.y/8),1) then
		if btn(2) then
			p.y -= p.speed
			p.state=p.anim.climb
		end
		if btn(3) then
			p.y += p.speed
			p.state=p.anim.climb
		end
	end
end
--]]


--[[
function bonk4()
	if bonk(p.tx,p.ty) or
				--bonk(p.tx,p.ty+p.h) or
				bonk(p.tx+p.w,p.ty) or
				--bonk(p.tx+p.w,p.ty+p.h) then
				hitground() then
		return true
	end
end --bonk4()
--]]

--[[
function move_player()
	if (p.state==p.anim.stand
		or p.state==p.anim.walk) then
		walk()
	end
end

function walk()
	local x,y = p.x,p.y
	if (btn(0)) x-=speed
	if (btn(1)) x+=speed
	if (collide(p) == false) then
		p.x,p.y = x,y
		p.state = p.anim.walk
	else
		p.state = p.anim.stand
	end
end
--]]

--[[
function draw_player()
	spr(p.state.spr[0], 
	p.x+p.state.x, 
	p.y+p.state.y)
end
--]]
-->8
--enemies
-->8
--map

function make_items()
 	--keys={}
 	--temp_item=nil
 	--keys={}

 	for y=0,32 do
 		for x=0,128 do
 			--local cell=mget(x,y)
 			--[[
 			if cell==84 then --key
 				add(keys,{x=x,y=y})
 				add(keys,{x=x*8,y=y*8,
 					w=8,h=8,name="key"})
 				mset(x,y,0)
 			end -- key
 			--]]
 		end -- for x
 	end --for y
end --make_items
 
 
function update_items()
 	--ipanel=nil
 	
 	local x,y,t=near(84)
 	if t then --key
 			set_ipanel({"key","pick up (❎)"})
 			if btnp(❎) then
 				set_ipanel({"key acquired"})
 				p.keys += 1
 				mset(x,y, 0)
 			end
 	end --keys
 	
 	local x,y,t=near(81)
 	if t then --door
 		if (p.keys>0) then
 			set_ipanel({"key door","unlock (❎)"})
 			if btnp(❎) then
 				set_ipanel({"door unlocked"})
 				p.keys -= 1
 				mset(x,y,82)
 			end
 		else
 			set_ipanel({"door locked","need a key"})
 		end
 	end -- locked door
 		
 	local x,y,t=near(79)
 	if t then --key
 			set_ipanel({"wooden door","open (❎)"})
 			if btnp(❎) then
 				set_ipanel({"door opened"})
 				mset(x,y, 80)
 			end
 	end --wooden door
 		
end --update_items()

--[[
function draw_items()
 	--[[
 	for k in all (keys) do
 		spr(84,k.x*8,k.y*8)
 		spr(84,k.x,k.y)
 	end
 	--]]
 end --draw_items
--]]
-->8
--biomes
--[[ comments
biome names!!!!!

prison,outside,uderground beach
snowy mountan caves,unmeables cavern
aliens home,music jungle






]]
-->8
--collision


 function box(obj,temp) --return box
 	local x,y = obj.x,obj.y
 	if (temp) x,y=obj.tx,obj.ty
 	local x1=x-obj.w/2
 	local x2=x+obj.w/2
 	local y1=y+7-obj.h
 	local y2=y+obj.h
 	return x1,y1,x2,y2
 end --box()


 function collide(p,e)
 	local l1,t1,r1,b1 = box(p)
 	local l2,t2,r2,b2 = box(e)
 	if r1>l2 and r2>l1 and
 				b1>t2 and b2>t1 then
 	--[[
 	local x1,y1,w1,h1 = 
 		p.x+p.state.x,
 		p.y+p.state.y,
 		p.state.w,p.state.h
 	local x2,y2,w2,h2 =
 		e.x,e.y,e.w,e.h
 	
 	if (x1+w1>x2 and x2+w2>x1 and
 					y1+h1>y2 and y2+w2>y1) then
 	--]]
 	 return true
 	end
 end
 
 function touching(sp)
		local x1,y1,x2,y2 = box(p,true)
		if (mget(x1/8,y1/8) == sp or
				 mget(x2/8,y1/8) == sp or
				 mget(x1/8,y2/8) == sp or
				 mget(x2/8,y2/8) == sp) then
		--return fget(p.cell,1)
		return true
	end
end

function near(sp)
	local x,y = flr(p.x/8),flr(p.y/8)
	if (mget(x,y) == sp) return x,y,true
	if (mget(x-1,y) == sp) return x-1,y,true
	if (mget(x+1,y) == sp) return x+1,y,true
end

 --[[
 function hitwall()
 	--facing left
 	local mod=(p.state.w-p.state.x)*p.xscale
	local x=p.tx+mod*p.xscale
	local y=p.ty-p.state.y
	local top=mget(x+mod,y)
	local btm=mget(x+mod,y+p.state.h)
	if fget(top,0) or 
				fget(btm,0) then
		return true
	else
		return false
 	end
 end


 function collide_all()
 	for e in all (enemies) do
 		if (collide(p,e)) return true
	end
	for w in all (walls) do
		if (collide(p,w)) return true
 	end
 	return false
 end

 function collide(p,e)
 	local x1,y1,w1,h1 = 
 		p.x+p.state.x,
 		p.y+p.state.y,
 		p.state.w,p.state.h
 	local x2,y2,w2,h2 =
 		e.x,e.y,e.w,e.h

 	if (x1+w1>x2 and x2+w2>x1 and
 					y1+h1>y2 and y2+w2>y1) then
 	 return true
 	else
 		return false
 	end
 end
 --]]
__gfx__
00000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ce0000000000000c000000001c00c0000c00c1000000000c0000000c000000000000000000000000000000000000000000000000000000000000000
0070070008801000c00000000ce00000010cc000000cc010000000000ce000000ce0000000000000000000000000000000000000000000000000000000000000
00077000088100000ce0000008801000011881100118811000000000088010000880100000000000000000000000000000000000000000000000000000000000
00077000022000000880000008810000000880100108800000000000088100000881000000000000000000000000000000000000000000000000000000000000
007007002002000008810000022000000002201001022000001100c0022000000220000000000000000000000000000000000000000000000000000000000000
00000000000000000220000020020000002002000020020022288c00200200002002000000000000000000000000000000000000000000000000000000000000
00000000000000002002000020020000002002000020020022288e00000200002000000000000000000000000000000000000000000000000000000000000000
00000000600005000000000000000000000000000000000000000900000000000005550001055500010555001105550000055500e4e4d8d80000000000000000
60000500600d50c0600005006000050000000000000000000000999000000000000c5c00010c5c00010c5c00110c5c00000c5c00444488880000000000000000
600d50c060122010600d50c0600d50c0005000000000000000000900aa1b1baa0005550005655500056555000605550600055506444488880000000000000000
60122010510221006012201060122010000500000000000000000000a7bbbb7a0006660005066600050667770666666606666666444488880000000000000000
51022100050110005102210051022100000600000000bbbb00001b1b77bbbb7700606060000060600000677700006000000060001b1bc9c90000999900008888
050110000010010005011000050110000506110000001b1b0000bbbb00bbbb000000100000001000000017770000100011001000bbbb99990000c9c90000d8d8
00100100000000000010010000100100005621110000bbbb0000bbbb000000000001010000010100000101700001010011010100bbbb99990000999900008888
00100100000000000010000000000100c0d221110000bbbb0000bbbb000000000001010000010100000101000001010000010100bbbb99990000999900008888
00000000000000000000000000000000000000006008800600000110000000000000000000000000000005500000000000000000000000000000000000000000
00444400000000000000000000000000000000006001100600000110060777770600c0c0000000007700015000000000000c5c00000000000000000000000000
6094940000000000000000000000000000001100601111060000c88c6467c5c70600110000888880070005500000000000005000005000000000000000000000
60444400000000000001111100000000000005006111111600008888040775770bb001b0008ccc800dddd6600000000005666665005500000000000000000000
600400000000000400010000000011110000111155111155000002200457777700bbb1b000888880060006600000000005066605000550000011110000004444
6555550004940554000100000000818100008181001001000000222204077777000011100000200006005665000ddd000500600500005000005000000000e4e4
55040550044455440080800000001111000011110010010000002002040666660000b0b0000020000600555555566655057777750c0667770c6c000000004444
00044444049444400000000000001111000011110000000000002002000650560000b0b000002222000050055156665500700070055067770666777700004444
00000000000000000006000000000000000000000bbb333000003330000ccc000000000000000000000000000c0c000000000000000000000000000000000000
00000000000cccc0886660000000000000000bbb0b0000300000bbb0000080000000000000000000000000000088000000000000000000000000000000000000
00000000cc7c66c7888600600000000000000b000b00003000003330099080990090900000000000000000000090000000000000000000000000000000000000
000c0000007cccc7cc8006660000000000000b000b0000300000b0000998b89990bbbb0999900999009bb9000099900000000000000000000000000000000000
00cc7777cc777777cc88886806000000000bbb00bbb00333000bbb0009ab8ba90bb99bb09a9009a99bb99bb90000990000000000000000000000000000000000
000c6767007cccc70888880866606000000bbb00bbb00333000bbb0009a8b8a9bb9999bbbbbbbbbbbb9999bb000aaa0000000000000000000000000000000000
00cc7777cc7cccc788888888c6866688000bbb0000000000000bbb000aa000aab999999b9b9bb9b9b999999b000a0a00c899aa00000000000000000000000000
000c7777000c00c080080080cc8868880000000000000000000000000000000099000099999999999999999900a00a00c99aa0aa000000000000000000000000
11111111511111515111511622222228bbbbbbbbbbbbbbbb1c1c1c1cccceeccc77776777c7cccccccc888877dddddd4544444444000011000001111000004400
111111111511151116151151222e2228b377773bb333333bc1c1c1c1c8eeee8c777777677c7ccc7c7c8888c6d55ddd4544444644000018000001118000004400
15111151151151111151161522e28888b739937bb3bbbb3b11111111cc9ee9cc67677777cccc7cc777c777c7d5d5445445444444000081000001118000004400
1151151111511511111651112e228e22b793397bb3b33b3bc1c1c1c1c8c99c8c77777677ccc7ccc7677cccc7d555445444444544000088000001888000005500
11155111151551111115611122e282e2b793397bb3b33b3bdcdcdcdc9c9889c977767777ccc7ccc777cc7776d555554544444444000088000001118000004400
11588511511155115161151122888e22b739937bb3bbbb3bdddddddd898888987767777777cc7cc776cc8887d5d5444544454444000018000001888000005500
111551111511151115115161228222e2b377773bb333333bdcdcdcdc9c9889c977777767cc7ccc7c77c78886dd55445444444464000081000001118000004400
11111111511111516115111522822222bbbbbbbbbbbbbbbbcdcdcdcdc8c88c8c76777777ccc7cccc67ccccc7dddd445446444444000011000001111000004400
00044440000066000006666040000004000060000000000000000000a99ada9900000000111111111111111182222222b333333b000000000000000000000000
00044440000066000006666044444444000606000000000000000000a9aaa99a0000000018811111111111158888222833044033000000000000000000000000
00044440000077000006667040000004000060000000000000000000a9aa99aa000000001118818811111d51222882883b0440b3000000000000000000000000
00055550000055000006665044444444000060000000000000000000aaa99aaa00000000111118811115155122228282bb0440bb000000000000000000000000
00044440000055000006665040000004000060000505050500000000da99aa9a0000000011818811111155518888828cbb0440bb000000000000000000000000
00055550000077000006667044444444006660000505050500500050a99aaa9a0000000011818111111112218888888cb004400b000000000000000000000000
00044440000066000006666040000004000060000505050505050505a9adaa9a00000000118111811111211288222ccc33344333000000000000000000000000
0004444000006600000666604444444400666000666666666666666699aaa9ad00000000181118811111211222222ccc30044003000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000d3d3d300000000000000000054000000005400000000000000c4000000c4000000000000d5d500750000000000000000000000d50000d575000000
84358484840085848484848435840000000000000000000000000000000085900000000013001313000c13000000000000000000130013131313001300000000
0000850cd3d3d3d3008585850000000000540071d5d500545454c4c4c4c4c4d3d38585c4c4c4d5a7000bbb0075d58585d5d5d5d5d5d5d5d5d5d5d5d575000085
75357585858485858585858535840000000000000000000000000000000085000000000077bbbb77003313130013000013131313131313131313131300000000
8585d3d3d3d3d3d3d38585858500000000540071d5d50000000000000000f485858585f285f2c40700d5757575d5d5d5d5d5d5d5e1e1d50000d5d50075000000
753575858584848585850072358400000000000000000000000000000000bbbb0000131300bbbb00000bbb131313000000131300131313001313130000000000
d3d385d3d3d3d3d3d38585858500000000540000000000545454c4c4c4c4c4c4c4c4c4c4c4c40000000b7500f400000000000000757575757575757575000000
753575850084848484848484358400000000000000000000000000000000bbbb0000bbbb00000000000b0b000013131300000000000013000000000000000000
d3d3d38585858585858500008500000000546161000054000000000000000000753585000000e100004575007564646464646464757575757575757500000000
75357500000085000000008435840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
85008585850085850085000085000000005454545454540000000000000000007535756464646455557500007575757575757504858585858585850004757575
75357500000000000000008435840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
85858500000000000085008585000000000000000000000000000000000000007535757575757575758500007500000000000004000000000000000004757575
75357500000000000000008435840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000850000000000000000000000000000000000000000743500510000858500e1000015000000000000d48500008585850000d4000000
00357500008484848484840000008484848484848484840000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000856464646464647575757575757575757575750485858585b385850004757575
75757500840000000000000000000000000000720000840000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000646464646464646400000000
00000000840000000300000384848484848484848435840000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008472008484848400000000000000008435840000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000084720000008400000000000000858435840000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000848585008400000000000000858435840000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000848484358400000000000000008435840000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000085850084358400000000000000008435840000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000858500000084358400000000000000008435840000000000008584848484840000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358400000000000000008435840000000000008584350035840000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358400000000000000008435840000000000000084358435840000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000008435848484848484848484a435840000000000000084358435848500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358572000000000000008535840000000000000084358435840000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084350000848494949494948484840000000000000084358435840000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358484840000000000000000000000000000000084358435840000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358484848400000000008484848484848400000084358435840000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358484848484848484040000000000000004848484358435840000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000008435000000001300e200d400858585000000d4000000358435840000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000008484848484848484848404008585c200000004848484848435848585858500000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000009494949494949400000000008435008585858500000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000008484848585858500000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101000001000100020000000100010101000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000585851535800530000184200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242534242534242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5858585858534242535100184200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5458585858534242534242424200585858580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242534242534f00544200585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5858585842534242424253424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000004f534200004153410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424200004153410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004153410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004153410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000005800000000004153410000000042424200000000000058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242420000004242424200000042424242424258580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000510000000000000000005400005800000000000051004258580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242420000194242424253424242424242180000424242425858580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004b4b4c0000004253420000000000424242000000424245454545454545454545454545454545454545454500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004253420000000000000000000000425300000000000000170000000000000000000000000045450000585800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424253424242424242424242420000425300580000000000000000000000000000000000000000004500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000534200000000000000004200004c5345454545454500150000170000000000000000000000004500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001b00581a00001b00005100002800540028004200004c534c4c4c4c4c4c45450000000000000000000000000000544400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00424242424242424242424242424242424242534258584c534c4c4c4c4c4c4c4c4500150000001d3d00165d000045450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004200000000000000000000000000000000425342585842534c4c4c4c4c4c4c4c4c45454500004545454545454500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004200000000000000000000000000000000425342000042534c4c4c4c4c4c4c4c4c4c4c4c00004c4c4c4c4c4c4c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0042000000000000424242424242424200004253420000425342000000000000000000004c00004c005d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0042424242424040000000000000000041004253420000425342000000000000000000004c00004c5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000040000000000000000041004253420000425342000000000000000000004c00584c000000004c4c4c004c4c4c4c4c4c4c58000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000584d00000000000000004d00425342424242534200000000004c4c4c4c4c4c00584c4c4c4c4c00004c4000000000000000404c4c4c000000000000000000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424040000000002a000000410000584f000000534200000000004c000000004f00004f000000000000514d000000000000004d00004c000000000000000000000000004800480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000042424242424242420042424242424242424200000000004c004c4c4c4c4b4b4b4b4c4c4c4b4b4b4000000020000000404c534c000000000000000000000000480000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000004c004c000000000000000000004c4c4c00434c4c4b4c4c43004c534c000000000000000000000048000000480048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000004c004c000000000000000000000000000000000000000000004c534c000000000048484848484800000048000053480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003d3d3d00000000000000000045454545454500000000000000004c004c000000000000000000000057575757575757575757574c534c575700000048530000000000584800000053480000000000000000000000000000000058000000000031000000000000000000000000000000000000310000000000000000
