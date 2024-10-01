; ---------------------------------------------------------------------------
; Object 35 - fireball that sits on the	floor (MZ)
; (appears when	you walk on sinking platforms)

; spawned by:
;	LargeGrass - routine 0
;	GrassFire - routine 4
; ---------------------------------------------------------------------------

GrassFire:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	GFire_Index(pc,d0.w),d1
		jmp	GFire_Index(pc,d1.w)
; ===========================================================================
GFire_Index:	index *,,2
		ptr GFire_Main
		ptr GFire_Spread
		ptr GFire_Hover

		rsobj GrassFire
ost_burn_x_start:	rs.w 1					; original x position
ost_burn_y_diff:	rs.w 1					; y distance from parent to fire
ost_burn_coll_ptr:	rs.l 1					; pointer to collision data
		rsobjend
; ===========================================================================

GFire_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto GFire_Spread next
		move.l	#Map_Fire,ost_mappings(a0)
		move.w	(v_tile_fireball).w,ost_tile(a0)
		move.w	ost_x_pos(a0),ost_burn_x_start(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_1,ost_priority(a0)
		move.b	#id_React_Hurt,ost_col_type(a0)
		move.b	#8,ost_col_width(a0)
		move.b	#8,ost_col_height(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#StrId_Fire,ost_name(a0)
		subq.w	#1,ost_x_pos(a0)
		play_sound sfx_Burning				; play burning sound

GFire_Spread:	; Routine 2
		addq.w	#1,ost_x_pos(a0)			; move 1px right
		getparent					; a1 = OST of platform object
		movea.l	ost_burn_coll_ptr(a0),a2		; a2 = pointer to platform heightmap
		move.w	ost_x_pos(a0),d1
		sub.w	ost_burn_x_start(a0),d1			; d0 = relative x position on platform
		move.w	d1,d0
		lsr.w	#1,d1
		moveq	#0,d2
		move.b	(a2,d1.w),d2				; get value from heightmap
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		sub.w	d2,ost_y_pos(a0)			; match y pos to heightmap
		andi.w	#$F,d0
		cmpi.b	#8,d0
		bne.s	.skip_fire				; branch if not aligned to 8px
		
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.s	.skip_fire				; branch if not found
		move.l	#GrassFire,ost_id(a1)			; create another fire
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.l	#Map_Fire,ost_mappings(a1)
		move.w	(v_tile_fireball).w,ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.w	#priority_1,ost_priority(a1)
		move.b	#id_React_Hurt,ost_col_type(a1)
		move.b	#8,ost_col_width(a1)
		move.b	#8,ost_col_height(a1)
		move.b	#8,ost_displaywidth(a1)
		move.b	#StrId_Fire,ost_name(a1)
		move.w	ost_parent(a0),ost_parent(a1)
		move.b	#id_GFire_Hover,ost_routine(a1)
		move.w	d2,ost_burn_y_diff(a1)			; save heightmap value
		
	.skip_fire:
		cmpi.w	#$78/2,d1
		bne.s	GFire_Animate				; branch if fire hasn't reached right edge
		addq.b	#2,ost_routine(a0)			; goto GFire_Hover next
		move.w	d2,ost_burn_y_diff(a0)			; save heightmap value
		bra.s	GFire_Animate
; ===========================================================================

GFire_Hover:	; Routine 4
		shortcut
		getparent					; a1 = OST of platform object
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		move.w	ost_burn_y_diff(a0),d0			; get value from heightmap
		sub.w	d0,ost_y_pos(a0)			; update position

GFire_Animate:
		lea	Ani_GFire(pc),a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_GFire:	index *
		ptr ani_gfire_0
		ptr ani_gfire_collide
		
ani_gfire_0:	dc.w 5
		dc.w id_frame_fire_vertical1
		dc.w id_frame_fire_vertical1+afxflip
		dc.w id_frame_fire_vertical2
		dc.w id_frame_fire_vertical2+afxflip
		dc.w id_Anim_Flag_Restart

ani_gfire_collide:
		dc.w 5
		dc.w id_frame_fire_vertcollide
		dc.w id_Anim_Flag_Routine
