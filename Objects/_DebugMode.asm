; ---------------------------------------------------------------------------
; When debug mode is currently in use
; ---------------------------------------------------------------------------

DebugMode:
		moveq	#0,d0
		move.b	(v_debug_active_hi).w,d0
		move.w	Debug_Index(pc,d0.w),d1
		jsr	Debug_Index(pc,d1.w)
		jmp	DisplaySprite
; ===========================================================================
Debug_Index:	index *,,2
		ptr Debug_Main
		ptr Debug_Action
; ===========================================================================

Debug_Main:	; Routine 0
		addq.b	#2,(v_debug_active_hi).w
		;move.w	(v_boundary_top).w,(v_boundary_top_debugcopy).w ; buffer level top boundary
		;move.w	(v_boundary_bottom_next).w,(v_boundary_bottom_debugcopy).w ; buffer level bottom boundary
		;move.w	#0,(v_boundary_top).w
		;move.w	#$720,(v_boundary_bottom_next).w	; set new boundaries
		andi.w	#$7FF,ost_y_pos(a0)
		andi.w	#$7FF,(v_camera_y_pos).w
		andi.w	#$3FF,(v_bg1_y_pos).w
		moveq	#0,d0
		move.b	d0,ost_status(a0)
		move.b	d0,ost_anim(a0)
		move.w	d0,ost_inertia(a0)
		move.w	d0,ost_x_vel(a0)
		move.w	d0,ost_y_vel(a0)
		movea.l	(v_debug_ptr).w,a2
		move.w	(v_debug_item_index).w,d0
		movea.l	a0,a3
		
Debug_GetFrame:
		move.b	9(a2,d0.w),d1
		andi.b	#status_xflip+status_yflip,d1
		andi.b	#$FF-render_xflip-render_yflip,ost_render(a3)
		or.b	d1,ost_render(a3)			; load x/yflip for item
		or.b	d1,ost_status(a3)
		
Debug_GetFrame_SkipStatus:
		move.l	4(a2,d0.w),ost_mappings(a3)		; load mappings for item
		move.w	10(a2,d0.w),ost_frame_hi(a3)		; load frame number for item
		move.l	12(a2,d0.w),d1				; load VRAM setting
		bpl.s	.not_ram				; branch if not a RAM address
		movea.l	d1,a4
		move.w	(a4),d1					; get tile setting from RAM
		
	.not_ram:
		or.w	16(a2,d0.w),d1				; add modifier to VRAM setting
		move.w	d1,ost_tile(a3)				; load VRAM setting for item
		rts
; ===========================================================================

Debug_Action:	; Routine 2
		movea.l	(v_debug_ptr).w,a2
		bsr.s	Debug_Control
		bsr.w	Debug_ChgItem
		bsr.w	Debug_Create
		bra.w	Debug_Restore

; ---------------------------------------------------------------------------
; Subroutine for directional movement in debug mode
; ---------------------------------------------------------------------------

Debug_Control:
		move.b	(v_joypad_hold_actual).w,d0
		btst	#bitA,d0
		bne.s	.exit					; branch if A is held
		andi.w	#btnDir,d0
		bne.s	.move_constant				; branch if direction held
		
	.exit:
		move.w	#0,(v_debug_move_time).w		; reset timer
		rts
		
	.move_constant:
		move.w	(v_debug_move_time).w,d1
		move.w	Debug_Speeds(pc,d1.w),d2
		
		btst	#bitUp,d0
		beq.s	.not_up
		sub.w	d2,ost_y_pos(a0)
		
	.not_up:
		btst	#bitDn,d0
		beq.s	.not_down
		add.w	d2,ost_y_pos(a0)
		
	.not_down:
		btst	#bitL,d0
		beq.s	.not_left
		sub.w	d2,ost_x_pos(a0)
		
	.not_left:
		btst	#bitR,d0
		beq.s	.exit2
		add.w	d2,ost_x_pos(a0)
		
	.exit2:
		cmpi.w	#Debug_Speeds_end-Debug_Speeds-2,d1
		beq.s	.dont_inc				; branch if at max
		addq.w	#2,d1					; increment timer
		move.w	d1,(v_debug_move_time).w		; update timer
		
	.dont_inc:
		rts
		
Debug_Speeds:	dc.w 1,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8
	Debug_Speeds_end:

; ---------------------------------------------------------------------------
; Subroutine to switch between objects
; ---------------------------------------------------------------------------

Debug_ChgItem:
		btst	#bitA,(v_joypad_press_actual).w		; is button A pressed?
		beq.s	.skip_item_menu				; if not, branch
		moveq	#2-1,d1
		move.w	#$40,d2
		
	.loop:
		jsr	FindFreeInert
		bne.s	.skip_item_menu
		move.l	#DebugItemAdjacent,ost_id(a1)		; load debug item menu
		move.b	d1,ost_subtype(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		add.w	d2,ost_x_pos(a1)			; first object is to the right
		move.b	#render_rel,ost_render(a1)
		neg.w	d2					; second object will be to the left
		dbf	d1,.loop
		
	.skip_item_menu:
		btst	#bitA,(v_joypad_hold_actual).w		; is button A held?
		beq.s	.exit					; if not, branch
		move.b	(v_joypad_press_actual).w,d1
		btst	#bitL,d1
		bne.s	.left					; branch if left is pressed
		btst	#bitR,d1
		bne.s	.right					; branch if right is pressed
		btst	#bitUp,d1
		bne.s	.up					; branch if up is pressed
		btst	#bitDn,d1
		beq.s	.exit					; branch if down isn't pressed
		
.down:
		bchg	#status_xflip_bit,ost_status(a0)
		bchg	#status_xflip_bit,ost_render(a0)	; toggle xflip
		bra.s	.blip
		
.up:
		bchg	#status_yflip_bit,ost_status(a0)
		bchg	#status_yflip_bit,ost_render(a0)	; toggle yflip
		bra.s	.blip

.right:
		move.w	(v_debug_item_index).w,d0
		cmp.w	(v_debug_lastitem).w,d0
		beq.s	.last_item				; branch if on the last item
		addi.w	#sizeof_dbitem,d0			; next item
		bra.s	.display				; update visual
		
	.last_item:
		moveq	#0,d0					; wrap to start
		bra.s	.display

.left:
		move.w	(v_debug_item_index).w,d0
		beq.s	.first_item				; branch if on the first item
		subi.w	#sizeof_dbitem,d0			; previous item
		bra.s	.display
		
	.first_item:
		move.w	(v_debug_lastitem).w,d0			; wrap to end

	.display:
		move.w	d0,(v_debug_item_index).w
		movea.l	a0,a3
		bsr.w	Debug_GetFrame
		
	.blip:
		play.w	1, jmp, sfx_Switch			; play sound

	.exit:
		rts
		
; ---------------------------------------------------------------------------
; Debug item menu objects
; ---------------------------------------------------------------------------

DebugItemAdjacent:
		tst.l	ost_mappings(a0)
		beq.s	.first_load				; branch if object has just been loaded
		btst	#bitA,(v_joypad_hold_actual).w		; is button A held?
		beq.s	.delete					; if not, branch
		move.b	(v_joypad_press_actual).w,d1
		andi.b	#btnL+btnR,d1
		beq.s	.display				; branch if left/right isn't pressed
		
	.first_load:
		tst.b	ost_subtype(a0)
		bne.s	.next_item				; branch if this is the "next item" object
		move.w	(v_debug_item_index).w,d0
		bne.s	.not_first				; branch if selected item isn't first item
		move.w	(v_debug_lastitem).w,d0			; wrap to end
		bra.s	.get_frame
		
	.not_first:
		subi.w	#sizeof_dbitem,d0			; use item before current one
		
	.get_frame:
		movea.l	a0,a3
		bsr.w	Debug_GetFrame				; get appropriate mappings/frame/VRAM settings
		
	.display:
		jmp	DisplaySprite
		
	.delete:
		jmp	DeleteObject

.next_item:
		move.w	(v_debug_item_index).w,d0
		cmp.w	(v_debug_lastitem).w,d0
		bne.s	.not_last				; branch if selected item isn't last item
		moveq	#0,d0					; wrap to start
		bra.s	.get_frame
		
	.not_last:
		addi.w	#sizeof_dbitem,d0			; use item after current one
		bra.s	.get_frame
		
; ---------------------------------------------------------------------------
; Subroutine to create an object
; ---------------------------------------------------------------------------

Debug_Create:
		btst	#bitC,(v_joypad_press_actual).w		; is button C pressed?
		beq.s	.exit					; if not, branch
		jsr	(FindFreeObj).l
		bne.s	.exit
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	(v_debug_item_index).w,d0
		move.l	(a2,d0.w),ost_id(a1)			; create object
		move.b	8(a2,d0.w),ost_subtype(a1)
		move.b	9(a2,d0.w),d1
		andi.b	#$FF-status_xflip-status_yflip,d1
		or.b	ost_status(a0),d1			; use x/yflip from Sonic
		move.b	d1,ost_status(a1)
		move.b	ost_render(a0),ost_render(a1)
		movea.l	a1,a3
		bsr.w	Debug_GetFrame_SkipStatus		; get mappings, frame & tile setting
		play.w	1, jmp, sfx_ActionBlock			; play sound
		
	.exit:
		rts
		
; ---------------------------------------------------------------------------
; Subroutine to restore Sonic from debug mode
; ---------------------------------------------------------------------------

Debug_Restore:
		btst	#bitB,(v_joypad_press_actual).w		; is button B pressed?
		beq.s	.exit					; if not, branch
		moveq	#0,d0
		move.w	d0,(v_debug_active).w			; deactivate debug mode
		move.l	#Map_Sonic,ost_mappings(a0)
		move.w	#tile_sonic,ost_tile(a0)
		move.b	d0,ost_anim(a0)
		move.b	d0,ost_anim_frame(a0)
		move.w	d0,ost_x_sub(a0)
		move.w	d0,ost_y_sub(a0)
		move.w	#id_frame_walk13,ost_frame_hi(a0)
		;move.w	(v_boundary_top_debugcopy).w,(v_boundary_top).w ; restore level boundaries
		;move.w	(v_boundary_bottom_debugcopy).w,(v_boundary_bottom_next).w
		cmpi.b	#id_Special,(v_gamemode).w
		bne.s	.exit					; branch if not in the special stage

		clr.w	(v_ss_angle).w
		move.w	#$40,(v_ss_rotation_speed).w		; set new level rotation speed
		move.b	#id_Roll,ost_anim(a0)
		ori.b	#status_jump+status_air,ost_status(a0)

	.exit:
		rts

; ---------------------------------------------------------------------------
; Debug	mode item lists
; ---------------------------------------------------------------------------

sizeof_dbitem:	equ 18

dbheader:	macros
		dc.w .end-*-sizeof_dbitem-2
		
dbitem:		macro object,mappings,subtype,xyflip,frame,vramsetting,vrammod
		dc.l object, mappings
		dc.b subtype, xyflip
		dc.w frame
		dc.l vramsetting
		dc.w vrammod
		endm

DebugList_GHZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		;dbitem	HiddenBonus, Map_Bonus, type_bonus_10k, 0, id_frame_bonus_10000, vram_bonus/sizeof_cell, 0
		dbitem	Boss, Map_Bosses, $80, 0, id_frame_boss_ship, tile_Art_Eggman, 0
		dbitem	Crabmeat, Map_Crab, 0, 0, id_frame_crab_stand, v_tile_crabmeat, 0
		dbitem	BuzzBomber, Map_Buzz, 0, 0, id_frame_buzz_fly1, v_tile_buzzbomber, 0
		dbitem	Chopper, Map_Chop, 0, 0, id_frame_chopper_shut, v_tile_chopper, 0
		dbitem	MotoBug, Map_Moto, 0, 0, id_frame_moto_0, v_tile_motobug, 0
		dbitem	Newtron, Map_Newt, type_newt_blue+$20, 0, id_frame_newt_norm, v_tile_newtron, 0
		dbitem	Newtron, Map_Newt, type_newt_green+$20, 0, id_frame_newt_norm, v_tile_newtron, tile_pal2
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	PurpleRock, Map_PRock, 0, 0, id_frame_rock_0, tile_Kos_PurpleRock, tile_pal4
		dbitem	EdgeWalls, Map_Edge, type_edge_shadow, 0, id_frame_edge_shadow, tile_Kos_GhzEdgeWall, tile_pal3
		dbitem	BasicPlatform, Map_Platform, type_plat_still, 0, id_frame_plat_small, 0, tile_pal3
	.end:
DebugList_MZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		dbitem	Boss, Map_Bosses, $81, 0, id_frame_boss_ship, tile_Art_Eggman, 0
		dbitem	BuzzBomber, Map_Buzz, 0, 0, id_frame_buzz_fly1, v_tile_buzzbomber, 0
		dbitem	Batbrain, Map_Bat, 0, 0, id_frame_bat_hanging, v_tile_batbrain, 0
		dbitem	Caterkiller, Map_Cat, 0, 0, id_frame_cat_head1, v_tile_caterkiller, tile_pal2
		dbitem	Caterkiller, Map_Cat, 0, status_xflip, id_frame_cat_head1, v_tile_caterkiller, tile_pal2
		dbitem	Splats, Map_Splats, 0, 0, id_frame_splats_fall, v_tile_splats, tile_pal2
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	SideStomp, Map_SStom, 0, 0, id_frame_mash_wallbracket, tile_Kos_MzMetal, 0
		dbitem	SideStomp, Map_SStom, 0, status_xflip, id_frame_mash_wallbracket, tile_Kos_MzMetal, 0
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	MarbleBrick, Map_Brick, type_brick_still, 0, id_frame_brick_0, 0, tile_pal3
		dbitem	PushBlock, Map_Push, type_pblock_single, 0, id_frame_pblock_single, tile_Kos_MzBlock, tile_pal3
		dbitem	SmashBlock, Map_Smab, 0, 0, id_frame_smash_two, tile_Kos_MzBlock, tile_pal3
		dbitem	CollapseFloor, Map_CFlo, 0, 0, id_frame_cfloor_mz, tile_Kos_MzBlock, tile_pal3
		dbitem	GlassBlock, Map_Glass, type_glass_drop_jump, 0, id_frame_glass_short, tile_Kos_MzGlass, tile_pal3
		dbitem	MovingBlock, Map_MBlock, type_mblock_3+type_mblock_leftright, 0, id_frame_mblock_mz3, tile_Kos_MzBlock, tile_pal3
	.end:
DebugList_SYZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		dbitem	Roller, Map_Roll, 0, 0, id_frame_roll_stand, v_tile_roller, 0
		dbitem	Crabmeat, Map_Crab, 0, 0, id_frame_crab_stand, v_tile_crabmeat, 0
		dbitem	BuzzBomber, Map_Buzz, 0, 0, id_frame_buzz_fly1, v_tile_buzzbomber, 0
		dbitem	Yadrin, Map_Yad, 0, 0, id_frame_yadrin_walk0, v_tile_yadrin, tile_pal2
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	Springs, Map_Spring, type_spring_yellow+type_spring_down, status_yflip, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	SpinningLight, Map_Light, 0, 0, id_frame_light_0, 0, 0
		dbitem	Bumper, Map_Bump, 0, 0, id_frame_bump_normal, v_tile_bumper, 0
		dbitem	Button, Map_But, 0, 0, id_frame_button_up, v_tile_button, 0
		dbitem	BasicPlatform, Map_Platform, type_plat_syz+type_plat_still, 0, id_frame_plat_syz, 0, tile_pal3
	.end:
DebugList_LZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		dbitem	Jaws, Map_Jaws, 8, 0, id_frame_jaws_open1, v_tile_jaws, tile_pal2
		dbitem	Burrobot, Map_Burro, 0, 0, id_frame_burro_walk1, v_tile_burrobot, tile_hi
		dbitem	Orbinaut, Map_Orb, 0, 0, id_frame_orb_normal, v_tile_orbinaut, 0
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Harpoon, Map_Harp, type_harp_h, 0, id_frame_harp_h_extended, tile_Kos_Harpoon, 0
		dbitem	Harpoon, Map_Harp, type_harp_v, 0, id_frame_harp_v_extended, tile_Kos_Harpoon, 0
		dbitem	Gargoyle, Map_Gar, 0, 0, id_frame_gargoyle_head, tile_Kos_Gargoyle, tile_pal3
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	Button, Map_But, 0, 0, id_frame_button_up, v_tile_button, 0
		dbitem	Bubble, Map_Bub, 0, 0, id_frame_bubble_bubmaker1, v_tile_bubbles, tile_hi
		dbitem	Cork, Map_Cork, 0, 0, id_frame_cork_0, tile_Kos_Cork, tile_pal3
		dbitem	LabyrinthBlock, Map_LBlock, type_lblock_sink, 0, id_frame_lblock_sinkblock, tile_Kos_LzDoorH, tile_pal3
		dbitem	LabyrinthBlock, Map_LBlock, type_lblock_solid, 0, id_frame_lblock_block, tile_Kos_LzBlock, tile_pal3
		dbitem	LabyrinthPlatform, Map_LPlat, 0, 0, id_frame_lplat_0, tile_Kos_LzPlatform, tile_pal3
		dbitem	HalfBlock, Map_MBlockLZ, $10, 0, id_frame_mblocklz_0, tile_Kos_LzHalfBlock, tile_pal3
		dbitem	Wheel, Map_LConv, 0, 0, id_frame_lcon_wheel1, tile_Kos_LzWheel, 0
		dbitem	Pole, Map_Pole, 0, 0, id_frame_pole_normal, tile_Kos_LzPole, tile_pal3
		dbitem	FlapDoor, Map_Flap, 2, 0, id_frame_flap_closed, tile_Kos_FlapDoor, tile_pal3
	.end:
DebugList_SLZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		dbitem	Orbinaut, Map_Orb, 3, 0, id_frame_orb_normal, v_tile_orbinaut, tile_pal2
		dbitem	Bomb, Map_Bomb, 0, 0, id_frame_bomb_stand1, v_tile_bomb, 0
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	Seesaw, Map_Seesaw, 0, 0, id_frame_seesaw_sloping_leftup, tile_Kos_Seesaw, 0
		dbitem	Seesaw, Map_Seesaw, 0, status_xflip, id_frame_seesaw_sloping_leftup, tile_Kos_Seesaw, 0
		dbitem	Fan, Map_Fan, type_fan_onoff, 0, id_frame_fan_0, tile_Kos_Fan, tile_pal3
		dbitem	BasicPlatform, Map_Platform, type_plat_slz+type_plat_still, 0, id_frame_plat_slz, 0, tile_pal3
		dbitem	CollapseFloor, Map_CFlo, type_cfloor_slz+type_cfloor_sided+1, 0, id_frame_cfloor_slz, tile_Kos_SlzBlock, tile_pal3
		dbitem	Elevator, Map_Elev, type_elev_up_short, 0, id_frame_elev_0, 0, tile_pal3
		dbitem	SquareBlock, Map_SBlock, 4, 0, id_frame_sblock_slz, 0, tile_pal3
	.end:
DebugList_SBZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		dbitem	Bomb, Map_Bomb, 0, 0, id_frame_bomb_stand1, v_tile_bomb, 0
		dbitem	ScrapEggman, Map_SEgg, 0, 0, id_frame_eggman_stand, tile_Art_Sbz2Eggman, 0
		dbitem	FalseFloor, Map_FFloor, 0, 0, id_frame_ffloor_wholeblock, tile_Kos_SbzBlock, tile_pal3
		dbitem	Caterkiller, Map_Cat, 0, 0, id_frame_cat_head1, v_tile_caterkiller, tile_pal2
		dbitem	BallHog, Map_Hog, $34, 0, id_frame_hog_standing, v_tile_ballhog, tile_pal2
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Saws, Map_Saw, type_saw_pizza_updown, 0, id_frame_saw_pizzacutter1, tile_Kos_Cutter, tile_pal3
		dbitem	Saws, Map_Saw, type_saw_ground_left, 0, id_frame_saw_groundsaw1, tile_Kos_Cutter, tile_pal3
		dbitem	Electro, Map_Elec, 4, 0, id_frame_electro_normal, tile_Kos_Electric, 0
		dbitem	ScrapStomp, Map_Stomp, type_stomp_slow, 0, id_frame_stomp_0, tile_Kos_Stomper, tile_pal2
		dbitem	Flamethrower, Map_Flame, $64, 0, id_frame_flame_pipe1, tile_Kos_FlamePipe, tile_hi
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	Button, Map_But, 0, 0, id_frame_button_up, v_tile_button, 0
		dbitem	AutoDoor, Map_ADoor, 0, 0, id_frame_autodoor_closed, tile_Kos_SbzDoorV, tile_pal3
		dbitem	AutoDoor, Map_ADoor, 0, status_xflip, id_frame_autodoor_closed, tile_Kos_SbzDoorV, tile_pal3
		dbitem	ScrapDoorH, Map_SDoorH, 0, 0, id_frame_sdoorh_0, tile_Kos_SbzDoorH, tile_pal3
		dbitem	Trapdoor, Map_Trap, 3, 0, id_frame_trap_closed, tile_Kos_TrapDoor, tile_pal3
		dbitem	Girder, Map_Gird, 0, 0, id_frame_girder_0, tile_Kos_Girder, tile_pal3
		dbitem	SlideBlock, Map_Slide, 0, 0, id_frame_slide_0, tile_Kos_SlideFloor, tile_pal3
		dbitem	YellowPlatform, Map_YPlat, 0, 0, id_frame_yplat_thin, tile_Kos_Stomper, tile_pal2
		dbitem	YellowPlatform, Map_YPlat, 1, 0, id_frame_yplat_fat, tile_Kos_Stomper, tile_pal2
	.end:
DebugList_Ending:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
	.end:
