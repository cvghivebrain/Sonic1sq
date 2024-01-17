; ---------------------------------------------------------------------------
; Subroutine to create explosions around an object

; input:
;	d0.b = frame offset delay
;	d1.b = bitmask used for frequency (7 = every 8th frame)

;	uses d0.l, d1.l, a1
; ---------------------------------------------------------------------------

Exploding:
		add.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		and.b	d1,d0					; read bits from bitmask
		bne.s	.exit					; branch if any are set
		jsr	FindFreeObj				; find free OST slot
		bne.s	.exit					; branch if not found
		move.l	#ExplosionBomb,ost_id(a1)		; load explosion object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		jsr	(RandomNumber).w
		andi.w	#$3F,d1
		subi.w	#$20,d1					; d1 = -$20 to $1F
		add.w	d1,ost_x_pos(a1)
		andi.w	#$1F,d0					; d0 = 0 to $1F
		add.w	d0,ost_y_pos(a1)			; randomise position
		
	.exit:
		rts
		
