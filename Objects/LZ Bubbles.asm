; ---------------------------------------------------------------------------
; Object 64 - bubbles (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3, ObjPos_SBZ3 - subtypes $80/$81/$82
;	Bubble
; ---------------------------------------------------------------------------

Bubble:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Bub_Index(pc,d0.w),d1
		jmp	Bub_Index(pc,d1.w)
; ===========================================================================
Bub_Index:	index *,,2
		ptr Bub_Main
		ptr Bub_Wait
		ptr Bub_Active
		ptr Bub_Mini
		ptr Bub_Mini2
		ptr Bub_Big
		ptr Bub_Big2
		ptr Bub_Burst
		ptr Bub_Delete

		rsobj Bubble
ost_bubble_x_start:	rs.w 1					; original x-axis position (2 bytes)
ost_bubble_freq:	rs.b 1					; number of cycles between large bubbles
ost_bubble_mini_count:	rs.b 1					; number of smaller bubbles to spawn
ost_bubble_wait_time:	rs.w 1					; general timer
ost_bubble_flag:	rs.b 1					; flag set when a big bubble has spawned
ost_bubble_mini_index:	rs.b 1					; position within bubble type list
		rsobjend
; ===========================================================================

Bub_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Bub_Wait next
		move.l	#Map_Bub,ost_mappings(a0)
		move.w	#tile_Kos_Bubbles+tile_hi,ost_tile(a0)
		move.b	#render_onscreen+render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#1,ost_priority(a0)
		move.b	#id_ani_bubble_bubmaker,ost_anim(a0)
		move.b	ost_subtype(a0),d0
		andi.b	#$F,d0					; low nybble of subtype
		move.b	d0,ost_bubble_freq(a0)			; set as frequency
		
Bub_Wait:	; Routine 2
		move.w	(v_water_height_actual).w,d0
		cmp.w	ost_y_pos(a0),d0
		bcc.w	DespawnQuick_NoDisplay			; branch if not underwater
		
		subq.w	#1,ost_bubble_wait_time(a0)		; decrement timer
		bpl.s	.animate				; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Bub_Active next

	.rand_0_to_5:
		jsr	(RandomNumber).l
		andi.w	#7,d0					; d0 = random 0-7
		cmpi.w	#6,d0
		bcc.s	.rand_0_to_5				; branch if 6 or 7
		move.b	d0,ost_bubble_mini_count(a0)		; set number of bubbles to spawn
		andi.w	#$C,d1					; read only bits 2-3 of random number
		move.b	d1,ost_bubble_mini_index(a0)		; set bubble pattern
		clr.w	ost_bubble_wait_time(a0)		; first bubble spawns immediately
		clr.b	ost_bubble_flag(a0)
		
	.animate:
		lea	(Ani_Bub).l,a1
		jsr	(AnimateSprite).l
		bra.w	DespawnQuick
; ===========================================================================
		
Bub_Active:	; Routine 4
		move.w	(v_water_height_actual).w,d0
		cmp.w	ost_y_pos(a0),d0
		bcc.w	DespawnQuick_NoDisplay			; branch if not underwater
		
		subq.w	#1,ost_bubble_wait_time(a0)		; decrement timer
		bpl.w	.animate				; branch if time remains
		jsr	(RandomNumber).l
		andi.w	#$1F,d0
		move.w	d0,ost_bubble_wait_time(a0)		; set next time (0-31 frames)
		bsr.w	FindFreeObj				; find free OST slot
		bne.w	.fail					; branch if not found
		move.l	#Bubble,ost_id(a1)			; load mini bubble object
		move.b	#id_Bub_Mini,ost_routine(a1)
		andi.w	#$F,d1
		subq.w	#8,d1					; d1 = random number between -8 and 8
		add.w	ost_x_pos(a0),d1
		move.w	d1,ost_x_pos(a1)			; x pos is within 8px either side of start
		move.w	ost_x_pos(a0),ost_bubble_x_start(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	#$10,ost_displaywidth(a1)
		move.b	#1,ost_priority(a1)
		move.w	#-$88,ost_y_vel(a1)
		moveq	#0,d0
		move.b	ost_bubble_mini_index(a0),d0
		move.b	Bub_Mini_List(pc,d0.w),ost_anim(a1)	; get animation from list based on random number
		addq.b	#1,ost_bubble_mini_index(a0)
		
		tst.b	ost_bubble_freq(a0)
		bne.s	.fail					; branch if current sequence shouldn't contain a big bubble
		tst.b	ost_bubble_flag(a0)
		bne.s	.fail					; branch if big bubble already spawned
		tst.b	ost_bubble_mini_count(a0)
		beq.s	.force_big				; branch if this is the last bubble
		move.b	(v_frame_counter_low).w,d0
		andi.b	#3,d0
		bne.s	.fail					; branch if two random bits aren't both 0
		
	.force_big:
		move.b	#id_Bub_Big,ost_routine(a1)		; convert mini bubble to big bubble
		move.b	#id_ani_bubble_large,ost_anim(a1)
		move.b	#1,ost_bubble_flag(a0)			; don't spawn another big bubble
		
	.fail:
		subq.b	#1,ost_bubble_mini_count(a0)		; decrement bubble counter
		bpl.s	.animate				; branch if not -1
		subq.b	#2,ost_routine(a0)			; goto Bub_Wait next
		subq.b	#1,ost_bubble_freq(a0)			; decrement frequency counter
		bpl.s	.keep_freq				; branch if frequency is 0+
		move.b	ost_subtype(a0),d0
		andi.b	#$F,d0					; low nybble of subtype
		move.b	d0,ost_bubble_freq(a0)			; set as frequency
		
	.keep_freq:
		jsr	(RandomNumber).l
		andi.w	#$7F,d0
		addi.w	#$80,d0
		move.w	d0,ost_bubble_wait_time(a0)		; set time until next sequence
		
	.animate:
		lea	(Ani_Bub).l,a1
		jsr	(AnimateSprite).l
		bra.w	DespawnQuick
		
Bub_Mini_List:	dc.b id_ani_bubble_small, id_ani_bubble_medium, id_ani_bubble_small
		dc.b id_ani_bubble_small, id_ani_bubble_small, id_ani_bubble_small
		dc.b id_ani_bubble_medium, id_ani_bubble_small, id_ani_bubble_small
		dc.b id_ani_bubble_small, id_ani_bubble_small, id_ani_bubble_medium
		dc.b id_ani_bubble_small, id_ani_bubble_medium, id_ani_bubble_small
		dc.b id_ani_bubble_small, id_ani_bubble_medium, id_ani_bubble_small
		even
; ===========================================================================

Bub_Mini:	; Routine 6
Bub_Big:	; Routine $A
		lea	(Ani_Bub).l,a1
		jsr	(AnimateSprite).l
		
Bub_Mini2:	; Routine 8
		tst.b	ost_render(a0)
		bpl.w	DeleteObject				; delete if off screen
		bsr.w	Bub_Move
		move.w	(v_water_height_actual).w,d0
		cmp.w	ost_y_pos(a0),d0
		bcc.w	DeleteObject				; branch if bubble is above water
		bra.w	DespawnQuick
; ===========================================================================

Bub_Big2:	; Routine $C
		tst.b	ost_render(a0)
		bpl.w	DeleteObject				; delete if off screen
		bsr.w	Bub_Move
		move.w	(v_water_height_actual).w,d0
		cmp.w	ost_y_pos(a0),d0
		bcc.w	.burst					; branch if bubble is above water
		
		tst.b	(v_lock_multi).w
		bmi.w	DespawnQuick				; branch if object collision disabled
		getsonic
		range_x
		cmp.w	#16,d1
		bcc.w	DespawnQuick
		range_y
		tst.w	d2
		bmi.w	DespawnQuick				; branch if Sonic is above bubble
		cmp.w	#16,d3
		bcc.w	DespawnQuick

		bsr.w	ResumeMusic				; cancel countdown music & reset air
		play.w	1, jsr, sfx_Bubble			; play collecting bubble sound
		clr.w	ost_x_vel(a1)
		clr.w	ost_y_vel(a1)
		clr.w	ost_inertia(a1)				; stop Sonic
		move.b	#id_GetAir,ost_anim(a1)			; use bubble-collecting animation
		move.w	#35,ost_sonic_lock_time(a1)		; lock controls for 35 frames
		move.b	#0,ost_sonic_jump(a1)			; cancel jump
		bclr	#status_pushing_bit,ost_status(a1)
		bclr	#status_rolljump_bit,ost_status(a1)
		bclr	#status_jump_bit,ost_status(a1)
		beq.s	.burst					; branch if Sonic wasn't jumping
		move.b	(v_player1_height).w,ost_height(a1)
		move.b	(v_player1_width).w,ost_width(a1)
		subq.w	#5,ost_y_pos(a1)
		
	.burst:
		move.b	#id_ani_bubble_burst,ost_anim(a0)
		addq.b	#2,ost_routine(a0)			; goto Bub_Burst next
		bra.w	DespawnQuick
		
; ---------------------------------------------------------------------------
; Subroutine to move bubble up and side-to-side

;	uses d0.l, a1
; ---------------------------------------------------------------------------

Bub_Move:
		update_y_pos
		move.b	ost_angle(a0),d0
		addq.b	#1,ost_angle(a0)
		andi.w	#$7F,d0
		lea	(Drown_WobbleData).l,a1
		move.b	(a1,d0.w),d0				; get byte from wobble array
		ext.w	d0
		add.w	ost_bubble_x_start(a0),d0
		move.w	d0,ost_x_pos(a0)			; update x pos
		rts
; ===========================================================================

Bub_Burst:	; Routine $E
		lea	Ani_Bub(pc),a1
		jsr	(AnimateSprite).l			; animate and goto Bub_Delete when finished
		bra.w	DisplaySprite
; ===========================================================================

Bub_Delete:	; Routine $10
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Bub:	index *
		ptr ani_bubble_small
		ptr ani_bubble_medium
		ptr ani_bubble_large
		ptr ani_bubble_burst
		ptr ani_bubble_bubmaker
		
ani_bubble_small:						; small bubble forming
		dc.w $E
		dc.w id_frame_bubble_0
		dc.w id_frame_bubble_1
		dc.w id_frame_bubble_2
		dc.w id_Anim_Flag_Routine

ani_bubble_medium:						; medium bubble forming
		dc.w $E
		dc.w id_frame_bubble_1
		dc.w id_frame_bubble_2
		dc.w id_frame_bubble_3
		dc.w id_frame_bubble_4
		dc.w id_Anim_Flag_Routine

ani_bubble_large:						; full size bubble forming
		dc.w $E
		dc.w id_frame_bubble_2
		dc.w id_frame_bubble_3
		dc.w id_frame_bubble_4
		dc.w id_frame_bubble_5
		dc.w id_frame_bubble_full
		dc.w id_Anim_Flag_Routine

ani_bubble_burst:						; large bubble bursts
		dc.w 4
		dc.w id_frame_bubble_full
		dc.w id_frame_bubble_burst1
		dc.w id_frame_bubble_burst2
		dc.w id_Anim_Flag_Routine

ani_bubble_bubmaker:						; bubble maker on the floor
		dc.w $F
		dc.w id_frame_bubble_bubmaker1
		dc.w id_frame_bubble_bubmaker2
		dc.w id_frame_bubble_bubmaker3
		dc.w id_Anim_Flag_Restart
