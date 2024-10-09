; ---------------------------------------------------------------------------
; Subroutine to	clear the screen
; Deletes fg/bg nametables and sprite/hscroll buffers

; output:
;	a6 = vdp_control_port ($C00004)

;	uses d0.l, d1.l, a1
; ---------------------------------------------------------------------------

ClearScreen:
		bsr.w	ClearVRAM_Tiles				; clear fg/bg tiles (also sets d2 to 0)
		
		move.l	d2,(v_fg_y_pos_vsram).w
		move.b	d2,(v_spritemask_height).w

		bsr.s	ClearRAM_Sprites			; clear sprite table (in RAM)
		
ClearRAM_HScroll:
		lea	(v_hscroll_buffer).w,a1			; clear hscroll table (in RAM)
		move.w	#loops_to_clear_hscroll,d1

; ---------------------------------------------------------------------------
; Subroutine to	clear RAM

; input:
;	d1.w = (size/4)-1
;	a1 = RAM address to start clearing

;	uses d0.l, d1.w, a1
; ---------------------------------------------------------------------------

ClearRAM:
		moveq	#0,d0
	.loop:
		move.l	d0,(a1)+
		dbf	d1,.loop
		rts
		
ClearRAM_Sprites:
		lea	(v_sprite_buffer).w,a1
		move.w	#loops_to_clear_sprites,d1
		bra.s	ClearRAM
		
; ---------------------------------------------------------------------------
; Subroutine to	clear VRAM

; input:
;	d0.l = VRAM address to start clearing (as VDP instruction)
;	d1.l = bytes to clear (as VDP instruction)

; output:
;	a6 = vdp_control_port ($C00004)

;	uses d0.w, d2.l
; ---------------------------------------------------------------------------

ClearVRAM:
		lea	(vdp_control_port).l,a6
		move.w	#vdp_auto_inc+1,(a6)			; set VDP increment to 1 byte
		move.l	d1,(a6)					; set DMA size
		move.w	#$9780,(a6)				; set DMA mode to fill
		ori.b	#$80,d0
		move.l	d0,(a6)
		moveq	#0,d2					; fill value
		move.w	d2,-4(a6)
	.wait_for_dma:
		move.w	(a6),d0					; get status register
		btst	#dma_status_bit,d0			; is DMA in progress?
		bne.s	.wait_for_dma				; if yes, branch
		move.w	#vdp_auto_inc+2,(a6)			; set VDP increment to 2 bytes
		rts
		
ClearVRAM_Tiles:
		bsr.s	ClearVRAM_Tiles_FG
		
ClearVRAM_Tiles_BG:
		locVRAM	vram_bg,d0
		set_dma_fill_size	sizeof_vram_bg,d1
		bra.s	ClearVRAM
		
ClearVRAM_Tiles_FG:
		locVRAM	vram_fg,d0
		set_dma_fill_size	sizeof_vram_fg,d1
		bra.s	ClearVRAM
		
ClearVRAM_HScroll:
		locVRAM	vram_hscroll,d0
		set_dma_fill_size	sizeof_vram_hscroll,d1
		bra.s	ClearVRAM
