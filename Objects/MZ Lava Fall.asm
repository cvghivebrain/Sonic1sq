; ---------------------------------------------------------------------------
; Lava fall (MZ)

; spawned by:
;	ObjPos_MZ2, ObjPos_MZ3 - subtype 1

; subtypes:
;	%00HHTTTT
;	HH - height to fall from (see LFall_Heights)
;	TTTT - time between lava falls (+1, *120 for ost_lfall_time_master)
; ---------------------------------------------------------------------------

LavaFall:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	LFall_Index(pc,d0.w),d1
		jmp	LFall_Index(pc,d1.w)
; ===========================================================================
LFall_Index:	index *,,2
		ptr LFall_Main
		ptr LFall_Action
		ptr LFall_Front
		ptr LFall_FrontStop
		ptr LFall_Delete
		ptr LFall_Column
		ptr LFall_Tail
		
LFall_Heights:	dc.w 360, 360, 360, 360

		rsobj LavaFall
ost_lfall_time_master:	rs.w 1					; time between lava falls
ost_lfall_time:		rs.w 1
ost_lfall_y_stop:	equ ost_lfall_time_master		; y pos to stop at lava
ost_lfall_y_dist:	rs.w 1					; y dist to drop from
		rsobjend
; ===========================================================================

LFall_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto LFall_Action next
		move.b	ost_subtype(a0),d0
		move.w	d0,d1
		andi.b	#$F,d0
		addq.b	#1,d0					; d0 = subtype +1
		mulu.w	#120,d0					; multiply by 2 seconds
		move.w	d0,ost_lfall_time_master(a0)
		move.w	d0,ost_lfall_time(a0)
		andi.b	#%00110000,d1
		lsr.b	#3,d1
		move.w	LFall_Heights(pc,d1.w),ost_lfall_y_dist(a0)

LFall_Action:	; Routine 2
		shortcut
		getsonic					; a1 = OST of Sonic
		move.w	ost_y_pos(a0),d0
		sub.w	ost_y_pos(a1),d0			; d0 = y dist between Sonic & object (-ve if Sonic is below)
		move.w	ost_lfall_y_dist(a0),d1
		cmp.w	d1,d0
		bgt.w	.wait					; branch if Sonic is > 360px above
		subq.w	#1,ost_lfall_time(a0)			; decrement timer
		bpl.w	.wait					; branch if time remains
		move.w	ost_lfall_time_master(a0),ost_lfall_time(a0) ; reset timer
		play.w	1, jsr, sfx_Burning			; play flame sound
		
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.w	.wait
		move.l	#LavaFall,ost_id(a1)			; load front of lava fall object
		move.l	#Map_Geyser,ost_mappings(a1)
		move.w	#tile_Kos_Lava+tile_pal4,ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#status_yflip,ost_status(a1)
		move.b	#0,ost_priority(a1)
		move.b	#$20,ost_displaywidth(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	ost_y_pos(a0),ost_lfall_y_stop(a1)
		move.w	ost_lfall_y_dist(a0),d0
		sub.w	d0,ost_y_pos(a1)			; start from above
		move.b	#id_LFall_Front,ost_routine(a1)
		movea.l	a1,a2					; save OST of front
		
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.w	.wait
		move.l	#LavaFall,ost_id(a1)			; load lava column object
		move.l	ost_mappings(a2),ost_mappings(a1)
		move.w	ost_tile(a2),ost_tile(a1)
		move.b	#render_rel+render_useheight,ost_render(a1)
		move.b	#1,ost_priority(a1)
		move.b	#$20,ost_displaywidth(a1)
		move.b	#$80,ost_height(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a2),ost_y_pos(a1)
		subi.w	#$80,ost_y_pos(a1)
		move.b	#id_LFall_Column,ost_routine(a1)
		move.b	#id_col_32x112+id_col_hurt,ost_col_type(a1)
		move.b	#id_ani_lfall_column,ost_anim(a1)
		move.w	a2,ost_parent(a1)			; set front of lava as parent
		
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.s	.wait
		move.l	#LavaFall,ost_id(a1)			; load lava tail object
		move.l	ost_mappings(a2),ost_mappings(a1)
		move.w	ost_tile(a2),ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.b	#$20,ost_displaywidth(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a2),ost_y_pos(a1)
		subi.w	#$E0,ost_y_pos(a1)
		move.w	ost_y_pos(a0),ost_lfall_y_stop(a1)
		move.b	#id_LFall_Tail,ost_routine(a1)
		move.w	a2,ost_parent(a1)			; set front of lava as parent
		
	.wait:
		rts
; ===========================================================================

LFall_Front:	; Routine 4
		move.w	ost_lfall_y_stop(a0),d0
		cmp.w	ost_y_pos(a0),d0
		bcs.s	.finish					; branch if lava fall drops below stop y pos
		update_y_fall	$18				; update position and apply gravity
		lea	Ani_LFall(pc),a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
		
	.finish:
		move.w	ost_lfall_y_stop(a0),ost_y_pos(a0)
		move.b	#id_ani_fount_wait,ost_anim(a0)		; use lava bubbling animation
		bset	#tile_hi_bit,ost_tile(a0)
		bclr	#status_yflip_bit,ost_status(a0)
		move.b	#$38,ost_displaywidth(a0)
		move.b	#id_LFall_FrontStop,ost_routine(a0)	; goto LFall_FrontStop next

LFall_FrontStop:
		; Routine 6
		lea	Ani_Fount,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

LFall_Delete:	; Routine 8
		bra.w	DeleteFamily				; delete all objects (except spawner)
; ===========================================================================

LFall_Column:	; Routine $A
		shortcut
		update_y_fall	$18				; update position and apply gravity
		lea	Ani_LFall(pc),a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

LFall_Tail:	; Routine $C
		shortcut
		move.w	ost_lfall_y_stop(a0),d0
		cmp.w	ost_y_pos(a0),d0
		bcs.s	.finish					; branch if lava fall drops below stop y pos
		update_y_fall	$18				; update position and apply gravity
		lea	Ani_LFall(pc),a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
		
	.finish:
		getparent					; a1 = OST of lava front
		move.b	#id_ani_fount_finish,ost_anim(a1)	; lava front finishes animating and runs LFall_Delete
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_LFall:	index *
		ptr ani_lfall_front
		ptr ani_lfall_column

ani_lfall_front:
		dc.w 2
		dc.w id_frame_geyser_end1
		dc.w id_frame_geyser_end2
		dc.w id_Anim_Flag_Restart

ani_lfall_column:
		dc.w 7
		dc.w id_frame_geyser_longcolumn1
		dc.w id_frame_geyser_longcolumn2
		dc.w id_Anim_Flag_Restart