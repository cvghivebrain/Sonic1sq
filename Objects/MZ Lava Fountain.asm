; ---------------------------------------------------------------------------
; Lava fountain (MZ)

; spawned by:
;	PushBlock, LavaFountain
; ---------------------------------------------------------------------------

LavaFountain:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Fount_Index(pc,d0.w),d1
		jmp	Fount_Index(pc,d1.w)
; ===========================================================================
Fount_Index:	index *,,2
		ptr Fount_Main
		ptr Fount_Animate
		ptr Fount_Make
		ptr Fount_Wait
		ptr Fount_Delete
		ptr Fount_Top
		ptr Fount_Column

		rsobj LavaFountain
ost_fount_time:		rs.w 1					; general timer
ost_fount_y_start:	rs.w 1					; original y pos
		rsobjend
; ===========================================================================

Fount_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Fount_Animate next
		move.l	#Map_Geyser,ost_mappings(a0)
		move.w	#tile_Kos_Lava+tile_pal4+tile_hi,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#1,ost_priority(a0)
		move.b	#$38,ost_displaywidth(a0)

Fount_Animate:	; Routine 2
Fount_Wait:	; Routine 6
		lea	Ani_Fount(pc),a1
		bsr.w	AnimateSprite				; animate and goto Fount_Make/Fount_Delete when finished
		bra.w	DisplaySprite
; ===========================================================================

Fount_Make:	; Routine 4
		move.b	#id_ani_fount_wait,ost_anim(a0)
		move.w	#120,ost_fount_time(a0)			; set timer to 2 seconds
		addq.b	#2,ost_routine(a0)			; goto Fount_Wait next
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.s	Fount_Wait				; branch if not found
		move.l	#LavaFountain,ost_id(a1)		; load actual fountain object
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	ost_priority(a0),ost_priority(a1)
		move.b	#$20,ost_displaywidth(a0)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	ost_y_pos(a0),ost_fount_y_start(a1)
		move.w	#-$500,ost_y_vel(a1)			; move upwards
		move.b	#id_ani_fount_top,ost_anim(a1)
		move.b	#id_Fount_Top,ost_routine(a1)
		saveparent
		play.w	1, jsr, sfx_Burning			; play flame sound
		bra.s	Fount_Wait
; ===========================================================================

Fount_Delete:	; Routine 8
		bra.w	DeleteObject
; ===========================================================================

Fount_Top:	; Routine $A
		bsr.w	FindNextFreeObj
		bne.s	.fail
		move.l	#LavaFountain,ost_id(a1)		; load column object
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		bclr	#tile_hi_bit,ost_tile(a1)
		move.b	ost_render(a0),ost_render(a1)
		bset	#render_useheight_bit,ost_render(a1)
		move.b	#$80,ost_height(a1)
		move.b	ost_priority(a0),ost_priority(a1)
		move.b	#$20,ost_displaywidth(a0)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		addi.w	#96,ost_y_pos(a1)			; 96px below top
		move.b	#id_Fount_Column,ost_routine(a1)
		move.b	#id_col_32x112+id_col_hurt,ost_col_type(a1)
		move.b	#id_ani_fount_column,ost_anim(a1)
		saveparent
		
	.fail:
		shortcut
		move.w	ost_fount_y_start(a0),d0
		cmp.w	ost_y_pos(a0),d0
		bcs.s	.finish					; branch if fountain drops below starting y pos
		update_y_fall	$18				; update position and apply gravity
		lea	Ani_Fount(pc),a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
		
	.finish:
		getparent					; a1 = OST of fountain source object
		move.b	#id_ani_fount_finish,ost_anim(a1)	; final animation and delete parent
		bra.w	DeleteFamily				; delete top & column
; ===========================================================================

Fount_Column:	; Routine $C
		shortcut
		getparent					; a1 = OST of top of fountain
		move.w	ost_y_pos(a1),d0
		addi.w	#96,d0
		move.w	d0,ost_y_pos(a0)			; match y pos to 96px below top
		lea	Ani_Fount(pc),a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
		

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Fount:	index *
		ptr ani_fount_start
		ptr ani_fount_wait
		ptr ani_fount_finish
		ptr ani_fount_top
		ptr ani_fount_column
		
ani_fount_start:
		dc.w 2
		dc.w id_frame_geyser_bubble1
		dc.w id_frame_geyser_bubble2
		dc.w id_frame_geyser_bubble1
		dc.w id_frame_geyser_bubble2
		dc.w id_frame_geyser_bubble5
		dc.w id_frame_geyser_bubble6
		dc.w id_frame_geyser_bubble5
		dc.w id_frame_geyser_bubble6
		dc.w id_Anim_Flag_Routine

ani_fount_wait:
		dc.w 2
		dc.w id_frame_geyser_bubble3
		dc.w id_frame_geyser_bubble4
		dc.w id_Anim_Flag_Restart

ani_fount_finish:
		dc.w 2
		dc.w id_frame_geyser_bubble3
		dc.w id_frame_geyser_bubble4
		dc.w id_frame_geyser_bubble1
		dc.w id_frame_geyser_bubble2
		dc.w id_frame_geyser_bubble1
		dc.w id_frame_geyser_bubble2
		dc.w id_Anim_Flag_Routine

ani_fount_top:
		dc.w 2
		dc.w id_frame_geyser_bubble7
		dc.w id_frame_geyser_bubble8
		dc.w id_Anim_Flag_Restart

ani_fount_column:
		dc.w 7
		dc.w id_frame_geyser_medcolumn1
		dc.w id_frame_geyser_medcolumn2
		dc.w id_Anim_Flag_Restart