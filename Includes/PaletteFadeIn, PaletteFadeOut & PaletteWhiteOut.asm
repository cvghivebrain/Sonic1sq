; ---------------------------------------------------------------------------
; Subroutine to	fade in from black or white
; ---------------------------------------------------------------------------

PaletteFadeIn:
		tst.w	(v_brightness).w
		beq.s	.exit					; branch if at default brightness
		bmi.s	.increase				; branch if < 0
		
		subq.w	#1,(v_brightness).w			; decrease brightness
		move.b	#1,(f_brightness_update).w		; set flag to update
		move.b	#id_VBlank_Fade,(v_vblank_routine).w
		bsr.w	WaitForVBlank				; wait for frame to end
		bra.s	PaletteFadeIn
		
	.increase:
		addq.w	#1,(v_brightness).w			; increase brightness
		move.b	#1,(f_brightness_update).w		; set flag to update
		move.b	#id_VBlank_Fade,(v_vblank_routine).w
		bsr.w	WaitForVBlank				; wait for frame to end
		bra.s	PaletteFadeIn
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to fade out to black
; ---------------------------------------------------------------------------

PaletteFadeOut:
		cmpi.w	#-brightness_range,(v_brightness).w
		beq.s	.exit					; branch if at minimum brightness
		subq.w	#1,(v_brightness).w			; decrease brightness
		move.b	#1,(f_brightness_update).w		; set flag to update
		move.b	#id_VBlank_Fade,(v_vblank_routine).w
		bsr.w	WaitForVBlank				; wait for frame to end
		bra.s	PaletteFadeOut
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to fade to white (Special Stage)
; ---------------------------------------------------------------------------

PaletteWhiteOut:
		cmpi.w	#brightness_range,(v_brightness).w
		beq.s	.exit					; branch if at maximum brightness
		addq.w	#1,(v_brightness).w			; increase brightness
		move.b	#1,(f_brightness_update).w		; set flag to update
		move.b	#id_VBlank_Fade,(v_vblank_routine).w
		bsr.w	WaitForVBlank				; wait for frame to end
		bra.s	PaletteWhiteOut
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to decrease brightness
; ---------------------------------------------------------------------------

Darken:
		cmpi.w	#-brightness_range,(v_brightness).w	; is brightness at minimum?
		beq.s	.exit					; branch if yes
		subq.w	#1,(v_brightness).w			; increase brightness
		move.b	#1,(f_brightness_update).w		; set flag to update
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to increase brightness
; ---------------------------------------------------------------------------

Brighten:
		cmpi.w	#brightness_range,(v_brightness).w	; is brightness at maximum?
		beq.s	.exit					; branch if yes
		addq.w	#1,(v_brightness).w			; increase brightness
		move.b	#1,(f_brightness_update).w		; set flag to update
		
	.exit:
		rts
		
