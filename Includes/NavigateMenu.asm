; ---------------------------------------------------------------------------
; Navigate a simple text menu

; input:
;	d0.w = number of items in menu
;	d1.w = items per column
;	(a1).w = current position in menu

; output:
;	d2.l = 1 if any direction pressed; 0 if otherwise
; ---------------------------------------------------------------------------

NavigateMenu:
		move.b	(v_joypad_press_actual).w,d2
		andi.b	#btnDir,d2
		bne.s	.input					; branch if direction is pressed
		rts
		
	.input:
		btst	#bitDn,d2
		bne.s	.down					; branch if down is pressed
		btst	#bitUp,d2
		bne.s	.up					; branch if up is pressed
		btst	#bitR,d2
		bne.s	.right					; branch if right is pressed
		
	.left:
		sub.w	d1,(a1)					; jump to previous column
		bpl.s	.down_ok				; branch if valid
		add.w	d0,(a1)					; wrap to end
		cmp.w	(a1),d0
		bhi.s	.down_ok				; branch if valid (i.e. not past the end of an incomplete column)
		sub.w	d1,(a1)					; jump to previous complete column
		moveq	#1,d2					; set flag
		rts
	
	.right:
		add.w	d1,(a1)					; jump to next column
		cmp.w	(a1),d0
		bhi.s	.down_ok				; branch if valid
		sub.w	d0,(a1)					; wrap to first column
		moveq	#1,d2					; set flag
		rts
	
	.down:
		addq.w	#1,(a1)
		cmp.w	(a1),d0
		bhi.s	.down_ok				; branch if valid
		clr.w	(a1)					; wrap to start
		
	.down_ok:
		moveq	#1,d2					; set flag
		rts
		
	.up:
		subq.w	#1,(a1)
		bpl.s	.down_ok				; branch if valid
		move.w	d0,(a1)					; wrap to end
		subq.w	#1,(a1)
		moveq	#1,d2					; set flag
		rts
