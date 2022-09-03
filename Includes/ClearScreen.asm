; ---------------------------------------------------------------------------
; Subroutine to	clear the screen
; Deletes fg/bg nametables and sprite/hscroll buffers

; output:
;	a5 = vdp_control_port ($C00004)

;	uses d0, d1, a1
; ---------------------------------------------------------------------------

ClearScreen:
		locVRAM	vram_fg,d0
		move.l	#sizeof_vram_fg-1,d1
		moveq	#0,d2
		bsr.w	ClearVRAM

		locVRAM	vram_bg,d0
		move.l	#sizeof_vram_bg-1,d1
		moveq	#0,d2
		bsr.w	ClearVRAM
		
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
		
; ---------------------------------------------------------------------------
; Subroutine to	clear VRAM

; input:
;	d0 = VRAM address to start clearing (as VDP instruction)
;	d1 = bytes to clear
;	d2 = byte value to fill with (usually 0)

; output:
;	a5 = vdp_control_port ($C00004)

;	uses d1
; ---------------------------------------------------------------------------

ClearVRAM:
		lea	(vdp_control_port).l,a5
		move.w	#$8F01,(a5)				; set VDP increment to 1 byte
		lsl.l	#8,d1					; move high byte into high word
		lsr.w	#8,d1					; move low byte back
		add.l	#$94009300,d1				; apply VDP registers
		move.l	d1,(a5)
		move.w	#$9780,(a5)				; set DMA mode to fill
		add.w	#$80,d0
		move.l	d0,(a5)
		lsl.w	#8,d2					; move fill value to high byte
		move.w	d2,(vdp_data_port).l
	.wait_for_dma:
		move.w	(a5),d1					; get status register
		btst	#1,d1					; is DMA in progress?
		bne.s	.wait_for_dma				; if yes, branch
		move.w	#$8F02,(a5)				; set VDP increment to 2 bytes
		rts
		