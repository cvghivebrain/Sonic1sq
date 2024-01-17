; ---------------------------------------------------------------------------
; Object 56 - floating blocks (SYZ)

; spawned by:
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_SYZ3 - subtypes 0/1/2/$13/$20

; subtypes:
;	%TTTTMMMM
;	TTTT - type (see FBlock_Var)
;	MMMM - movement type (see FBlock_Types)

type_fblock_syz1x1:	equ ((FBlock_Var_0-FBlock_Var)/sizeof_FBlock_Var)<<4 ; $0x - single 32x32 square
type_fblock_syz2x2:	equ ((FBlock_Var_1-FBlock_Var)/sizeof_FBlock_Var)<<4 ; $1x - 2x2 32x32 squares
type_fblock_syz1x2:	equ ((FBlock_Var_2-FBlock_Var)/sizeof_FBlock_Var)<<4 ; $2x - 1x2 32x32 squares
type_fblock_syzrect2x2:	equ ((FBlock_Var_3-FBlock_Var)/sizeof_FBlock_Var)<<4 ; $3x - 2x2 32x26 squares
type_fblock_syzrect1x3:	equ ((FBlock_Var_4-FBlock_Var)/sizeof_FBlock_Var)<<4 ; $4x - 1x3 32x26 squares
type_fblock_still:	equ id_FBlock_Still			; $x0 - doesn't move
type_fblock_leftright:	equ id_FBlock_LeftRight			; $x1 - moves side to side
type_fblock_leftrightwide: equ id_FBlock_LeftRightWide		; $x2 - moves side to side, larger distance
type_fblock_updown:	equ id_FBlock_UpDown			; $x3 - moves up and down
type_fblock_updownwide:	equ id_FBlock_UpDownWide		; $x4 - moves up and down, larger distance
; ---------------------------------------------------------------------------

FloatingBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	FBlock_Index(pc,d0.w),d1
		jmp	FBlock_Index(pc,d1.w)
; ===========================================================================
FBlock_Index:	index *,,2
		ptr FBlock_Main
		ptr FBlock_Action

		rsobj FloatingBlock
ost_fblock_y_start:	rs.w 1					; original y position
ost_fblock_x_start:	rs.w 1					; original x position
		rsobjend

FBlock_Var:
FBlock_Var_0:	dc.b  $10, $10, id_frame_fblock_syz1x1		; height, width, frame
FBlock_Var_1:	dc.b  $20, $20, id_frame_fblock_syz2x2
FBlock_Var_2:	dc.b  $10, $20, id_frame_fblock_syz1x2
FBlock_Var_3:	dc.b  $20, $1A, id_frame_fblock_syzrect2x2
FBlock_Var_4:	dc.b  $10, $27, id_frame_fblock_syzrect1x3
		even
		
sizeof_FBlock_Var:	equ FBlock_Var_1-FBlock_Var
; ===========================================================================

FBlock_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto FBlock_Action next
		move.l	#Map_FBlock,ost_mappings(a0)
		move.w	#0+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_3,ost_priority(a0)
		move.b	ost_subtype(a0),d0			; get subtype
		move.b	d0,d2
		lsr.w	#4,d0
		andi.w	#$F,d0					; read only high nybble
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0					; multiply by 3
		lea	FBlock_Var(pc,d0.w),a2			; get size data
		move.b	(a2),ost_width(a0)
		move.b	(a2)+,ost_displaywidth(a0)
		move.b	(a2)+,ost_height(a0)
		move.b	(a2)+,ost_frame(a0)
		move.w	ost_x_pos(a0),ost_fblock_x_start(a0)
		move.w	ost_y_pos(a0),ost_fblock_y_start(a0)
		andi.w	#$F,d2					; read low nybble of subtype
		add.w	d2,d2
		move.b	d2,ost_subtype(a0)			; update subtype for FBlock_Types

FBlock_Action:	; Routine 2
		shortcut
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get object subtype
		move.w	FBlock_Types(pc,d0.w),d1
		jsr	FBlock_Types(pc,d1.w)			; update position
		bsr.w	SolidObject				; detect collision
		move.w	ost_fblock_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================
FBlock_Types:	index *
		ptr FBlock_Still				; 0
		ptr FBlock_LeftRight				; 1
		ptr FBlock_LeftRightWide			; 2
		ptr FBlock_UpDown				; 3
		ptr FBlock_UpDownWide				; 4 - unused
; ===========================================================================

; Type 0 - doesn't move
FBlock_Still:
		rts	
; ===========================================================================

; Type 1 - moves side-to-side
FBlock_LeftRight:
		move.w	#$40,d1					; set move distance
		moveq	#0,d0
		move.b	(v_oscillating_0_to_40).w,d0
		bra.s	FBlock_LeftRight_Move
; ===========================================================================

; Type 2 - moves side-to-side
FBlock_LeftRightWide:
		move.w	#$80,d1					; set move distance
		moveq	#0,d0
		move.b	(v_oscillating_0_to_80).w,d0

FBlock_LeftRight_Move:
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip
		neg.w	d0
		add.w	d1,d0

	.noflip:
		move.w	ost_fblock_x_start(a0),d1
		sub.w	d0,d1
		move.w	d1,ost_x_pos(a0)			; move object horizontally
		rts	
; ===========================================================================

; Type 3 - moves up/down
FBlock_UpDown:
		move.w	#$40,d1					; set move distance
		moveq	#0,d0
		move.b	(v_oscillating_0_to_40).w,d0
		bra.s	FBlock_UpDown_Move
; ===========================================================================

; Type 4 - moves up/down
FBlock_UpDownWide:
		move.w	#$80,d1					; set move distance
		moveq	#0,d0
		move.b	(v_oscillating_0_to_80).w,d0

FBlock_UpDown_Move:
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip
		neg.w	d0
		add.w	d1,d0

	.noflip:
		move.w	ost_fblock_y_start(a0),d1
		sub.w	d0,d1
		move.w	d1,ost_y_pos(a0)			; move object vertically
		rts
