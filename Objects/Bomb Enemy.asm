; ---------------------------------------------------------------------------
; Object 5F - walking bomb enemy (SLZ, SBZ)

; spawned by:
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SLZ3, ObjPos_SBZ1, ObjPos_SBZ2

; subtypes:
;	%0000FFFF
;	FFFF - fuse time/speed (see Bom_FuseTimes and Bom_FuseSpeeds)
; ---------------------------------------------------------------------------

Bomb:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Bom_Index(pc,d0.w),d1
		jmp	Bom_Index(pc,d1.w)
; ===========================================================================
Bom_Index:	index *,,2
		ptr Bom_Main
		ptr Bom_Wait
		ptr Bom_Walk
		ptr Bom_Explode

		rsobj Bomb
ost_bomb_time:	rs.w 1						; time left on fuse - also used for change direction timer
		rsobjend
; ===========================================================================

Bom_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Bom_Wait next
		move.l	#Map_Bomb,ost_mappings(a0)
		move.w	(v_tile_bomb).w,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.w	#priority_3,ost_priority(a0)
		move.b	#$C,ost_displaywidth(a0)
		move.b	#StrId_Bomb,ost_name(a0)
		move.b	#id_React_Hurt,ost_col_type(a0)
		move.b	#12,ost_col_width(a0)
		move.b	#12,ost_col_height(a0)
		bchg	#status_xflip_bit,ost_status(a0)
		move.w	#$10,ost_x_vel(a0)

Bom_Wait:	; Routine 2
		toggleframe	$13
		subq.w	#1,ost_bomb_time(a0)			; decrement timer
		bpl.s	Bom_ChkDist				; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Bom_Walk next
		move.b	#id_ani_bomb_walk,ost_anim(a0)		; use walking animation
		move.w	#1535,ost_bomb_time(a0)			; set time delay to 25.5 seconds
		bchg	#status_xflip_bit,ost_status(a0)
		neg.w	ost_x_vel(a0)				; change direction
		bra.s	Bom_ChkDist
; ===========================================================================

Bom_Walk:	; Routine 4
		lea	Ani_Bomb(pc),a1
		bsr.w	AnimateSprite
		update_x_pos
		subq.w	#1,ost_bomb_time(a0)			; decrement timer
		bpl.s	Bom_ChkDist				; branch if time remains
		subq.b	#2,ost_routine(a0)			; goto Bom_Wait next
		move.w	#179,ost_bomb_time(a0)			; set time delay to 3 seconds
		move.b	#id_frame_bomb_stand2,ost_frame(a0)

Bom_ChkDist:
		getsonic
		range_x_test	$60
		bcc.w	DespawnObject				; branch if Sonic is outside $60px
		range_y_test	$60
		bcc.w	DespawnObject
		tst.w	(v_debug_active).w
		bne.w	DespawnObject

		move.b	#id_Bom_Explode,ost_routine(a0)		; goto Bom_Explode next
		move.b	ost_subtype(a0),d1
		andi.w	#$F,d1
		add.w	d1,d1
		move.w	Bom_FuseTimes(pc,d1.w),d0		; get fuse time from list based on subtype
		move.w	d0,ost_bomb_time(a0)			; set fuse time
		move.b	#id_frame_bomb_activate1,ost_frame(a0)	; use activated animation
		bsr.w	FindNextFreeObj
		bne.w	DespawnObject
		move.l	#BombFuse,ost_id(a1)			; load fuse object
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.w	#priority_3,ost_priority(a1)
		move.b	#4,ost_displaywidth(a1)
		move.b	#StrId_Fuse,ost_name(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	ost_status(a0),ost_status(a1)
		saveparent
		move.b	#id_frame_bomb_fuse1,ost_frame(a1)
		move.w	ost_bomb_time(a0),ost_bomb_time(a1)	; set fuse time
		move.w	Bom_FuseSpeeds(pc,d1.w),d0		; get fuse speed from list based on subtype
		move.w	d0,ost_y_vel(a1)
		btst	#status_yflip_bit,ost_status(a0)	; is bomb upside-down?
		beq.w	DespawnObject				; if not, branch
		neg.w	ost_y_vel(a1)				; reverse direction for fuse
		bra.w	DespawnObject
		
Bom_FuseTimes:	dc.w 143, 71, 35
Bom_FuseSpeeds:	dc.w $10, $20, $40
; ===========================================================================

Bom_Explode:	; Routine 6
		shortcut
		toggleframe	$13
		subq.w	#1,ost_bomb_time(a0)			; decrement timer
		bpl.w	DespawnFamily				; branch if time remains
		bsr.w	Explode					; replace bomb with explosion (on next frame)
		moveq	#4-1,d1					; 4 shrapnel objects
		lea	Bom_ShrSpeed(pc),a2			; load shrapnel speed data

	.loop:
		bsr.w	FindFreeObj
		bne.w	DespawnFamily
		move.l	#BombShrapnel,ost_id(a1)		; load shrapnel	object
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.w	#priority_3,ost_priority(a1)
		move.b	#4,ost_displaywidth(a1)
		move.b	#StrId_BombFrag,ost_name(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	#id_frame_bomb_shrapnel1,ost_frame(a1)
		move.w	(a2)+,ost_x_vel(a1)
		move.w	(a2)+,ost_y_vel(a1)
		move.b	#id_React_Hurt,ost_col_type(a1)
		move.b	#4,ost_col_width(a1)
		move.b	#4,ost_col_height(a1)
		bset	#render_onscreen_bit,ost_render(a1)
		dbf	d1,.loop				; repeat 3 more	times
		bra.w	DespawnFamily
; ===========================================================================
Bom_ShrSpeed:	dc.w -$200, -$300				; top left
		dc.w -$100, -$200				; bottom left
		dc.w $200, -$300				; top right
		dc.w $100, -$200				; bottom right

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Bomb:	index *
		ptr ani_bomb_walk

ani_bomb_walk:
		dc.w $13
		dc.w id_frame_bomb_walk4
		dc.w id_frame_bomb_walk3
		dc.w id_frame_bomb_walk2
		dc.w id_frame_bomb_walk1
		dc.w id_Anim_Flag_Restart
		
; ---------------------------------------------------------------------------
; Bomb fuse and shrapnel objects
; ---------------------------------------------------------------------------

BombFuse:
		toggleframe	3				; animate
		update_y_pos					; update position
		subq.w	#1,ost_bomb_time(a0)			; decrement fuse timer
		bmi.w	DeleteObject				; branch if fuse runs out
		bra.w	DespawnQuick
; ===========================================================================

BombShrapnel:
		toggleframe	3
		update_xy_fall	$18				; update position & apply gravity
		tst.b	ost_render(a0)				; is object on-screen?
		bpl.w	DeleteObject				; if not, branch
		bra.w	DisplaySprite
