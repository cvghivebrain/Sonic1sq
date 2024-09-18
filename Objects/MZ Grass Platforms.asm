; ---------------------------------------------------------------------------
; Object 2F - large grass-covered platforms (MZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 1/$15/$20/$21/$22/$23/$29/$2A/$2B

; subtypes:
;	%0SSSRMMM
;	SSS - size settings from list (0 = wide; 1 = wide sloped; 2 = narrow)
;	R - 1 for reverse direction (when MMM is 1-4)
;	MMM - movement type (0 = doesn't move; 1-4 = up & down; 5 = sinks & catches fire)

type_grass_wide:	equ 0					; $0x - wide platform
type_grass_sloped:	equ $10					; $1x - sloped platform, usually sinks and catches fire
type_grass_narrow:	equ $20					; $2x - narrow platform
type_grass_still:	equ id_LGrass_Type00			; $x0 - doesn't move
type_grass_1:		equ id_LGrass_Type01			; $x1 - moves up and down 32 pixels
type_grass_2:		equ id_LGrass_Type02			; $x2 - moves up and down 48 pixels
type_grass_3:		equ id_LGrass_Type03			; $x3 - moves up and down 64 pixels
type_grass_4:		equ id_LGrass_Type04			; $x4 - moves up and down 96 pixels
type_grass_sinks:	equ id_LGrass_Type05			; $x5 - sinks and catches fire when stood on
type_grass_rev_bit:	equ 3
type_grass_rev:		equ 1<<type_grass_rev_bit		; +8 - reverse movement direction
; ---------------------------------------------------------------------------

LargeGrass:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	LGrass_Index(pc,d0.w),d1
		jmp	LGrass_Index(pc,d1.w)
; ===========================================================================
LGrass_Index:	index *,,2
		ptr LGrass_Main
		ptr LGrass_Action

		rsobj LargeGrass
ost_grass_y_start:	rs.w 1					; original y position
ost_grass_coll_ptr:	rs.l 1					; pointer to collision data
ost_grass_burn_flag:	rs.b 1					; 0 = not burning; 1 = burning
ost_grass_type:		rs.b 1					; movement type
		rsobjend
		
LGrass_Sizes:	; heightmap pointer, frame, width, height
		dc.l LGrass_Coll_Wide
		dc.b id_frame_grass_wide, $40, 40, 0
		
		dc.l LGrass_Coll_Sloped
		dc.b id_frame_grass_sloped, $40, 48, 0
		
		dc.l 0
		dc.b id_frame_grass_narrow, $20, 48, 0
; ===========================================================================

LGrass_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto LGrass_Action next
		move.l	#Map_LGrass,ost_mappings(a0)
		move.w	#tile_pal3+tile_hi,ost_tile(a0)
		move.b	#render_rel+render_useheight,ost_render(a0)
		move.w	#priority_5,ost_priority(a0)
		move.w	ost_y_pos(a0),ost_grass_y_start(a0)
		move.b	ost_subtype(a0),d0
		move.b	d0,d1
		andi.w	#%01110000,d0				; read bits 4-6 of subtype
		lsr.w	#1,d0
		lea	LGrass_Sizes(pc,d0.w),a2
		move.l	(a2)+,ost_grass_coll_ptr(a0)
		move.b	(a2)+,ost_frame(a0)
		move.b	(a2),ost_displaywidth(a0)
		move.b	(a2)+,ost_width(a0)
		move.b	(a2),ost_height(a0)
		andi.b	#%00000111,d1				; read only bits 0-2 of subtype
		add.b	d1,d1
		move.b	d1,ost_grass_type(a0)

LGrass_Action:	; Routine 2
		shortcut
		bsr.s	LGrass_Types
		move.l	ost_grass_coll_ptr(a0),d0
		beq.s	.no_heightmap				; branch if there is no heightmap
		moveq	#1,d6					; 1 byte in heightmap = 2px
		movea.l	d0,a2
		bsr.w	SolidObject_Heightmap
		cmpi.b	#id_frame_grass_sloped,ost_frame(a0)
		beq.w	DespawnFamily				; branch if object is the sloped burning kind
		bra.w	DespawnQuick
		
	.no_heightmap:
		bsr.w	SolidObject
		bra.w	DespawnQuick

; ---------------------------------------------------------------------------
; Subroutine to update platform position and load burning grass object
; ---------------------------------------------------------------------------

LGrass_Types:
		moveq	#0,d0
		move.b	ost_grass_type(a0),d0			; get relevant part of subtype
		move.w	LGrass_TypeIndex(pc,d0.w),d1
		jmp	LGrass_TypeIndex(pc,d1.w)

; ===========================================================================
LGrass_TypeIndex:
		index *
		ptr LGrass_Type00
		ptr LGrass_Type01
		ptr LGrass_Type02
		ptr LGrass_Type03
		ptr LGrass_Type04
		ptr LGrass_Type05
; ===========================================================================

; Type 0 - doesn't move
LGrass_Type00:
		rts
; ===========================================================================

; Type 1 - moves up and down 32 pixels
LGrass_Type01:
		move.b	(v_oscillating_0_to_20).w,d0
		move.w	#$20,d1
		bra.s	LGrass_Move
; ===========================================================================

; Type 2 - moves up and down 48 pixels
LGrass_Type02:
		move.b	(v_oscillating_0_to_30).w,d0
		move.w	#$30,d1
		bra.s	LGrass_Move
; ===========================================================================

; Type 3 - moves up and down 64 pixels
LGrass_Type03:
		move.b	(v_oscillating_0_to_40).w,d0
		move.w	#$40,d1
		bra.s	LGrass_Move
; ===========================================================================

; Type 4 - moves up and down 96 pixels (unused)
LGrass_Type04:
		move.b	(v_oscillating_0_to_60).w,d0
		move.w	#$60,d1

LGrass_Move:
		btst	#type_grass_rev_bit,ost_subtype(a0)	; is bit 3 of subtype set? (+8)
		beq.s	.no_rev					; if not, branch
		neg.w	d0					; reverse direction
		add.w	d1,d0

	.no_rev:
		move.w	ost_grass_y_start(a0),d1
		sub.w	d0,d1
		move.w	d1,ost_y_pos(a0)			; update y position
		rts	
; ===========================================================================

; Type 5 - sinks when stood on and catches fire
LGrass_Type05:
		move.w	ost_grass_y_start(a0),d0
		bsr.w	SinkBig
		cmpi.b	#$20,ost_sink(a0)
		bne.s	.exit					; branch if not at $20
		tst.b	ost_grass_burn_flag(a0)
		bne.s	.exit					; branch if already burning
		move.b	#1,ost_grass_burn_flag(a0)		; set burning flag
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.s	.exit
		move.l	#GrassFire,ost_id(a1)			; load sitting flame object (this spreads itself)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		subi.w	#$40,ost_x_pos(a1)			; start at left side of platform
		move.l	ost_grass_coll_ptr(a0),ost_burn_coll_ptr(a1)
		saveparent
		
	.exit:
		rts
