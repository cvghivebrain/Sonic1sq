; ---------------------------------------------------------------------------
; Object 5A - platforms	moving in circles (SLZ)

; spawned by:
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SLZ3 - subtypes 0-7
; ---------------------------------------------------------------------------

CirclingPlatform:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Circ_Index(pc,d0.w),d1
		jmp	Circ_Index(pc,d1.w)
; ===========================================================================
Circ_Index:	index *,,2
		ptr Circ_Main
		ptr Circ_Action

		rsobj CirclingPlatform
ost_circ_y_start:	rs.w 1					; original y-axis position
ost_circ_x_start:	rs.w 1					; original x-axis position
		rsobjend
; ===========================================================================

Circ_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Circ_Action next
		move.l	#Map_Circ,ost_mappings(a0)
		move.w	#0+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_4,ost_priority(a0)
		move.b	#$18,ost_displaywidth(a0)
		move.b	#$18,ost_width(a0)
		move.b	#8,ost_height(a0)
		move.w	ost_x_pos(a0),ost_circ_x_start(a0)
		move.w	ost_y_pos(a0),ost_circ_y_start(a0)
		move.b	ost_subtype(a0),d0
		add.b	d0,d0
		move.b	d0,ost_subtype(a0)

Circ_Action:	; Routine 2
		shortcut
		move.w	ost_x_pos(a0),ost_x_prev(a0)		; save x pos before moving
		
		move.b	(v_oscillating_0_to_A0).w,d1
		subi.b	#$50,d1
		ext.w	d1
		move.b	(v_oscillating_0_to_A0_alt).w,d2
		subi.b	#$50,d2
		ext.w	d2
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		move.w	Circ_Type_Index(pc,d0.w),d0
		jsr	Circ_Type_Index(pc,d0.w)
		add.w	ost_circ_x_start(a0),d1
		move.w	d1,ost_x_pos(a0)
		add.w	ost_circ_y_start(a0),d2
		move.w	d2,ost_y_pos(a0)
		
		bsr.w	SolidObject_TopOnly
		move.w	ost_circ_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================
Circ_Type_Index:
		index *,,2
		ptr Circ_Anticlockwise_0
		ptr Circ_Anticlockwise_1
		ptr Circ_Anticlockwise_2
		ptr Circ_Anticlockwise_3
		ptr Circ_Clockwise_4
		ptr Circ_Clockwise_5
		ptr Circ_Clockwise_6
		ptr Circ_Clockwise_7
; ===========================================================================

Circ_Anticlockwise_0:
		rts
		
Circ_Anticlockwise_1:
		neg.w	d1
		neg.w	d2
		rts

Circ_Anticlockwise_2:
		neg.w	d1
		exg	d1,d2
		rts

Circ_Anticlockwise_3:
		neg.w	d2
		exg	d1,d2
		rts

Circ_Clockwise_4:
		neg.w	d1
		rts
		
Circ_Clockwise_5:
		neg.w	d2
		rts

Circ_Clockwise_6:
		neg.w	d1
		exg	d1,d2
		neg.w	d1
		rts

Circ_Clockwise_7:
		exg	d1,d2
		rts
