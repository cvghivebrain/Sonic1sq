; ---------------------------------------------------------------------------
; Subroutine to sink object slightly when stood on

; input:
;	d0.w = y position without sink applied

;	uses d0.w, d1.l

; usage:
;		move.w	ost_cork_y_pos(a0),d0
;		bsr.w	Sink
; ---------------------------------------------------------------------------

Sink:
		tst.b	ost_mode(a0)
		bne.s	.standing_on				; branch if object is being stood on
		tst.b	ost_sink(a0)
		beq.s	.default				; branch if object is in default position
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
		add.w	Sink_Data(pc,d1.w),d0
		
.default:
		move.w	d0,ost_y_pos(a0)			; update position
		rts
		
Sink_Data:
		dc.w 0,0,0,1,1,1,2,2
		dc.w 2,3,3,3,3,3,3,4
		
; ---------------------------------------------------------------------------
; As above, but for the large grass platform in MZ
; ---------------------------------------------------------------------------

SinkBig:
		btst	#status_platform_bit,ost_status(a0)
		bne.s	.standing_on				; branch if object is being stood on
		tst.b	ost_sink(a0)
		beq.s	.default				; branch if object is in default position
		subq.b	#2,ost_sink(a0)				; incrementally return block to default
		bra.s	.update_y
; ===========================================================================

.standing_on:
		cmpi.b	#$40,ost_sink(a0)
		beq.s	.update_y				; branch if at maximum sink level
		addq.b	#4,ost_sink(a0)				; keep sinking

.update_y:
		moveq	#0,d1
		move.b	ost_sink(a0),d1
		add.w	SinkBig_Data(pc,d1.w),d0
		
.default:
		move.w	d0,ost_y_pos(a0)			; update position
		rts
		
SinkBig_Data:
		dc.w 0,0,1,2,3,3,4,5
		dc.w 6,6,7,8,8,9,10,10
		dc.w 11,11,12,12,13,13,14,14
		dc.w 14,15,15,15,15,15,15,15
		dc.w 16
		
