; ---------------------------------------------------------------------------
; Subroutine to	find 256x256 chunk id at position

; input:
;	d0.w = x position
;	d1.w = y position

; output:
;	a2 = address within level layout
;	(a2).b = 256x256 chunk id

;	uses d0.l, d1.w

; usage:
;		ost_x_pos(a0),d0
;		ost_y_pos(a0),d1
;		bsr.w	PosToChunk
;		move.b	(a2),d0					; d0 = $000000nn
; ---------------------------------------------------------------------------

PosToChunk:
		pushr.w	d0
		moveq	#0,d0
		popr.b	d0					; get high byte of x pos (divide by 256)
		;lsr.w	#8,d0
		andi.w	#$FF00,d1
		lsr.w	#1,d1					; d1 = y pos divided by 256, times level width ($80)
		add.w	d0,d1					; d1 = address within layout
		lea	(v_level_layout).w,a2
		adda.w	d1,a2					; jump to RAM address for specific tile within layout
		rts
		