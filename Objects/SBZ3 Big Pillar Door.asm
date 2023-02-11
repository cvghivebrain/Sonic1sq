; ---------------------------------------------------------------------------
; Big pillar sliding door (SBZ)

; spawned by:
;	ObjPos_SBZ3 - subtypes $80/$B
; ---------------------------------------------------------------------------

BigPillar:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Pillar_Index(pc,d0.w),d1
		jsr	Pillar_Index(pc,d1.w)
		move.w	ost_x_pos(a0),d0
		bsr.w	CheckActive
		bne.s	Pillar_Delete
		jmp	DisplaySprite
		
Pillar_Delete:
		jmp	DeleteObject
; ===========================================================================
Pillar_Index:	index *,,2
		ptr Pillar_Main
		ptr Pillar_Start
		ptr Pillar_Move
		ptr Pillar_Finish

		rsobj BigPillar
ost_pillar_x_dist:	rs.w 1					; x distance moved
		rsobjend
; ===========================================================================

Pillar_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Pillar_Start next
		move.b	#$80,ost_displaywidth(a0)
		move.b	#$80,ost_width(a0)
		move.b	#$40,ost_height(a0)
		move.w	#tile_Kos_Sbz3HugeDoor+tile_pal3,ost_tile(a0)
		move.l	#Map_Pillar,ost_mappings(a0)
		ori.b	#render_rel+render_useheight,ost_render(a0)
		move.b	#4,ost_priority(a0)
		tst.b	ost_subtype(a0)
		bmi.w	Pillar_Final				; branch if object is the final version
		tst.b	(v_sbz3pillar_status).w
		bne.s	Pillar_Delete				; delete if object has already moved
		
Pillar_Start:	; Routine 2
		bsr.w	SolidNew
		lea	(v_button_state).w,a2
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		andi.b	#$F,d0
		btst	#0,(a2,d0.w)				; has relevant button been pressed?
		beq.s	.exit					; if not, branch
		
		addq.b	#2,ost_routine(a0)			; goto Pillar_Move next
		move.b	#1,(v_sbz3pillar_status).w
		
	.exit:
		rts
; ===========================================================================
		
Pillar_Move:	; Routine 4
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		subi.w	#1,ost_x_pos(a0)			; move left 1px
		addi.l	#$8000,ost_y_pos(a0)			; move down 0.5px
		addq.w	#1,ost_pillar_x_dist(a0)
		bsr.w	SolidNew
		cmpi.w	#$100,ost_pillar_x_dist(a0)
		bne.s	.exit					; branch if object hasn't reached destination
		
		addq.b	#2,ost_routine(a0)			; goto Pillar_Finish next
		move.b	#2,(v_sbz3pillar_status).w
		
	.exit:
		rts
; ===========================================================================

Pillar_Finish:	; Routine 6
		bra.w	SolidNew
; ===========================================================================
		
Pillar_Final:
		cmpi.b	#2,(v_sbz3pillar_status).w
		bne.w	Pillar_Delete				; delete if original object hasn't reached final position
		rts
		