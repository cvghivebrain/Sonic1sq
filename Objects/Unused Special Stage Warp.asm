; ---------------------------------------------------------------------------
; Object 4A - unused special stage entry from beta
; ---------------------------------------------------------------------------

VanishSonic:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Van_Index(pc,d0.w),d1
		jmp	Van_Index(pc,d1.w)
; ===========================================================================
Van_Index:	index *,,2
		ptr Van_Main
		ptr Van_RmvSonic
		ptr Van_LoadSonic

		rsobj VanishSonic
ost_vanish_time:	rs.w 1					; time for Sonic to disappear
		rsobjend
; ===========================================================================

Van_Main:	; Routine 0
		moveq	#id_UPLC_Warp,d0
		jsr	UncPLC
		addq.b	#2,ost_routine(a0)			; goto Van_RmvSonic next
		move.l	#Map_Vanish,ost_mappings(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_1,ost_priority(a0)
		move.b	#$38,ost_displaywidth(a0)
		move.w	#vram_shield/sizeof_cell,ost_tile(a0)
		move.w	#120,ost_vanish_time(a0)		; set time for Sonic's disappearance to 2 seconds

Van_RmvSonic:	; Routine 2
		getsonic a3					; a3 = OST of Sonic
		move.w	ost_x_pos(a3),ost_x_pos(a0)
		move.w	ost_y_pos(a3),ost_y_pos(a0)
		move.b	ost_status(a3),ost_status(a0)
		lea	Ani_Vanish(pc),a1
		jsr	(AnimateSprite).l			; animate and goto Van_LoadSonic next
		cmpi.b	#id_frame_vanish_flash3,ost_frame(a0)	; is final flash frame displayed?
		bne.s	.display				; if not, branch

		tst.b	ost_id(a3)				; has Sonic already been removed?
		beq.s	.display				; if yes, branch
		move.l	#0,ost_id(a3)				; remove Sonic
		play_sound sfx_Goal				; play Special Stage "GOAL" sound

	.display:
		jmp	(DisplaySprite).l
; ===========================================================================

Van_LoadSonic:	; Routine 4
		subq.w	#1,ost_vanish_time(a0)			; decrement timer
		bne.s	.wait					; if time remains, branch
		move.l	(v_player1_ptr).w,d0
		move.l	d0,(v_ost_player).w			; load Sonic object
		jmp	(DeleteObject).l

	.wait:
		rts	

; ---------------------------------------------------------------------------
; Animation script - special stage entry effect from beta
; ---------------------------------------------------------------------------

Ani_Vanish:	index *
		ptr ani_vanish_0
		
ani_vanish_0:	dc.w 5
		dc.w id_frame_vanish_flash1
		dc.w id_frame_vanish_flash2
		dc.w id_frame_vanish_flash1
		dc.w id_frame_vanish_flash2
		dc.w id_frame_vanish_flash1
		dc.w id_frame_vanish_blank
		dc.w id_frame_vanish_flash2
		dc.w id_frame_vanish_blank
		dc.w id_frame_vanish_flash3
		dc.w id_frame_vanish_blank
		dc.w id_frame_vanish_sparkle1
		dc.w id_frame_vanish_blank
		dc.w id_frame_vanish_sparkle2
		dc.w id_frame_vanish_blank
		dc.w id_frame_vanish_sparkle3
		dc.w id_frame_vanish_blank
		dc.w id_frame_vanish_sparkle4
		dc.w id_frame_vanish_blank
		dc.w id_Anim_Flag_Routine
