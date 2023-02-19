; ---------------------------------------------------------------------------
; Subroutine to	load level boundaries and start	locations

;	uses d0, d1, d2, a0, a1, a2
; ---------------------------------------------------------------------------

LevelParameterLoad:
		moveq	#0,d0
		move.b	d0,(v_dle_routine).w			; clear DynamicLevelEvents routine counter
		move.w	#$1010,(v_fg_x_redraw_flag).w		; set fg redraw flag
		move.w	#camera_y_shift_default,(v_camera_y_shift).w ; default camera shift = $60 (changes when Sonic looks up/down)
		
		tst.b	(v_last_lamppost).w			; have any lampposts been hit?
		beq.s	.no_lamppost				; if not, branch

		jsr	(Lamp_LoadInfo).l			; load lamppost variables
		bra.s	LPL_Camera
; ===========================================================================

.no_lamppost:
		tst.w	(v_demo_mode).w				; is demo mode on?
		beq.s	LPL_Camera				; if not, branch
		tst.l	(v_demo_x_start).w			; is demo start pos set?
		beq.s	LPL_Camera				; if not, branch

		move.w	(v_demo_x_start).w,(v_ost_player+ost_x_pos).w ; set Sonic's x position
		move.w	(v_demo_y_start).w,(v_ost_player+ost_y_pos).w ; set Sonic's y position

LPL_Camera:
		move.w	(v_ost_player+ost_x_pos).w,d1
		move.w	(v_ost_player+ost_y_pos).w,d0		; d0/d1 = Sonic's position
		subi.w	#160,d1					; is Sonic more than 160px from left edge?
		bcc.s	.chk_right				; if yes, branch
		moveq	#0,d1

	.chk_right:
		move.w	(v_boundary_right).w,d2
		cmp.w	d2,d1					; is Sonic inside the right edge?
		bcs.s	.set_camera_x				; if yes, branch
		move.w	d2,d1

	.set_camera_x:
		move.w	d1,(v_camera_x_pos).w			; set camera x position

		subi.w	#96,d0					; is Sonic within 96px of upper edge?
		bcc.s	.chk_bottom				; if yes, branch
		moveq	#0,d0

	.chk_bottom:
		cmp.w	(v_boundary_bottom).w,d0		; is Sonic above the bottom edge?
		blt.s	.set_camera_y				; if yes, branch
		move.w	(v_boundary_bottom).w,d0

	.set_camera_y:
		move.w	d0,(v_camera_y_pos).w			; set vertical screen position

; ---------------------------------------------------------------------------
; Subroutine to	initialise background position and scrolling

; input:
;	d0 = v_camera_y_pos
;	d1 = v_camera_x_pos

;	uses d0, d1, d2, a2
; ---------------------------------------------------------------------------

LPL_InitBG:
		tst.b	(v_last_lamppost).w			; have any lampposts been hit?
		bne.s	.no_lamppost				; if yes, branch
		move.w	d0,(v_bg1_y_pos).w
		move.w	d0,(v_bg2_y_pos).w
		move.w	d1,(v_bg1_x_pos).w
		move.w	d1,(v_bg2_x_pos).w
		move.w	d1,(v_bg3_x_pos).w			; use same x/y pos for fg and bg

	.no_lamppost:
		moveq	#0,d2
		move.b	(v_zone).w,d2
		add.w	d2,d2
		move.w	LPL_InitBG_Index(pc,d2.w),d2
		jmp	LPL_InitBG_Index(pc,d2.w)

; ===========================================================================
LPL_InitBG_Index:
		index *
		ptr LPL_InitBG_GHZ
		ptr LPL_InitBG_LZ
		ptr LPL_InitBG_MZ
		ptr LPL_InitBG_SLZ
		ptr LPL_InitBG_SYZ
		ptr LPL_InitBG_SBZ
		ptr LPL_InitBG_End
; ===========================================================================

LPL_InitBG_GHZ:
		clr.l	(v_bg1_x_pos).w
		clr.l	(v_bg1_y_pos).w
		clr.l	(v_bg2_y_pos).w
		clr.l	(v_bg3_y_pos).w
		lea	(v_bgscroll_buffer).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts
; ===========================================================================

LPL_InitBG_LZ:
		asr.l	#1,d0					; d0 = v_camera_y_pos/2
		move.w	d0,(v_bg1_y_pos).w
		rts	
; ===========================================================================

LPL_InitBG_MZ:
		rts	
; ===========================================================================

LPL_InitBG_SLZ:
		asr.l	#1,d0
		addi.w	#$C0,d0					; d0 = (v_camera_y_pos/2)+$C0
		move.w	d0,(v_bg1_y_pos).w
		clr.l	(v_bg1_x_pos).w
		rts	
; ===========================================================================

LPL_InitBG_SYZ:
		asl.l	#4,d0
		move.l	d0,d2
		asl.l	#1,d0
		add.l	d2,d0
		asr.l	#8,d0					; d0 = v_camera_y_pos/5 (approx)
		addq.w	#1,d0
		move.w	d0,(v_bg1_y_pos).w
		clr.l	(v_bg1_x_pos).w
		rts	
; ===========================================================================

LPL_InitBG_SBZ:
		andi.w	#$7F8,d0
		asr.w	#3,d0
		addq.w	#1,d0					; d0 = (v_camera_y_pos/8)+1
		move.w	d0,(v_bg1_y_pos).w
		rts	
; ===========================================================================

LPL_InitBG_End:
		move.w	(v_camera_x_pos).w,d0
		asr.w	#1,d0
		move.w	d0,(v_bg1_x_pos).w
		move.w	d0,(v_bg2_x_pos).w
		asr.w	#2,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,(v_bg3_x_pos).w
		clr.l	(v_bg1_y_pos).w
		clr.l	(v_bg2_y_pos).w
		clr.l	(v_bg3_y_pos).w
		lea	(v_bgscroll_buffer).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts
