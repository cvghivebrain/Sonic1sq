; ---------------------------------------------------------------------------
; Subroutine to	find distance to floor at position

; input:
;	d0.w = x position
;	d1.w = y position
;	d6.w = max number of tiles to check (0 = 1; 1 = 2...)

; output:
;	d5.w = distance to floor (-ve if below floor)
;	a2 = address within level layout
;	(a2).b = 256x256 chunk id
;	a3 = address within 256x256 mappings
;	d4.w, (a3).w = 16x16 tile id & flags

;	uses d1.w, d2.l, d3.l, d4.l, d5.l, d6.w

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
		move.w	(a3),d2
		btst	#tilemap_solid_top_bit,d2
		beq.s	.chk_below				; branch if tile isn't top solid
		move.w	d2,d4					; d4 = tile id with flags
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
		lea	(CollArray1).l,a4
		move.b	(a4,d3.w),d3				; d3 = actual height value from heightmap
		beq.s	.chk_below				; branch if height is 0
		ext.w	d3
		btst	#tilemap_yflip_bit,d4
		beq.s	.noyflip				; branch if not yflipped
		neg.w	d3
		
	.noyflip:
		cmpi.w	#16,d3
		bcs.s	.height_ok				; branch if height is between 0 and 15
		tst.w	d5
		beq.s	.chk_above				; branch if this is the first tile
		
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
		
	.chk_above:
		subi.w	#16,d1					; 16px above
		subi.w	#16,d5					; 16px -ve distance
		dbf	d6,.loop				; check tile below this one
		rts
		
	.under_floor:
		move.w	d1,d5					; copy y pos
		andi.w	#$F,d5					; get y pos within 16x16 tile
		neg.w	d5					; object is < 16px under floor
		rts
		