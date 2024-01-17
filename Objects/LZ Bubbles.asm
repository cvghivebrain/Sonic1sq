; ---------------------------------------------------------------------------
; Bubbles (LZ)

; spawned by:
;	BubbleMaker, DrownCount

; subtypes:
;	%000STTTT
;	S - 1 if aligned to Sonic's mouth
;	TTTT - type (0 = small, 1 = medium, 2 = large breathable)
; ---------------------------------------------------------------------------

Bubble:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Bub_Index(pc,d0.w),d1
		jmp	Bub_Index(pc,d1.w)
; ===========================================================================
Bub_Index:	index *,,2
		ptr Bub_Main
		ptr Bub_Mini
		ptr Bub_Mini2
		ptr Bub_Big
		ptr Bub_Big2
		ptr Bub_Burst
		ptr Bub_Delete

Bub_Settings:	; routine, animation, width/2
		dc.b id_Bub_Mini, id_ani_bubble_small, 4
		dc.b id_Bub_Mini, id_ani_bubble_medium, 8
		dc.b id_Bub_Big, id_ani_bubble_large, 16
		even

		rsobj Bubble
ost_bubble_x_start:	rs.w 1					; original x-axis position (2 bytes)
		rsobjend
; ===========================================================================

Bub_Wait:
		rts

Bub_Main:	; Routine 0
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bpl.s	Bub_Wait				; branch if time remains
		move.l	#Map_Bub,ost_mappings(a0)
		move.w	(v_tile_bubbles).w,ost_tile(a0)
		ori.w	#tile_hi,ost_tile(a0)
		move.b	#render_onscreen+render_rel,ost_render(a0)
		move.b	#priority_1,ost_priority(a0)
		move.w	#-$88,ost_y_vel(a0)
		move.b	ost_subtype(a0),d0
		andi.w	#$F,d0					; read low nybble of subtype
		mulu.w	#3,d0
		lea	Bub_Settings(pc,d0.w),a2		; get settings for specified type
		move.b	(a2)+,ost_routine(a0)
		move.b	(a2)+,ost_anim(a0)
		move.b	(a2)+,ost_displaywidth(a0)
		btst	#4,ost_subtype(a0)
		beq.s	.skip_sonic				; branch if not +$10
		moveq	#6,d0					; 6 pixels to right
		getsonic
		btst	#status_xflip_bit,ost_status(a1)
		beq.s	.noflip					; branch if Sonic is facing right
		neg.w	d0					; 6 pixels to left
		move.b	#$40,ost_angle(a0)			; start moving left
	.noflip:
		add.w	ost_x_pos(a1),d0			; copy Sonic's position
		move.w	d0,ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)

	.skip_sonic:
		move.w	ost_x_pos(a0),ost_bubble_x_start(a0)

Bub_Mini:	; Routine 2
Bub_Big:	; Routine 6
		lea	Ani_Bub(pc),a1
		jsr	(AnimateSprite).l

Bub_Mini2:	; Routine 4
		tst.b	ost_render(a0)
		bpl.w	DeleteObject				; delete if off screen
		bsr.w	Bub_Move
		move.w	(v_water_height_actual).w,d0
		cmp.w	ost_y_pos(a0),d0
		bcc.w	DeleteObject				; branch if bubble is above water
		bra.w	DespawnQuick
; ===========================================================================

Bub_Big2:	; Routine 8
		tst.b	ost_render(a0)
		bpl.w	DeleteObject				; delete if off screen
		bsr.w	Bub_Move
		move.w	(v_water_height_actual).w,d0
		cmp.w	ost_y_pos(a0),d0
		bcc.w	.burst					; branch if bubble is above water

		tst.b	(v_lock_multi).w
		bmi.w	DespawnQuick				; branch if object collision disabled
		getsonic
		range_x_test	16
		bcc.w	DespawnQuick
		range_y_quick
		bmi.w	DespawnQuick				; branch if Sonic is above bubble
		cmp.w	#16,d2
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

;	uses d0.l
; ---------------------------------------------------------------------------

Bub_Move:
		update_y_pos
		move.b	ost_angle(a0),d0
		addq.b	#1,ost_angle(a0)
		andi.w	#$7F,d0
		move.b	Bub_WobbleData(pc,d0.w),d0		; get byte from wobble array
		ext.w	d0
		add.w	ost_bubble_x_start(a0),d0
		move.w	d0,ost_x_pos(a0)			; update x pos
		rts

Bub_WobbleData:
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

Bub_Burst:	; Routine $A
		lea	Ani_Bub(pc),a1
		jsr	(AnimateSprite).l			; animate and goto Bub_Delete when finished
		bra.w	DisplaySprite
; ===========================================================================

Bub_Delete:	; Routine $C
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Bub:	index *
		ptr ani_bubble_small
		ptr ani_bubble_medium
		ptr ani_bubble_large
		ptr ani_bubble_burst

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
