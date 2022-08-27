; ---------------------------------------------------------------------------
; Subroutine to	clear the screen
; Deletes fg/bg nametables and sprite/hscroll buffers

; input:
;	a5 = vdp_control_port ($C00004)

;	uses d0, d1, a1
; ---------------------------------------------------------------------------

ClearScreen:
		dma_fill	0,sizeof_vram_fg-1,vram_fg	; clear foreground nametable

	.wait_for_dma:
		move.w	(a5),d1					; get status register (a5 = vdp_control_port)
		btst	#1,d1					; is DMA in progress?
		bne.s	.wait_for_dma				; if yes, branch

		move.w	#$8F02,(a5)				; set VDP increment 2 bytes
		dma_fill	0,sizeof_vram_bg-1,vram_bg	; clear background nametable

	.wait_for_dma2:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	.wait_for_dma2

		move.w	#$8F02,(a5)				; set VDP increment 2 bytes
		clr.l	(v_fg_y_pos_vsram).w

		lea	(v_sprite_buffer).w,a1
		move.w	#loops_to_clear_sprites,d1
		bsr.s	ClearRAM				; clear sprite table (in RAM)

		lea	(v_hscroll_buffer).w,a1
		move.w	#loops_to_clear_hscroll,d1

; ---------------------------------------------------------------------------
; Subroutine to	clear RAM

; input:
;	a1 = RAM address to start clearing
;	d1 = (size/4)-1

;	uses d0, d1, a1
; ---------------------------------------------------------------------------

ClearRAM:
		moveq	#0,d0
	.loop:
		move.l	d0,(a1)+
		dbf	d1,.loop
		rts
		