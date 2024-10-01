; ---------------------------------------------------------------------------
; Object 83 - blocks that disintegrate when Eggman presses a button (SBZ2)

; spawned by:
;	ObjPos_SBZ2

; subtypes:
;	%TTTTBBBB
;	TTTT - time delay for collapse
;	BBBB - button id that triggers collapse
; ---------------------------------------------------------------------------

FalseFloor:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	FFloor_Index(pc,d0.w),d1
		jmp	FFloor_Index(pc,d1.w)
; ===========================================================================
FFloor_Index:	index *,,2
		ptr FFloor_Main
		ptr FFloor_Solid
		ptr FFloor_Break

		rsobj FalseFloor
ost_ffloor_time:	rs.w 1					; time to wait until collapsing
		rsobjend
; ===========================================================================

FFloor_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto FFloor_Solid next
		move.l	#Map_FFloor,ost_mappings(a0)
		move.w	#tile_Kos_SbzBlock+tile_pal3,ost_tile(a0)
		move.w	#priority_0,ost_priority(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#StrId_Block,ost_name(a0)
		move.b	#$10,ost_width(a0)
		move.b	#$10,ost_height(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	ost_subtype(a0),d0
		andi.w	#$F0,d0					; read high nybble of subtype
		move.w	d0,ost_ffloor_time(a0)
		andi.b	#$F,ost_subtype(a0)			; clear high nybble

FFloor_Solid:	; Routine 2
		jsr	SolidObject
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		lea	(v_button_state).w,a3
		adda.w	d0,a3					; (a3) = button status
		tst.b	(a3)
		beq.s	.wait					; branch if button isn't pressed
		addq.b	#2,ost_routine(a0)			; goto FFloor_Break next
		
	.wait:
		jmp	DespawnObject
; ===========================================================================

FFloor_Break:	; Routine 4
		subq.w	#1,ost_ffloor_time(a0)			; decrement timer
		bmi.s	.break					; branch if time hits -1
		jsr	SolidObject
		jmp	DespawnObject
		
	.break:
		jsr	UnSolid
		moveq	#4-1,d1					; 4 fragments
		lea	FFloor_FragData(pc),a2
		
	.loop:
		jsr	FindNextFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#CrumbFall,ost_id(a1)			; load fragment object
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	#8,ost_displaywidth(a1)
		move.b	#StrId_Frag,ost_name(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.w	ost_priority(a0),ost_priority(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	(a2)+,ost_y_vel(a1)
		move.w	(a2)+,d0
		add.w	d0,ost_x_pos(a1)
		move.w	(a2)+,d0
		add.w	d0,ost_y_pos(a1)
		move.w	(a2)+,ost_frame_hi(a1)
		dbf	d1,.loop				; repeat sequence 3 more times
		
	.fail:
		play_sound sfx_Smash				; play smashing sound
		jmp	DeleteObject				; delete original block
		
FFloor_FragData:
		dc.w $80, -8, -8, id_frame_ffloor_topleft	; y speed, x pos, y pos, frame
		dc.w 0, 8, -8, id_frame_ffloor_topright
		dc.w $120, -8, 8, id_frame_ffloor_bottomleft
		dc.w $C0, 8, 8, id_frame_ffloor_bottomright
