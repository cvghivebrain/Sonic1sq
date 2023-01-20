; ---------------------------------------------------------------------------
; Subroutine to get distance between Sonic and an object
;
; input:
;	a0 = address of OST of object
;
; output:
;	d0.w = x distance (-ve if Sonic is to the left)
;	d1.w = x distance (always +ve)
;	d2.w = y distance (-ve if Sonic is above)
;	d3.w = y distance (always +ve)
;	a1 = address of OST of Sonic
; ---------------------------------------------------------------------------

Range:
		lea	(v_ost_player).w,a1			; get OST of Sonic
		
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0			; d0 = x dist (-ve if Sonic is to the left)
		move.w	d0,d1
		abs.w	d1					; make d1 +ve
		
		move.w	ost_y_pos(a1),d2
		sub.w	ost_y_pos(a0),d2			; d2 = y dist (-ve if Sonic is above)
		move.w	d2,d3
		abs.w	d3					; make d3 +ve
		
		rts
		
; ---------------------------------------------------------------------------
; Subroutine to get distance between Sonic and an object, taking width and
;  height into account
;
; input:
;	a0 = address of OST of object
;
; output:
;	d0.w = x distance (-ve if Sonic is to the left)
;	d1.w = x distance between hitbox edges (-ve if overlapping)
;	d2.w = y distance (-ve if Sonic is above)
;	d3.w = y distance between hitbox edges (-ve if overlapping)
;	d4.b = object height
;	a1 = address of OST of Sonic

;	uses d4.l
; ---------------------------------------------------------------------------

RangePlus:
		lea	(v_ost_player).w,a1			; get OST of Sonic
		moveq	#0,d4
		
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0			; d0 = x dist (-ve if Sonic is to the left)
		move.w	d0,d1
		abs.w	d1					; make d1 +ve
		;move.b	ost_width(a1),d4
		move.b	(v_player1_width).w,d4
		sub.w	d4,d1
		move.b	ost_width(a0),d4
		sub.w	d4,d1					; d1 = x dist between hitbox edges (-ve if overlapping)
		
		move.w	ost_y_pos(a1),d2
		sub.w	ost_y_pos(a0),d2			; d2 = y dist (-ve if Sonic is above)
		move.w	d2,d3
		abs.w	d3					; make d3 +ve
		move.b	ost_height(a1),d4
		sub.w	d4,d3
		move.b	ost_height(a0),d4
		sub.w	d4,d3					; d3 = y dist between hitbox edges (-ve if overlapping)
		
		rts
		