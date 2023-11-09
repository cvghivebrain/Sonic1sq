; ---------------------------------------------------------------------------
; Subroutine to find the distance of an object to the floor

; Runs FindFloor without the need for inputs, taking inputs from local OST variables

; input:
;	d3.w = x position of object (FindFloorObj2 only)

; output:
;	d1.w = distance to the floor
;	d3.b = floor angle
;	a3 = address within 256x256 mappings where object is standing
;	(a3).w = 16x16 tile number, x/yflip, solidness
;	(a4).b = floor angle

;	uses d0.w, d2.w, d4.w, d5.l, d6.w
; ---------------------------------------------------------------------------

FindFloorObj:
		move.w	ost_x_pos(a0),d3


FindFloorObj2:
		move.w	ost_y_pos(a0),d2
		moveq	#0,d0
		move.b	ost_height(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos of bottom edge
		move.w	#0,d6
		moveq	#tilemap_solid_top_bit,d5		; bit to test for solidness
		lea	(v_angle_right).w,a4			; write angle here
		bsr.w	FindFloor
		btst	#0,d3					; is angle snap bit set?
		beq.s	.no_snap
		move.b	#0,d3					; snap to flat floor

	.no_snap:
		addi.w	#1,d1
		rts
		
SnapFloor:
		bsr.s	FindFloorObj
		tst.w	d1
		bmi.s	.found					; branch if touching the floor
		addi.w	#16,ost_y_pos(a0)			; try 16px lower
		bsr.s	FindFloorObj
		tst.w	d1
		bmi.s	.found
		addi.w	#16,ost_y_pos(a0)			; try 32px lower
		bsr.s	FindFloorObj
		tst.w	d1
		bmi.s	.found
		bra.w	DeleteObject				; delete object if floor not found within 48px
		
	.found:
		add.w	d1,ost_y_pos(a0)			; align to floor
		rts

; ---------------------------------------------------------------------------
; Subroutine to find the distance of an object to the wall to its right

; Runs FindWall without the need for inputs, taking inputs from local OST variables

; output:
;	d1.w = distance to the wall
;	d3.b = wall angle
;	a3 = address within 256x256 mappings where object is standing
;	(a3).w = 16x16 tile number, x/yflip, solidness
;	(a4).b = wall angle

;	uses d0.w, d3.w, d4.w, d5.l, d6.w
; ---------------------------------------------------------------------------

FindWallRightObj:
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_width(a0),d0
		add.w	d0,d3
		move.w	ost_y_pos(a0),d2
		move.w	#0,d6
		moveq	#tilemap_solid_lrb_bit,d5		; bit to test for solidness
		lea	(v_angle_right).w,a4			; write angle here
		bsr.w	FindWall
		btst	#0,d3					; is angle snap bit set?
		beq.s	.no_snap
		move.b	#$C0,d3					; snap to flat right wall

	.no_snap:
		rts

; ---------------------------------------------------------------------------
; Subroutine to find the distance of an object to the ceiling

; Runs FindFloor without the need for inputs, taking inputs from local OST variables

; output:
;	d1.w = distance to the ceiling
;	d3.b = ceiling angle
;	a3 = address within 256x256 mappings where object is standing
;	(a3).w = 16x16 tile number, x/yflip, solidness
;	(a4).b = ceiling angle

;	uses d0.w, d2.w, d4.w, d5.l, d6.w
; ---------------------------------------------------------------------------

FindCeilingObj:
		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_height(a0),d0
		ext.w	d0
		sub.w	d0,d2					; d2 = y pos of top edge
		eori.w	#$F,d2
		move.w	#tilemap_yflip,d6			; eor mask
		moveq	#tilemap_solid_lrb_bit,d5		; bit to test for solidness
		lea	(v_angle_right).w,a4			; write angle here
		bsr.w	FindCeiling
		btst	#0,d3					; is angle snap bit set?
		beq.s	.no_snap
		move.b	#$80,d3					; snap to flat ceiling

	.no_snap:
		rts
		
SnapCeiling:
		bsr.s	FindCeilingObj
		tst.w	d1
		bpl.s	.exit					; branch if not touching the ceiling
		sub.w	d1,ost_y_pos(a0)			; align to ceiling
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to find the distance of an object to the wall to its left

; Runs FindWall without the need for inputs, taking inputs from local OST variables

; output:
;	d1.w = distance to the wall
;	d3.b = wall angle
;	a3 = address within 256x256 mappings where object is standing
;	(a3).w = 16x16 tile number, x/yflip, solidness
;	(a4).b = wall angle

;	uses d0.w, d3.w, d4.w, d5.l, d6.w
; ---------------------------------------------------------------------------

FindWallLeftObj:
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_width(a0),d0
		sub.w	d0,d3
		move.w	ost_y_pos(a0),d2
		eori.w	#$F,d3					; enable this line to fix bug
		move.w	#tilemap_xflip,d6			; eor mask
		moveq	#tilemap_solid_lrb_bit,d5		; bit to test for solidness
		lea	(v_angle_right).w,a4			; write angle here
		bsr.w	FindWallLeft
		btst	#0,d3					; is angle snap bit set?
		beq.s	.no_snap
		move.b	#$40,d3					; snap to flat left wall

	.no_snap:
		rts
