; ---------------------------------------------------------------------------
; Subroutine to	decompress a tile map to VRAM fg/bg nametable

; input:
;	d0.l = VRAM fg/bg nametable address (as VDP command)
;	d1.w = width (cells)
;	d2.w = height (cells)
;	d3.w = tile setting, added to each tile
;	a0 = compressed tile map address
;	a1 = RAM buffer address

; output:
;	a2 = vdp_data_port ($C00000)

;	uses d0.l, d1.w, d2.w, d4.w, d5.w, a1
; ---------------------------------------------------------------------------

LoadTilemap:
		bsr.w	KosDec					; decompress to RAM
		lea	(vdp_data_port).l,a2
		subq.w	#1,d1
		subq.w	#1,d2

	.loop_row:
		move.l	d0,4(a2)				; move d0 to vdp_control_port
		move.w	d1,d5					; reset tile counter for new row

	.loop_cell:
		move.w	(a1)+,d4				; get tile
		add.w	d3,d4					; apply tile setting
		move.w	d4,(a2)					; write value to nametable
		dbf	d5,.loop_cell				; next tile
		addi.l	#sizeof_vram_row<<16,d0			; goto next line (add $800000)
		dbf	d2,.loop_row				; next line
		rts
		
