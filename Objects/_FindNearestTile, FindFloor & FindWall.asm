; ---------------------------------------------------------------------------
; Subroutine to	find which tile	the object is standing on

; input:
;	d2.w = y position of object's bottom edge
;	d3.w = x position of object

; output:
;	a3 = address within 256x256 mappings where object is standing
;	(a3).w = 16x16 tile number, x/yflip, solidness

;	uses d0.w, d1.l
; ---------------------------------------------------------------------------

FindNearestTile:
		move.w	d2,d0					; copy y pos
		andi.w	#$700,d0				; round down 256px
		lsr.w	#1,d0					; divide by 256 (tile height), multiply by 128 (level width)
		move.w	a5,d1					; copy x pos
		andi.w	#$7F00,d1				; round down 256px
		pushr.w	d1
		moveq	#0,d1
		popr.b	d1
		;lsr.w	#8,d1					; divide by 256 (tile width)
		add.w	d1,d0					; combine for position within layout
		moveq	#-1,d1					; d1 = $FFFFFFFF
		clr.w	d1					; d1 = $FFFF0000
		lea	(v_level_layout).w,a3
		move.b	(a3,d0.w),d1				; get 256x256 tile number
		beq.s	.blanktile				; branch if 0

		add.w	d1,d1
		move.w	TileOffsetList(pc,d1.w),d1		; get RAM address of 256x256 tile
		
		move.w	d2,d0					; copy y pos
		andi.w	#$F0,d0
		add.w	d0,d0					; get y pos within 256x256 tile
		add.w	d0,d1					; add to base address
		
		move.w	a5,d0					; copy x pos
		andi.w	#$F0,d0
		lsr.w	#3,d0					; get x pos within 256x256 tile
		add.w	d0,d1					; add to base address

	.blanktile:
		movea.l	d1,a3
		rts

TileOffsetList:
		c: = -$200
		rept countof_256x256+1
		dc.w c
		c: = c+$200
		endr
; ---------------------------------------------------------------------------
; Subroutine to	find the floor

; input:
;	d2.w = y position of object's bottom edge
;	d3.w = x position of object
;	d5.l = bit to test for solidness: $D = top solid; $E = left/right/bottom solid
;	d6.w = eor bitmask for 16x16 tile
;	a4 = RAM address to write angle byte

; output:
;	d1.w = distance to the floor
;	d3.b = floor angle
;	a3 = address within 256x256 mappings where object is standing
;	(a3).w = 16x16 tile number, x/yflip, solidness
;	(a4).b = floor angle

;	uses d0.w, d2.w, d3.l, d4.w, a2, a5
; ---------------------------------------------------------------------------

FindFloor:
		move.w	d3,a5
		moveq	#0,d3
		bsr.w	FindNearestTile				; a3 = address within 256x256 mappings of 16x16 tile being stood on
		move.w	(a3),d0					; get value for solidness, orientation and 16x16 tile number
		move.w	d0,d4
		andi.w	#$7FF,d0				; ignore solid/orientation bits
		beq.s	.isblank				; branch if tile is blank
		btst	d5,d4					; is the tile solid?
		bne.s	.issolid				; if yes, branch

.isblank:
		addi.w	#16,d2
		bsr.w	FindFloor2				; try tile below the nearest
		;subi.w	#16,d2
		addi.w	#$10,d1					; return distance to floor
		rts	
; ===========================================================================

.issolid:
		bsr.w	FindFloor_GetHeight
		tst.w	d0
		beq.s	.isblank				; branch if height is 0
		bmi.s	.negfloor				; branch if height is negative
		cmpi.b	#$10,d0
		beq.s	.maxfloor				; branch if height is $10 (max)
		move.w	d2,d1					; get y pos of object
		andi.w	#$F,d1					; read only low nybble for y pos within 16x16 tile
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1					; return distance to floor
		rts	
; ===========================================================================

.negfloor:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	.isblank

.maxfloor:
		subi.w	#16,d2
		bsr.w	FindFloor2				; try tile above the nearest
		;addi.w	#16,d2
		subi.w	#$10,d1					; return distance to floor
		rts

FindCeiling:
		move.w	d3,a5
		moveq	#0,d3
		bsr.w	FindNearestTile				; a3 = address within 256x256 mappings of 16x16 tile being stood on
		move.w	(a3),d0					; get value for solidness, orientation and 16x16 tile number
		move.w	d0,d4
		andi.w	#$7FF,d0				; ignore solid/orientation bits
		beq.s	.isblank				; branch if tile is blank
		btst	d5,d4					; is the tile solid?
		bne.s	.issolid				; if yes, branch

.isblank:
		subi.w	#16,d2
		bsr.w	FindFloor2				; try tile below the nearest
		;addi.w	#16,d2
		addi.w	#$10,d1					; return distance to floor
		rts	
; ===========================================================================

.issolid:
		bsr.w	FindFloor_GetHeight
		tst.w	d0
		beq.s	.isblank				; branch if height is 0
		bmi.s	.negfloor				; branch if height is negative
		cmpi.b	#$10,d0
		beq.s	.maxfloor				; branch if height is $10 (max)
		move.w	d2,d1					; get y pos of object
		andi.w	#$F,d1					; read only low nybble for y pos within 16x16 tile
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1					; return distance to floor
		rts	
; ===========================================================================

.negfloor:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	.isblank

.maxfloor:
		addi.w	#16,d2
		bsr.s	FindFloor2				; try tile above the nearest
		;subi.w	#16,d2
		subi.w	#$10,d1					; return distance to floor
		rts

; ---------------------------------------------------------------------------
; Subroutine to	find the floor above/below the current 16x16 tile
; ---------------------------------------------------------------------------

FindFloor2:
		bsr.w	FindNearestTile
		move.w	(a3),d0
		move.w	d0,d4
		andi.w	#$7FF,d0
		beq.s	.isblank
		btst	d5,d4
		bne.s	.issolid

.isblank:
		move.w	#$F,d1
		move.w	d2,d0
		andi.w	#$F,d0
		sub.w	d0,d1
		rts	
; ===========================================================================

.issolid:
		bsr.s	FindFloor_GetHeight
		tst.w	d0
		beq.s	.isblank
		bmi.s	.negfloor
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts	
; ===========================================================================

.negfloor:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	.isblank
		not.w	d1
		rts

FindFloor_GetHeight:
		movea.l	(v_collision_index_ptr).w,a2
		move.b	(a2,d0.w),d0				; get collision heightmap id
		andi.w	#$FF,d0					; heightmap id is 1 byte
		beq.s	.exit					; branch if 0
		move.w	a5,d1					; get x pos of object
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),d3				; get collision angle value
		lsl.w	#4,d0					; d0 = heightmap id * $10 (the width of a heightmap for 1 tile)
		btst	#tilemap_xflip_bit,d4			; is tile flipped horizontally?
		beq.s	.no_xflip				; if not, branch
		not.w	d1
		neg.b	d3					; xflip angle

	.no_xflip:
		btst	#tilemap_yflip_bit,d4			; is tile flipped vertically?
		beq.s	.no_yflip				; if not, branch
		addi.b	#$40,d3
		neg.b	d3
		subi.b	#$40,d3					; yflip angle

	.no_yflip:
		move.b	d3,(a4)
		andi.w	#$F,d1					; read only low nybble of x pos (i.e. x pos within 16x16 tile)
		add.w	d0,d1					; (id * $10) + x pos. = place in heightmap data
		lea	(CollArray1).l,a2
		move.b	(a2,d1.w),d0				; get actual height value from heightmap
		ext.w	d0
		eor.w	d6,d4					; apply x/yflip (allows for double-flip cancellation)
		btst	#tilemap_yflip_bit,d4			; is block flipped vertically?
		beq.s	.exit					; if not, branch
		neg.w	d0
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	find a wall

; input:
;	d2.w = y position of object's bottom edge
;	d3.w = x position of object
;	d5.l = bit to test for solidness: $D = top solid; $E = left/right/bottom solid
;	d6.w = eor bitmask for 16x16 tile
;	a4 = RAM address to write angle byte

; output:
;	d1.w = distance to the wall
;	d3.b = floor angle
;	a3 = address within 256x256 mappings where object is standing
;	(a3).w = 16x16 tile number, x/yflip, solidness
;	(a4).b = floor angle

;	uses d0.w, d3.l, d4.w, a2, a5
; ---------------------------------------------------------------------------

FindWall:
		move.w	d3,a5
		moveq	#0,d3
		bsr.w	FindNearestTile				; a3 = address within 256x256 mappings of 16x16 tile being stood on
		move.w	(a3),d0					; get value for solidness, orientation and 16x16 tile number
		move.w	d0,d4
		andi.w	#$7FF,d0				; ignore solid/orientation bits
		beq.s	.isblank				; branch if tile is blank
		btst	d5,d4					; is the tile solid?
		bne.s	.issolid				; if yes, branch

.isblank:
		adda.w	#16,a5
		bsr.w	FindWall2				; try tile to the right
		;suba.w	#16,a5
		addi.w	#$10,d1					; return distance to wall
		rts	
; ===========================================================================

.issolid:
		bsr.w	FindWall_GetHeight
		tst.w	d0
		beq.s	.isblank				; branch if height is 0
		bmi.s	.negfloor				; branch if height is negative
		cmpi.b	#$10,d0
		beq.s	.maxfloor				; branch if height is $10 (max)
		move.w	a5,d1					; get x pos of object
		andi.w	#$F,d1					; read only low nybble for x pos within 16x16 tile
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1					; return distance to wall
		rts	
; ===========================================================================

.negfloor:
		move.w	a5,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	.isblank

.maxfloor:
		suba.w	#16,a5
		bsr.w	FindWall2				; try tile to the left
		;adda.w	#16,a5
		subi.w	#$10,d1					; return distance to wall
		rts

FindWallLeft:
		move.w	d3,a5
		moveq	#0,d3
		bsr.w	FindNearestTile				; a3 = address within 256x256 mappings of 16x16 tile being stood on
		move.w	(a3),d0					; get value for solidness, orientation and 16x16 tile number
		move.w	d0,d4
		andi.w	#$7FF,d0				; ignore solid/orientation bits
		beq.s	.isblank				; branch if tile is blank
		btst	d5,d4					; is the tile solid?
		bne.s	.issolid				; if yes, branch

.isblank:
		suba.w	#16,a5
		bsr.w	FindWall2				; try tile to the right
		;adda.w	#16,a5
		addi.w	#$10,d1					; return distance to wall
		rts	
; ===========================================================================

.issolid:
		bsr.w	FindWall_GetHeight
		tst.w	d0
		beq.s	.isblank				; branch if height is 0
		bmi.s	.negfloor				; branch if height is negative
		cmpi.b	#$10,d0
		beq.s	.maxfloor				; branch if height is $10 (max)
		move.w	a5,d1					; get x pos of object
		andi.w	#$F,d1					; read only low nybble for x pos within 16x16 tile
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1					; return distance to wall
		rts	
; ===========================================================================

.negfloor:
		move.w	a5,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	.isblank

.maxfloor:
		adda.w	#16,a5
		bsr.s	FindWall2				; try tile to the left
		;suba.w	#16,a5
		subi.w	#$10,d1					; return distance to wall
		rts

; ---------------------------------------------------------------------------
; Subroutine to	find a wall left/right of the current 16x16 tile
; ---------------------------------------------------------------------------

FindWall2:
		bsr.w	FindNearestTile
		move.w	(a3),d0
		move.w	d0,d4
		andi.w	#$7FF,d0
		beq.s	.isblank
		btst	d5,d4
		bne.s	.issolid

.isblank:
		move.w	#$F,d1
		move.w	a5,d0
		andi.w	#$F,d0
		sub.w	d0,d1
		rts	
; ===========================================================================

.issolid:
		bsr.s	FindWall_GetHeight
		tst.w	d0
		beq.s	.isblank
		bmi.s	.negfloor
		move.w	a5,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts	
; ===========================================================================

.negfloor:
		move.w	a5,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	.isblank
		not.w	d1
		rts

FindWall_GetHeight:
		movea.l	(v_collision_index_ptr).w,a2
		move.b	(a2,d0.w),d0				; get collision heightmap id
		andi.w	#$FF,d0					; heightmap id is 1 byte
		beq.s	.exit					; branch if 0
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),d3				; get collision angle value
		lsl.w	#4,d0					; d0 = heightmap id * $10 (the width of a heightmap for 1 tile)
		move.w	d2,d1					; get y pos of object
		btst	#tilemap_yflip_bit,d4			; is block flipped vertically?
		beq.s	.no_yflip				; if not, branch
		not.w	d1
		addi.b	#$40,d3
		neg.b	d3
		subi.b	#$40,d3					; yflip angle

	.no_yflip:
		btst	#tilemap_xflip_bit,d4			; is block flipped horizontally?
		beq.s	.no_xflip				; if not, branch
		neg.b	d3					; xflip angle

	.no_xflip:
		move.b	d3,(a4)
		andi.w	#$F,d1					; read only low nybble of x pos (i.e. x pos within 16x16 tile)
		add.w	d0,d1					; (id * $10) + x pos. = place in heightmap data
		lea	(CollArray2).l,a2
		move.b	(a2,d1.w),d0				; get actual height value from heightmap
		ext.w	d0
		eor.w	d6,d4					; apply x/yflip (allows for double-flip cancellation)
		btst	#tilemap_xflip_bit,d4			; is block flipped horizontally?
		beq.s	.exit					; if not, branch
		neg.w	d0
		
	.exit:
		rts
		