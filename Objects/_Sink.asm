; ---------------------------------------------------------------------------
; Subroutine to sink object slightly when stood on

; input:
;	d0 = y position without sink applied

;	uses d0, d1, a1
; ---------------------------------------------------------------------------

Sink:
		btst	#status_platform_bit,ost_status(a0)
		bne.s	.standing_on				; branch if object is being stood on
		tst.b	ost_sink(a0)
		beq.s	.update_y				; branch if object is in default position
		subq.b	#2,ost_sink(a0)				; incrementally return block to default
		bra.s	.update_y
; ===========================================================================

.standing_on:
		cmpi.b	#$1E,ost_sink(a0)
		beq.s	.update_y				; branch if at maximum sink level
		addq.b	#2,ost_sink(a0)				; keep sinking

.update_y:
		moveq	#0,d1
		move.b	ost_sink(a0),d1
		lea	Sink_Data(pc),a1
		add.w	(a1,d1.w),d0
		move.w	d0,ost_y_pos(a0)			; update position
		rts
		
Sink_Data:
		dc.w 0,0,0,1,1,1,2,2
		dc.w 2,3,3,3,3,3,3,4
		even
		