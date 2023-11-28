; ---------------------------------------------------------------------------
; Subroutine to find nearest object to the current one

; input:
;	d0.l = id of object to search for

; output:
;	d1.w = address of OST of nearest object (0 if not found)
;	d5.w = x+y distance ($FFFF if not found)

;	uses d1.l, d2.w, d3.w, d4.w, d5.l, a1

; usage:
;		move.l	#Crabmeat,d0
;		bsr.w	FindNearestObj
;		beq.s	.fail					; branch if no match is found
; ---------------------------------------------------------------------------

FindNearestObj:
		lea	(v_ost_level_obj).w,a1			; start address for OSTs
		move.w	#countof_ost_ert-1,d2
		moveq	#-1,d5					; initial dist = $FFFF
		moveq	#0,d1

	.loop:
		cmp.l	ost_id(a1),d0
		bne.s	.next					; branch if id doesn't match
		move.w	ost_x_pos(a1),d3
		sbabs.w	ost_x_pos(a0),d3			; d3 = x dist
		move.w	ost_y_pos(a1),d4
		sbabs.w	ost_y_pos(a0),d4			; d4 = y dist
		add.w	d4,d3					; d3 = sum x+y dist
		
		cmp.w	d3,d5
		bls.s	.next					; branch if not nearer than previous
		move.w	d3,d5					; d5 = new nearest dist
		move.w	a1,d1					; save OST address for new nearest
		
	.next:
		lea	sizeof_ost(a1),a1			; goto next OST
		dbf	d2,.loop				; repeat $5F times

		move.w	d1,ost_linked(a0)			; save OST address of nearest (or 0 if not found)
		rts

; ---------------------------------------------------------------------------
; As above, but finds nearest to Sonic instead of local object

;	uses d2.w, d3.w, d4.w, d5.l, d6.l, a1, a2
; ---------------------------------------------------------------------------

FindNearestSonic:
		lea	(v_ost_player).w,a2
		lea	(v_ost_level_obj).w,a1			; start address for OSTs
		move.w	#countof_ost_ert-1,d2
		moveq	#-1,d5					; initial dist = $FFFF
		moveq	#0,d6

	.loop:
		tst.l	ost_id(a1)
		beq.s	.next					; branch if there isn't an object in this OST
		move.w	ost_x_pos(a1),d3
		sbabs.w	ost_x_pos(a2),d3			; d3 = x dist
		move.w	ost_y_pos(a1),d4
		sbabs.w	ost_y_pos(a2),d4			; d4 = y dist
		add.w	d4,d3					; d3 = sum x+y dist
		
		cmp.w	d3,d5
		bls.s	.next					; branch if not nearer than previous
		move.w	d3,d5					; d5 = new nearest dist
		move.w	a1,d6					; save OST address for new nearest
		
	.next:
		lea	sizeof_ost(a1),a1			; goto next OST
		dbf	d2,.loop				; repeat $5F times

		move.w	d6,ost_linked(a0)			; save OST address of nearest (or 0 if not found)
		move.w	d6,(v_nearest_obj).w
		rts
		