; ---------------------------------------------------------------------------
; Object 44 - edge walls (GHZ)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3 - subtypes 0/1/2/$10/$11/$12
; ---------------------------------------------------------------------------

EdgeWalls:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Edge_Index(pc,d0.w),d1
		jmp	Edge_Index(pc,d1.w)
; ===========================================================================
Edge_Index:	index *,,2
		ptr Edge_Main
		ptr Edge_Solid
		ptr Edge_Display
; ===========================================================================

Edge_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Edge_Solid next
		move.l	#Map_Edge,ost_mappings(a0)
		move.w	#tile_Kos_GhzEdgeWall+tile_pal3,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#9,ost_width(a0)
		move.b	#32,ost_height(a0)
		move.b	#6,ost_priority(a0)
		move.b	ost_subtype(a0),ost_frame(a0)		; copy object type number to frame number
		bclr	#4,ost_frame(a0)			; clear 4th bit (deduct $10)
		beq.s	Edge_Solid				; branch if already clear (subtype 0/1/2 is solid)

		addq.b	#2,ost_routine(a0)			; goto Edge_Display next
		bra.s	Edge_Display				; bit 4 was already set (subtype $10/$11/$12 is not solid)
; ===========================================================================

Edge_Solid:	; Routine 2
		bsr.w	SolidNew_SidesOnly

Edge_Display:	; Routine 4
		move.w	ost_x_pos(a0),d0
		bsr.w	CheckActive
		bne.w	DeleteObject
		bra.w	DisplaySprite
