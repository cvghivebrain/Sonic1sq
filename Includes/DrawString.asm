; ---------------------------------------------------------------------------
; Draw string on screen

; input:
;	d0.w = x pos (1 = 8px; 2 = 16px etc.)
;	d1.w = y pos
;	d2.w = x/y flip or palette setting (tile_xflip/tile_yflip/tile_pal2 etc.)
;	a1 = vdp_data_port
;	a2 = address of string, terminated by 0

;	uses d2.b, d3.l, d4.w, a2
; ---------------------------------------------------------------------------

DrawString:
		move.l	#(vram_fg&$3FFF)+((vram_fg&$C000)<<2)+$4000,d3
		add.w	d0,d3
		add.w	d0,d3
		move.w	d1,d4
		mulu.w	#sizeof_vram_row,d4
		add.w	d4,d3					; d3 = address within fg table
		swap	d3					; create VRAM write instruction for VDP
		move.l	d3,4(a1)				; send to vdp_control_port
		
DrawString_SkipVDP:						; jump here to draw directly after previous string
	.loop:
		move.b	(a2)+,d2				; get char
		beq.s	.exit					; branch if 0
		cmpi.b	#$20,d2
		beq.s	.space					; branch if it's a space
		move.w	(v_tile_text).w,d4			; tile address for 0-Z gfx
		subi.w	#$30,d4					; adjust for ASCII starting at 0
		add.w	d2,d4					; create final tile
		move.w	d4,(a1)					; send to vdp_data_port
		bra.s	.loop					; repeat until 0 is reached
		
	.space:
		move.w	#0,(a1)					; write blank tile
		bra.s	.loop
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; As above, except strings are always 8 characters long
; ---------------------------------------------------------------------------

DrawString8:
		move.l	#(vram_fg&$3FFF)+((vram_fg&$C000)<<2)+$4000,d3
		add.w	d0,d3
		add.w	d0,d3
		move.w	d1,d4
		mulu.w	#sizeof_vram_row,d4
		add.w	d4,d3					; d3 = address within fg table
		swap	d3					; create VRAM write instruction for VDP
		move.l	d3,4(a1)				; send to vdp_control_port
		
DrawString8_SkipVDP:						; jump here to draw directly after previous string
		moveq	#8-1,d3
		
	.loop:
		move.b	(a2)+,d2				; get char
		cmpi.b	#$20,d2
		beq.s	.space					; branch if it's a space
		move.w	(v_tile_text).w,d4			; tile address for 0-Z gfx
		subi.w	#$30,d4					; adjust for ASCII starting at 0
		add.w	d2,d4					; create final tile
		move.w	d4,(a1)					; send to vdp_data_port
		dbf	d3,.loop				; repeat for all 8 characters
		rts
		
	.space:
		move.w	#0,(a1)					; write blank tile
		dbf	d3,.loop				; repeat for all 8 characters
		rts
		