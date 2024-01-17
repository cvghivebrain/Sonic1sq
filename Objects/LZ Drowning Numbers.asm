; ---------------------------------------------------------------------------
; Object that depletes Sonic's air, causes drowning and spawns mini bubbles
;  and countdown numbers

; spawned by:
;	GM_Level
; ---------------------------------------------------------------------------

DrownCount:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Drown_Index(pc,d0.w),d1
		jmp	Drown_Index(pc,d1.w)
; ===========================================================================
Drown_Index:	index *,,2
		ptr Drown_Main
		ptr Drown_NumWait
		ptr Drown_NumBub
		ptr Drown_NumSet
		ptr Drown_NumAnim
		ptr Drown_NumDel

		rsobj DrownCount
ost_drown_restart_time:	rs.w 1					; time to restart after Sonic drowns (2 bytes)
		rsobjend
; ===========================================================================

Drown_Main:	; Routine 0
		shortcut
		tst.w	(v_debug_active).w
		bne.s	.exit					; branch if debug mode is in use
		getsonic
		cmpi.b	#id_Sonic_Death,ost_routine(a1)
		bcc.s	.exit					; branch if Sonic is dead
		btst	#status_underwater_bit,ost_status(a1)
		beq.s	.exit					; branch if not underwater
		subq.b	#1,(v_air_frames).w			; decrement timer
		bpl.s	.exit					; branch if time remains
		
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		move.b	#59,(v_air_frames).w			; reset timer to 1 second
		moveq	#0,d0
		move.b	(v_air).w,d0
		move.b	Drown_Air_List(pc,d0.w),d0		; get routine for this second
		move.w	Drown_Air_Index(pc,d0.w),d1
		jsr	Drown_Air_Index(pc,d1.w)
		subq.b	#1,(v_air).w				; decrement air
		
	.exit:
		rts
; ===========================================================================
		
Drown_Air_List:	dc.b id_Drown_Death				; 0 - Sonic dies
		dc.b id_Drown_Bubble				; 1 - mini bubble appears
		dc.b id_Drown_Number				; 2 - number appears
		dc.b id_Drown_Bubble				; 3
		dc.b id_Drown_Number				; 4
		dc.b id_Drown_Bubble				; 5
		dc.b id_Drown_Number				; 6
		dc.b id_Drown_Bubble				; 7
		dc.b id_Drown_Number				; 8
		dc.b id_Drown_Bubble				; 9
		dc.b id_Drown_Number				; 10
		dc.b id_Drown_Bubble				; 11
		dc.b id_Drown_Music				; 12 - drowning music starts
		dc.b id_Drown_Bubble				; 13
		dc.b id_Drown_Bubble				; 14
		dc.b id_Drown_Ding				; 15 - ding alert
		dc.b id_Drown_Bubble				; 16
		dc.b id_Drown_Bubble				; 17
		dc.b id_Drown_Bubble				; 18
		dc.b id_Drown_Bubble				; 19
		dc.b id_Drown_Ding				; 20
		dc.b id_Drown_Bubble				; 21
		dc.b id_Drown_Bubble				; 22
		dc.b id_Drown_Bubble				; 23
		dc.b id_Drown_Bubble				; 24
		dc.b id_Drown_Ding				; 25
		dc.b id_Drown_Bubble				; 26
		dc.b id_Drown_Bubble				; 27
		dc.b id_Drown_Bubble				; 28
		dc.b id_Drown_Bubble				; 29
		dc.b id_Drown_Bubble				; 30
		even
; ===========================================================================
Drown_Air_Index:	index *,,2
		ptr Drown_Bubble
		ptr Drown_Ding
		ptr Drown_Music
		ptr Drown_Number
		ptr Drown_Death
; ===========================================================================

Drown_Ding:
		play.w	1, jsr, sfx_Ding			; play "ding-ding" warning sound

Drown_Bubble:
		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#Bubble,ost_id(a1)			; load mini bubble object
		move.b	#$10,ost_subtype(a1)
		jsr	(RandomNumber).w
		andi.b	#1,d0
		beq.s	.fail					; branch if random bit is 0
		movea.l	a1,a2					; copy OST address of first bubble
		bsr.w	FindFreeObj
		bne.s	.fail
		move.l	#Bubble,ost_id(a1)			; load 2nd mini bubble object
		move.b	#$10,ost_subtype(a1)
		andi.b	#$F,d1
		addq.b	#1,d1
		move.b	d1,ost_anim_time(a1)			; set random delay (1-16) for 2nd bubble
		
	.fail:
		rts
		
Drown_Music:
		play.w	0, jsr, mus_Drowning			; play countdown music
		
Drown_Number:
		bsr.s	Drown_Bubble				; spawn 1 or 2 bubbles
		tst.b	ost_anim_time(a1)
		beq.s	.convert_bubble				; branch if only 1 bubble was spawned
		jsr	(RandomNumber).w
		andi.b	#1,d0
		beq.s	.convert_bubble				; branch if random bit is 0
		movea.l	a2,a1					; select first bubble
		
	.convert_bubble:
		move.l	#DrownCount,ost_id(a1)
		move.b	#id_Drown_NumWait,ost_routine(a1)	; one bubble becomes a number
		move.b	(v_air).w,ost_subtype(a1)		; copy air at time of spawning
		rts
		
Drown_Death:
		bsr.w	ResumeMusic
		move.b	#$81,(v_lock_multi).w			; lock controls
		play.w	1, jsr, sfx_Drown			; play drowning sound
		move.b	#11,ost_subtype(a0)			; create 11 bubbles
		move.w	#120,ost_drown_restart_time(a0)		; restart after 2 seconds
		jsr	(RandomNumber).w
		andi.b	#$F,d0					; d0 = 0-15
		move.b	d0,ost_anim_time(a0)			; time until first bubble
		getsonic					; a1 = OST of Sonic
		exg	a0,a1					; use Sonic's OST temporarily
		bsr.w	Sonic_ResetOnFloor			; clear Sonic's status flags
		move.b	#id_Drown,ost_anim(a0)			; use Sonic's drowning animation
		bset	#status_air_bit,ost_status(a0)
		bset	#tile_hi_bit,ost_tile(a0)		; Sonic appears in front of foreground
		move.w	#0,ost_y_vel(a0)
		move.w	#0,ost_x_vel(a0)
		move.w	#0,ost_inertia(a0)
		move.b	#1,(f_disable_scrolling).w
		exg	a0,a1					; restore OST
		
		shortcut
		getsonic a2					; a2 = OST of Sonic
		subq.w	#1,ost_drown_restart_time(a0)		; decrement timer
		bne.s	.delay_death				; branch if time remains
		move.b	#id_Sonic_Death,ost_routine(a2)		; kill Sonic
		rts
		
	.delay_death:
		exg	a0,a2					; use Sonic's OST temporarily
		update_y_fall	$10				; update Sonic's position & apply gravity
		exg	a0,a2					; restore OST
		tst.b	ost_subtype(a0)
		beq.w	.fail					; branch if bubble counter hits 0
		subq.b	#1,ost_anim_time(a0)			; decrement bubble timer
		bmi.s	.spawn_bubble				; branch if time runs out
		rts
		
	.spawn_bubble:
		subq.b	#1,ost_subtype(a0)			; decrement bubble counter
		jsr	(RandomNumber).w
		andi.b	#7,d0					; d0 = 0-7
		addq.b	#1,d0					; d0 = 1-8
		move.b	d0,ost_anim_time(a0)			; time until next bubble
		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		
		move.l	#Bubble,ost_id(a1)			; load mini bubble object
		move.b	d1,ost_angle(a1)			; random movement
		move.w	ost_x_pos(a2),ost_x_pos(a1)
		move.w	ost_y_pos(a2),d0
		subi.w	#$C,d0
		move.w	d0,ost_y_pos(a1)
		move.b	(v_frame_counter_low).w,d0
		andi.b	#3,d0
		bne.s	.fail
		move.b	#1,ost_subtype(a1)			; 25% chance of medium bubble
		
	.fail:
		rts
		
; ===========================================================================

Drown_NumWait:	; Routine 2
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Drown_NumBub next
		move.b	#id_ani_drown_smallbubble,ost_anim(a0)
		move.l	#Map_Bub,ost_mappings(a0)
		move.w	(v_tile_bubbles).w,ost_tile(a0)
		ori.w	#tile_hi,ost_tile(a0)
		move.b	#render_rel+render_onscreen,ost_render(a0)
		move.b	#4,ost_displaywidth(a0)
		move.b	#priority_1,ost_priority(a0)
		move.w	#-$88,ost_y_vel(a0)
		moveq	#6,d0					; 6 pixels to right
		getsonic
		btst	#status_xflip_bit,ost_status(a1)
		beq.s	.noflip					; branch if Sonic is facing right
		neg.w	d0					; 6 pixels to left
		move.b	#$40,ost_angle(a0)			; start moving left

	.noflip:
		add.w	ost_x_pos(a1),d0
		move.w	d0,ost_x_pos(a0)
		move.w	ost_x_pos(a0),ost_bubble_x_start(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		
	.wait:
		rts
; ===========================================================================

Drown_NumBub:	; Routine 4
		lea	Ani_Drown(pc),a1
		jsr	(AnimateSprite).l			; animate and goto Drown_NumSet when finished
		bsr.w	Bub_Move				; move bubble up & sideways
		move.w	(v_water_height_actual).w,d0
		cmp.w	ost_y_pos(a0),d0
		bcs.w	DisplaySprite				; branch if bubble is below water
		rts
; ===========================================================================

Drown_Num_List:	dc.b id_ani_drown_zeroappear			; 0 - unused
		dc.b id_ani_drown_zeroappear			; 2
		dc.b id_ani_drown_oneappear			; 4
		dc.b id_ani_drown_twoappear			; 6
		dc.b id_ani_drown_threeappear			; 8
		dc.b id_ani_drown_fourappear			; 10
		dc.b id_ani_drown_fiveappear			; 12
		dc.b id_ani_drown_fiveappear			; 14 - unused
		even
		
Drown_NumSet:	; Routine 6
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get air value from time of spawning
		lsr.b	#1,d0
		move.b	Drown_Num_List(pc,d0.w),ost_anim(a0)	; convert air to animation id
		addq.b	#2,ost_routine(a0)			; goto Drown_NumAnim next
		move.b	#render_onscreen+render_abs,ost_render(a0)
		move.w	ost_x_pos(a0),d0
		sub.w	(v_camera_x_pos).w,d0
		addi.w	#screen_left,d0
		move.w	d0,ost_x_pos(a0)
		move.w	ost_y_pos(a0),d0
		sub.w	(v_camera_y_pos).w,d0
		addi.w	#screen_top,d0
		move.w	d0,ost_y_screen(a0)			; fix position to screen

Drown_NumAnim:	; Routine 8
		lea	Ani_Drown(pc),a1
		jsr	(AnimateSprite).l			; animate and goto Drown_NumDel when finished
		bra.w	DisplaySprite
; ===========================================================================

Drown_NumDel:	; Routine $A
		bra.w	DeleteObject
		
; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Drown:	index *
		ptr ani_drown_zeroappear
		ptr ani_drown_oneappear
		ptr ani_drown_twoappear
		ptr ani_drown_threeappear
		ptr ani_drown_fourappear
		ptr ani_drown_fiveappear
		ptr ani_drown_smallbubble
		ptr ani_drown_zeroflash
		ptr ani_drown_oneflash
		ptr ani_drown_twoflash
		ptr ani_drown_threeflash
		ptr ani_drown_fourflash
		ptr ani_drown_fiveflash
		
ani_drown_zeroappear:
		dc.w 5
		dc.w id_frame_bubble_zero_small
		dc.w id_frame_bubble_zero
		dc.w id_Anim_Flag_Change, id_ani_drown_zeroflash

ani_drown_oneappear:
		dc.w 5
		dc.w id_frame_bubble_one_small
		dc.w id_frame_bubble_one
		dc.w id_Anim_Flag_Change, id_ani_drown_oneflash

ani_drown_twoappear:
		dc.w 5
		dc.w id_frame_bubble_one_small
		dc.w id_frame_bubble_two
		dc.w id_Anim_Flag_Change, id_ani_drown_twoflash

ani_drown_threeappear:
		dc.w 5
		dc.w id_frame_bubble_three_small
		dc.w id_frame_bubble_three
		dc.w id_Anim_Flag_Change, id_ani_drown_threeflash

ani_drown_fourappear:
		dc.w 5
		dc.w id_frame_bubble_zero_small
		dc.w id_frame_bubble_four
		dc.w id_Anim_Flag_Change, id_ani_drown_fourflash

ani_drown_fiveappear:
		dc.w 5
		dc.w id_frame_bubble_five_small
		dc.w id_frame_bubble_five
		dc.w id_Anim_Flag_Change, id_ani_drown_fiveflash

ani_drown_smallbubble:
		dc.w 5
		dc.w id_frame_bubble_0
		dc.w id_frame_bubble_1
		dc.w id_frame_bubble_2
		dc.w id_frame_bubble_3
		dc.w id_frame_bubble_4
		dc.w id_Anim_Flag_Routine

ani_drown_zeroflash:
		dc.w 7
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_zero
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_zero
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_zero
		dc.w id_Anim_Flag_Routine

ani_drown_oneflash:
		dc.w 7
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_one
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_one
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_one
		dc.w id_Anim_Flag_Routine

ani_drown_twoflash:
		dc.w 7
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_two
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_two
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_two
		dc.w id_Anim_Flag_Routine

ani_drown_threeflash:
		dc.w 7
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_three
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_three
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_three
		dc.w id_Anim_Flag_Routine

ani_drown_fourflash:
		dc.w 7
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_four
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_four
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_four
		dc.w id_Anim_Flag_Routine

ani_drown_fiveflash:
		dc.w 7
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_five
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_five
		dc.w id_frame_bubble_blank
		dc.w id_frame_bubble_five
		dc.w id_Anim_Flag_Routine
