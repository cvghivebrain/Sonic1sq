; ---------------------------------------------------------------------------
; Object 44 - edge walls (GHZ)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3 - subtypes 0/1/2/$10/$11/$12

; subtypes:
;	%000SFFFF
;	S - 1 if wall isn't solid
;	FFFF - frame id

type_edge_unsolid_bit:	equ 4
type_edge_unsolid:	equ 1<<type_edge_unsolid_bit		; wall isn't solid
type_edge_shadow:	equ id_frame_edge_shadow		; 0
type_edge_light:	equ id_frame_edge_light			; 1
type_edge_dark:		equ id_frame_edge_dark			; 2
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
		move.w	#priority_6,ost_priority(a0)
		move.b	ost_subtype(a0),d0
		move.b	d0,d1
		andi.w	#$F,d0					; read low nybble of subtype
		move.b	d0,ost_frame(a0)			; set as frame number
		btst	#type_edge_unsolid_bit,d1
		beq.s	Edge_Solid				; branch if unsolid bit is clear

		addq.b	#2,ost_routine(a0)			; goto Edge_Display next
		bra.s	Edge_Display
; ===========================================================================

Edge_Solid:	; Routine 2
		shortcut
		bsr.w	SolidObject_SidesOnly
		bra.w	DespawnQuick
; ===========================================================================

Edge_Display:	; Routine 4
		shortcut	DespawnQuick
		bra.w	DespawnQuick
