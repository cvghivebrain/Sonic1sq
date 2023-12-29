; ---------------------------------------------------------------------------
; Bosses

; spawned by:
;	
; ---------------------------------------------------------------------------

Boss:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Boss_Index(pc,d0.w),d1
		jmp	Boss_Index(pc,d1.w)
; ===========================================================================
Boss_Index:	index *,,2
		ptr Boss_Main
		ptr Boss_Wait
		ptr Boss_Move

		rsobj Boss2
ost_boss2_y_normal:	rs.l 1					; y position without wobble
ost_boss2_time:		rs.w 1					; time until next action
ost_boss2_cam_start:	equ ost_boss2_time			; camera x pos where boss activates
ost_boss2_wobble:	rs.b 1					; wobble counter
		rsobjend
		
Boss_CamXPos:	dc.w 0,$2960					; camera x pos where the boss becomes active
Boss_InitMode:	dc.b 0						; initial mode for each boss
		even
		
bmove:		macro xvel,yvel,time,xflip,next
		dc.w xvel, yvel, time
		dc.b xflip, next
		endm
Boss_MoveList:	; x speed, y speed, duration, xflip flag, next mode
		bmove 0, $100, $B8, 0, 1
		bmove -$100, -$40, $60, 0, 2
		bmove 0, 0, 119, 0, 3
		bmove -$40, 0, 127, 0, 4
		bmove 0, 0, 63, 1, 5
		bmove $100, 0, 63, 1, 6
		bmove 0, 0, 63, 0, 7
		bmove -$100, 0, 63, 0, 4
; ===========================================================================

Boss_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Boss_Wait next
		move.l	#Map_Bosses,ost_mappings(a0)
		move.w	#tile_Art_Eggman,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.b	#priority_3,ost_priority(a0)
		move.b	#id_React_Boss,ost_col_type(a0)
		move.b	#24,ost_col_width(a0)
		move.b	#24,ost_col_height(a0)
		move.b	#hitcount_ghz,ost_col_property(a0)	; set number of hits to 8
		move.w	ost_y_pos(a0),ost_boss2_y_normal(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		lea	Boss_InitMode,a2
		move.b	(a2,d0.w),ost_mode(a0)
		add.w	d0,d0
		lea	Boss_CamXPos,a2
		move.w	(a2,d0.w),ost_boss2_cam_start(a0)
		
		moveq	#id_UPLC_Boss,d0
		jsr	UncPLC

Boss_Wait:	; Routine 2
		move.w	ost_boss2_cam_start(a0),d0
		cmp.w	(v_camera_x_pos).w,d0
		bls.s	.activate				; branch if camera reaches position
		jmp	DisplaySprite
		
	.activate:
		addq.b	#2,ost_routine(a0)			; goto Boss_Move next
		bsr.s	Boss_SetMode
		jmp	DisplaySprite
		
; ===========================================================================

Boss_Move:	; Routine 4
		subq.w	#1,ost_boss2_time(a0)			; decrement timer
		bpl.s	.continue				; branch if time remains
		bsr.s	Boss_SetMode
		
	.continue:
		update_x_pos
		move.w	ost_y_vel(a0),d0			; load vertical speed
		ext.l	d0
		asl.l	#8,d0					; multiply speed by $100
		add.l	d0,ost_boss2_y_normal(a0)		; update y position
		
		move.b	ost_boss2_wobble(a0),d0			; get wobble byte
		jsr	(CalcSine).l				; convert to sine
		asr.w	#6,d0					; divide by 64
		add.w	ost_boss2_y_normal(a0),d0		; add y pos
		move.w	d0,ost_y_pos(a0)			; update actual y pos
		addq.b	#2,ost_boss2_wobble(a0)			; increment wobble (wraps to 0 after $FE)
		
		jmp	DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to load info for and update the boss mode
; ---------------------------------------------------------------------------

Boss_SetMode:
		moveq	#0,d0
		move.b	ost_mode(a0),d0
		lsl.w	#3,d0
		lea	Boss_MoveList,a2
		adda.l	d0,a2
		move.w	(a2)+,ost_x_vel(a0)
		move.w	(a2)+,ost_y_vel(a0)
		move.w	(a2)+,ost_boss2_time(a0)
		move.b	(a2)+,d0
		bclr	#render_xflip_bit,ost_render(a0)
		bclr	#status_xflip_bit,ost_status(a0)
		andi.b	#status_xflip,d0
		beq.s	.noflip
		bset	#render_xflip_bit,ost_render(a0)
		bset	#status_xflip_bit,ost_status(a0)
		
	.noflip:
		move.b	(a2)+,ost_mode(a0)
		rts
		