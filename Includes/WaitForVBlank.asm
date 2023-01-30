; ---------------------------------------------------------------------------
; Subroutine to	wait for VBlank routines to complete
; ---------------------------------------------------------------------------

WaitForVBlank:
		enable_ints

	.wait:
		tst.b	(v_vblank_routine).w			; has VBlank routine finished?
		bne.s	.wait					; if not, branch
		rts

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
