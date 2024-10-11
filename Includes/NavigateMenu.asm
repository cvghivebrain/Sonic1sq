; ---------------------------------------------------------------------------
; Navigate a simple text menu

; input:
;	d0.w = number of items in menu
;	d1.w = items per column
;	(a1).w = current position in menu

; output:
;	d2.l = 1 if any direction pressed; 0 if otherwise

;	uses d3.l
; ---------------------------------------------------------------------------

NavigateMenu:
		move.b	(v_joypad_press_actual).w,d2
		andi.b	#btnDir,d2
		bne.s	.input					; branch if direction is pressed
		rts
		
	.input:
		moveq	#0,d3
		move.w	(a1),d3
		btst	#bitDn,d2
		bne.s	Nav_Down				; branch if down is pressed
		btst	#bitUp,d2
		bne.s	Nav_Up					; branch if up is pressed
		btst	#bitR,d2
		bne.s	Nav_Right				; branch if right is pressed
		
	Nav_Left:
		sub.w	d1,(a1)					; jump to previous column
		bpl.s	Nav_Valid				; branch if valid
		bsr.s	RoundUp					; d2 = number of items rounded up
		divu.w	d1,d3
		swap	d3					; d3 = item within column
		add.w	d2,d3
		sub.w	d1,d3
		move.w	d3,(a1)					; wrap to end
		cmp.w	(a1),d0
		bhi.s	Nav_Valid				; branch if valid (i.e. not past the end of an incomplete column)
		sub.w	d1,(a1)					; jump to previous complete column
		moveq	#1,d2					; set flag
		rts
	
	Nav_Right:
		add.w	d1,(a1)					; jump to next column
		cmp.w	(a1),d0
		bhi.s	Nav_Valid				; branch if valid
		divu.w	d1,d3
		swap	d3					; d3 = item within column
		move.w	d3,(a1)					; wrap to first column
		moveq	#1,d2					; set flag
		rts
	
	Nav_Down:
		addq.w	#1,(a1)
		cmp.w	(a1),d0
		bhi.s	Nav_Valid				; branch if valid
		clr.w	(a1)					; wrap to start
		
	Nav_Valid:
		moveq	#1,d2					; set flag
		rts
		
	Nav_Up:
		subq.w	#1,(a1)
		bpl.s	Nav_Valid				; branch if valid
		move.w	d0,(a1)					; wrap to end
		subq.w	#1,(a1)
		moveq	#1,d2					; set flag
		rts

; ---------------------------------------------------------------------------
; As above, but with left/right disabled
; ---------------------------------------------------------------------------

NavigateMenu_NoLR:
		move.b	(v_joypad_press_actual).w,d2
		andi.b	#btnUp+btnDn,d2
		bne.s	.input					; branch if direction is pressed
		rts
		
	.input:
		moveq	#0,d3
		move.w	(a1),d3
		btst	#bitDn,d2
		bne.s	Nav_Down				; branch if down is pressed
		bra.s	Nav_Up

; ---------------------------------------------------------------------------
; Round up an integer to next multiple

; input:
;	d0.w = integer
;	d1.w = multiple

; output:
;	d2.w = rounded integer
; ---------------------------------------------------------------------------

RoundUp:
		moveq	#0,d2
		move.w	d0,d2
		divu.w	d1,d2					; divide by multiple
		swap	d2					; move remainder to low word
		tst.w	d2
		beq.s	.already_round				; branch if it was already round
		neg.w	d2
		add.w	d0,d2
		add.w	d1,d2					; round up
		rts
		
	.already_round:
		move.w	d0,d2					; return original integer
		rts
		