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
ost_drown_restart_time:	rs.w 1 ; $2C				; time to restart after Sonic drowns (2 bytes)
ost_drown_x_start:	rs.w 1 ; $30				; original x-axis position (2 bytes)
ost_drown_disp_time:	rs.b 1 ; $32				; time to display each number
ost_drown_type:		rs.b 1 ; $33				; bubble type
ost_drown_extra_bub:	rs.b 1 ; $34				; number of extra bubbles to create
ost_drown_extra_flag:	rs.w 1 ; $36				; flags for extra bubbles (2 bytes)
ost_drown_num_time:	rs.w 1 ; $38				; time between each number changes (2 bytes)
ost_drown_delay_time	rs.w 1 ; $3A				; delay between bubbles (2 bytes)
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
		move.l	#DelayedBubble,ost_id(a1)		; load mini bubble object
		jsr	(RandomNumber).l
		andi.b	#1,d0
		beq.s	.fail					; branch if random bit is 0
		movea.l	a1,a2					; copy OST address of first bubble
		bsr.w	FindFreeObj
		bne.s	.fail
		move.l	#DelayedBubble,ost_id(a1)		; load 2nd mini bubble object
		andi.b	#$F,d1
		addq.b	#1,d1
		move.b	d1,ost_anim_time(a1)			; set random delay (1-16) for 2nd bubble
		
	.fail:
		rts
		
Drown_Music:
		play.w	0, jsr, mus_Drowning			; play countdown music
		
Drown_Number:
		bsr.s	Drown_Bubble				; spawn 1 or 2 bubbles
		move.l	#DrownCount,ost_id(a1)
		move.b	#id_Drown_NumWait,ost_routine(a1)	; one bubble becomes a number instead
		rts
		
Drown_Death:
		rts
; ===========================================================================

Drown_NumWait:	; Routine 2
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Drown_NumBub next
		move.b	#id_ani_drown_smallbubble,ost_anim(a0)
		bra.w	DelayBub_Setup
		
	.wait:
		rts
; ===========================================================================

Drown_NumBub:	; Routine 4
		lea	(Ani_Drown).l,a1
		jsr	(AnimateSprite).l			; animate and goto Drown_NumSet when finished
		bsr.w	Bub_Move				; move bubble up & sideways
		move.w	(v_water_height_actual).w,d0
		cmp.w	ost_y_pos(a0),d0
		bcs.w	DisplaySprite				; branch if bubble is below water
		rts
; ===========================================================================

Drown_NumSet:	; Routine 6
		move.b	(v_air).w,d0
		subq.b	#2,d0
		lsr.b	#1,d0					; convert air to animation id
		move.b	d0,ost_anim(a0)
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
		lea	(Ani_Drown).l,a1
		jsr	(AnimateSprite).l			; animate and goto Drown_NumDel when finished
		bra.w	DisplaySprite
; ===========================================================================

Drown_NumDel:	; Routine $A
		bra.w	DeleteObject
		
; ---------------------------------------------------------------------------
; Mini bubbles that float out of Sonic's mouth

; spawned by:
;	DrownCount
; ---------------------------------------------------------------------------

DelayedBubble:
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bpl.s	DelayBub_Wait				; branch if time remains
		move.l	#Bubble,ost_id(a0)			; convert to mini bubble object
		move.b	#id_Bub_Mini,ost_routine(a0)
		move.b	#id_ani_bubble_small,ost_anim(a0)
		
DelayBub_Setup:
		move.l	#Map_Bub,ost_mappings(a0)
		move.w	#tile_Kos_Bubbles+tile_hi,ost_tile(a0)
		move.b	#render_rel+render_onscreen,ost_render(a0)
		move.b	#4,ost_displaywidth(a0)
		move.b	#1,ost_priority(a0)
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
		
DelayBub_Wait:
		rts
		
; ---------------------------------------------------------------------------
; Data for a bubble's side-to-side wobble (also used by REV01's underwater
; background ripple effect)
; ---------------------------------------------------------------------------
Drown_WobbleData:
LZ_BG_Ripple_Data:
		rept 2
		dc.b 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2
		dc.b 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
		dc.b 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2
		dc.b 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0
		dc.b 0, -1, -1, -1, -1, -1, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3
		dc.b -3, -3, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4
		dc.b -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -3
		dc.b -3, -3, -3, -3, -3, -3, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1
		endr
; ===========================================================================

Drown_Countdown:; Routine $A
		tst.w	ost_drown_restart_time(a0)		; has Sonic drowned?
		bne.w	.kill_sonic				; if yes, branch
		cmpi.b	#id_Sonic_Death,(v_ost_player+ost_routine).w ; is Sonic dead?
		bcc.w	.nocountdown				; if yes, branch
		btst	#status_underwater_bit,(v_ost_player+ost_status).w ; is Sonic underwater?
		beq.w	.nocountdown				; if not, branch

		subq.w	#1,ost_drown_num_time(a0)		; decrement timer between countdown number changes
		bpl.w	.create_bubble				; branch if time remains
		move.w	#59,ost_drown_num_time(a0)		; set timer to 1 second
		move.w	#1,ost_drown_extra_flag(a0)
		jsr	(RandomNumber).l
		andi.w	#1,d0					; random number 0 or 1
		move.b	d0,ost_drown_extra_bub(a0)
		move.w	(v_air).w,d0				; check air remaining
		cmpi.w	#air_ding1,d0
		beq.s	.warnsound				; play sound if	air is 25
		cmpi.w	#air_ding2,d0
		beq.s	.warnsound				; play sound if	air is 20
		cmpi.w	#air_ding3,d0
		beq.s	.warnsound				; play sound if	air is 15
		cmpi.w	#air_alert,d0
		bhi.s	.reduceair				; if air is above 12, branch

		bne.s	.skipmusic				; if air is less than 12, branch
		play.w	0, jsr, mus_Drowning			; play countdown music

	.skipmusic:
		subq.b	#1,ost_drown_disp_time(a0)		; decrement display timer
		bpl.s	.reduceair				; branch if time remains
		move.b	ost_drown_type(a0),ost_drown_disp_time(a0) ; reset timer (1)
		bset	#7,ost_drown_extra_flag(a0)
		bra.s	.reduceair
; ===========================================================================

.warnsound:
		play.w	1, jsr, sfx_Ding			; play "ding-ding" warning sound

.reduceair:
		subq.w	#1,(v_air).w				; decrement air remaining
		bcc.w	.gotomakenum				; if air is above 0, branch

		; Sonic drowns here
		bsr.w	ResumeMusic
		move.b	#$81,(v_lock_multi).w			; lock controls
		play.w	1, jsr, sfx_Drown			; play drowning sound
		move.b	#$A,ost_drown_extra_bub(a0)
		move.w	#1,ost_drown_extra_flag(a0)
		move.w	#120,ost_drown_restart_time(a0)		; restart after 2 seconds
		move.l	a0,-(sp)				; save OST address to stack
		lea	(v_ost_player).w,a0			; use Sonic's OST temporarily
		bsr.w	Sonic_ResetOnFloor			; clear Sonic's status flags
		move.b	#id_Drown,ost_anim(a0)			; use Sonic's drowning animation
		bset	#status_air_bit,ost_status(a0)
		bset	#tile_hi_bit,ost_tile(a0)
		move.w	#0,ost_y_vel(a0)
		move.w	#0,ost_x_vel(a0)
		move.w	#0,ost_inertia(a0)
		move.b	#1,(f_disable_scrolling).w
		movea.l	(sp)+,a0				; restore OST from stack
		rts	
; ===========================================================================

.kill_sonic:
		subq.w	#1,ost_drown_restart_time(a0)		; decrement delay timer after drowning
		bne.s	.delay_death				; branch if time remains
		move.b	#id_Sonic_Death,(v_ost_player+ost_routine).w ; kill Sonic
		rts	
; ===========================================================================

	.delay_death:
		move.l	a0,-(sp)				; save OST address to stack
		lea	(v_ost_player).w,a0			; use Sonic's OST temporarily
		jsr	(SpeedToPos).l				; update Sonic's position
		addi.w	#$10,ost_y_vel(a0)			; make Sonic fall
		movea.l	(sp)+,a0				; restore OST
		bra.s	.create_bubble
; ===========================================================================

.gotomakenum:
		bra.s	.makenum
; ===========================================================================

.create_bubble:
		tst.w	ost_drown_extra_flag(a0)		; should bubbles/numbers be spawned?
		beq.w	.nocountdown				; if not, branch
		subq.w	#1,ost_drown_delay_time(a0)		; decrement timer between bubble spawning
		bpl.w	.nocountdown				; branch if time remains

.makenum:
		jsr	(RandomNumber).l
		andi.w	#$F,d0
		move.w	d0,ost_drown_delay_time(a0)		; set timer as random 0-15 frames
		jsr	(FindFreeObj).l				; find free OST slot
		bne.w	.nocountdown				; branch if not found
		move.l	#DrownCount,ost_id(a1)			; load object
		move.w	(v_ost_player+ost_x_pos).w,ost_x_pos(a1)
		moveq	#6,d0					; 6 pixels to right
		btst	#status_xflip_bit,(v_ost_player+ost_status).w ; is Sonic facing left?
		beq.s	.noflip					; if not, branch
		neg.w	d0					; 6 pixels to left
		move.b	#$40,ost_angle(a1)

	.noflip:
		add.w	d0,ost_x_pos(a1)
		move.w	(v_ost_player+ost_y_pos).w,ost_y_pos(a1)
		move.b	#id_ani_drown_smallbubble,ost_subtype(a1) ; object is small bubble (6)
		tst.w	ost_drown_restart_time(a0)		; has Sonic drowned?
		beq.w	.not_dead				; if not, branch
		andi.w	#7,ost_drown_delay_time(a0)		; cut time between bubbles to 7 frames or less
		addi.w	#0,ost_drown_delay_time(a0)
		move.w	(v_ost_player+ost_y_pos).w,d0
		subi.w	#$C,d0
		move.w	d0,ost_y_pos(a1)
		jsr	(RandomNumber).l
		move.b	d0,ost_angle(a1)
		move.w	(v_frame_counter).w,d0
		andi.b	#3,d0
		bne.s	.loc_14082
		move.b	#id_ani_drown_mediumbubble,ost_subtype(a1) ; object is medium bubble ($E)
		bra.s	.loc_14082
; ===========================================================================

.not_dead:
		btst	#7,ost_drown_extra_flag(a0)
		beq.s	.loc_14082
		move.w	(v_air).w,d2				; get air remaining
		lsr.w	#1,d2					; divide by 2
		jsr	(RandomNumber).l
		andi.w	#3,d0
		bne.s	.loc_1406A
		bset	#6,ost_drown_extra_flag(a0)
		bne.s	.loc_14082
		move.b	d2,ost_subtype(a1)			; object is a number (0-5)
		move.w	#28,ost_drown_num_time(a1)

	.loc_1406A:
		tst.b	ost_drown_extra_bub(a0)
		bne.s	.loc_14082
		bset	#6,ost_drown_extra_flag(a0)
		bne.s	.loc_14082
		move.b	d2,ost_subtype(a1)
		move.w	#28,ost_drown_num_time(a1)

.loc_14082:
		subq.b	#1,ost_drown_extra_bub(a0)
		bpl.s	.nocountdown
		clr.w	ost_drown_extra_flag(a0)

.nocountdown:
		rts	

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
		ptr ani_drown_blank
		ptr ani_drown_mediumbubble
		
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

ani_drown_blank:
		dc.w $E
		dc.w id_Anim_Flag_Routine

ani_drown_mediumbubble:
		dc.w $E
		dc.w id_frame_bubble_1
		dc.w id_frame_bubble_2
		dc.w id_frame_bubble_3
		dc.w id_frame_bubble_4
		dc.w id_Anim_Flag_Routine
