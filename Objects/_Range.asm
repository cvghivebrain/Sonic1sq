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
		bsr.s	RangeX
		bra.s	RangeY2

RangeX:
		lea	(v_ost_player).w,a1			; get OST of Sonic
		
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0			; d0 = x dist (-ve if Sonic is to the left)
		mvabs.w	d0,d1					; make d1 +ve
		rts
		
RangeY:
		lea	(v_ost_player).w,a1			; get OST of Sonic
		
RangeY2:
		move.w	ost_y_pos(a1),d2
		sub.w	ost_y_pos(a0),d2			; d2 = y dist (-ve if Sonic is above)
		mvabs.w	d2,d3					; make d3 +ve		
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
;	d4.w = x position of Sonic on object, starting at 0 on left edge
;	a1 = address of OST of Sonic

;	uses d4.l, d5.l
; ---------------------------------------------------------------------------

RangePlus:
		bsr.s	RangePlusX
		bra.s	RangePlusY2

RangePlusX:
		lea	(v_ost_player).w,a1			; get OST of Sonic
		
		moveq	#0,d4
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0			; d0 = x dist (-ve if Sonic is to the left)
		mvabs.w	d0,d1					; make d1 +ve
		move.b	(v_player1_width).w,d4			; use fixed player width
		sub.w	d4,d1
		move.b	ost_width(a0),d4
		sub.w	d4,d1					; d1 = x dist between hitbox edges (-ve if overlapping)
		add.w	d0,d4					; d4 = Sonic's x pos relative to left edge
		
		subq.w	#2,d1
		rts
		
RangePlusY:
		lea	(v_ost_player).w,a1			; get OST of Sonic
		
RangePlusY2:
		moveq	#0,d5
		move.w	ost_y_pos(a1),d2
		sub.w	ost_y_pos(a0),d2			; d2 = y dist (-ve if Sonic is above)
		mvabs.w	d2,d3					; make d3 +ve
		move.b	ost_height(a1),d5
		sub.w	d5,d3
		move.b	ost_height(a0),d5
		sub.w	d5,d3					; d3 = y dist between hitbox edges (-ve if overlapping)
		
		subq.w	#1,d3
		rts
		
RangePlusX_NoPlayerWidth:
		lea	(v_ost_player).w,a1			; get OST of Sonic
		
		moveq	#0,d4
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0			; d0 = x dist (-ve if Sonic is to the left)
		mvabs.w	d0,d1					; make d1 +ve
		move.b	ost_width(a0),d4
		sub.w	d4,d1					; d1 = x dist between hitbox edges (-ve if overlapping)
		add.w	d0,d4					; d4 = Sonic's x pos relative to left edge
		rts
		
; ---------------------------------------------------------------------------
; As above, using a heightmap instead of ost_height
;
; input:
;	d6.l = resolution of heightmap (0 = 1px per byte; 1 = 2px; 2 = 4px; 3 = 8px)
;	a0 = address of OST of object
;	a2 = address of heightmap
;
; output:
;	d0.w = x distance (-ve if Sonic is to the left)
;	d1.w = x distance between hitbox edges (-ve if overlapping)
;	d2.w = y distance (-ve if Sonic is above)
;	d3.w = y distance between hitbox edges (-ve if overlapping)
;	d4.w = x position of Sonic on object, starting at 0 on left edge
;	a1 = address of OST of Sonic

;	uses d4.l, d5.l
; ---------------------------------------------------------------------------

RangePlus_Heightmap:
		getsonic
		range_x_sonic
		cmp.w	#0,d1
		bgt.s	.outside_x				; branch if outside x hitbox
		
		moveq	#0,d5
		move.w	ost_y_pos(a1),d2
		sub.w	ost_y_pos(a0),d2			; d2 = y dist (-ve if Sonic is above)
		mvabs.w	d2,d3					; make d3 +ve
		tst.w	d2
		bmi.s	.use_heightmap				; branch if Sonic is above object
		move.b	ost_height(a0),d5			; use regular height if below
		bra.s	.skip_heightmap
		
	.use_heightmap:
		tst.w	d4
		bmi.s	.left_edge				; branch if outside left edge (d5 stays 0)
		move.w	d4,d5					; d5 = x pos on object
		lsr.w	d6,d5					; reduce precision
		
	.left_edge:
		move.b	(a2,d5.w),d5				; get height byte from heightmap
		andi.w	#$FF,d5
		
	.skip_heightmap:
		sub.w	d5,d3
		move.b	ost_height(a1),d5
		sub.w	d5,d3					; d3 = y dist between hitbox edges (-ve if overlapping)
		
		subq.w	#1,d3
		rts
		
	.outside_x:
		moveq	#1,d3					; d3 = arbitrary +ve number
		rts

RangePlus_Heightmap_NoPlayerWidth:
		getsonic
		range_x_sonic0
		cmp.w	#0,d1
		bgt.s	.outside_x				; branch if outside x hitbox
		
		moveq	#0,d5
		move.w	ost_y_pos(a1),d2
		sub.w	ost_y_pos(a0),d2			; d2 = y dist (-ve if Sonic is above)
		mvabs.w	d2,d3					; make d3 +ve
		tst.w	d4
		bmi.s	.left_edge				; branch if outside left edge (d5 stays 0)
		move.w	d4,d5					; d5 = x pos on object
		lsr.w	d6,d5					; reduce precision
		
	.left_edge:
		move.b	(a2,d5.w),d5				; get height byte from heightmap
		andi.w	#$FF,d5
		sub.w	d5,d3
		move.b	ost_height(a1),d5
		sub.w	d5,d3					; d3 = y dist between hitbox edges (-ve if overlapping)
		
		subq.w	#1,d3
		rts
		
	.outside_x:
		moveq	#1,d3					; d3 = arbitrary +ve number
		rts
		