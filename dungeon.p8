pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--dungeon
--by ben + jeffu warmouth

function _init()
	trace=false
	active=false
	gravity=.2
	init_enemies()
	init_items()
	init_player()
	init_ui()
	init_cam(true) --true=halfsize
end --_init()

function _update()
	--poke(0x5f00+92,255)
	log={}
	if active then
 	update_player()
 	update_enemies()
 	update_items()
 	update_cam()
 end
 update_ui()
end --_update()

function _draw()
	cls()
	draw_cam()
	--map(0,0,0,0,128,64)
 map(0,0,0,0,128,64)
 if active then
 	foreach(enemies,draw_enemy)
 	draw_player()
 end
 camera(0,0)
 draw_ui()
end --_draw()


--------------------
-----  buttons  ----
--------------------
function btnu(b)
	if b==⬆️ or b==🅾️ then
		if not btn(b) and p.⬆️ then
			p.⬆️ = false
			return true
		end
	end
end --btnu

function btnd(b)
		if b==⬆️ or b==🅾️ then
		if btn(b) and not p.⬆️ then
			p.⬆️ = true
			return true
		end
	end
end --btnd


--------------------
-----  utility  ----
--------------------
function lerp(a,b,t)
	return a + t * (b-a)
end --lerp()

function movet(a,b,m)
	local d = abs(b-a) --distance
	if (d<=m) return b
	--if (b<a) m *= -1
	--return a + d * m
	return a + sgn(b-a) * m
end --movetowards



--------------------
-----  camera  -----
--------------------
function init_cam(half)
	cam={}
	gamew,gameh=128,128
	cam.w,cam.h=gamew/2,gameh/3
	if (half) then
		poke(0x5f2c,3)
		gamew,gameh=64,64
		cam.w,cam.h=gamew/2,gameh/2
	end    
	cam.lx=p.x
	cam.ly=p.y
	cam.x=p.x-cam.w
	cam.y=p.y-cam.h
	cam.cx=0
	cam.cy=0
	camx_timer=30
	camy_timer=60
	camxspeed=0
	camyspeed=0
	
	--start menu
	cam.x = 0
	cam.y = 450
end

function update_cam()
	--no lerp
	--[
	cam.x=p.x-cam.w
	cam.y=p.y-cam.h
	--]]
	
	--lerp cam x speed
	--[[
	cam.cx=movet(cam.cx,p.cx,1/5)
	cam.cy=movet(cam.cy,p.cy,1/5)
	cam.x += cam.cx
	cam.y += cam.cy
	add(log,"cam: "..cam.x..","..cam.y)
	--]]

	
	--update cam x
	--[[
	if lerpx==p.x then
		camx_timer=15
	else
		camx_timer -= 1
		if camx_timer<0 then
			lerpx=lerp(lerpx,p.x,.2)
			if (abs(lerpx-p.x)<1) lerpx=p.x
		end
	end
		--update cam y
	if lerpy==p.y then
		camy_timer=20
	else
		camy_timer -= 1
		if camy_timer<0 then
			lerpy=lerp(lerpy,p.y,.2)
			if (abs(lerpy-p.y)<1) lerpy=p.y
		end
	end
	
 if hitground() or onladder() then
 	--lerpy=lerp(lerpy,p.y,0.15)
 end
 --]]
end --update_cam()

function draw_cam()
	--camera(lerpx-camw,lerpy-camh)
	camera(cam.x,cam.y)
end
 

-->8
--ui

function init_ui()
	--log={}
	dpanel={"you have been","pix-cel-ated","❎ restart"}
 spanel={--"p|x ✽ cels",
 								--"p|x ● cels",
 								--"p|x ☉ cels","",
 								"❎ start"}
	set_ipanel({"⬅️⬇️⬆️➡️ move"},300)
	uh={x=0,y=0,w=12,h=0,cb=8,cf=11} --health
	uk={x=0,y=2,w=6,h=3} --keys
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
	if (active and ipanel) then
		draw_panel(ipanel,"c","b",1,8,true)
	end
 if (log) then
 	--draw_panel(log,"r","b",1,8)
 end
 for i=1,p.keys do
 	spr(93,uk.x+uk.w*(i-1),uk.y)
 end
 healthbar()
 if (not active and not p.dead) then
  draw_panel(spanel,"c","b",1,8,true,4)
 	if btnp(❎) then
 	 active = true
 	end --if btnp(❎)
 end
 if (p.dead) then
 	draw_panel(dpanel,"c","c",1,8,true)
 	if btnp(❎) then
 	 reload(0x2000, 0x2000, 0x1000)
 		_init()
 	end --if btnp(❎)
 end --if p.dead
end

function healthbar()
	--rectfill(0,0,20,0,8)
	--uh.fill=uh.w*p.health/p.maxhealth
 uh.w = p.maxhealth
 uh.fill=p.health
 rectfill(uh.x,uh.y,uh.x+uh.w,uh.y+uh.h,uh.cb)
 rectfill(uh.x,uh.y,uh.x+uh.fill,uh.y+uh.h,uh.cf)
end

function draw_panel(panel,horz,vert,fill,outline,centered,gap)
	local x,y,w,h = 0,0,0,0
	if (gap==nil) gap=1
	--local special="⬅️➡️⬆️⬇️❎🅾️✽◆"
	local lines={}
	--panel height
	h = #panel*(5+gap)+gap
	--line width
	for i=1,#panel do
		local ln = panel[i]
		local w2 = #ln*4 + gap*2
		for j=1,#ln do
			--for k=1,#special do
				--if sub(ln,j,j)==sub(special,k,k) then
				local ltr = sub(ln,j,j)
				if ord(ltr) > 127 and ord(ltr) < 154 then
				 w2+=4
				end
			--end
		end
		add(lines,w2)
		if (w2>w) w=w2
	end --line width
	--panel width
	if (horz=="l") x=0
	if (horz=="r") x=gamew-w
	if (horz=="c") x=gamew/2-w/2
	--panel height
	if (vert=="t") y=0
	if (vert=="b") y=gameh-h-1
	if (vert=="c") y=gameh/2-h/2
	if (vert=="m") y=gameh/2+h/3
	rectfill(x,y,x+w-2,y+h-1,fill)
	rect(x-1,y-1,x+w-1,y+h,outline)
	for i = 1,#panel do
		local ln=panel[i]
		local mod=0
		--if (gamew==64) ln=lowercase(ln)
		if (centered) mod=(w-lines[i])/2
		
		print(ln,x+gap+mod,y+gap+(i-1)*(5+gap),6)
	end --for
end

function lowercase(s)
	local d=""
	local c=true
	for i=1,#s do
		local a=sub(s,i,i)
			for j=1,26 do
				if a==sub("abcdefghijklmnopqrstuvwxyz",j,j) then
					a=sub("\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79\80\81\82\83\84\85\86\87\88\89\90\91\92",j,j)
				end --if a
			end -- forj
		d=d..a
	end-- for i
	return d
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
function init_player()
	p={     --attributes
		x=8,y=48,--pos
		speed=2,--walk speed
		jforce=-2.25,--jump force
		jumps=0,maxjumps=1,--jumps
		framerate=12,
		
		--temp stuff
		tx=0,ty=8,--temp x,y
		w=4,h=8,--start sprite
		cell=0,--map cell sprite
		dy=0,--for gravity
 	gnd=false,--on ground?
 	xscale=1,flip=false,--flip
 	--count=0,--current game frame
 	--frame=0,--current anim frame
 	--sp=3,
 	keys=0,
 	weapon=weapons.sword, --weapon
 	cx=0,cy=0, --change from last frame
		health=10,maxhealth=10,
		dead=false,
		x1=0,x2=0,y1=0,y2=0,spx=0,
		melee={x1=0,x2=0,y1=0,y2=0,spx=0},
	
 	anim={
 		rate=12,tick=0,fr=0,sp=0,
 		stand={sp={3},x=0,y=1,w=4,h=7,name="stand"},
			walk={sp={7,8},x=0,y=1,w=4,h=7,name="walk"},
			crouch={sp={2},x=0,y=2,w=4,h=7,name="crouch"},
			jump={sp={1},x=0,y=0,w=4,h=7,name="jump"},
			climb={sp={4,5},x=1,y=1,w=4,h=7,	name="climb"},
			ladder={sp={4},x=1,y=1,w=4,h=7,	name="ladder"}
			}, --end anim
		--inventory={},
		w_anim={rate=15,tick=0,fr=0,sp=0,dur=10},
		weapons={},hitting=false
	} --end p
	p.state=p.anim.stand
	p.tx,p.ty=p.x,p.y
	p.px,p.py=p.x,p.y
	p.⬆️ = false --jump button
end

function update_player()
	btnu(⬆️)
 move_player() --walk,climb,crouch
 jump()
 fall()
 set_player_state()
 --fall()
 
 player_hitboxes()
 combat()
	player_combat()
 
 --not sure what these do
 --p.cell=mget(p.x/8,p.y/8)
 --p.cx,p.cy=p.x-p.px,p.y-p.py
 p.px,p.py=p.x,p.y
	--animate_player()
	
	animate(p.anim,p.state.sp)
	--log_player()
	--add(log,"p:"..flr(p.x)..","..flr(p.y))
end


function animate(obj,frames)
	 --update animation
 obj.tick+=1
 if obj.tick%(30/obj.rate) == 0 then
 	obj.fr+=1
 	if (obj.fr>#frames) obj.fr=1
		obj.sp = frames[obj.fr]
	end --if
end


function move_player()
	p.tx,p.ty = p.x,p.y
	local speed=p.speed
	
	--tar: 75% speed
	if (groundis(75)) speed/=2
	
	--walking
		
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
	
	--[      climbing
	if onladder() then
		if btn(2) then
			p.ty -= p.speed
			p.x = flr(p.x/8)*8
		elseif btn(3) then
		 p.ty += p.speed
			p.x = flr(p.x/8)*8
		end
	end -- climbing ]]
	
	--[
	if trymove() then
		p.x,p.y=p.tx,p.ty
	else
		p.tx,p.ty=p.x,p.y
	end --]]

end --move()


function set_player_state()
	--setting animation states
	--[[
	if onladder() then
		if (p.y != p.py) then
			p.state=p.anim.climb
		else
			p.state = p.anim.ladder
		end
	--]]
	if onladder() and (p.y != p.py) then
			p.state=p.anim.climb
	elseif (p.x != p.px) then
		p.state = p.anim.walk
	elseif btn(⬇️) then
			p.state=p.anim.crouch
	else
		p.state = p.anim.stand
	end
	
	state_collider()
end --set_player_state()
	

function state_collider()
	-- set collider box (uh, later?)
	p.x1,p.y1=p.x,p.y
	
	p.w=p.state.w
	p.h=p.state.h
	
	p.x2=p.x+p.state.w
	p.y2=p.y+p.state.h
	--p.w=(p.state.w-p.state.x-1) -- *p.xscale
 --p.h=p.state.h-p.state.y-1
 	
end --state_collider()


function jump()
	if (onladder()) return
	if btnd(⬆️) and
				p.jumps<p.maxjumps then
		p.dy=p.jforce
		p.jumps += 1
		p.state=p.anim.jump
		p.gnd=false
	end
end --jump()


function onladder()
	if touching(83) or 
				groundis(83) then
	 return true
	end
end --onladder()


function fall()
	if onladder() then
		return
	elseif not p.gnd then
		p.dy+=gravity
		p.ty+=p.dy
		if fallhit() then
			p.jumps=0
			p.dy=0
			p.gnd=true
			p.ty=p.y
			--p.y=flr(p.y/8)*8+p.state.y
		elseif hithead() then
			p.dy=0
		else
			p.y=p.ty
		end
	else -- if not falling
		if not fallhit() then
			p.gnd=false
		end
	end
end --fall()


function trymove()
 	local hit = hitground() 
 		or	hithead() 
 		or hitbounds()
 	return not hit
end --trymove()


function pbox(temp)
	local x,y=p.x,p.y
	if (temp) x,y=p.tx,p.ty
	--return player hit box
	--[[
	local x1=x-p.state.w/2
	local x2=x+p.state.w/2
	local y1=y+7-p.state.h
	local y2=y+7
	--]]
	local x1 = x-p.state.x
	if (p.flip) x1=x-8+p.state.w
	local y1 = y-p.state.y
	local x2 = x1 + p.state.w
	local y2 = y1 + p.state.h
	
	local wx1 = x+p.weapon.x
	local wy1 = y+p.weapon.y
	local wx2 = wx1+p.weapon.w
	local wy2 = wy1+p.weapon.h
	
 return x1,y1,x2,y2,wx1,wy1,wx2,wy2
end --pbox()


function player_hitboxes()
	--p.w=p.state.w
	--p.h=p.state.h
 p.x1 = p.x --p.state.x
	p.y1 = p.y --p.state.y
	p.x2 = p.x1 + p.state.w
	p.y2 = p.y1 + p.state.h
	
	p.melee.x1 = p.x+p.weapon.x*p.xscale
	p.melee.y1 = p.y1
	p.melee.x2 = p.melee.x1+p.weapon.w
	p.melee.y2 = p.melee.y1+p.weapon.h
	
 p.spx = p.x1
 p.melee.spx = p.melee.x1
	if p.flip then
		p.spx -= (8-p.state.w)
		p.melee.spx -= p.weapon.w
	end
end
 

function draw_player()
	--player sprite
	spr(p.anim.sp,p.spx,p.y1,1,1,p.flip)
	
	--weapon
	spr(p.w_anim.sp,p.melee.spx,
					p.melee.y1,1,1,p.flip)
	
-- bounding boxes
	if trace then
		--player hitbox
		rect(p.x1,p.y1,p.x2,p.y2,6)
		--rect(p.x,p.y,p.x+p.w,p.y+p.h,6)
		--player x,y
		rectfill(p.x1,p.y1,p.x1,p.y1,10)
		rectfill(p.x,p.y,p.x,p.y,9)
		
		if p.hitting then
		--weapon hitbox
		rect(p.melee.x1,p.melee.y1,p.melee.x2,p.melee.y2,8)
		end
		--[[
		rect(p.x+p.weapon.x*p.xscale,
					p.y+p.weapon.y,
					p.x+p.weapon.x*p.xscale+p.weapon.w,
					p.y+p.weapon.y+p.weapon.h,8)
					--]]
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

 	--[[
 	log={}
 	add(log,"player: "..p.x..","..p.y)
 	add(log,"anim x,y: "..p.state.x..","..p.state.y)
 	add(log,"anim w,h: "..p.state.w..","..p.state.h)
 	add(log,"xmod: "..p.w..","..p.h)

 	--]]
-->8
--enemies

function init_enemies()
	enemies={}
	enemy_classes={
		{name="default",sp=16,
			health=5,dmg=1,
			speed=.5,w=8,h=8,
			cool=10,hitc=6,hitr=8},
		{name="skeleton",sp=24,
			health=3,dmg=2,
			speed=.5,w=5,h=8,
			cool=10,hitc=6,hitr=8},
	}
	e_hitflash=15
end


function update_enemies()
	local gx=flr(p.x/8)-gamew/16
	local gy=flr(p.y/8)-gameh/16
	for i=gx,gx+gamew/8 do
		for j=gy,gy+gameh/8 do
			if (fget(mget(i,j),7)) wake_enemy(i,j)
		end
	end
	foreach(enemies,update_enemy)
end


function wake_enemy(mx,my)
	local sp=mget(mx,my)
	local c=getclass(sp)
	local e={x=mx*8,y=my*8,tx=mx*8,ty=my*8,
							sp=sp,w=c.w,h=c.h,
							health=c.health,
							speed=-c.speed,
							flipx=c.flipx,cool=0,
							hitflash=0,class=c}
	add(enemies,e)
	mset(mx,my,0)
end


function getclass(sp)
	for e in all (enemy_classes) do
		if (e.sp==sp) return e
	end
	return enemy_classes[1]
end


function update_enemy(e)
	--sleep if offscreen+full health
	
	--if not hitting wall, move
	--local d = 1
	--if (e.flipx) d=-1  --direction
	e.tx = e.x+e.speed
	if bonk(e.tx+4,e.ty) or 
		e.tx<0 or e.tx>128*8 then
		e.tx = e.x
		flip_enemy(e)
	else
		e.x = e.tx
	end
	
	if e.hitflash>0 then
		e.hitflash -=1
	end
	
	--add(log,e.class.name.." "..flr(e.x)..","..flr(e.y))
end

function flip_enemy(e)
		e.flipx = not e.flipx
		e.speed *= -1
end

function draw_enemy(e)
	--flash enemy if damaged
	if e.hitflash>0 then
		pal(e.class.hitc,e.class.hitr)
	end
	
	local sprx = e.x
	if (e.flipx) sprx=e.x-8+e.w
	spr(e.sp,sprx,e.y,1,1,e.flipx)
	if (trace) then
		rect(e.x,e.y,e.x+e.w,e.y+e.h,8)
		rectfill(e.x,e.y,e.x,e.y,9)
	end
	pal()
end
-->8
--collision

function box(obj,temp) --return box
 local x,y = obj.x,obj.y
 if (temp) x,y=obj.tx,obj.ty
 --local x1=x-obj.w/2
 --local x2=x+obj.w/2
 local x1=x
 local x2=x+obj.w
 local y1=y+7-obj.h
 local y2=y+obj.h
 return x1,y1,x2,y2
end --box()


function collide(a,b)
 if a.x+a.w>b.x and
 			b.x+b.w>a.x and
 			a.y+a.h>b.y and
 			b.y+b.h>a.y then
 	return true
 end
 return false
end --collide

function collide_xy(a,b)
 if a.x2>b.x1 and
 			b.x2>a.x1 and
 			a.y2>b.y1 and
 			b.y2>a.y1 then
 	return true
 end
 return false
end --collide


function touching(sp)
	local x1,y1,x2,y2 = box(p,true)
	if mget(x1/8,y1/8) == sp or
				mget(x2/8,y1/8) == sp or
				mget(x1/8,y2/8) == sp or
				mget(x2/8,y2/8) == sp then
		--return fget(p.cell,1)
		return true
	end
end --touching()

function near(sp)
	--local x,y = flr(p.x/8),flr(p.y/8)
	local ym = flr(p.y/8)
	local mod={-6,0,6}
	for i=1,#mod do
		local xm=flr((p.x+mod[i])/8)
		if mget(xm,ym) == sp then
			return xm,ym,true
		end
	end
	--if (mget(x,y) == sp) return x,y,true
	--if (mget(x-1,y) == sp) return x-1,y,true
	--if (mget(x+1,y) == sp) return x+1,y,true
end --near()


----- player collision
function bonk(x,y)
 --add(log,"bonk: "..x..","..y)
 --add(log,"bonk: "..x..","..y)
 return fget(mget(x/8,y/8),0)
end --bonk

function hithead()
	if --bonk(p.tx,p.ty+p.state.y) or
				bonk(p.tx+p.w/2,p.ty+p.state.y) then
		return true
	end
end --hithead()

function hitbounds()
	if p.tx<0 or p.tx+p.w<0 or
				p.tx>128*8 or p.tx+p.w>128*8 or
				p.ty<0 or p.ty+p.h<0 or
				p.ty>63*8 or p.ty+p.h>63*8 then
		return true
	end
end --hitbounds()

function fallhit()

	local x1=p.tx
	local x2=p.tx+p.w
	local y=p.ty+p.h
	
	if fget(mget(x1/8,y/8),0)
		or fget(mget(x2/8,y/8),0)
		or fget(mget(x1/8,y/8),1)
		or fget(mget(x2/8,y/8),1) 
		then
		return true
	end
end

function hitground()
--one point only
	if bonk(p.tx,p.ty+p.h) or
				bonk(p.tx+p.w,p.ty+p.h) then
		return true
	end
	
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
 if mget((p.tx+p.w/2)/8,(p.ty+10)/8) == sp then
 	return true
 end
end






--[[
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
--]]

--[[
 function collide_all()
 	for e in all (enemies) do
 		if (collide(p,e)) return true
	end
	for w in all (walls) do
		if (collide(p,w)) return true
 	end
 	return false
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
-->8
--combat

function init_weapons()
	weapons={
		none={dmg=0,t=1,r=0,
			x=4,y=1,w=4,h=7,dur=0,
			name="unarmed",
			sp={15}},
		sword={dmg=2,t=5,r=4,
			x=4,y=0,w=4,h=7,dur=10,
			action=sword_attack,
			name="sword",
			sp={9,10,11}},
		bow={dmg=1,t=5,r=4,
			x=4,y=0,w=4,h=7,dur=5,
			action=bow_attack,
			name="bow",
			sp={12}}
		} 
end

--[[
	notes on bow use
	bow action = spawn arrow
	arrow is entity, updated in combat update
	need entity system (not specifically weapon)
--]]

function combat()
	for e in all (enemies) do
		--local ee = {x=e.x,y=e.y,
		--w=e.class.w,h=e.class.h}
		local exy = {x1=e.x,y1=e.y,x2=e.x+e.class.w,y2=e.y+e.class.h}
		
		-- enemy hits player
		if e.cool>0 then
			e.cool -= 1
		elseif collide_xy(p,exy) and e.cool<=0 then
			p.health -= e.class.dmg
			e.cool = e.class.cool
		end --if e hit p
	
 	-- player weapon hits enemy
 		if btnp(❎) and 
 		collide_xy(p.melee,exy) then
				hit_enemy(e)
			end --if btnp(❎)
		
		if (p.health<=0) p.dead=true
	end --enemies loop
end


function player_combat()
 if p.hitting then
		animate(p.w_anim,p.weapon.sp)
		if p.w_anim.tick>p.w_anim.dur then
			p.hitting=false
		end --tick
	else --if not p.hitting
		if btnp(❎) then
			p.w_anim.tick=1
			p.weapon.action()
 		--p.hitting=true
 	end
		p.w_anim.sp=p.weapon.sp[1]	
	end --p.hitting
end --player_combat

function sword_attack()
 p.hitting=true
end

function bow_attack()
	
end


function hit_enemy(e)
	e.health -= p.weapon.dmg
	e.hitflash=e_hitflash
	if e.health <= 0 then
		del(enemies,e)
	end --if health<=0
	flip_enemy(e)
	--e.flipx = e.x<p.x
	--e.x += 4 * sgn(e.x-p.x)
end

--[[
function attack(e)
	local wp = {w=p.weapon.w,
		x=p.x+p.weapon.x*p.xscale,
		y=p.y+p.weapon.y,h=p.weapon.h}
		
	local ee = {x=e.x,y=e.y,
		w=e.class.w,h=e.class.h}
 
 if collide(wp,ee) then
		e.health -= p.weapon.dmg
		if e.health <= 0 then
			del(enemies,e)
		end --if health<=0
		e.flipx = e.x<p.x
		e.x += 4 * sgn(e.x-p.x)
		
	end --if collide
end
--]]
-->8
--items

function init_items()
	init_weapons()
	
	items={
	 {name="key",sprite=84,
		 action=function()
			 p.keys+=1
		 end
	 },
	 
	 {name="health",sprite=94,
		 msg={"heal","healed","health"},
		 blocked=function()
			 if (p.health==p.maxhealth) return true
		 end,
		 action=function()
			 p.health += 10
			 if p.health>p.maxhealth then
				 p.health = p.maxhealth
			 end
		 end
	 },
	
	 {name="door",
		 sprite=79,newsprite=80,
		 verb={"open","opened"}
		 },
	
	 {name="locked door",
			sprite=81,newsprite=82,
			msg={"unlock door",
				"door unlocked",
				"locked door"},
		 blocked=function()
			 if (p.keys<=0) return true
		 end,
		 action=function()
		 	p.keys -= 1
		 end
	 },	 
	 
	 --runes
	 {name="chalice rune",sprite=104,
	 	msg={"chalice rune","gold x2"},
	 	action=function()
	 		--double gold
	 	end},	 
	 	
	 {name="sword rune",sprite=105,
	 	msg={"sword rune","melee x2"},
	 	action=function()
	 		--double melee strength
	 	end},
	 	
	 {name="shield rune",sprite=106,
	 	msg={"shield rune","defense x2"},
	 	action=function()
	 		--double defense
	 	end},	 
	 	
	 {name="heart rune",sprite=107,
	 	msg={"heart rune","health x2"},
	 	action=function()
	 		--double health
	 		p.maxhealth *= 2
	 	end},
	 	
	 {name="fist rune",sprite=108,
	 	msg={"fist rune","damage x2"},
	 	action=function()
	 		--double damage
	 	end},
	 	
	 {name="key rune",sprite=109,
	 	msg={"key rune","extra key"},
	 	action=function()
	 		--extra key?
	 	end},
	 	
	 {name="slime rune",sprite=110,
	 	msg={"slime rune","summon slime pet"},
	 	action=function()
	 		--summon slime pet
	 	end},
	 	
	 {name="bow rune",sprite=111,
	 	msg={"bow rune","range x2"},
	 	action=function()
	 		--double ranged damage
	 	end},
	 
	}
end
 

--loop through item types
function update_items()
	for i=1,#items do
		local item=items[i]
		local x,y,t=touching(item.sprite)
		if t then
			behavior(x,y,item)
			return
		end --if t
		local x,y,t=near(item.sprite)
		if t then
			behavior(x,y,item)
		end --if t
	end --for loop
end --update_items()

--set generic item behavior
function behavior(x,y,item)
	local verb=item.verb
	if (verb==nil) verb={"take","taken"}
	local msg=item.msg
	if msg==nil then
		msg={
			verb[1].." "..item.name,
			item.name.." "..verb[2],
			item.name}
	end
	
	if (item.blocked) and
		 item.blocked() then
		set_ipanel({msg[3]})
	else
		set_ipanel({"🅾️ "..msg[1]})
		if btnp(🅾️) then
			set_ipanel({msg[2]})
			if (item.action) item.action()
			if (verb[1]=="take") mset(x,y,0)
			if (item.newsprite) mset(x,y,item.newsprite)
		end --if btnp
	end --if item.blocked
end -- function
	
--[[
		--key
 	local x,y,t=near(key.sp)
 	if t then --key
 			set_ipanel({key.msg[1]})
 			if btnp(key.bt) then
 				set_ipanel({key.msg[2]})
 				p.keys += 1
 				mset(x,y, 0)
 			end
 	end --keys
 	
 	--locked door
 	local x,y,t=near(81)
 	if t then --door
 		if p.keys>0 then
 			set_ipanel({"🅾️ unlock door"})
 			if btnp(🅾️) then
 				set_ipanel({"door unlocked"})
 				p.keys -= 1
 				mset(x,y,82)
 			end
 		else
 			set_ipanel({"locked door"})
 		end
 	end -- locked door
 		
 	-- door
 	local x,y,t=near(door.sp)
 	if t then --door
 			set_ipanel({door.msg[1]})
 			if btnp(🅾️) or btnp(❎) then
 				set_ipanel({door.msg[2]})
 				mset(x,y, 80)
 			end
 	end -- door
 	
 	--health potion
 	local x,y,t=near(health.sp)
 	if t then
 		if p.health<p.maxhealth then --health potion
 	--set_ipanel({"iron key","❎ take"})
 			set_ipanel({health.msg[1]})
 			if btnp(🅾️) then
 				set_ipanel({health.msg[2]})
 				p.health = p.maxhealth
 				mset(x,y, 0)
 			end
 		else
 			set_ipanel({health.msg[3]})
 		end --keys
 	end
end --update_items()

--]]

--[[
--generic item behavior
function item_behavior(x,y,item)
	if item.condition == nil or
		item.condition() then
		set_ipanel({item.msg[1]})
		if btnp(item.btn) then
			set_ipanel({item.msg[2]})
			item.action()
			mset(x,y,0)
		end
	end
end
--]]

--[[
-- set a generic action
function item_action(item)
	if not item.dcon then
		
	end
end
--]]


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

--[[
function make_items()
 	--temp_item=nil
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
--]]
-->8
--notes
--[[ comments
sprite, name, damage, health

enemies
24 skeleton dmg=2,health=3
25 skeleton
26 shield skeleton
27
28
29 slime boss
30 orange slime
31 red slime
21 green slime
47 brown slime
14 barbarian slime
15 
61 wizard slime
62 warrior slime
63 rogue slime

bosses
32 snake boss
34 worm boss
37
38
39
40
41
42
44
46
48 frost slime
49
50 red dragon


runes
104 chalic3,doubl3 gold
105 sword,doubl3 mala strangth
106 shild,doubl3 dfanc3
107 ha3rt,doubl3 h3alth
108 fist,doubol3 damg3
109 k3y,3xtra k3y
110 slim3,sumon slim3 p3t
111 bow,doubl3 progtial3 damg3

95  what's that?
120 gold?
121 pieces of gold?


--biomes

biome names!!!!!

prison,outside,uderground beach
snowy mountan caves,unmeables cavern
aliens home,music jungle






]]
__gfx__
00000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000666665000000000000000000
000000000ce0000000000000c000000005c00c0000c00c5000000000c0000000c000000000600000000500000000000004000000000000000000000000000000
0070070008805000c00000000ce00000050cc000000cc050000000000ce000000ce0000006000000055550000000000000400000000000000400004000000000
00077000088500000ce0000008805000055885500558855000000000088050000880500060000000555550000000000000400000000000000440044004000000
00077000022000000880000008850000000880500508800000000000088500000885000000000000666660005555000000400000000000000488884004bbbb00
007007002002000008850000022000000022205005022200001100c00220000002200000000000000000000065550000040000000000000000181800041b1b00
00000000000000000220000020020000002002000020020022288c002002000020020000000000000000000006500000400000000000000000b8bb0004bbbb00
00000000000000002002000020020000000002000020000022288e000002000020000000000000000000000000600000000000000000000000bbbb0004bbbb00
00000000600005000000000000000000000000000000000000000900000000000555000010555000105550001105550000055500e4e4d8d80000000000000000
60000500600d50c06000050060000500000000000000000000009990000000000c5c000010c5c00010c5c000110c5c00000c5c00444488880000000000000000
600d50c060122010600d50c0600d50c0005000000000000000000900aa1b1baa0555000056555000565550000605550600055506444488880000000000000000
60122010510221006012201060122010000500000000000000000000a7bbbb7a0666000050666000506677700666666606666666444488880000000000000000
51022100050110005102210051022100000600000000bbbb00001b1b77bbbb7760606000000606000006777000006000000060001b1bc9c90000999900008888
050110000010010005011000050110000506110000001b1b0000bbbb00bbbb000010000000010000000177700000100011001000bbbb99990000c9c90000d8d8
00100100000000000010010000100100005621110000bbbb0000bbbb000000000101000000101000001017000001010011010100bbbb99990000999900008888
00100100000000000010000000000100c0d221110000bbbb0000bbbb000000000101000000101000001010000001010000010100bbbb99990000999900008888
00000000000000000000000000000000000000006008800600000110000000000000000000000000000005500000000000000000000000000000000000000000
00444400000000000000000000000000000000006001100600000110060777770600c0c0000000007700015000000000000c5c00000000000000000000000000
6094940000000000000000000000000000001100601111060000c88c6467c5c70600110000888880070005500000000000005000005000000000000000000000
60444400000000000001111100000000000005006111111600008888040775770bb001b0008ccc800dddd6600000000005666665005500000000000000000000
600400000000000400010000000011110000111155111155000002200457777700bbb1b000888880060006600000000005066605000550000011110000004444
6555550004940554000100000000818100008181001001000000222204077777000011100000200006005665000ddd000500600500005000005000000000e4e4
55040550044455440080800000001111000011110010010000002002040666660000b0b0000020000600555555566655057777750c0667770c6c000000004444
00044444049444400000000000001111000011110000000000002002000650560000b0b000002222000050055156665500700070055067770666777700004444
00000000000000000006000000000000000000000bbb333000003330000ccc000000000000000000000000000c0c000000000000000019000000000000000000
00000000000cccc0886660000000000000000bbb0b0000300000bbb0000080000000000000000000000000000088000000000000000111000000000000000000
00000000cc7c66c7888600600000000000000b000b00003000003330099080990090900000000000000000000090000000000000001191000000000000000000
0c000000007cccc7cc8006660000000000000b000b0000300000b0000998b89990bbbb0999900999009bb9000099900000000000019111100000000000000000
cc777700cc777777cc88886806000000000bbb00bbb00333000bbb0009ab8ba90bb99bb09a9009a99bb99bb9000099000000000000bbbb0006bbbb0000bbbb44
0c676700007cccc70888880866606000000bbb00bbb00333000bbb0009a8b8a9bb9999bbbbbbbbbbbb9999bb000aaa0000000000101b1b00061b1666001b1449
cc777700cc7cccc788888888c6866688000bbb0000000000000bbb000aa000aab999999b9b9bb9b9b999999b000a0a00c899aa0040bbbb0006bbb66604bbbb94
0c777700000c00c080080080cc8868880000000000000000000000000000000099000099999999999999999900a00a00c99aa0aa04bbbb0004bbbb6006bbbb44
11111111511111515111511622222228bbbbbbbbbbbbbbbb1c1c1c1cccceeccc77776777c7cccccccc888877dddddd4544444444000011000001111000004400
111111111511151116151151222e2228b377773bb333333bc1c1c1c1c8eeee8c777777677c7ccc7c7c8888c6d55ddd4544444644000018000001118000004400
15111151151151111151161522e28888b739937bb3bbbb3b11111111cc9ee9cc67677777cccc7cc777c777c7d5d5445445444444000081000001118000004400
1151151111511511111651112e228e22b793397bb3b33b3bc1c1c1c1c8c99c8c77777677ccc7ccc7677cccc7d555445444444544000088000001888000005500
11155111151551111115611122e282e2b793397bb3b33b3bdcdcdcdc9c9889c977767777ccc7ccc777cc7776d555554544444444000088000001118000004400
11588511511155115161151122888e22b739937bb3bbbb3bdddddddd898888987767777777cc7cc776cc8887d5d5444544454444000018000001888000005500
111551111511151115115161228222e2b377773bb333333bdcdcdcdc9c9889c977777767cc7ccc7c77c78886dd55445444444464000081000001118000004400
11111111511111516115111522822222bbbbbbbbbbbbbbbbcdcdcdcdc8c88c8c76777777ccc7cccc67ccccc7dddd445446444444000011000001111000004400
00044440000066000006666040000004000060000000000000000000a99ada9900000000111111111111111182222222b333333b060060000000000000000000
00044440000066000006666044444444000606000000000000000000a9aaa99a0000000018811111111111158888222833044033606660000000000000000000
00044440000077000006667040000004000060000000000000000000a9aa99aa000000001118818811111d51222882883b0440b30600000000444400009bbb00
00055550000055000006665044444444000060000000000000000000aaa99aaa00000000111118811115155122228282bb0440bb0000000000077000097bbb00
00044440000055000006665040000004000060000505050500000000da99aa9a0000000011818811111155518888828cbb0440bb0000000000788700000bbb70
00055550000077000006667044444444006660000505050500500050a99aaa9a0000000011818111111112218888888cb004400b00000000078999700077b900
00044440000066000006666040000004000060000505050505050505a9adaa9a00000000118111811111211288222ccc3334433300000000007987000998e000
0004444000006600000666604444444400666000666666666666666699aaa9ad00000000181118811111211222222ccc300440030000000000077000008ee900
77777000770077007700000077777700770070000077700077000000000000000000000000000000000000000000000000000000000000000000000000000000
77777700770077007700000077777000770077000007770077000000000000000055550000555500005555000055550000555500005955000055550000555500
770077007700770077000000770000000000770000007700770000000000000005999550095665900577755005b5b550055555500595955005bbbb5005595550
760077007700c7007700000077000000000077000000770077000000000000005599950055666500557775005bbbbb005558280055595500551b1b0055999900
770077006700770077000000770000000000770000007700770000000000000055595550544655505577755055bbb550558885505559955055bbbb5055595550
7700770077007700770000007700000000007700000077007700000000000000559995505545595055575550555b5550555528505559555055bbbb5055999950
67007700770076006700000077000000000077000000770077700000000000000555555005555550055555500555555005555550055995500555555005595550
770077007d0077007700000077000000000077000000770007770000000000000005550000055500000555000005550000055500000555000005550000055500
77007700770077007700000077000000000077000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000
67007700770077007700000077000000000077000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000
77007700770077007700000077000000000077000000770000000000000000000000044000000000000000000000000000000000000000000000000000000000
77007700770077007700000077000000000077000000770000000000000000000004400400000000000000000000000000000000000000000000000000000000
77007c00770077007700000077000000000077000000770000000000000000000044940000000000000000000000000000000000000000000000000000000000
c70076006700760076000000670000000000d7000000770000000000000000000449444000000000000000000000000000000000000000000000000000000000
7c7767007700777c77000000777776007c0077007d776c0000000000000000000444944000000099000000000000000000000000000000000000000000000000
6677c6007c0006d770000000767c770077007600676c760000000000000000000044440099090099000000000000000000000000000000000000000000000000
0000000000d3d3d300000000000000000054000000005400000000000000c4c43500c40000000000000000007500000000000000000000000000000075000000
84358484840085848484848435840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000850cd3d3d3d3008585850000000000540071000000545454c4c4c4c4c485358585c4c4c40000000000007500000000000000000000000000000075000085
75357585858485858585858535840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8585d3d3d3d3d3d3d3858585850000000054007100000000e58585850000f485358585f285f2c400000075757500000000000000e1e1000000f5e5e575000000
75357585858484858585007235840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d3d385d3d3d3d3d3d38585858500000000540000000000545454c4c4c4c4c4c4c4c4c4c4c4c4000000007500f4000000e5e5e5e5757575757575757575000000
75357585008484848484848435840000000000000000000000000000000000000000000000343500000000000000000000000000000000000000000000000000
d3d3d3858585858585850000850000000054616100005400000000000000000075358500f6e5e100004575007564646464646464757575757575757500000000
75357500000085000000008435840000000000000000000000000000000000000000000000343500000000000000000000000000000000000000000000000000
85008585850085850085000085000000005454545454540000000000000000007535756464646455557500007575757575757504858585858585850004757575
75357500000000000000008435840000000000000000000000000000000000000000000000343500000000000000000000000000000034343434343434000000
85858500000000000085008585000000000000000000000000000000000000007535757575757575758500007500000000000004000000000000000004757575
75357500000000000000008435840000000000000000000000000000000000000000000000343500043434343434340000000000003485006200000034000000
0000000000000000000000850000000000000000000000000000000000000000743500510000858500e10000150085e5f5f500d40085000000000000d4000000
00357500008484848484840000008484848484848484840000000000000000000000000000343500040000000000000434343434343400343434343534000000
0000000000000000000000000000000000000000000000000000000000000000856464646464647575757575757575757575750400000000b300000004757575
757575008400000000000000f50000e5000000720000840000000000000000000000000000343500d4000000000000d4e5e5e5e5e50000f5f5f5343534000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000646464646464646400000000
00000000840000000300000384848484848484848435840000000000000000000000000000343434040000230000000434343434343434343434343534000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008472008484848400000000000000008435840000000000000000000000000000000000043434343434340400000000348500000000003534000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000084720000008400000000000000008435840000000000000000000000000000000000000000000000000000000000343500000000003534000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000848500008400000000000000008435840000000000000000000000000000000000000000000000000000000000343500000000b53534000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000848484358400000000000000008435840000000000000000000000000000000000000000000000000000000000343534343434003592000092
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000850084358400000000000000008435840000000000000000000000000000000000000000000000000000000000343500000000343434343434
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358400000000000000008435840000000000000084848484840000000000000000000000000000000000343500006200000000853534
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358400000000000000008435840000000000000084350035840000000000000000000000000000000000003434e5006200e5f5853534
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358400000000000000008435840000000000000084358435840000000000000000000000000000000000000000343400343434343534
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000008435848484848484848484a435840000000000000084358435848500000000000000000000000000000000000000000034340000003554
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000008435857200000000e500008535840000000000000084358435840000000000000000000000000000000000000000000000000000003554
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084350000848494949494948484840000000000000084358435840000000000000000000000009000000000000000000000000000003554
00000000000000000000e50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358484840000000000000000000000000000000084358435840000000000000000000000004300c50000000000000000000000003554
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358484848400000000008484848484848400000084358435840000000000000000000054545454545454e50000000000000000003554
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000008435848484848484848404000000000000000484848435843584000000000000000000540000000000000054e585000000000000003554
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000008435f5f5e5e513f5e2f5d400000000000000d40000003584358400005300000053005400000000000000005454e5000000000000003554
06162600363626360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000008484848484848484848404000000c200000004848484848435848585858500000054000000000000000000005454e50000000000003554
07172703263726660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000009494949494949400000000008435008585f5c5e5e5850000000000000000000000005454f5d4000000003554
26162600262626560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000008484845454545454540085000000000000000000000000545404000083003554
27162600373737570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000c4c4c4c4c4c4c4c4000000000000000004545454545454
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c400000000000000000000000000c4
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c400000000000000009363b693c4
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c4c4c4c4c4c4c4c4c4c4c4c4c4
__label__
bbbbbbbbbbbbbbbbbbbbbbbbbb661155111155110000000000000000000000000000000000000000000000000000000000000000444444444444444411661155
bbbbbbbbbbbbbbbbbbbbbbbbbb661155111155110000000000000000000000000000000000000000000000000000000000000000444444444444444411661155
00000000000000000000000011115511116611550000000000000000000000000000000000000000000000000000000000000000440000000000004411115511
00000000000000000000000011115511116611550000000000000000000000000000000000000000000000000000000000000000440000000000004411115511
00000000000000000000000011111166551111110000000000000000000000000000000000000000000000000000000000000000444444444444444411111166
00000000000000000000000011111166551111110000000000000000000000000000000000000000000000000000000000000000444444444444444411111166
00000000000000000000000011111155661111110000000000000000000000000000000000000000000000000000000000000000440000000000004411111155
00000000000000000000000011111155661111110000000000000000000000000000000000000000000000000000000000000000440000000000004411111155
00000000000000000000000055116611115511110000000000000000000000000000000000000000000000000000000000000000444444444444444455116611
00000000000000000000000055116611115511110000000000000000000000000000000000000000000000000000000000000000444444444444444455116611
00000000000000000000000011551111551166110000000000000000000000000000000000000000000000000000000000000000440000000000004411551111
00000000000000000000000011551111551166110000000000000000000000000000000000000000000000000000000000000000440000000000004411551111
00000000000000000000000066111155111111550000000000000000000000000000000000000000000000000000000000000000444444444444444466111155
00000000000000000000000066111155111111550000000000000000000000000000000000000000000000000000000000000000444444444444444466111155
00000000000000000000000055111111551111660000000066000000000000000000000000000000000000000000000000000000440000000000004455111111
00000000000000000000000055111111551111660000000066000000000000000000000000000000000000000000000000000000440000000000004455111111
00000000000000000000000011661155111155110000006600660000000000000000000000000000000000000000000000000000444444444444444411661155
00000000000000000000000011661155111155110000006600660000000000000000000000000000000000000000000000000000444444444444444411661155
00000000000000000000000011115511116611550000000066000000000000000000000000000000000000000000000000000000440000000000004411115511
00000000000000000000000011115511116611550000000066000000000000000000000000000000000000000000000000000000440000000000004411115511
00000000000000000000000011111166551111110000000066000000000000000000000000000000000000000000000000000000444444444444444411111166
00000000000000000000000011111166551111110000000066000000000000000000000000000000000000000000000000000000444444444444444411111166
00000000000000000000000011111155661111110000000066000000000000000000000000000000000000000000000000000000440000000000004411111155
00000000000000000000000011111155661111110000000066000000000000000000000000000000000000000000000000000000440000000000004411111155
00000000000000000000000055116611115511110000666666000000000000000000000000000000000000000000000000000000444444444444444455116611
00000000000000000000000055116611115511110000666666000000000000000000000000000000000000000000000000000000444444444444444455116611
00000000000000000000000011551111551166110000000066000000000000000000000000000000000000000000000000000000440000000000004411551111
00000000000000000000000011551111551166110000000066000000000000000000000000000000000000000000000000000000440000000000004411551111
00000000000000000000000066111155111111550000666666000000000000000000000000000000000000000000000000000000444444444444444466111155
00000000000000000000000066111155111111550000666666000000000000000000000000000000000000000000000000000000444444444444444466111155
00000000000000000000000055111111551111665511111155111166551111115511116655111111551111665511111155111166440000000000004455111111
00000000000000000000000055111111551111665511111155111166551111115511116655111111551111665511111155111166440000000000004455111111
00000000000000000000000011661155111155111166115511115511116611551111551111661155111155111166115511115511444444444444444411661155
00000000000000000000000011661155111155111166115511115511116611551111551111661155111155111166115511115511444444444444444411661155
00000000000000000000000011115511116611551111551111661155111155111166115511115511116611551111551111661155440000000000004411115511
00000000000000000000000011115511116611551111551111661155111155111166115511115511116611551111551111661155440000000000004411115511
00000000000000000000000011111166551111111111116655111111111111665511111111111166551111111111116655111111444444444444444411111166
00000000000000000000000011111166551111111111116655111111111111665511111111111166551111111111116655111111444444444444444411111166
00000000000000000000000011111155661111111111115566111111111111556611111111111155661111111111115566111111440000000000004411111155
00000000000000000000000011111155661111111111115566111111111111556611111111111155661111111111115566111111440000000000004411111155
00000000000000000000000055116611115511115511661111551111551166111155111155116611115511115511661111551111444444444444444455116611
00000000000000000000000055116611115511115511661111551111551166111155111155116611115511115511661111551111444444444444444455116611
00000000000000000000000011551111551166111155111155116611115511115511661111551111551166111155111155116611440000000000004411551111
00000000000000000000000011551111551166111155111155116611115511115511661111551111551166111155111155116611440000000000004411551111
00000000000000000000000066111155111111556611115511111155661111551111115566111155111111556611115511111155444444444444444466111155
00000000000000000000000066111155111111556611115511111155661111551111115566111155111111556611115511111155444444444444444466111155
00000000000000000000000055111111551111660000000000000000000000000000000000000000000000005511111155111166440000000000004455111111
00000000000000000000000055111111551111660000000000000000000000000000000000000000000000005511111155111166440000000000004455111111
00000000000000000000000011661155111155110000000000000000000000000000000000000000000000001166115511115511444444444444444411661155
00000000000000000000000011661155111155110000000000000000000000000000000000000000000000001166115511115511444444444444444411661155
00000000000000000000000011115511116611550000000000000000000000000000000000000000000000001111551111661155440000000000004411115511
00000000000000000000000011115511116611550000000000000000000000000000000000000000000000001111551111661155440000000000004411115511
00000000000000000000000011111166551111110000000000000000000000000000000000000000000000001111116655111111444444444444444411111166
00000000000000000000000011111166551111110000000000000000000000000000000000000000000000001111116655111111444444444444444411111166
00000000000000000000000011111155661111110000000000000000000000000000000000000000000000001111115566111111440000000000004411111155
00000000000000000000000011111155661111110000000000000000000000000000000000000000000000001111115566111111440000000000004411111155
00000000000000000000000055116611115511110000000000000000000000000000000000000000000000005511661111551111444444444444444455116611
00000000000000000000000055116611115511110000000000000000000000000000000000000000000000005511661111551111444444444444444455116611
00000000000000000000000011551111551166110000000000000000000000000000000000000000000000001155111155116611440000000000004411551111
00000000000000000000000011551111551166110000000000000000000000000000000000000000000000001155111155116611440000000000004411551111
00000000000000000000000066111155111111550000000000000000000000000000000000000000000000006611115511111155444444444444444466111155
00000000000000000000000066111155111111550000000000000000000000000000000000000000000000006611115511111155444444444444444466111155
00000000000000000000000055111111551111660000000000000000000000000000000000000000000000000000000044440000440000000000004455111111
00000000000000000000000055111111551111660000000000000000000000000000000000000000000000000000000044440000440000000000004455111111
0000000000000000000000001166115511115511000000000000000000000000cc00000000006600000000000000000044440000444444444444444411661155
0000000000000000000000001166115511115511000000000000000000000000cc00000000006600000000000000000044440000444444444444444411661155
000000000000000000000000111155111166115500000000000000000000000000ccee0000660000000000000000000044440000440000000000004411115511
000000000000000000000000111155111166115500000000000000000000000000ccee0000660000000000000000000044440000440000000000004411115511
00000000000000000000000011111166551111110000000000000000000000000088880066000000000000000000000055550000444444444444444411111166
00000000000000000000000011111166551111110000000000000000000000000088880066000000000000000000000055550000444444444444444411111166
00000000000000000000000011111155661111110000000000000000000000000088885500000000000000000000000044440000440000000000004411111155
00000000000000000000000011111155661111110000000000000000000000000088885500000000000000000000000044440000440000000000004411111155
00000000000000000000000055116611115511110000000000000000000000000022220000000000000000000000000055550000444444444444444455116611
00000000000000000000000055116611115511110000000000000000000000000022220000000000000000000000000055550000444444444444444455116611
00000000000000000000000011551111551166110000000000000000000000002200002200000000000000000000000044440000440000000000004411551111
00000000000000000000000011551111551166110000000000000000000000002200002200000000000000000000000044440000440000000000004411551111
00000000000000000000000066111155111111550000000000000000000000002200002200000000000000000000000044440000444444444444444466111155
00000000000000000000000066111155111111550000000000000000000000002200002200000000000000000000000044440000444444444444444466111155
00000000000000000000000055111111551111665511111155111166551111115511116655111111551111665511111155111166551111115511116655111111
00000000000000000000000055111111551111665511111155111166551111115511116655111111551111665511111155111166551111115511116655111111
00000000000000000000000011661155111155111166115511115511116611551111551111661155111155111166115511115511116611551111551111661155
00000000000000000000000011661155111155111166115511115511116611551111551111661155111155111166115511115511116611551111551111661155
00000000000000000000000011115511116611551111551111661155111155111166115511115511116611551111551111661155111155111166115511115511
00000000000000000000000011115511116611551111551111661155111155111166115511115511116611551111551111661155111155111166115511115511
00000000000000000000000011111166551111111111116655111111111111665511111111111166551111111111116655111111111111665511111111111166
00000000000000000000000011111166551111111111116655111111111111665511111111111166551111111111116655111111111111665511111111111166
00000000000000000000000011111155661111111111115566111111111111556611111111111155661111111111115566111111111111556611111111111155
00000000000000000000000011111155661111111111115566111111111111556611111111111155661111111111115566111111111111556611111111111155
00000000000000000000000055116611115511115511661111551111551166111155111155116611115511115511661111551111551166111155111155116611
00000000000000000000000055116611115511115511661111551111551166111155111155116611115511115511661111551111551166111155111155116611
00000000000000000000000011551111551166111155111155116611115511115511661111551111551166111155111155116611115511115511661111551111
00000000000000000000000011551111551166111155111155116611115511115511661111551111551166111155111155116611115511115511661111551111
00000000000000000000000066111155111111556611115511111155661111551111115566111155111111556611115511111155661111551111115566111155
00000000000000000000000066111155111111556611115511111155661111551111115566111155111111556611115511111155661111551111115566111155
00000000000000000000000055111111551111660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055111111551111660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011661155111155110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011661155111155110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011115511116611550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011115511116611550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011111166551111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011111166551111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011111155661111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011111155661111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055116611115511110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055116611115511110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011551111551166110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011551111551166110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000066111155111111550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000066111155111111550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000
00000000dd1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dd0000000000
00000000dd1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dd0000000000
00000000dd1111666666666611111166666666661111116666666666111111666666666611111111111166666611116666116611661166666611dd0000000000
00000000dd1111666666666611111166666666661111116666666666111111666666666611111111111166666611116666116611661166666611dd0000000000
00000000dd1166666611116666116666111111666611666666116666661166661111666666111111111166666611661166116611661166111111dd0000000000
00000000dd1166666611116666116666111111666611666666116666661166661111666666111111111166666611661166116611661166111111dd0000000000
00000000dd1166661111116666116666111111666611666611111166661166661111116666111111111166116611661166116611661166661111dd0000000000
00000000dd1166661111116666116666111111666611666611111166661166661111116666111111111166116611661166116611661166661111dd0000000000
00000000dd1166666611116666116666661166666611666611111166661166661111666666111111111166116611661166116666661166111111dd0000000000
00000000dd1166666611116666116666661166666611666611111166661166661111666666111111111166116611661166116666661166111111dd0000000000
00000000dd1111666666666611111166666666661111116666666666111111666666666611111111111166116611666611111166111166666611dd0000000000
00000000dd1111666666666611111166666666661111116666666666111111666666666611111111111166116611666611111166111166666611dd0000000000
00000000dd1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dd0000000000
00000000dd1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dd0000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000

__gff__
0000000000000000000000000000808080808080008080c080808080808080808000808080808080808080008000808080808000c0c0c080800000800080808001010101010101010101010101000001000100020000000100010101000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4242424242424242424242424200000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
42005e5851535800530000184200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242534242534242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
425858585853424253515e184200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4254000000534242534242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242534242004f00544200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4258585842534242424253424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
420000004f534200004153410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424200004153410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200000000000000004153410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200000000000000004153410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200000000000000004153410000000042424200000000000058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242420000004242424200000042424242424258580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
425e5100000000000000000054000058000000000000515f4258580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242420019004242424253424242424242180000424242425858580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200004b4b4c0000004253420000000000424242000000424245454545454545454545454545454545454545454500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200000000000000004253420000000000000000000000425300000000000000170000000000000000000000000045450000585800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424253424242424242424242420000425300580000000000000000000000000000000000000000004500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000534200000000000000004200004c5345454545454500150000170000000000000000000000004500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001b00581a00001b000051005f2800546928004200004c534c4c4c4c4c4c4545000000000000000000000000006e544400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00424242424242424242424242424242424242534258584c534c4c4c4c4c4c4c4c4500150000001d58001658000045450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004200000000000000000000000000000000425342585842534c4c4c4c4c4c4c4c4c45454500004545454545454500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004200000000000000000000000000000000425342000042534c4c4c4c4c4c4c4c4c4c4c4c00004c4c4c4c4c4c4c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0042000000000000424242424242424200004253420000425342000000000000000000004c00004c005d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0042424242424040000000000000000041004253420000425342000000000000000000004c00004c5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000040000000000000000041004253420000425342000000000000000000004c00584c000000004c4c4c004c4c4c4c4c4c4c58000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5f5e5e5e5f00004d00000000000000004d00425342424242534200000000004c4c4c4c4c4c00584c4c4c4c4c00004c4000000000000000404c4c4c000000000000000000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424040000000002a0000004100006a4f5e5e5f534200000000004c530000004f00004f005f5e5e5e5e514d000000000000004d5e004c000000000000000000000000004800480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000042424242424242420042424242424242424200000000004c534c4c4c4c4b4b4b4b4c4c4c4b4b4b4000000020000000404c534c0000000000000000000000004800005e4800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000004c534c000000000000000000004c4c4c00434c4c4b4c4c43004c534c00000000000000000000004800005e480048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000004c534c000000000000000000000000000000000000000000004c534c000000000048484848484800000048000053480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003d3d3d00000000000000000045454545454500000000000000004c534c000000000000000000000057575757575757575757574c534c57570000004853000000000058485e5f0053480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
