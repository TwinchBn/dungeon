pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--dungeon
--by ben + jeffu warmouth

function _init()
	reload(0x1000, 0x1000, 0x2000)
	poke(0x5f5c, 255)	--btnp fix	
	trace=true
	sound=false
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
 update_player()
	if active then
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
 foreach(enemies,draw_enemy)
	draw_player()
 camera(0,0)
 draw_ui()
end --_draw()


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
 

--------------------
-----  buttons  ----
--------------------
--[[
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
--]]

-->8
--ui

function init_ui()
	--log={}
	dpanel1={"you have been","pixelated!"}
	dpanel2={"❎ restart"}
 spanel={"❎ start"}
	set_ipanel({"⬅️⬇️⬆️➡️ move"},300)
	uh={x=0,y=0,w=10,h=0,cb=8,cf=11} --health
	ug={x=0,y=1,w=10,h=0,cf=9}--gold
	uk={x=0,y=2,w=6,h=3} --keys
	ur={x=0,y=6,h=4} --runes
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
 if (msg and t==nil) ipanel_timer=30
end

function draw_ui()
	--foreach (ui,draw_panel)
	--draw_panel(cpanel,"l","b",1,8)

	if active then
		keys_ui()
 	healthbar()
 	goldbar()
 	draw_runes()
		if (ipanel) draw_panel(ipanel,"c","b",1,8,true)
 	if (log) draw_panel(log,"l","t",1,8)
 	if (trace and onladder()) spr(83,0,56) 
	else --if not active
  if p.dead then
 		draw_panel(dpanel1,"c","t",1,8,true)
 		draw_panel(dpanel2,"c","b",1,8,true)
 		if (btnp(❎)) _init()
 	else --if not p.dead
 		 title_screen()
  	if (btnp(❎)) active = true
		end --if p.dead
 end --if active
end

function keys_ui()
 for i=1,p.keys do
 	spr(93,uk.x+uk.w*(i-1),uk.y)
 end
end

function healthbar()
	--rectfill(0,0,20,0,8)
	--uh.fill=uh.w*p.health/p.maxhealth
 uh.w = p.maxhealth
 uh.fill=p.health
 rectfill(uh.x,uh.y,uh.x+uh.w,uh.y+uh.h,uh.cb)
 rectfill(uh.x,uh.y,uh.x+uh.fill,uh.y+uh.h,uh.cf)
end

function goldbar()
	if p.gold>0 then
 	rectfill(ug.x,ug.y,ug.x+p.gold,ug.y+ug.h,ug.cf)
	end
end

function draw_runes()
	for i=1,#p.runes do
		spr(p.runes[i],0,64-8*i)
	end
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



function title_screen()
	--if (btn(🅾️)) return
	
	local x,y=1,2
	
	cls()
	--p
	spr(192,x,y,1,2)
	spr(192,x,y+14,.3,2)
	spr(192,x,y+16,.3,2,true,false)
	pset(x+1,y+31,0)
	--pset(x+5,y,0)
	
	--i
	x+=8
	spr(192,x,y,.3,2,true)
	spr(192,x,y+16,.3,2)
	
	--x
	x+=4
	spr(192,x,y,.3,.4)
	spr(192,x+4,y,.3,.4)
	spr(192,x,y+2,1,1.8,false,true)
	spr(192,x,y+16,.3,2,false,true)
	spr(192,x+4,y+16,.3,2,true)
	pset(x,y+15,0)
	--rect(x+2,y+16)
	
	--dwarf
	spr(48,x+9,y+8)
	
	--c
	x+=18
	spr(192,x,y,1,.3,false,true)
	spr(192,x,y,.3,2,true)
	spr(192,x,y+16,1,2)
	rectfill(x+2,y+16,x+6,y+29,0)
	
	--e
	x+=8
	spr(192,x,y,1,.3,false,true)
	spr(192,x,y,.3,2,true)
	spr(192,x,y+14,.8,2,true,true)
	spr(192,x,y+16,.8,2,true)
	rectfill(x+2,y+16,x+6,y+29,0)
	--spr(192,x,y+16,1,.3,false,true)
	
	--l
	x+=8
	spr(192,x,y,.3,2,true)
	spr(192,x,y+16,.8,2)
	rectfill(x+2,y+16,x+6,y+29,0)
	--spr(192,x,y+16,.3,2)
	
	--s
	x+=8
	spr(192,x,y,1,.3,false,true)
	spr(192,x,y,.3,1.9,true)
	spr(192,x,y+16,.8,2)
	rectfill(x,y+16,x+2,y+29,0)
	rectfill(x+1,y+14,x+2,y+15,7)
	rectfill(x+2,y+15,x+3,y+16,7)

	draw_panel({"BY tWINCHbN",
								"+ jEFFU wARMOUTH"},
									"c","m",0,0,true,1)
	draw_panel(spanel,
								"c","b",1,8,true,2)
 		
end

--[[
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
--]]

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
		--x=8,y=50,--pos
		x=43*8,y=38*8,
		speed=2,--walk speed
		jforce=-2.5,--jump force
		jumps=0,maxjumps=1,--jumps
		framerate=12,
		
		--temp stuff
		tx=0,ty=8,--temp x,y
		w=4,h=8,--start sprite
		cell=0,--map cell sprite
		dy=0,--for gravity
 	gnd=false,--on ground?
 	xscale=1,flip=false,--flip
 	--hitflash=0,
 	flash=colormap.pink,
 	--count=0,--current game frame
 	--frame=0,--current anim frame
 	--sp=3,
 	keys=0,
 	weapon=weapons.none, --weapon
 	cx=0,cy=0, --change from last frame
		health=10,maxhealth=10,
		gold=0,
		x1=0,x2=0,y1=0,y2=0,spx=0,
		melee={x1=0,x2=0,y1=0,y2=0,spx=0},
	
 	anim={
 		rate=12,tick=0,fr=0,sp=0,
 		stand={sp={3},x=0,y=1,w=4,h=7,name="stand"},
			walk={sp={7,8},x=0,y=1,w=4,h=7,name="walk"},
			crouch={sp={2},x=0,y=2,w=4,h=7,name="crouch"},
			jump={sp={1},x=0,y=0,w=4,h=7,name="jump"},
			climb={sp={4,5},x=1,y=1,w=4,h=7,	name="climb"},
			ladder={sp={4},x=1,y=1,w=4,h=7,	name="ladder"},
			dead={sp={6},x=0,y=5,w=7,h=3, name="dead"},
		}, --end anim
		--inventory={},
		w_anim={rate=15,tick=0,fr=0,sp=0},
		weapons={},
		runes={},
		die=function()
			p.weapon=weapons.none
			p.dead=true
			active=false
		end,
		defend=function()
		end
	} --end p
	p.state=p.anim.stand
	p.tx,p.ty=p.x,p.y
	p.px,p.py=p.x,p.y
	p.⬆️ = false --jump button
end

function update_player()
	--btnu(⬆️)
	if (p.dead) then
			p.state=p.anim.dead
			animate(p.anim,p.state.sp)
			return
	end
	
 	move_player() --walk,climb,crouch
 	jump()
 	fall()
 	set_player_state()
 	player_hitboxes()
		player_combat()
 
 --not sure what these do
 --p.cell=mget(p.x/8,p.y/8)
 --p.cx,p.cy=p.x-p.px,p.y-p.py
 p.px,p.py=p.x,p.y
	--animate_player()
	
	animate(p.anim,p.state.sp)
	update_flash(p)
	
	--log_player()
	if trace then
		add(log,"p:"..p.x..","..p.y)
	end
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
	
	if onladder() then
		climb()
	else
		walk()
	end
	
	--[
	if trymove() then
		p.x,p.y=p.tx,p.ty
	else
		p.tx,p.ty=p.x,p.y
	end --]]

end --move()

function climb()
	if btn(2) then
		p.ty -= p.speed
		center_on_ladder()
	elseif btn(3) then
		p.ty += p.speed
		center_on_ladder()
	else
		walk()
	end
end

function walk()
	local speed=p.speed
	
	--tar: 50% speed
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
	
end


function set_player_state()
	--setting animation states
	if p.dead then
		p.state=p.anim.dead
	elseif onladder() and (p.y != p.py) then
			p.state=p.anim.climb
	elseif (p.x != p.px) then
		p.state = p.anim.walk
	--elseif btn(⬇️) then
	--		p.state=p.anim.crouch
	else
		p.state = p.anim.stand
	end
	
	--[[
	p.x1,p.y1=p.x,p.y
	p.x2,p.y2=p.x+p.w,p.y+p.h
	--]]
end --set_player_state()
	
--[[
function state_collider()
	-- set collider box (uh, later?)
	p.w,p.h=p.state.w,p.state.h
	p.x1,p.y1=p.x,p.y
	p.x2,p.y2=p.x+p.w,p.y+p.h
	--p.w=(p.state.w-p.state.x-1) -- *p.xscale
 --p.h=p.state.h-p.state.y-1
end --state_collider()
--]]

function jump()
	if (onladder()) return
	if btnp(⬆️) and
				p.jumps<p.maxjumps then
		p.dy=p.jforce
		p.jumps += 1
		p.state=p.anim.jump
		p.gnd=false
	end
end --jump()


function onladder()
	if touching(83) or 
				groundis(83) or
				touching(103) or 
				groundis(103) then
	 return true
	end
end --onladder()

function center_on_ladder()
	local x1,y1,x2,y2 = temp_exy(p)
	local ladder_x
	if fget(mget(x1/8,y1/8),2) or
				fget(mget(x1/8,y2/8),2) then
				ladder_x = x1
	elseif fget(mget(x2/8,y1/8),2) or
				fget(mget(x2/8,y2/8),2) then
				ladder_x = x2
	end
	if not (ladder_x==0) then
		ladder_x = flr(p.x/8)*8 + 2
		p.x = ladder_x
	end
end --center_on_ladder()


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
			p.y=flr(p.y)
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
 	local hit = hitground(p) 
 		or	hithead() 
 		or hitbounds()
 	return not hit
end --trymove()


function player_hitboxes()
	p.w,p.h=p.state.w,p.state.h
	find_exy(p)
	
	p.melee.x1 = p.x+p.weapon.x*p.xscale
	p.melee.y1 = p.y1+p.weapon.y
	p.melee.x2 = p.melee.x1+p.weapon.w
	p.melee.y2 = p.melee.y1+p.weapon.h
	
 p.spx = p.x1
 p.melee.spx = p.melee.x1
	if p.flip then
		p.spx -= (7-p.state.w)
		p.melee.spx -= p.weapon.w - 1
	end
end
 

function draw_player()

	--player sprite
	draw_flash(p)
	spr(p.anim.sp,p.spx,p.y1,1,1,p.flip)
	pal()
	
	if (p.dead) return
	
	--weapon
	spr(p.w_anim.sp,p.melee.spx,
					p.melee.y1,1,1,p.flip)
	
	--arrows
	for a in all (arrows) do
		rectfill(a.x,a.y,a.x+a.w,a.y,a.colors[1])
		pset((a.x+a.w/2)+a.w/2*sgn(a.dx),a.y,a.colors[2])	
	end
	
-- bounding boxes
	if trace then
		rect(p.x1,p.y1,p.x2,p.y2,6)
		pset(p.x1,p.y1,10)
		
		if p.hitting then
			--weapon hitbox
			rect(p.melee.x1,p.melee.y1,p.melee.x2,p.melee.y2,8)
		end
	
	end
end --draw_player()
	
	
--[[
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
--]]

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
	bosses={}

	colormap={
		gray={6,8},
		green={11,8},
		brown={4,8},
		orange={9,8},
		white={7,8},
		red={8,5},
		blue={12,8},
		pink={8,13},
	}
	
	enemy_classes={
		{name="default",sp=16,
			health=5,dmg=1,
			speed=.5,w=7,h=7,
			cool=10,
			flash=colormap.gray,
			state=state_patrol,
			defend=enemy_defend,
			die=enemy_die},
			
		{name="skeleton",sp=24,
			health=4,dmg=3,
			speed=.6,w=4,h=7,
			cool=10},
			
		{name="sword skeleton",sp=25,
			health=5,dmg=4,
			speed=.6,w=5,h=7,
			cool=10},
			
		{name="warrior skeleton",sp=26,
			health=8,dmg=4,
			speed=.4,w=6,h=7,
			cool=10},
			
		{name="bomb skeleton",sp=27,
			health=5,dmg=2,
			speed=.5,w=7,h=7,
			cool=10},
			
		{name="zombie",sp=40,
			health=6,dmg=5,
			speed=.4,w=5,h=7,
			cool=10,
			flash=colormap.green},
			
		{name="cyclops",sp=42,
			health=15,dmg=8,
			speed=.75,w=7,h=7,
			cool=10,
			deathsp=43,
			drops={9,10,17,18}
			},
			
		--outside
		{name="dirty worm",sp=32,
			health=25,dmg=12,
			speed=.8,w=7,h=7,
			cool=30,
			deathsp=33,
			drops={1,6}
			},
			
		--underground beach
		{name="sand man",sp=59,
			health=30,dmg=15,
			speed=.4,w=4,h=7,
			cool=30,
			deathsp=60,
			drops={1,8},
			flash=colormap.orange
			},
		
			
		--snowy biome
		{name="snowy dwarf",sp=39,
			health=18,dmg=8,
			speed=.7,w=7,h=7,
			cool=10,
			flash=colormap.white},
			
		{name="ice troll",sp=49,
			health=20,dmg=10,
			speed=.4,w=7,h=7,
			cool=10,
			flash=colormap.blue},
			
		{name="turret worm",sp=46,
			health=15,dmg=7,
			speed=.5,w=6,h=7,
			cool=10,
			},
			
		{name="snow dwarf king",sp=44,
			health=30,dmg=15,
			speed=.5,w=6,h=7,
			cool=10,
			deathsp=45,
			flash=colormap.gray
			},
			
		--music jungle
		{name="music note",sp=52,
			health=20,dmg=10,
			speed=.6,w=4,h=7,
			cool=10,
			flash=colormap.green
			},
			
		{name="music note",sp=53,
			health=20,dmg=10,
			speed=.4,w=7,h=7,
			cool=10,
			flash=colormap.green
			},
			
		{name="music note",sp=54,
			health=20,dmg=10,
			speed=.5,w=3,h=7,
			cool=10,
			flash=colormap.green
			},
			
		{name="giant fly",sp=55,
			health=15,dmg=5,
			speed=.5,w=6,h=7,
			cool=10,
			flash=colormap.orange
			},
			
		{name="slime mage",sp=56,
			health=15,dmg=5,
			speed=.5,w=7,h=7,
			cool=10,
			deathsp=58,
			flash=colormap.green
			},
			
		--alien home
		{name="alien",sp=38,
			health=10,dmg=5,
			speed=.5,w=3,h=7,
			cool=10,
			flash=colormap.red
			},
			
		{name="alien worm",sp=41,
			health=10,dmg=5,
			speed=.5,w=5,h=7,
			cool=10,
			flash=colormap.red
			},
			
		{name="alien dragon",sp=50,
			health=15,dmg=5,
			speed=.5,w=7,h=7,
			cool=10,
			deathsp=51,
			flash=colormap.red
			},
			
		
		--unmentionable biome
		{name="black worm",sp=34,
			health=5,dmg=3,
			speed=.5,w=5,h=7,
			cool=10,
			},
		
		--slimes
			
		{name="slime pack",sp=29,
			health=10,dmg=6,
			speed=.2,w=7,h=7,
			cool=10,
			flash=colormap.green,
			die=spawn_slimes
			},
		
		{name="green slime",sp=21,
			health=8,dmg=3,
			speed=.3,w=3,h=7,
			cool=10,
			flash=colormap.green},
			
		{name="flying slime",sp=23,
			health=8,dmg=4,
			speed=.7,w=7,h=3,
			cool=10,
			flash=colormap.green},
			
		{name="holy slime",sp=22,
			health=12,dmg=5,
			speed=.6,w=3,h=7,
			cool=10,
			flash=colormap.green},
			
		{name="brown slime",sp=47,
			health=10,dmg=5,
			speed=.25,w=3,h=7,
			cool=10,
			flash=colormap.brown},
			
		{name="orange slime",sp=30,
			health=12,dmg=6,
			speed=.35,w=3,h=7,
			cool=10,
			flash=colormap.orange},
			
		{name="red slime",sp=31,
			health=15,dmg=5,
			speed=.4,w=3,h=7,
			cool=10,
			flash=colormap.red},
			
		{name="frost slime",sp=48,
			health=15,dmg=6,
			speed=.7,w=3,h=7,
			cool=10,
			flash=colormap.white},
			
		{name="viking slime",sp=14,
			health=20,dmg=10,
			speed=.5,w=5,h=7,
			cool=10,
			flash=colormap.green},
			
		{name="monk slime",sp=15,
			health=20,dmg=10,
			speed=.5,w=4,h=7,
			cool=10,
			flash=colormap.green},
			
		{name="wiz slime",sp=61,
			health=20,dmg=10,
			speed=.5,w=6,h=7,
			cool=10,
			flash=colormap.green},
			
		{name="warrior slime",sp=62,
			health=10,dmg=5,
			speed=.5,w=6,h=7,
			cool=10,
			flash=colormap.green},
			
		{name="thief slime",sp=63,
			health=10,dmg=5,
			speed=.5,w=6,h=7,
			cool=10,
			flash=colormap.green},
			
		{name="spikes",sp=85,
			h=3,y=4,dmg=10,speed=0},
			
		{name="sm spikes",sp=86,
			h=3,y=4,dmg=5,speed=0},
		
	}

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
end --update_enemies


function wake_enemy(mx,my)
	local sp=mget(mx,my)
	make_enemy(sp,mx*8,my*8)
	mset(mx,my,0)
end

function make_enemy(sp,x,y,flipped)
	local c=getclass(sp)
	local d=enemy_classes[1] --default
	local e={sp=sp,
							x=x,  y=y,
							tx=x, ty=y,
							w=c.w,   h=c.h,
							health=c.health,
							flipx=c.flipx,
							speed=c.speed * flipfactor(c.flipx),
							--hitflash=0,
							class=c,
							cool=c.cool,
							defend=c.defend,
							die=c.die,
							state=c.state,
							flash=c.flash,
							deathsp=c.deathsp,
							drops=c.drops,
							invulnerable=c.invulnerable,
							}
	if (fget(sp,6)) then
		e.boss=true
		e.die=boss_die
	end
	if (fget(sp,5)) then
		e.invulnerable=true
		e.cool=300
		e.flash=colormap.green
		e.state=state_freeze
	end
	if (fget(sp,5)) e.fly=true
	if (not e.defend)	e.defend=d.defend
	if (not e.state) e.state=d.state
	if (not e.flash) e.flash=d.flash
	if (not e.cool) e.cool=d.cool
	if (not e.die) e.die=d.die
	if (not e.w) e.w=d.w
	if (not e.h) e.h=d.h
	if (not e.speed) e.speed=d.speed
	if (flipped) flip_enemy(e)
	add(enemies,e)
	if (e.boss) init_boss(e)
end


function getclass(sp)
	for e in all (enemy_classes) do
		if (e.sp==sp) return e
	end
	return enemy_classes[1]
end


function update_enemy(e)
	
	if e.boss then
		update_boss(e)
	else
		check_sleep(e)
	end --if
	
	enemy_label(e)
	e:state()
	update_flash(e)
	combat(e)
	--add(log,e.class.name.." "..flr(e.x)..","..flr(e.y))
end

function enemy_label(e)
		if (e.x-p.x)^2+(e.y-p.y)^2 < 240 then
			set_ipanel({e.class.name})
			--if (e.boss) closedoor(e)
		end
end


function check_sleep(e)
	--sleep if offscreen+full health
	if mget(e.x/8,e.y/8) == 0 and
		(abs(e.x-p.x) > gamew or
			abs(e.y-p.y) >gameh) then
			--(e.x < p.x - gamew or
			--e.x > p.x + gamew or
			--e.y < p.y - gameh or
			--e.y > p.y + gameh) then
	 mset(e.x/8,e.y/8,e.sp)
	 del(enemies,e)
	end --if
end

function init_boss(e)
	add(bosses,e)
	for i=e.x/8-5,e.x/8+5 do
		for j=e.y/8-1,e.y/8 do
			local sp=mget(i,j)
			if (sp==78) e.entrance={i,j}
			if (sp==77) e.exit={i,j}
		end --for j
	end --for i
end

function update_boss(e)
	if mget(e.entrance[1],e.entrance[2],78) then
		local ddist = abs(e.x-e.entrance[1]*8)
		local pdist = abs(e.x-p.x)
		--if e.entrance[1]*8+1 < p.x then
		if pdist<ddist-8 and abs(e.y-p.y) < 16	then
			closedoors(e)
		end --if
	end --if
end

function closedoors(e)
	mset(e.entrance[1],e.entrance[2],77)
	--del(e,e.entrance)
end

function opendoors(e)
	mset(e.entrance[1],e.entrance[2],78)
 mset(e.exit[1],e.exit[2],78)
end 

--enemy states
function	state_patrol(e)
	e.tx = e.x+e.speed
	if e.tx<0 or e.tx+e.w>128*8
		or bonk(e.tx,e.y,true)
		or bonk(e.tx+e.w,e.y,true)
		or (not e.fly 
				and (not bonk(e.tx,e.y+8,true)
				or not bonk(e.tx+e.w,e.y+8,true))
			)
		then
		flip_enemy(e)
	else
		e.x = e.tx
	end
end

function state_freeze(e)

end

function enemy_defend(e)
	flip_enemy(e)
end

function enemy_die(e)
	del(enemies,e)
end

function boss_die(e)
	mset(e.x/8,e.y/8,e.deathsp)
	if (e.drops) drop_loot(e)
	opendoors(e)
	del(enemies,e)
	del(bosses,e)
end

function drop_loot(e)
	--[
	local xlocs={}
	for i=e.x/8-1,e.x/8+1,2 do
		if (not fget(mget(i,e.y/8),0)) add(xlocs,i)
	end
	if (#xlocs==0) add(xlocs,e.x/8)
	mset(rnd(xlocs),e.y/8,items[rnd(e.drops)].sprite)
	--]]
	--mset(e.x/8,e.y/8,items[rnd(e.drops)].sprite)
end

function spawn_slimes(e)
	--local mx,my=e.x/8,e.y/8
	local slimes={21,30,31,47}
	local x=e.x-10
	for i=1,#slimes do
		--mset(mx,my,)
		make_enemy(slimes[i],e.x+i*4,e.y,i%2==0)
	end --for
	del(enemies,e)
end --function

function flip_enemy(e)
		e.flipx = not e.flipx
		e.speed = abs(e.speed) * flipfactor(e.flipx)
end

function flipfactor(flipx)
		if (flipx) return 1
		return -1
end

function draw_enemy(e)
	local sprx = e.x
	if (e.flipx) sprx=e.x-7+e.w
	
	draw_flash(e)
	spr(e.sp,sprx,e.y,1,1,e.flipx)
	pal()
	
	if (trace) then
		rect(e.x1,e.y1,e.x2,e.y2,8)
		pset(e.x,e.y,9)
	end
end
-->8
--collision

function find_exy(o)
	-- find x1,y1,x2,y2 of object
	o.x1,o.y1=o.x,o.y
	if (o.class and o.class.y) o.y1+=o.class.y
	o.x2,o.y2=o.x1+o.w,o.y1+o.h
end

function temp_exy(o) --return box
 local x,y = o.tx,o.ty
 return x,x+o.w,y+7-o.h,y+o.h
end --box()


function collide_xy(a,b)
 return a.x2>b.x1 and b.x2>a.x1
 		 and a.y2>b.y1 and	b.y2>a.y1
end --collide


function touching(sp)
	local x1,y1,x2,y2 = temp_exy(p)
	return mget(x1/8,y1/8) == sp 
				 or mget(x2/8,y1/8) == sp
				 or mget(x1/8,y2/8) == sp
				 or mget(x2/8,y2/8) == sp
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
end --near()


----- player collision
function bonk(x,y,enemy)
 --add(log,"bonk: "..x..","..y)
 --add(log,"bonk: "..x..","..y)
 if (fget(mget(x/8,y/8),0)) return true
 if enemy then 
 	if (fget(mget(x/8,y/8),2))	return true
 	if (fget(mget(x/8,y/8),1)) return true
 end
end --bonk

function hithead()
	--if --bonk(p.tx,p.ty+p.state.y) or
				--bonk(p.tx+p.w/2,p.ty+p.state.y) then
	local x1,x2,y=p.tx,p.tx+p.w,p.ty+1
	
	return fget(mget(x1/8,y/8),0)
					or fget(mget(x2/8,y/8),0)
end --hithead()

function hitbounds()
	return p.tx<0	or p.tx>128*8 
					or p.ty<0 or p.ty+p.h>63*8
					--or p.tx+p.w<0
					--or p.tx+p.w>128*8
					--or p.ty+p.h<0
					--or p.ty>63*8 
end --hitbounds()

function fallhit()
	local x1,x2,y=p.tx,p.tx+p.w,p.ty+p.h
	
	return fget(mget(x1/8,y/8),0)
					or fget(mget(x2/8,y/8),0)
					or fget(mget(x1/8,y/8),1)
					or fget(mget(x2/8,y/8),1) 
end

function hitground(o)
--one point only
	if bonk(o.tx,o.ty+o.h) or
				bonk(o.tx+o.w,o.ty+o.h) then
		return true
	end
end --hitground()

function groundis(sp)
 if mget((p.tx+p.w/2)/8,(p.ty+10)/8) == sp then
 	return true
 end
end



--[[
function find_exy(e)

	local exy={
		x1=e.x,
		y1=e.y,
		x2=e.x+e.w,
		y2=e.y+e.h
	}

	if e.class.y then
		exy.y1+=e.class.y
		exy.y2+=e.class.y
	end
	
	return exy
end
--]]

--[[
function box(obj,temp) --return box
 local x,y = obj.x,obj.y
 if (temp) x,y=obj.tx,obj.ty
 --local x1=x-obj.w/2
 --local x2=x+obj.w/2
 --local x1=x
 --local x2=x+obj.w
 --local y1=y+7-obj.h
 --local y2=y+obj.h
 --return x1,y1,x2,y2
 return x, x+obj.w,
 							y+7-obj.h,
 							y+obj.h
end --box()
--]]

--[[
function collide(a,b)
 if a.x+a.w>b.x and
 			b.x+b.w>a.x and
 			a.y+a.h>b.y and
 			b.y+b.h>a.y then
 	return true
 end
 return false
end --collide
--]]


	--[[
	--old hitground
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
		arrow_normal={
			dmg=2,w=6,h=1,
			speed=3,
			colors={6,5}
		} --arrow_normal
		
		arrow_fire={
			dmg=4,w=6,h=1,
			speed=3,
			colors={9,8}
		} --arrow_normal
		
	weapons={
		none={
			name="fist",
			dmg=1,t=1,r=0,
			x=4,y=2,w=2,h=2,
			sp={0},
			drop_sp=0,
			dur=5,cooldown=5,
			melee=true,
			sound=3,
			action=fist_attack},
			
		sword={
			name="sword",
			dmg=3,t=5,r=4,
			x=4,y=0,w=4,h=7,
			dur=5,cooldown=5,
			melee=true,
			sp={9,10,11},
			drop_sp=119,
			sound=0,
			action=melee_attack},
			
		axe={
			name="axe",
			dmg=4,t=5,r=4,
			x=5,y=0,w=4,h=7,
			dur=5,cooldown=5,
			melee=true,
			sp={98,100,99},
			drop_sp=114,
			sound=0,
			action=melee_attack},
			
		bow={
			name="bow",
			t=5,r=4,
			dmg=0,
			x=4,y=0,w=4,h=7,
			dur=2,cooldown=15,
			melee=false,
			sp={12,13,13,12,12,12,12,12,12},
			drop_sp=118,
			sound=1,
			arrow=arrow_normal,
			action=bow_attack}
		} --weapons
		
		arrows={}
end

--[[
	notes on bow use
	bow action = spawn arrow
	arrow is entity, updated in combat update
	need entity system (not specifically weapon)
--]]

function combat(e)

	find_exy(e)

	-- enemy hits player
	if e.cool>0 then
		e.cool -= 1
	elseif collide_xy(p,e) then
		--p.health -= e.class.dmg
		local dmg=e.class.dmg
		if (p.rune_shield) dmg/=2
		damage(p,dmg)
		--end
		e.cool = e.class.cool
	end --if e hit p
	
 -- player weapon hits enemy
 if btnp(❎) and p.weapon.melee and
 	collide_xy(p.melee,e) then
			--damage_enemy(e,p.weapon.dmg)
		local dmg=p.weapon.dmg
		if (p.rune_sword) dmg*=2
		--or match sword/fist/axe
		damage(e,dmg)
	end --if btnp(❎)
end --combat

function damage(o,dmg)
	if (o.invulnerable) return
	o.health -= dmg
	o.hitflash=15 --e.cool
	if (o.health<=0) o:die()
	o:defend()
	--if enemy
	--if (not o==p) flip_enemy(o)
end --damage

function update_flash(o)
	if o.hitflash and o.hitflash>0 then
		o.hitflash -=1
	end
end

function draw_flash(o)
	if o.hitflash and o.hitflash>0 then
		pal(o.flash[1],o.flash[2])
	end
end

function player_combat()
	foreach(arrows,update_arrow)
	
 if p.hitting then
		animate(p.w_anim,p.weapon.sp)
		if p.w_anim.tick>p.weapon.cooldown then
			p.hitting=false
		end --tick
	else --if not p.hitting
		if btnp(❎) then
			p.w_anim.tick=1
			p.weapon:action()
 		p.hitting=true
 		if sound and p.weapon.sound then
 			sfx(p.weapon.sound)
 		end --if
 	end
		p.w_anim.sp=p.weapon.sp[1]	
	end --p.hitting
end --player_combat


--weapons
function melee_attack(self)
	if (sound) sfx(0)
 --p.hitting=true
end

function fist_attack(self)
	if (sound) sfx(3)
 --p.hitting=true
end

function bow_attack(self)
	if (sound) sfx(1)
	--p.hitting=true
	local arrow=self.arrow
	local a={
		w=arrow.w,
		h=arrow.h,
		x=p.melee.spx,
		y=p.y+4,
		dmg=arrow.dmg,
		colors=arrow.colors,
		dx=arrow.speed * p.xscale,
	}
	add(arrows,a)
end

function update_arrow(a)
	a.x+=a.dx
	a.x1,a.x2=a.x,a.x+a.w
	a.y1,a.y2=a.y,a.y+a.h
	if a.x<0 or a.x>128*8 or
		fget(mget(a.x/8,a.y/8),0)  then
	 del(arrows,a)
	end --if
	for e in all (enemies) do
		local exy = {x1=e.x,y1=e.y,x2=e.x+e.class.w,y2=e.y+e.class.h}
		if collide_xy(a,exy) then
			local dmg=a.dmg
			if (p.rune_bow) dmg *=2
			damage(e,dmg)
			del(arrows,a)
		end --if collide
	end --for
end --update arrows


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
		{name="loot bag",sprite=120,
	 	action=function()
	 		-- +10-20 gold
	 		local g=flr(rnd(10))+10
	 		if (p.rune_chalice) g*=2
	 		p.gold += g
	 		set_ipanel({"+"..g.." gold"})
	 	end},
	 	
	 {name="gold",sprite=121,
	 	action=function()
	 		-- +5-10 gold
	 		local g=flr(rnd(5))+5
	 		if (p.rune_chalice) g*=2
	 		p.gold += g
	 		set_ipanel({"+"..g.." gold"})
	 	end},
	 	
	 {name="key",sprite=84,
	 	sound=4,
		 action=function()
			 p.keys+=1
		 end
	 },
	 
	 {name="door",
		 sprite=79,newsprite=80,
		 verb={"open","opened"}
		 },
	
	 {name="locked door",
			sprite=81,newsprite=82,
			verb={"locked","unlocked"},
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
	 
	 {name="scroll",sprite=95,
	 	msg={"scroll","health +2"},
	 	action=function()
	 		--double health
	 		p.maxhealth += 2
	 	end},
	 
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
	 
	 --runes
	 {name="chalice rune",sprite=104,
	 	msg={"chalice rune","gold x2"},
			blocked=function()
		 	return p.rune_chalice
		 end,
	 	action=function()
	 		--double gold
	 		p.rune_chalice=true
	 		add(p.runes,104)
	 	end},	 
	 	
	 {name="sword rune",sprite=105,
	 	msg={"sword rune","melee x2"},
	 	blocked=function()
		 	return p.rune_melee
		 end,
	 	action=function()
	 		--double melee strength
	 		p.rune_melee=true
	 		add(p.runes,105)
	 	end},
	 	
	 {name="shield rune",sprite=106,
	 	msg={"shield rune","defense x2"},
	 	blocked=function()
		 	return p.rune_shield
		 end,
	 	action=function()
	 		--double defense
	 		p.rune_shield=true
	 		add(p.runes,106)
	 	end},	 
	 	
	 {name="heart rune",sprite=107,
	 	msg={"heart rune","health x2"},
	 	blocked=function()
		 	return p.rune_heart
		 end,
	 	action=function()
	 		--double health
	 		p.maxhealth *= 2
	 		p.rune_heart=true
	 		add(p.runes,107)
	 	end},
	 	
	 {name="fist rune",sprite=108,
	 	msg={"fist rune","damage x2"},
	 	blocked=function()
		 	return p.rune_fist
		 end,
	 	action=function()
	 		--double damage ???
	 		p.rune_fist=true
	 		add(p.runes,108)
	 	end},
	 	
	 {name="key rune",sprite=109,
	 	msg={"key rune","extra key"},
	 	blocked=function()
		 	return p.rune_key
		 end,
	 	action=function()
	 		--extra key? might get rid
	 		p.rune_key=true
	 		add(p.runes,109)
	 	end},
	 	
	 {name="slime rune",sprite=110,
	 	msg={"slime rune","summon slime pet"},
	 	blocked=function()
		 	return p.rune_slime
		 end,
	 	action=function()
	 		--summon slime pet
	 		p.rune_slime=true
	 		add(p.runes,110)
	 	end},
	 	
	 {name="bow rune",sprite=111,
	 	msg={"bow rune","range x2"},
	 	blocked=function()
		 	return p.rune_bow
		 end,
	 	action=function()
	 		--double ranged damage
	 		p.rune_bow=true
	 		add(p.runes,111)
	 	end},
	 	
	 {name="bow",sprite=118,
	 	verb={"equip","equipped"},
		 blocked=function()
		 	return name == p.weapon.name
		 end,
	 	action=function(x,y)
	 		mset(x,y,p.weapon.drop_sp)
				p.weapon = weapons.bow
	 	end
	 	--set_weapon(x,y,weapons.bow)
	 },
	 	
	 {name="sword",sprite=119,
	 	verb={"equip","equipped"},
			blocked=function()
		 	return name == p.weapon.name
		 end,
	 	action=function(x,y)
	 		mset(x,y,p.weapon.drop_sp)
				p.weapon = weapons.sword
			end
	 },
	 	
	 {name="axe",sprite=114,
	 	verb={"equip","equipped"},
		 blocked=function()
		 	return name == p.weapon.name
		 end,
		 action=function(x,y)
	 		mset(x,y,p.weapon.drop_sp)
				p.weapon = weapons.axe
			end
	 },
	 
	 --locations
	 {loc="outside",sprite=69},
		{loc="beach",sprite=87},
		{loc="ice caves",sprite=72},
		{loc="music jungle",sprite=92},
		{loc="aliens home",sprite=67},
		{loc="unmeables cavern",sprite=90},
	}
	--[[
			 blocked=function()
			 if p.weapon.name == "sword" then
			 	return true
			 end
		 end,
	 	action=function(x,y)
	 		if p.weapon.name == "bow" then
	 			mset(x,y,118)
	 		else
	 			mset(x,y,0)
	 		end
	 		p.weapon = weapons.sword
	 	end},
	 --]]
	 
	 --[[
	loot:
		1 bag
		2 gold
		3 key
		6 scroll
		7 health
		8 chalice_rune 104
		9 sword_rune 105
		10 shield_rune 106
		11 heart_rune 107
		12 fist_rune 108
		13 key_rune 109
		14 slime_rune 110
		15 bow_rune 111
		16 bow
		17 sword
		18 pickaxe
	--]]

end

--[[
function already_got_one(name)
	if p then
		return name == p.weapon.name
	end
end

function set_weapon(x,y,weapon)
	if p then
		mset(x,y,p.weapon.drop_sp)
		p.weapon = weapon
	end
end
--]]
 

--loop through item types
function update_items()
	--local onx=p.x+p.w/2
	--local ony=p.y+p.h/2
	local near_items={}
	for i=1,#items do
		local item=items[i]
		local x,y,near=near(item.sprite)
		
		--if mget(onx/8,ony/8)==item.sprite then
			--behavior(onx,ony,item)
			--return

		if near then
			behavior(x,y,item)
			return
		end --if -- [ 
	end --loop to see if near
	
	--find closest
end --update_items()


--set generic item behavior
function behavior(x,y,item)
	if item.loc then
		set_ipanel({item.loc})
		return
	end
	
	local verb=item.verb
	if (verb==nil) verb={"take","taken"}
	local msg=item.msg
	if msg==nil then
		msg={item.name}
	else
		msg={
			verb[1].." "..item.name,
			item.name.." "..verb[2],
			item.name}
	end
	
	if item.blocked and item.blocked() 
		then
		set_ipanel({msg[3]})
	else
		set_ipanel({"🅾️ "..msg[1]})
		if (item.loc) item.loc()
		if btnp(🅾️) then
			set_ipanel({msg[2]})
			if (item.action) item.action(x,y)
			if (verb[1]=="take") mset(x,y,0)
			if (item.newsprite) mset(x,y,item.newsprite)
			if (sound and item.sound) sfx(item.sound)	
		end --if btnp
	end --if item.blocked
end -- function

-->8
--notes
--[[ comments

--jeff to do
[] bosses more interesting
[] enemy states
	[] pause / frozen
	[] aggro / charge
	[] retreat
	[] missile attack
	[] melee attack
	[] teleport
	[] telegraph move
[] balance enemy drops
	[] treasure drops
	[] weapon drops
[] new weapon mechanics
	❎ pickaxe
	[] shield
	[] frost shield
	[] staff w/missiles
	[] fists
	[] more weapon sub-types
❎ make sure all runes work
	❎ rune inventory
	❎ display active runes
	[] fist rune?
	[] key rune?
	[] slime rune?
[] summon a slime pet
[] status effects
	[] weapons with status
[] fine tune hp,dmg,drops
[] optimize box collision?

--jeff done
❎ enemy heights corrected
❎ player death sprite
❎ map reload - fix
❎ biome entry signs
❎ spikes
❎ slime pack split
❎ bow cooldown
❎ player hit flash
❎ bow/arrow system!
❎ enemy drop system
❎ get sizes right
❎ balance hp,damage
❎ mobs shouldn't float
❎ flying mobs turn
❎ locked out of slime mage


sprite, name, damage, health
player 10 hp
pickup +5 hp healed
scroll +2 hp permanent

enemies
14 barbarian slime
15 monk slime
21 green slime
24 skeleton d=3,h=3,c=30
25 sword skeleton
26 warrior skeleton
27 bomb skeleton
28
30 orange slime
31 red slime
39 frost dwarf - white
47 brown slime
61 wizard slime
62 warrior slime
63 rogue slime

bosses
29 slime boss
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

flags
0 ground
1 ladder
2 enemies can't pass
3
4
5 stationary hazard
6 boss
7 enemy


runes
95  scroll,+10 health
104 chalic3,doubl3 gold
105 sword,doubl3 mala strangth
106 shild,doubl3 dfanc3
107 ha3rt,doubl3 h3alth
108 fist,doubol3 damg3
109 k3y,3xtra k3y
110 slim3,sumon slim3 p3t
111 bow,doubl3 progtial3 damg3


120 gold?
121 pieces of gold?


--biomes

biome names!!!!!

66 prison,
69 outside,
87 underground beach
72 snowy mountan caves,
67 aliens home,
92 music jungle
unmeables cavern






]]
__gfx__
00000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ce0000000000000c0000000500c0000c005000000000000c0000000c000000000600000000500000000000040000000000000000000000000000000
0000000008805000c00000000ce000005cc000000cc50000000000000ce000000ce0000006000000055550000000000004000000444000004000040000000000
00000000088500000ce0000008805000588500005885000000000000088050000880500060000000555550000000000000400000000400004400440040000000
0000000002200000088000000885000008850000588000000000000008850000088500000000000066666000555500000040000000004000488884004bbbb000
000000002002000008850000022000002225000052220000001100c0022000000220000000000000000000006555000000400000000400000181800041b1b000
00000000000000000220000020020000200200002002000022288c00200200002002000000000000000000000650000004000000444000000b8bb0004bbbb000
00000000000000002002000020020000000200002000000022288e00000200002000000000000000000000000060000040000000000000000bbbb0004bbbb000
00000000600005000000000000000000000000000000000009000000aa1b1baa0555000010555000105550000055501100555000e4e4d8d80000000000000000
60000500600d50c06000050060000500000000000000000099900000a7bbbb7a0c5c000010c5c00010c5c00000c5c01100c5c000444488880000000000000000
600d50c060122010600d50c0600d50c000500000000000000900000077bbbb770555000056555000565550006055506060555000444488880000000000000000
6012201051022100601220106012201000050000000000000000000000bbbb000666000050666000506677706666666066666660444488880000000000000000
5102210005011000510221005102210000060000bbbb00001b1b00000000000060606000000606000006777000666000006660601b1bc9c99999000088880000
05011000001001000501100005011000050611001b1b0000bbbb0000000000000010000000010000000177700006000000060000bbbb9999c9c90000d8d80000
0010010000000000001001000010010000562111bbbb0000bbbb0000000000000101000000101000001017000010100000101000bbbb99999999000088880000
00100100000000000010000000000100c0d22111bbbb0000bbbb0000000000000101000000101000001010000010100000101000bbbb99999999000088880000
00000000000000000000000000000000000000006008800601100000000000000000000000000000000005500000000000000000000000000000000000000000
0044440000000000000000000000000000000000600110060110000006077777600c0c0000000000770001500000000000c5c000000000000000000000000000
609494000000000000000000000000001100000060111106c88c00006467c5c76001100088888000070005500000000000050000050000000000000000000000
6044440000000000011111000000000005000000611111168888000004077577bb001b008ccc80000dddd6600000000056666650055000000000000000000000
60040000000000040100000011110000111100005511115502200000045777770bbb1b0088888000060006600000000050666050005500000111100044440000
6555550004940554010000008181000081810000001001002222000004077777000111000020000006005665000ddd00500600500005000005000000e4e40000
5504055004445544808000001111000011110000001001002002000004066666000b0b0000200000060055555556665557777750c0667770c6c0000044440000
0004444404944440000000001111000011110000000000002002000000065056000b0b0000222200000050055156665507000700550677706667777044440000
0000000000000000000600000000000000bbb000000000000000000000ccc000000000000000000000000000c0c0000000000000000019000000000000000000
00000000000cccc0886660000000000000b000000bbb333003330000000800000000000000000000000000000880000000000000000111000000000000000000
00000000cc7c66c7888600600000000000b000000b0000300bbb0000990809900090900000000000000000000900000000000000001191000000000000000000
0c000000007cccc7cc80066600000000bbb000000b00003003330000998b899090bbbb0999900999009bb9000999000000000000019111100000000000000000
cc777700cc777777cc88886806000000bbb000000b0000300b0000009ab8ba900bb99bb09a9009a99bb99bb9000990000000000000bbbb006bbbb0000bbbb440
0c676700007cccc70888880866606000bbb00000bbb00333bbb000009a8b8a90bb9999bbbbbbbbbbbb9999bb00aaa00000000000101b1b0061b1666001b14490
cc777700cc7cccc788888888c686668800000000bbb00333bbb00000aa000aa0b999999b9b9bb9b9b999999b00a0a000c899aa0040bbbb006bbb66606bbbb940
0c777700000c00c080080080cc8868880000000000000000bbb00000000000009900009999999999999999990a00a000c99aa0aa04bbbb004bbbb6004bbbb440
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
00111111111111000066000000660000000000000000000000000000003030000000000000000000000000000000000000000000000000000000000000000000
00188111111881000004600000046000000000000000000000000000003303000055550000555500005555000055550000555500005955000055550000559500
001111111111110000406000004560000000000000000000000000003003003005999550095665900577755005b5b550055555500595955005bbbb5005595550
00000011110000000400000004555000400050000000000000000000333333335599950055666500557775005bbbbb005558280055595500551b1b0055955500
110000111100001140000000405000000455500000000000000000000030003055595550544655505577755055bbb550558885505559955055bbbb5059999990
1110001111000111000000000000000000456000000000000000000003333000559995505545595055575550555b5550555528505559555055bbbb5055955550
11111111111111110000000000000000000460000000000000000000330030000555555005555550055555500555555005555550055995500555555005595550
11111111111111110000000000000000006600000000000000000000300030000005550000055500000555000005550000055500000555000005550000059500
1100001111000011000000900000000000000000900cc00700090000000090000000000000000000000000000000000000000000000000000000000000000000
000011111111000000000000090000090000000000000c770000000000000000000000000000000000007cc00000000000000000000000000000000000555500
00011111111110009006666000000000000000000cc007700000004000900060000004400000000000007000000000000006000005d500000005d50005545550
0001000000001000000006600000707000000000000c77000060004000000600000440040000000000007cc07770000044446000555000000055500055444400
0001000000001000000040600004777000000000c00770009006004005006009004494000000000000007000777000000006000000d500000000d50055545550
11111110011111110004006000407770000000000c7700900000640900560000044944400000000000007cc07770000000000000000000000000000055444450
11010110011010110040000000047770000000000770000000004600004500000444944000000099000070000700000000000000000000000000000005545550
11010110011010110400000990000700000000007709000004440050040050000044440099090099000000000000000000000000000000000000000000055500
000000000000000000000000000000000054000000005400000000000000c4c43500c40000000000000000007500000000000000000000000000000075000000
84358484840000848484848435840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000540071000000545454c4c4c4c4c400350000c4c4c40000000000007500000000000000000000000000000075000000
75357500008400000000000035840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000054007100000000e50000000000f400350000f200f2c475757575757500000000000000e1e1000000f5e5e575000000
75357500008484000000007235840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000540000000000545454c4c4c4c4c4c4c4c4c4c4c4c4000000007500f4000000e5e5e5e5757575757575757575000000
75357500008484848484848435840000000000000000000000000000000000000000000000343500000000000000000000000000000000000000000000000000
000000000000000000000000000000000054616100005400000000000000000075350000f6e5e100004575007564646464646464757575757575757500000000
75357500000000000000008435840000000000000000000000000000000000000000000000343500000000000000000000000000000000000000000000000000
00000000000000000000000000000000005454545454540000000000000000007535756464646455557500007575757575757504000000000000000004757575
75357500000000000000008435840000000000000000000000000000000000000000000000343500000000000000000000000000000034343434343434343434
00000000000000000000000000000000000000000000000000000000000000007535757575757575750000007500000000000004000000000000000004757575
75357500000000000000008435840000000000000000000000000000000000000000000000343500043434343434340000000000003400006200000034000000
0000000000000000000000000000000000000000000000000000000000000000743500510000000000e17700150000e5f5f500e40000000000000000d4000000
00357500008484848484840000008484848484848484840000000000000000000000000000343500040000000000000434343434343400343434343534000000
0000000000000000000000000000000000000000000000000000000000000000006464646464647575757575757575757575750400000000b300000004757575
757575008400000000000000f50000e5000000720000840000000000000000000000000000343500d4000000000000e4e5e5e5e5e50000f5f5f5343534f1f100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000646464646464646400000000
00000000840000000300000384848484848484848435840000000000000000000000000000343434040000230000000434343434343434343434343534343435
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008400008484848400000000000000008435840000000000000000000000000000000000043434343434340400000000340000000000003534000035
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000084000000008400000000000000008435840000000000000000000000000000000000000000000000000000000000343500000000003534000035
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000847200008400000000000000008435840000000000000000000000000000000000000000000000000000000000343500000000b53534000035
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000848484358400000000000000008435840000000000000000000000000000000000000000000000000000000000343534343434003592009235
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358400000000000000008435840000000000000000000000000000000000000000000000000000000000343500000000343434343434
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000084358400000000000000008435840000000000000084848484840000000000000000000000000000000000343500006200000000003534
77777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777700000000000084358400000000000000008435840000000000000084350035840000000000000000000000000000000000003434e5006200e5f5003534
77007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76007700000000000084358400000000000000008435840000000000000084358435840000000000000000000000000000000000000000343400343434547634
77007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7700770000000000008435848484848484848484a435840000000000000084358435840000000000000000000000000000000000000000343434343434547654
77006700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7700770000000000008435007200000000e500000035840000000000000084358435840000000000000000000000000000000000000000003434343454547654
67007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77007700000000000084350000848494949494948484840000000000000084358435840000000000000000000000000000000000000000003434345454547654
77007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
770077000000000000843584848400000000000000000000000000000000843584358400000000000000000000000043c5000000000000003434545454547654
76007c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77007600000000000084358484848400000000008484848484848400000084358435840000000000000000000054545454e50000000000005454545454547654
c7776700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7677c60000000000008435848484848484848404000000000000000484848435843584000000000000000000540000000054e500000000005454545454547654
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000008435f5f5e5e513f5e2f5e400000000000000d40000003584358400005300000053005400000000000054e5000000545454545454547654
06162600363626360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000008484848484848484848404000000c200000004848484848435840000000000007654000000000000000054e50000540000000000547654
07172703263726660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000009494949494949400000000008435000000f5c5e5e5765400000000000000000054f500040000000000047654
26162600262626560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000008484845454545454540000000000000000000000005400e40000008300d47654
27162600373737570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000c4c4c4c4c4c4c4c4000000000054045454545454045454
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c400000000000073000000000000c4
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
00000000000000000000000000008080c0808080008080a08080808080808080c000a080808080808080c000c00080808080c000a0a0a0a0c00000c000808080010101010101010101010101010104010001000200a0a00100010101000000000000000000000002000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
42005e7651000000000000184200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242534242534242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
420000000053424253515e184200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4254697700534242534242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242534242004f00544200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200000042534242424253424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
42005e794f534200004153410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424200004153410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200000000000000004153410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200000000000000004153410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200000000000000004153410000000042424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242420000004242424200000042424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
425e5100000000000000000054000000000000000000515f4200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242420019004242424253424242424242180000424242420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200004b4b4c0000004253420000000000424242000000424245454545454545454545454545454545454545454500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200000000000000004253420000000000000000000000425300000000000000170000000000000000000000000045450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424253424242424242424242420000425372000000000000000000000000000000000000000000004500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000534200000000000000004200004c5345454545454500150000170000000000000000000000004500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001b00001a00001b005342005f2800006928004200004c534c4c4c4c4c4c4545000000000000000000000000006e544400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00424242424242424242424242424242424242534200004c534c4c4c4c4c4c4c4c4500150000001d00001600000045450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004200000000000000000000000000000000425342000042534c4c4c4c4c4c4c4c4c45454553534545454545454500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004200000000000000000000000000000000425342000042534c4c4c4c4c4c4c4c4c4c4c4c53534c4c4c4c4c4c4c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0042000000000000424242424242424200004253420000425342000000000000000000004c53534c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0042424242424040000000000000000041004253420000425342000000000000000000004c53534c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000040000000000000000041004253420000425342000000000000000000004c53534c000000004c4c4c004c4c4c4c4c4c4c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5f5e5e5e5f00284e00000000000000004d00425342424242534200000000004c4c4c4c4c4c53534c4c4c4c4c00004c4000000000000000404c4c4c000000000000000000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424040000000002a0000004100006a4f5e5e5f534200000000004c530000004f00004f005f5e5e5e5e514e000000000000004d5e004c000000000000000000000000004800480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000042424242424242420042424242424242424200000000004c534c4c4c4c4b4b4b4b4c4c4c4b4b4b4000000020000000404c534c0000000000000000000000004800005e4800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000004c534c000000000000000000004c4c4c00434c4c4b4c4c43004c534c00000000000000000000004800005e480048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000004c534c000000000000000000000000000000000000000000004c534c000000000048484848484800000048000053480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000045454545454500000000000000004c534c000000000000000000000057575757575757575757574c534c57570000004853000000000000485e5f0053480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000001750017500375004750077500a7500d7500f750127501375014750137501274012740107400f7400f7400e7300c7300b7300a7200872004720037100071003700027000170000000000000000000000
0001000003100061100b1300e1300a1400e1401314019140141400c1401b140161300a140071300a1300913001130031200410001100041000210000100001000000000000000000000000000000000000000000
000100000d7500a750087500775007750067500675006750067500675007750087500b7500d7500f7501775025750247502674024720000000000000000000000000000000000000000000000000000000000000
000100000f75011750117500b7500d750097500575003750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000e1500e1502a1502a1502b1502b1502b1502b1402b1302b1102b1002b1002b10000000000002210000000201001f100000001f1001e1001e1001d1000000000000000000000000000000000000000000
