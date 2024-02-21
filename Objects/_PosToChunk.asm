; ---------------------------------------------------------------------------
; Subroutine to	find 256x256 chunk id at position

; input:
;	d0.w = x position
;	d1.w = y position

; output:
;	a2 = address within level layout
;	(a2).b = 256x256 chunk id

;	uses d2.l, d3.w

; usage:
;		ost_x_pos(a0),d0
;		ost_y_pos(a0),d1
;		bsr.w	PosToChunk
;		move.b	(a2),d2					; d2 = $000000nn
; ---------------------------------------------------------------------------

PosToChunk:
		tst.b	(f_128x128_mode).w
		bne.s	PosToChunk_128				; branch if in 128x128 mode
		
PosToChunk_SkipChk:
		pushr.w	d0
		moveq	#0,d2
		popr.b	d2					; d2 = x pos / width of chunk (256)
		move.w	d1,d3
		andi.w	#$FF00,d3
		lsr.w	#1,d3					; d3 = y pos / width of chunk (256) * level width ($80)
		add.w	d2,d3					; d3 = address within layout
		lea	(v_level_layout).w,a2
		adda.w	d3,a2					; jump to RAM address for specific tile within layout
		rts
		
PosToChunk_128:
		move.w	d0,d2
		lsr.w	#7,d2					; d2 = x pos / width of chunk (128)
		move.w	d1,d3
		andi.w	#$FF00,d3				; d3 = y pos / width of chunk (128) * level width ($80)
		add.w	d2,d3					; d3 = address within layout
		lea	(v_level_layout).w,a2
		adda.w	d3,a2					; jump to RAM address for specific tile within layout
		rts
		
; ---------------------------------------------------------------------------
; Subroutine to	find 16x16 tile id at position

; input:
;	d0.w = x position
;	d1.w = y position

; output:
;	a2 = address within level layout
;	(a2).b = 256x256 chunk id
;	a3 = address within 256x256 mappings
;	(a3).w = 16x16 tile id & flags

;	uses d2.l, d3.w, d4.l

; usage:
;		ost_x_pos(a0),d0
;		ost_y_pos(a0),d1
;		bsr.w	PosToTile
;		move.w	(a3),d0
; ---------------------------------------------------------------------------

PosToTile:
		bsr.s	PosToChunk_SkipChk
		move.b	(a2),d2					; get 256x256 chunk id
		beq.s	.chunk0					; branch if 0
		
		moveq	#-1,d4					; d4 = $FFFFFFFF
		add.w	d2,d2
		move.w	ChunkList(pc,d2.w),d4			; get RAM address of specific 256x256 chunk
		
		move.w	d0,d2					; copy x/y pos
		move.w	d1,d3
		
		andi.w	#$F0,d2					; d2 = x pos within chunk
		lsr.w	#3,d2					; d2 = x pos / tiles per row (16) * bytes per tile (2)
		add.w	d2,d4					; add to base address
		
		andi.w	#$F0,d3					; d3 = y pos within chunk
		add.w	d3,d3					; d3 = y pos / tiles per row (16) * bytes per row (32)
		add.w	d3,d4					; add to base address
		
		movea.l	d4,a3					; RAM address for 16x16 tile within 256x256 mappings
		rts
		
	.chunk0:
		lea	(v_256x256_tiles).l,a3			; $FF0000
		rts

ChunkList:
		c: = -sizeof_256x256
		rept countof_256x256+1
		dc.w c
		c: = c+sizeof_256x256
		endr
