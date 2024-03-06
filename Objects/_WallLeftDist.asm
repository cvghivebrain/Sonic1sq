; ---------------------------------------------------------------------------
; Subroutine to	find distance to wall left of position

; input:
;	d0.w = x position
;	d1.w = y position
;	d6.w = max number of tiles to check (0 = 1; 1 = 2...)

; output:
;	d4.w = 16x16 tile id & flags
;	d5.w = distance to wall (-ve if inside wall)
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
;		bsr.w	WallLeftDist
; ---------------------------------------------------------------------------

WallLeftDist:
		moveq	#0,d5
		
	.loop:
		bsr.w	PosToTile				; (a3).w = 16x16 tile id
		move.w	(a3),d4					; d4 = tile id with flags
		btst	#tilemap_solid_lrb_bit,d4
		beq.s	.chk_left				; branch if tile isn't l/r solid
		move.w	d4,d2
		andi.w	#$7FF,d2				; ignore flags
		beq.s	.chk_left				; branch if tile is blank
		movea.l	(v_collision_index_ptr).w,a4
		moveq	#0,d3
		move.b	(a4,d2.w),d3				; get collision heightmap id
		lsl.w	#4,d3					; multiply by bytes per tile heightmap (16)
		
		move.w	d1,d2					; copy y pos
		btst	#tilemap_yflip_bit,d4
		beq.s	.noyflip				; branch if not yflipped
		not.w	d2
		
	.noyflip:
		andi.w	#$F,d2					; get y pos within 16x16 tile
		add.w	d2,d3					; d3 = offset within whole heightmap
		lea	(CollArray2).l,a5
		move.b	(a5,d3.w),d3				; d3 = actual height value from heightmap
		beq.s	.chk_left				; branch if height is 0
		ext.w	d3
		btst	#tilemap_xflip_bit,d4
		beq.s	.noxflip				; branch if not xflipped
		neg.w	d3
		
	.noxflip:
		cmpi.w	#-16,d3
		beq.s	.full_height
		tst.w	d3
		bmi.s	.height_ok				; branch if height is between -1 and -15
		moveq	#-16,d3					; force height to be -16px (was already +ve)
		
	.full_height:
		tst.w	d5
		bgt.s	.height_ok				; branch if previously checked left
		
	.chk_right:
		addi.w	#16,d0					; 16px right
		subi.w	#16,d5					; 16px -ve distance
		dbf	d6,.loop				; check tile right of this one
		rts
		
	.height_ok:
		move.w	d0,d2					; copy x pos
		andi.w	#$F,d2					; get x pos within 16x16 tile
		add.w	d2,d3					; d3 = dist between object & wall (-ve if overlapping)
		add.w	d3,d5					; d5 = total distance
		rts
		
	.chk_left:
		tst.w	d5
		bmi.s	.inside_wall				; branch if tile left was previously checked
		subi.w	#16,d0					; 16px left
		addi.w	#16,d5					; add 16px to distance
		dbf	d6,.loop				; check tile left of this one
		rts
		
	.inside_wall:
		move.w	d0,d3					; copy x pos
		andi.w	#$F,d3					; get x pos within 16x16 tile
		add.w	d3,d5					; object is < 16px inside wall
		rts

; ---------------------------------------------------------------------------
; Subroutine to snap a new object to a wall

;	uses d0.w, d1.l, d2.l, d3.l, d4.l, d5.l, d6.l, a2, a3, a4, a5
; ---------------------------------------------------------------------------

SnapWallLeft:
		getpos_left					; d0 = x pos of left of object; d1 = y pos
		moveq	#5,d6					; check up to 6 tiles
		bsr.w	WallLeftDist
		cmpi.w	#16*6,d5
		beq.w	DeleteObject				; delete if not within 6 tiles of wall
		sub.w	d5,ost_x_pos(a0)			; align to wall
		rts
		