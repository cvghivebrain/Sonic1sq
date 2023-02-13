; ---------------------------------------------------------------------------
; Subroutine to	decompress a tile map to VRAM fg/bg nametable

; input:
;	d0 = VRAM fg/bg nametable address (as VDP command)
;	d1 = width (cells)
;	d2 = height (cells)
;	d3 = tile setting, added to each tile
;	a0 = compressed tile map address
;	a1 = RAM buffer address

; output:
;	a2 = vdp_data_port ($C00000)

;	uses d0, d1, d2, d3, d4, d5, a1
; ---------------------------------------------------------------------------

LoadTilemap:
		bsr.w	KosDec					; decompress to RAM
		lea	(vdp_data_port).l,a2
		sub.w	#1,d1
		sub.w	#1,d2

	.loop_row:
		move.l	d0,4(a2)				; move d0 to vdp_control_port
		move.w	d1,d5					; reset tile counter for new row

	.loop_cell:
		move.w	(a1)+,d4				; get tile
		add.w	d3,d4					; apply tile setting
		move.w	d4,(a2)					; write value to nametable
		dbf	d5,.loop_cell				; next tile
		add.l	#sizeof_vram_row<<16,d0			; goto next line (add $800000)
		dbf	d2,.loop_row				; next line
		rts
		