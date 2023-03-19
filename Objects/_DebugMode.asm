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
Debug_Index:	index *
		ptr Debug_Main
		ptr Debug_Action
; ===========================================================================

Debug_Main:	; Routine 0
		addq.b	#2,(v_debug_active_hi).w
		move.w	(v_boundary_top).w,(v_boundary_top_debugcopy).w ; buffer level top boundary
		move.w	(v_boundary_bottom_next).w,(v_boundary_bottom_debugcopy).w ; buffer level bottom boundary
		move.w	#0,(v_boundary_top).w
		move.w	#$720,(v_boundary_bottom_next).w	; set new boundaries
		andi.w	#$7FF,ost_y_pos(a0)
		andi.w	#$7FF,(v_camera_y_pos).w
		andi.w	#$3FF,(v_bg1_y_pos).w
		andi.b	#$FF-render_xflip-render_yflip,ost_render(a0)
		move.b	#0,ost_anim(a0)
		move.w	#0,ost_inertia(a0)
		move.w	#0,ost_x_vel(a0)
		move.w	#0,ost_y_vel(a0)
		movea.l	(v_debug_ptr).w,a2
		move.w	(v_debug_item_index).w,d0
		movea.l	a0,a3
		
Debug_GetFrame:
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
		beq.s	.exit					; branch if right isn't pressed

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
		move.b	9(a2,d0.w),ost_status(a1)
		movea.l	a1,a3
		bsr.w	Debug_GetFrame				; get mappings, frame & tile setting
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
		move.w	d0,ost_x_sub(a0)
		move.w	d0,ost_y_sub(a0)
		move.w	(v_boundary_top_debugcopy).w,(v_boundary_top).w ; restore level boundaries
		move.w	(v_boundary_bottom_debugcopy).w,(v_boundary_bottom_next).w
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

dbug:		macro map,object,subtype,frame,vram
		dc.l map
		dc.b subtype,frame
		dc.w vram
		dc.l object
		endm
		
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
		dbitem	Rings, Map_Ring, 0, 0, 0, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, 0, tile_Art_Monitors, 0
		dbitem	Crabmeat, Map_Crab, 0, 0, 0, v_tile_crabmeat, 0
		dbitem	BuzzBomber, Map_Buzz, 0, 0, 0, v_tile_buzzbomber, 0
		dbitem	Chopper, Map_Chop, 0, 0, 0, v_tile_chopper, 0
		dbitem	MotoBug, Map_Moto, 0, 0, 0, v_tile_motobug, 0
		dbitem	Newtron, Map_Newt, 0, 0, id_frame_newt_norm, v_tile_newtron, 0
		dbitem	Newtron, Map_Newt, 1, 0, id_frame_newt_norm, v_tile_newtron, tile_pal2
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Lamppost, Map_Lamp, 1, 0, 0, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	PurpleRock, Map_PRock, 0, 0, 0, tile_Kos_PurpleRock, tile_pal4
		dbitem	EdgeWalls, Map_Edge, type_edge_shadow, 0, id_frame_edge_shadow, tile_Kos_GhzEdgeWall, tile_pal3
		dbitem	BasicPlatform, Map_Platform, type_plat_still, 0, id_frame_plat_small, 0, tile_pal3
	.end:
DebugList_MZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, 0, v_tile_rings, tile_pal2
	.end:
DebugList_SYZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, 0, v_tile_rings, tile_pal2
	.end:
DebugList_LZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, 0, v_tile_rings, tile_pal2
	.end:
DebugList_SLZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, 0, v_tile_rings, tile_pal2
	.end:
DebugList_SBZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, 0, v_tile_rings, tile_pal2
	.end:
DebugList_Ending:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, 0, v_tile_rings, tile_pal2
	.end:

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Kos_Ring_KPLC_LZ+tile_pal2
		dbug	Map_Monitor,	Monitor,	0,	0,	tile_Art_Monitors
		dbug	Map_Spring,	Springs,	type_spring_red+type_spring_up,	0,	tile_Kos_HSpring_KPLC_LZ
		dbug	Map_Jaws,	Jaws,		8,	0,	tile_Kos_Jaws+tile_pal2
		dbug	Map_Burro,	Burrobot,	0,	id_frame_burro_dig1,	tile_Kos_Burrobot+tile_hi
		dbug	Map_Harp,	Harpoon,	type_harp_h,	id_frame_harp_h_retracted,	tile_Kos_Harpoon
		dbug	Map_Harp,	Harpoon,	type_harp_v,	id_frame_harp_v_retracted,	tile_Kos_Harpoon
		dbug	Map_Push,	PushBlock,	0,	0,	tile_Kos_LzHalfBlock+tile_pal3
		dbug	Map_But,	Button,		0,	0,	tile_Kos_Button_KPLC_LZ
		dbug	Map_Spike,	Spikes,		type_spike_3up+type_spike_still,	0,	tile_Kos_Spikes_KPLC_LZ
		dbug	Map_MBlockLZ,	MovingBlock,	type_mblock_1+type_mblock_rightdrop,	0,	tile_Kos_LzHalfBlock+tile_pal3
		dbug	Map_LBlock,	LabyrinthBlock, type_lblock_sink,	id_frame_lblock_sinkblock,	tile_Kos_LzDoorH+tile_pal3
		dbug	Map_LPlat,	LabyrinthPlatform, 0,	0,	tile_Kos_LzPlatform+tile_pal3
		dbug	Map_Gar,	Gargoyle,	0,	0,	tile_Kos_Gargoyle+tile_pal3
		dbug	Map_Cork,	Cork, 		0,	0,	tile_Kos_Cork+tile_pal3
		dbug	Map_LBlock,	LabyrinthBlock, type_lblock_solid,	id_frame_lblock_block,	tile_Kos_LzBlock+tile_pal3
		dbug	Map_LConv,	Wheel,		0,	0,	tile_Kos_LzWheel
		dbug	Map_Orb,	Orbinaut,	0,	0,	tile_Kos_Orbinaut
		dbug	Map_Bub,	Bubble,		$84,	id_frame_bubble_bubmaker1,	tile_Kos_Bubbles+tile_hi
		dbug	Map_WFall,	Waterfall,	type_wfall_cornermedium,	id_frame_wfall_cornermedium,	tile_Kos_Splash+tile_pal3+tile_hi
		dbug	Map_WFall,	Waterfall,	type_wfall_splash,	id_frame_wfall_splash1,	tile_Kos_Splash+tile_pal3+tile_hi
		dbug	Map_Pole,	Pole,		0,	0,	tile_Kos_LzPole+tile_pal3
		dbug	Map_Flap,	FlapDoor,	2,	0,	tile_Kos_FlapDoor+tile_pal3
		dbug	Map_Lamp,	Lamppost,	1,	0,	tile_Kos_Lamp_KPLC_LZ

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Kos_Ring_KPLC_MZ+tile_pal2
		dbug	Map_Monitor,	Monitor,	0,	0,	tile_Art_Monitors
		dbug	Map_Buzz,	BuzzBomber,	0,	0,	tile_Kos_Buzz_KPLC_MZ
		dbug	Map_Spike,	Spikes,		type_spike_3up+type_spike_still,	0,	tile_Kos_Spikes_KPLC_MZ
		dbug	Map_Spring,	Springs,	type_spring_red+type_spring_up,	0,	tile_Kos_HSpring_KPLC_MZ
		dbug	Map_Fire,	FireMaker,	0,	0,	tile_Kos_Fireball
		dbug	Map_Brick,	MarbleBrick,	type_brick_still,	0,	0+tile_pal3
		dbug	Map_Geyser,	GeyserMaker,	0,	0,	tile_Kos_Lava+tile_pal4
		dbug	Map_LWall,	LavaWall,	0,	0,	tile_Kos_Lava+tile_pal4
		dbug	Map_Push,	PushBlock,	type_pblock_single,	0,	tile_Kos_MzBlock+tile_pal3
		dbug	Map_Smab,	SmashBlock,	0,	0,	tile_Kos_MzBlock+tile_pal3
		dbug	Map_MBlock,	MovingBlock,	type_mblock_1+type_mblock_still,	0,	tile_Kos_MzBlock
		dbug	Map_CFlo,	CollapseFloor,	0,	0,	tile_Kos_MzBlock+tile_pal4
		dbug	Map_LTag,	LavaTag,	0,	0,	tile_Art_Monitors+tile_hi
		dbug	Map_Bat,	Batbrain,	0,	0,	tile_Kos_Batbrain
		dbug	Map_Cat,	Caterkiller,	0,	0,	tile_Kos_Cater+tile_pal2
		dbug	Map_Lamp,	Lamppost,	1,	0,	tile_Kos_Lamp_KPLC_MZ

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Kos_Ring_KPLC_SLZ+tile_pal2
		dbug	Map_Monitor,	Monitor,	0,	0,	tile_Art_Monitors
		dbug	Map_Elev,	Elevator,	type_elev_up_short,	0,	0+tile_pal3
		dbug	Map_CFlo,	CollapseFloor,	0,	id_frame_cfloor_slz,	tile_Kos_SlzBlock+tile_pal3
		dbug	Map_Platform,	BasicPlatform,	type_plat_slz+type_plat_still,	0,	0+tile_pal3
		dbug	Map_Circ,	CirclingPlatform, 0,	0,	0+tile_pal3
		dbug	Map_Stair,	Staircase,	type_stair_above,	0,	0+tile_pal3
		dbug	Map_Fan,	Fan,		type_fan_left_onoff,	0,	tile_Kos_Fan+tile_pal3
		dbug	Map_Seesaw,	Seesaw,		0,	0,	tile_Kos_Seesaw
		dbug	Map_Spring,	Springs,	type_spring_red+type_spring_up,	0,	tile_Kos_HSpring_KPLC_SLZ
		dbug	Map_Fire,	FireMaker,	0,	0,	tile_Kos_Fireball_KPLC_SLZ
		dbug	Map_Scen,	Scenery,	type_scen_cannon,	0,	tile_Kos_SlzCannon+tile_pal3
		dbug	Map_Bomb,	Bomb,		0,	0,	tile_Kos_Bomb
		dbug	Map_Orb,	Orbinaut,	0,	0,	tile_Kos_Orbinaut_KPLC_SLZ+tile_pal2
		dbug	Map_Lamp,	Lamppost,	1,	0,	tile_Kos_Lamp_KPLC_SLZ

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Kos_Ring_KPLC_SYZ+tile_pal2
		dbug	Map_Monitor,	Monitor,	0,	0,	tile_Art_Monitors
		dbug	Map_Spike,	Spikes,		type_spike_3up+type_spike_still,	0,	tile_Kos_Spikes_KPLC_SYZ
		dbug	Map_Spring,	Springs,	type_spring_red+type_spring_up,	0,	tile_Kos_HSpring_KPLC_SYZ
		dbug	Map_Roll,	Roller,		0,	0,	tile_Kos_Roller
		dbug	Map_Light,	SpinningLight,	0,	0,	0
		dbug	Map_Bump,	Bumper,		0,	0,	tile_Kos_Bumper
		dbug	Map_Crab,	Crabmeat,	0,	0,	tile_Kos_Crabmeat_KPLC_SYZ
		dbug	Map_Buzz,	BuzzBomber,	0,	0,	tile_Kos_Buzz_KPLC_SYZ
		dbug	Map_Yad,	Yadrin,		0,	0,	tile_Kos_Yadrin+tile_pal2
		dbug	Map_Platform,	BasicPlatform,	type_plat_syz+type_plat_still,	0,	0+tile_pal3
		dbug	Map_FBlock,	FloatingBlock,	type_fblock_syz1x1+type_fblock_still,	0,	0+tile_pal3
		dbug	Map_But,	Button,		0,	0,	tile_Kos_Button
		dbug	Map_Lamp,	Lamppost,	1,	0,	tile_Kos_Lamp_KPLC_SYZ

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Kos_Ring_KPLC_SBZ+tile_pal2
		dbug	Map_Monitor,	Monitor,	0,	0,	tile_Art_Monitors
		dbug	Map_Bomb,	Bomb,		0,	0,	tile_Kos_Bomb_KPLC_SBZ
		dbug	Map_Cat,	Caterkiller,	0,	0,	tile_Kos_Cater_KPLC_SBZ+tile_pal2
		dbug	Map_BBall,	SwingingPlatform, 7,	id_frame_bball_anchor,	tile_Kos_BigSpike_KPLC_SBZ+tile_pal3
		dbug	Map_Disc,	RunningDisc,	$E0,	0,	tile_Kos_SbzDisc+tile_pal3+tile_hi
		dbug	Map_MBlock,	MovingBlock,	type_mblock_sbz+type_mblock_updown,	id_frame_mblock_sbz,	tile_Kos_Stomper+tile_pal2
		dbug	Map_But,	Button,		0,	0,	tile_Kos_Button_KPLC_SBZ
		dbug	Map_Trap,	SpinPlatform,	3,	0,	tile_Kos_TrapDoor+tile_pal3
		dbug	Map_Spin,	SpinPlatform,	$83,	0,	tile_Kos_SpinPlatform
		dbug	Map_Saw,	Saws,		type_saw_pizza_updown,	0,	tile_Kos_Cutter+tile_pal3
		dbug	Map_CFlo,	CollapseFloor,	0,	0,	tile_Kos_SbzFloor+tile_pal3
		dbug	Map_MBlock,	MovingBlock,	type_mblock_sbzwide+type_mblock_slide,	id_frame_mblock_sbzwide,	tile_Kos_SlideFloor+tile_pal3
		dbug	Map_Stomp,	ScrapDoorH,	0,	0,	tile_Kos_Stomper+tile_pal2
		dbug	Map_ADoor,	AutoDoor,	0,	0,	tile_Kos_SbzDoorV+tile_pal3
		dbug	Map_Stomp,	ScrapStomp,	type_stomp_slow,	0,	tile_Kos_Stomper+tile_pal2
		dbug	Map_Saw,	Saws,		type_saw_pizza_sideways,	id_frame_saw_pizzacutter1,	tile_Kos_Cutter+tile_pal3
		dbug	Map_Stomp,	ScrapStomp,	type_stomp_fast_short,	0,	tile_Kos_Stomper+tile_pal2
		dbug	Map_Saw,	Saws,		type_saw_ground_left,	id_frame_saw_groundsaw1,	tile_Kos_Cutter+tile_pal3
		dbug	Map_Stomp,	ScrapStomp,	type_stomp_fast_long,	0,	tile_Kos_Stomper+tile_pal2
		dbug	Map_VanP,	VanishPlatform, 0,	0,	tile_Kos_SbzBlock+tile_pal3
		dbug	Map_Flame,	Flamethrower,	$64,	id_frame_flame_pipe1,	tile_Kos_FlamePipe+tile_hi
		dbug	Map_Flame,	Flamethrower,	$64,	id_frame_flame_valve1,	tile_Kos_FlamePipe+tile_hi
		dbug	Map_Elec,	Electro,	4,	0,	tile_Kos_Electric
		dbug	Map_Gird,	Girder,		0,	0,	tile_Kos_Girder+tile_pal3
		dbug	Map_Invis,	Invisibarrier,	$11,	0,	tile_Art_Monitors+tile_hi
		dbug	Map_Hog,	BallHog,	4,	0,	tile_Kos_BallHog+tile_pal2
		dbug	Map_Lamp,	Lamppost,	1,	0,	tile_Kos_Lamp_KPLC_SBZ

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Kos_Ring+tile_pal2
		dbug	Map_Ring,	Rings,		0,	id_frame_ring_blank,	tile_Kos_Ring+tile_pal2
