; ---------------------------------------------------------------------------
; Tile switcher for loops (GHZ/SLZ)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3
; ---------------------------------------------------------------------------

TileSwitch:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	TSwi_Index(pc,d0.w),d1
		jmp	TSwi_Index(pc,d1.w)
; ===========================================================================
TSwi_Index:	index *,,2
		ptr TSwi_Main
		ptr TSwi_Detect
		
		rsobj TileSwitch
ost_tswi_left:		rs.w 1					; x pos of left edge of tile
ost_tswi_top:		rs.w 1					; y pos of top edge of tile
ost_tswi_tile_ptr:	rs.w 1					; RAM address for specific tile within layout
ost_tswi_tile_alt:	rs.b 1					; id for second tile (first tile is in ost_subtype)
		rsobjend
; ===========================================================================

TSwi_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto TSwi_Detect next
		move.w	ost_x_pos(a0),d0
		andi.w	#$FF00,d0				; x pos of left edge of tile
		move.w	d0,ost_tswi_left(a0)
		move.w	ost_y_pos(a0),d1
		andi.w	#$FF00,d1				; y pos of top edge of tile
		move.w	d1,ost_tswi_top(a0)
		lsr.w	#8,d0
		lsr.w	#1,d1
		add.w	d1,d0					; d0 = position within layout
		lea	(v_level_layout).w,a2
		adda.w	d0,a2					; jump to RAM address for specific tile within layout
		move.w	a2,ost_tswi_tile_ptr(a0)		; save pointer
		move.b	ost_subtype(a0),ost_tswi_tile_alt(a0)
		addq.b	#1,ost_tswi_tile_alt(a0)

TSwi_Detect:	; Routine 2
		lea	(v_ost_player).w,a1
		move.w	ost_x_pos(a1),d0
		sub.w	ost_tswi_left(a0),d0			; d0 = Sonic's x pos within tile
		bmi.w	DespawnQuick_NoDisplay			; branch if outside left
		cmpi.w	#256,d0
		bcc.w	DespawnQuick_NoDisplay			; branch if outside right
		move.w	ost_y_pos(a1),d1
		sub.w	ost_tswi_top(a0),d1			; d1 = Sonic's y pos within tile
		bmi.w	DespawnQuick_NoDisplay			; branch if outside top
		cmpi.w	#256,d1
		bcc.w	DespawnQuick_NoDisplay			; branch if outside bottom
		
		cmpi.w	#64,d1
		bcc.w	.bottom_section				; branch if in bottom three quarters
		cmpi.w	#128-16,d0
		bcs.w	DespawnQuick_NoDisplay
		cmpi.w	#128+16,d0
		bcc.w	DespawnQuick_NoDisplay			; branch if not in centre
		tst.w	ost_x_vel(a1)
		bmi.s	.right_section				; branch if Sonic is moving left
		bra.s	.left_section
		
	.bottom_section:
		cmpi.w	#32,d0
		bcs.s	.left_section				; branch if on left side
		cmpi.w	#256-32,d0
		bcs.w	DespawnQuick_NoDisplay			; branch if not on right side
		
	.right_section:
		move.b	ost_tswi_tile_alt(a0),d0		; use alternate value
		bra.s	.update_layout
		
	.left_section:
		move.b	ost_subtype(a0),d0			; use default value
		
	.update_layout:
		moveq	#-1,d1
		move.w	ost_tswi_tile_ptr(a0),d1
		movea.l	d1,a2
		move.b	d0,(a2)					; write value to layout
		bra.w	DespawnQuick_NoDisplay
