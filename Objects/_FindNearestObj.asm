; ---------------------------------------------------------------------------
; Subroutine to find nearest object to the current one

; input:
;	d0.l = id of object to search for

; output:
;	d5.w = x+y distance ($FFFF if not found)
;	d6.w = address of OST of nearest object (0 if not found)

;	uses d2.w, d3.w, d4.w, d5.l, d6.l, a1

; usage:
;		move.l	#Crabmeat,d0
;		bsr.w	FindNearestObj
;		beq.s	.fail					; branch if no match is found
; ---------------------------------------------------------------------------

FindNearestObj:
		lea	(v_ost_level_obj).w,a1			; start address for OSTs
		move.w	#countof_ost_ert-1,d2
		moveq	#-1,d5					; initial dist = $FFFF
		moveq	#0,d6

	.loop:
		cmp.l	ost_id(a1),d0
		bne.s	.next					; branch if id doesn't match
		move.w	ost_x_pos(a1),d3
		sub.w	ost_x_pos(a0),d3			; d3 = x dist
		abs.w	d3					; make d3 +ve
		move.w	ost_y_pos(a1),d4
		sub.w	ost_y_pos(a0),d4			; d4 = y dist
		abs.w	d4					; make d4 +ve
		add.w	d4,d3					; d3 = sum x+y dist
		
		cmp.w	d3,d5
		bls.s	.next					; branch if not nearer than previous
		move.w	d3,d5					; d5 = new nearest dist
		move.w	a1,d6					; save OST address for new nearest
		
	.next:
		lea	sizeof_ost(a1),a1			; goto next OST
		dbf	d2,.loop				; repeat $5F times

		tst.w	d6
		beq.s	.exit					; branch if no matching objects were found
		move.w	d6,ost_linked(a0)			; save OST address of nearest
		
	.exit:
		rts
