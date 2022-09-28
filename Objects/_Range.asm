; ---------------------------------------------------------------------------
; Subroutine to get distance between Sonic and an object
;
; input:
;	a0 = address of OST of object
;
; output:
;	d0 = x distance (-ve if Sonic is to the left)
;	d1 = x distance (always +ve)
;	d2 = y distance (-ve if Sonic is above)
;	d3 = y distance (always +ve)
;	a1 = address of OST of Sonic
; ---------------------------------------------------------------------------

Range:
		lea	(v_ost_player).w,a1			; get OST of Sonic
		
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0			; d0 = x dist (-ve if Sonic is to the left)
		move.w	d0,d1
		bpl.s	.x_not_neg
		neg.w	d1
	.x_not_neg:
		
		move.w	ost_y_pos(a1),d2
		sub.w	ost_y_pos(a0),d2			; d2 = y dist (-ve if Sonic is above)
		move.w	d2,d3
		bpl.s	.y_not_neg
		neg.w	d3
	.y_not_neg:
		
		rts
		
; ---------------------------------------------------------------------------
; Subroutine to get distance between Sonic and an object, taking width and
;  height into account
;
; input:
;	a0 = address of OST of object
;
; output:
;	d0 = x distance (-ve if Sonic is to the left)
;	d1 = x distance between hitbox edges (-ve if overlapping)
;	d2 = y distance (-ve if Sonic is above)
;	d3 = y distance between hitbox edges (-ve if overlapping)
;	a1 = address of OST of Sonic
;	uses d4
; ---------------------------------------------------------------------------

RangePlus:
		lea	(v_ost_player).w,a1			; get OST of Sonic
		moveq	#0,d4
		
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0			; d0 = x dist (-ve if Sonic is to the left)
		move.w	d0,d1
		bpl.s	.x_not_neg
		neg.w	d1
	.x_not_neg:
		move.b	ost_width(a1),d4
		sub.w	d4,d1
		move.b	ost_width(a0),d4
		sub.w	d4,d1					; d1 = x dist between hitbox edges (-ve if overlapping)
		
		move.w	ost_y_pos(a1),d2
		sub.w	ost_y_pos(a0),d2			; d2 = y dist (-ve if Sonic is above)
		move.w	d2,d3
		bpl.s	.y_not_neg
		neg.w	d3
	.y_not_neg:
		move.b	ost_height(a1),d4
		sub.w	d4,d3
		move.b	ost_height(a0),d4
		sub.w	d4,d3					; d3 = y dist between hitbox edges (-ve if overlapping)
		
		rts
		