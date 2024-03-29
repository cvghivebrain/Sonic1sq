; ---------------------------------------------------------------------------
; Subroutine to	find distance to floor at position

; input:
;	d0.w = x position
;	d1.w = y position
;	d6.w = max number of tiles to check (0 = 1; 1 = 2...)

; output:
;	d4.w = 16x16 tile id & flags
;	d5.w = distance to floor (-ve if below floor)
;	a2 = address within level layout
;	(a2).b = 256x256 chunk id
;	a3 = address within 256x256 mappings
;	(a3).w = 16x16 tile id & flags
;	a4 = address of collision index for this level

;	uses d1.w, d2.l, d3.l, d4.l, d5.l, d6.w, a5

; usage:
;		ost_x_pos(a0),d0
;		ost_y_pos(a0),d1
;		moveq	#1,d6
;		bsr.w	FloorDist
; ---------------------------------------------------------------------------

FloorDist:
		moveq	#0,d5
		
	.loop:
		bsr.w	PosToTile				; (a3).w = 16x16 tile id
		move.w	(a3),d4					; d4 = tile id with flags  256: 0SSY X0II IIII IIII; 128: SSTT YXII IIII IIII
		btst	#tilemap_solid_top_bit,d4
		beq.s	.chk_below				; branch if tile isn't top solid
		move.w	d4,d2
		andi.w	#$7FF,d2				; ignore flags
		beq.s	.chk_below				; branch if tile is blank
		movea.l	(v_collision_index_ptr).w,a4
		moveq	#0,d3
		move.b	(a4,d2.w),d3				; get collision heightmap id
		lsl.w	#4,d3					; multiply by bytes per tile heightmap (16)
		
		move.w	d0,d2					; copy x pos
		btst	#tilemap_xflip_bit,d4
		beq.s	.noxflip				; branch if not xflipped
		not.w	d2
		
	.noxflip:
		andi.w	#$F,d2					; get x pos within 16x16 tile
		add.w	d2,d3					; d3 = offset within whole heightmap
		lea	(CollArray1).l,a5
		move.b	(a5,d3.w),d3				; d3 = actual height value from heightmap
		beq.s	.chk_below				; branch if height is 0
		ext.w	d3
		btst	#tilemap_yflip_bit,d4
		beq.s	.noyflip				; branch if not yflipped
		neg.w	d3
		
	.noyflip:
		cmpi.w	#16,d3
		bcs.s	.height_ok				; branch if height is between 1 and 15
		moveq	#16,d3					; force height to be 16px (was already -ve or 16)
		tst.w	d5
		bgt.s	.height_ok				; branch if previously checked below (object is above floor)
		
	.chk_above:
		subi.w	#16,d1					; 16px above
		subi.w	#16,d5					; 16px -ve distance
		dbf	d6,.loop				; check tile above this one
		rts
		
	.height_ok:
		move.w	d1,d2					; copy y pos
		andi.w	#$F,d2					; get y pos within 16x16 tile
		add.w	d3,d2
		moveq	#16,d3
		sub.w	d2,d3					; d3 = dist between object & ground (-ve if overlapping)
		add.w	d3,d5					; d5 = total distance
		rts
		
	.chk_below:
		tst.w	d5
		bmi.s	.under_floor				; branch if tile below was previously checked
		addi.w	#16,d1					; 16px below
		addi.w	#16,d5					; add 16px to distance
		dbf	d6,.loop				; check tile below this one
		rts
		
	.under_floor:
		move.w	d1,d3					; copy y pos
		andi.w	#$F,d3					; get y pos within 16x16 tile
		sub.w	d3,d5					; object is < 16px under floor
		addi.w	#16,d5
		rts
		
; ---------------------------------------------------------------------------
; Subroutine to	find angle of floor

; input:
;	d4.w = 16x16 tile id & flags
;	a4 = address of collision index for this level

; output:
;	d2.b = angle

;	uses d2.l, a4

; usage:
;		ost_x_pos(a0),d0
;		ost_y_pos(a0),d1
;		moveq	#1,d6
;		bsr.w	FloorDist
;		bsr.w	FloorAngle
;		move.b	d2,ost_angle(a0)
; ---------------------------------------------------------------------------

FloorAngle:
		move.w	d4,d2
		andi.w	#$7FF,d2				; 16x16 tile id only
		moveq	#0,d2
		move.b	(a4,d2.w),d2				; get collision id
		beq.s	.exit					; branch if 0
		lea	(AngleMap).l,a4
		move.b	(a4,d2.w),d2				; get collision angle value
		btst	#tilemap_xflip_bit,d4
		beq.s	.no_xflip				; branch if not xflipped
		neg.b	d2					; xflip angle

	.no_xflip:
		btst	#tilemap_yflip_bit,d4
		beq.s	.no_yflip				; branch if not yflipped
		addi.b	#$40,d2
		neg.b	d2
		subi.b	#$40,d2					; yflip angle

	.no_yflip:
		btst	#0,d2
		beq.s	.exit					; branch if snap bit isn't set
		addi.b	#$20,d2
		andi.b	#$C0,d2					; snap to 90 degree angle
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to snap a new object to the floor

;	uses d0.w, d1.l, d2.l, d3.l, d4.l, d5.l, d6.l, a2, a3, a4, a5
; ---------------------------------------------------------------------------

SnapFloor:
		getpos_bottom					; d0 = x pos; d1 = y pos of bottom of object
		moveq	#5,d6					; check up to 6 tiles
		bsr.w	FloorDist
		cmpi.w	#16*6,d5
		beq.w	DeleteObject				; delete if not within 6 tiles of floor
		add.w	d5,ost_y_pos(a0)			; align to floor
		rts
		