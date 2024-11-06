; ---------------------------------------------------------------------------
; Subroutine to	wait for VBlank routines to complete
; ---------------------------------------------------------------------------

WaitForVBlank:
		tst.b	(f_pause).w
		bne.s	WaitForVBlank_NoCPU			; branch if paused

WaitForVBlank_SkipChk:
		move.w	(vdp_counter).l,d3			; get vertical position
		move.w	d3,(v_frame_usage).w			; save as end of previous frame
		move.w	(v_vblank_overflow).w,d3
		move.w	d3,(v_vblank_overflow_prev).w		; save previous VBlank overflow
		enable_ints

	.wait:
		tst.b	(v_vblank_routine).w			; has VBlank routine finished?
		bne.s	.wait					; if not, branch
		move.w	(vdp_counter).l,d3			; get vertical position
		move.w	d3,(v_vblank_overflow).w		; save as start of frame (should be 0, assuming no overflow)
		rts

WaitForVBlank_NoCPU:
		enable_ints

	.wait:
		tst.b	(v_vblank_routine).w			; has VBlank routine finished?
		bne.s	.wait					; if not, branch
		rts

WaitForVBlank_Paused:
		tst.b	(f_pause).w
		bpl.s	WaitForVBlank_NoCPU			; branch if not using slow-mo
		move.b	#1,(f_pause).w				; clear slow-mo flag
		bra.s	WaitForVBlank_SkipChk

; ---------------------------------------------------------------------------
; Subroutine to	freeze the game for a set time

; inputs:
;	d0.w = number of frames to wait
;	d1.b = VBlank routine

;	uses d0.w
; ---------------------------------------------------------------------------

WaitLoop:
		move.b	d1,(v_vblank_routine).w
		bsr.w	WaitForVBlank				; wait for frame to end
		dbf	d0,WaitLoop				; repeat for d0 frames
		rts
