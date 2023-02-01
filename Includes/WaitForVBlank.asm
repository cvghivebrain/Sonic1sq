; ---------------------------------------------------------------------------
; Subroutine to	wait for VBlank routines to complete
; ---------------------------------------------------------------------------

WaitForVBlank_CPU:
		pushr	d0-d3/a2
		move.w	(vdp_counter).l,d0			; get HV counter
		lsr.w	#8,d0					; get vertical position
		set_dma_dest	$DF40,d1			; VRAM address
		jsr	HUD_ShowByte				; update CPU usage monitor
		popr	d0-d3/a2

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
