; ---------------------------------------------------------------------------
; When debug mode is currently in use
; ---------------------------------------------------------------------------

DebugMode:
		moveq	#0,d0
		move.b	(v_debug_active_hi).w,d0
		move.w	Debug_Index(pc,d0.w),d1
		jmp	Debug_Index(pc,d1.w)
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
		andi.w	#$7FF,(v_ost_player+ost_y_pos).w
		andi.w	#$7FF,(v_camera_y_pos).w
		andi.w	#$3FF,(v_bg1_y_pos).w
		move.w	#0,ost_frame_hi(a0)
		move.b	#0,ost_anim(a0)
		movea.l	(v_debug_ptr).w,a2
		move.w	(v_debug_count).w,d6			; get number of items in list
		cmp.b	(v_debug_item_index).w,d6		; have you gone past the last item?
		bhi.s	.noreset				; if not, branch
		move.b	#0,(v_debug_item_index).w		; back to start of list

	.noreset:
		bsr.w	Debug_GetFrame				; get mappings, VRAM & frame id from debug list
		move.b	#12,(v_debug_move_delay).w
		move.b	#1,(v_debug_move_speed).w

Debug_Action:	; Routine 2
		movea.l	(v_debug_ptr).w,a2
		move.w	(v_debug_count).w,d6
		bsr.s	Debug_Control
		jmp	(DisplaySprite).l

; ---------------------------------------------------------------------------
; Subroutine for controls while debug is in use

; input:
;	d6 = number of items in debug list
;	a2 = address of first item in debug list
; ---------------------------------------------------------------------------

Debug_Control:
		moveq	#0,d4
		move.w	#1,d1
		move.b	(v_joypad_press_actual).w,d4
		andi.w	#btnDir,d4				; is up/down/left/right	pressed?
		bne.s	.dirpressed				; if yes, branch

		move.b	(v_joypad_hold_actual).w,d0
		andi.w	#btnDir,d0				; is up/down/left/right	held?
		bne.s	.dirheld				; if yes, branch

		move.b	#12,(v_debug_move_delay).w
		move.b	#15,(v_debug_move_speed).w
		bra.w	Debug_ChgItem
; ===========================================================================

.dirheld:
		subq.b	#1,(v_debug_move_delay).w		; decrement timer
		bne.s	.chk_up					; if not 0, branch
		move.b	#1,(v_debug_move_delay).w		; set delay timer to 1 frame
		addq.b	#1,(v_debug_move_speed).w		; increment speed
		bne.s	.dirpressed				; if not 0, branch
		move.b	#-1,(v_debug_move_speed).w

.dirpressed:
		move.b	(v_joypad_hold_actual).w,d4

	.chk_up:
		moveq	#0,d1
		move.b	(v_debug_move_speed).w,d1
		addq.w	#1,d1
		swap	d1
		asr.l	#4,d1					; d1 = speed * $1000
		move.l	ost_y_pos(a0),d2
		move.l	ost_x_pos(a0),d3
		btst	#bitUp,d4				; is up	being held?
		beq.s	.chk_down				; if not, branch
		sub.l	d1,d2					; move Sonic up
		bcc.s	.chk_down
		moveq	#0,d2					; keep Sonic within top boundary

	.chk_down:
		btst	#bitDn,d4				; is down being held?
		beq.s	.chk_left				; if not, branch
		add.l	d1,d2					; move Sonic down
		cmpi.l	#$7FF0000,d2				; is Sonic above $7FF? (bottom boundary)
		bcs.s	.chk_left				; if yes, branch
		move.l	#$7FF0000,d2				; keep Sonic within bottom boundary

	.chk_left:
		btst	#bitL,d4				; is left being held?
		beq.s	.chk_right				; if not, branch
		sub.l	d1,d3					; move Sonic left
		bcc.s	.chk_right
		moveq	#0,d3					; keep Sonic within left boundary

	.chk_right:
		btst	#bitR,d4				; is right being held?
		beq.s	.update_pos				; if not, branch
		add.l	d1,d3					; move Sonic right (no boundary check for right side)

	.update_pos:
		move.l	d2,ost_y_pos(a0)
		move.l	d3,ost_x_pos(a0)

Debug_ChgItem:
		btst	#bitA,(v_joypad_hold_actual).w		; is button A held?
		beq.s	.createitem				; if not, branch
		btst	#bitC,(v_joypad_press_actual).w		; is button C pressed?
		beq.s	.nextitem				; if not, branch

		subq.b	#1,(v_debug_item_index).w		; go back 1 item
		bcc.s	.display				; if item is 0 or higher, branch
		add.b	d6,(v_debug_item_index).w		; if item is -1, loop to last item
		bra.s	.display
; ===========================================================================

.nextitem:
		btst	#bitA,(v_joypad_press_actual).w		; is button A pressed?
		beq.s	.createitem				; if not, branch
		addq.b	#1,(v_debug_item_index).w		; go forwards 1 item
		cmp.b	(v_debug_item_index).w,d6
		bhi.s	.display
		move.b	#0,(v_debug_item_index).w		; loop back to first item

	.display:
		bra.w	Debug_GetFrame
; ===========================================================================

.createitem:
		btst	#bitC,(v_joypad_press_actual).w		; is button C pressed?
		beq.s	.backtonormal				; if not, branch
		jsr	(FindFreeObj).l
		bne.s	.backtonormal
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	ost_render(a0),ost_status(a1)
		andi.b	#$FF-status_broken,ost_status(a1)	; remove broken flag from status
		moveq	#0,d0
		move.b	(v_debug_item_index).w,d0
		mulu.w	#12,d0
		move.b	4(a2,d0.w),ost_subtype(a1)		; get subtype from debug list
		move.l	8(a2,d0.w),ost_id(a1)			; create object
		rts	
; ===========================================================================

.backtonormal:
		btst	#bitB,(v_joypad_press_actual).w		; is button B pressed?
		beq.s	.stayindebug				; if not, branch
		moveq	#0,d0
		move.w	d0,(v_debug_active).w			; deactivate debug mode
		move.l	#Map_Sonic,(v_ost_player+ost_mappings).w
		move.w	#tile_sonic,(v_ost_player+ost_tile).w
		move.b	d0,(v_ost_player+ost_anim).w
		move.w	d0,ost_x_sub(a0)
		move.w	d0,ost_y_sub(a0)
		move.w	(v_boundary_top_debugcopy).w,(v_boundary_top).w ; restore level boundaries
		move.w	(v_boundary_bottom_debugcopy).w,(v_boundary_bottom_next).w
		cmpi.b	#id_Special,(v_gamemode).w		; are you in the special stage?
		bne.s	.stayindebug				; if not, branch

		clr.w	(v_ss_angle).w
		move.w	#$40,(v_ss_rotation_speed).w		; set new level rotation speed
		move.l	#Map_Sonic,(v_ost_player+ost_mappings).w
		move.w	#tile_sonic,(v_ost_player+ost_tile).w
		move.b	#id_Roll,(v_ost_player+ost_anim).w
		bset	#status_jump_bit,(v_ost_player+ost_status).w
		bset	#status_air_bit,(v_ost_player+ost_status).w

	.stayindebug:
		rts

; ---------------------------------------------------------------------------
; Subroutine to get mappings, VRAM & frame info from debug list
; ---------------------------------------------------------------------------

Debug_GetFrame:
		moveq	#0,d0
		move.b	(v_debug_item_index).w,d0
		mulu.w	#12,d0
		move.l	(a2,d0.w),ost_mappings(a0)		; load mappings for item
		move.w	6(a2,d0.w),ost_tile(a0)			; load VRAM setting for item
		move.b	5(a2,d0.w),ost_frame(a0)		; load frame number for item
		rts

; ---------------------------------------------------------------------------
; Debug	mode item lists
; ---------------------------------------------------------------------------

dbug:		macro map,object,subtype,frame,vram
		dc.l map
		dc.b subtype,frame
		dc.w vram
		dc.l object
		endm

DebugList_GHZ:
		dc.w (DebugList_GHZ_end-DebugList_GHZ-2)/12

;			mappings	object		subtype	frame	VRAM setting
		dbug 	Map_Ring,	Rings,		0,	0,	tile_Kos_Ring+tile_pal2
		dbug	Map_Monitor,	Monitor,	0,	0,	tile_Art_Monitors
		dbug	Map_Crab,	Crabmeat,	0,	0,	tile_Kos_Crabmeat
		dbug	Map_Buzz,	BuzzBomber,	0,	0,	tile_Kos_Buzz
		dbug	Map_Chop,	Chopper,	0,	0,	tile_Kos_Chopper
		dbug	Map_Spike,	Spikes,		type_spike_3up+type_spike_still,	0,	tile_Kos_Spikes
		dbug	Map_Platform,	BasicPlatform,type_plat_slz+	type_plat_still,	0,	0+tile_pal3
		dbug	Map_PRock,	PurpleRock,	0,	0,	tile_Kos_PurpleRock+tile_pal4
		dbug	Map_Moto,	MotoBug,	0,	0,	tile_Kos_Motobug
		dbug	Map_Spring,	Springs,	type_spring_red+type_spring_up,	0,	tile_Kos_HSpring
		dbug	Map_Newt,	Newtron,	0,	0,	tile_Kos_Newtron+tile_pal2
		dbug	Map_Edge,	EdgeWalls,	type_edge_shadow,	0,	tile_Kos_GhzEdgeWall+tile_pal3
		dbug	Map_Lamp,	Lamppost,	1,	0,	tile_Kos_Lamp
		dbug	Map_GRing,	GiantRing,	0,	0,	(vram_giantring/sizeof_cell)+tile_pal2
		dbug	Map_Bonus,	HiddenBonus,	type_bonus_10k,	id_frame_bonus_10000,	(vram_bonus/sizeof_cell)+tile_hi
	DebugList_GHZ_end:

DebugList_LZ:
		dc.w (DebugList_LZ_end-DebugList_LZ-2)/12

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
	DebugList_LZ_end:

DebugList_MZ:
		dc.w (DebugList_MZ_end-DebugList_MZ-2)/12

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
	DebugList_MZ_end:

DebugList_SLZ:
		dc.w (DebugList_SLZ_end-DebugList_SLZ-2)/12

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
	DebugList_SLZ_end:

DebugList_SYZ:
		dc.w (DebugList_SYZ_end-DebugList_SYZ-2)/12

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
	DebugList_SYZ_end:

DebugList_SBZ:
		dc.w (DebugList_SBZ_end-DebugList_SBZ-2)/12

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
	DebugList_SBZ_end:

DebugList_Ending:
		dc.w (DebugList_Ending_end-DebugList_Ending-2)/12

;			mappings	object		subtype	frame	VRAM setting
		dbug	Map_Ring,	Rings,		0,	0,	tile_Kos_Ring+tile_pal2
		dbug	Map_Ring,	Rings,		0,	id_frame_ring_blank,	tile_Kos_Ring+tile_pal2
	DebugList_Ending_end:

		even
