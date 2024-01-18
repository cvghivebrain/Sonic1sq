; ---------------------------------------------------------------------------
; Tile switcher for loops (GHZ/SLZ)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3 - subtype 0
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SLZ3 - subtypes 1/2
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
ost_tswi_tile_ptr:	rs.l 1					; RAM address for specific tile within layout
ost_tswi_tile_default:	rs.b 1					; id for default tile
ost_tswi_tile_alt:	rs.b 1					; id for replacement tile
ost_tswi_flag:		rs.b 1					; flag set when hotspot has already triggered
		rsobjend
		
TSwi_Info_0:	; GHZ loops
		dc.b $35, $36					; default/replacement tile ids
		dc.b 16, 128, 32/2, 128/2, id_Hotspot_Default	; hotspot #1 (x pos, y pos, width, height, type)
		dc.b 256-16, 128, 32/2, 128/2, id_Hotspot_Replace ; hotspot #2
		dc.b 128, 32, 32/2, 64/2, id_Hotspot_LR		; hotspot #3
		even
TSwi_Info_1:	; SLZ loops (left-right)
		dc.b $2A, $2B					; default/replacement tile ids
		dc.b 16, 160, 32/2, 128/2, id_Hotspot_Default	; hotspot #1 (x pos, y pos, width, height, type)
		dc.b 256-16, 160, 32/2, 128/2, id_Hotspot_Replace ; hotspot #2
		dc.b 128, 48, 32/2, 96/2, id_Hotspot_LR		; hotspot #3
		even
TSwi_Info_2:	; SLZ loops (left-down)
		dc.b $34, $35					; default/replacement tile ids
		dc.b 16, 142, 32/2, 160/2, id_Hotspot_Default	; hotspot #1 (x pos, y pos, width, height, type)
		dc.b 80, 255, 96/2, 30/2, id_Hotspot_Replace	; hotspot #2
		dc.b 128, 48, 32/2, 96/2, id_Hotspot_LR		; hotspot #3
		even
; ===========================================================================

TSwi_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto TSwi_Detect next
		move.w	ost_x_pos(a0),d0
		andi.w	#$FF00,d0				; x pos of left edge of tile
		move.w	d0,d2
		move.w	ost_y_pos(a0),d1
		andi.w	#$FF00,d1				; y pos of top edge of tile
		move.w	d1,d3
		lsr.w	#8,d0
		lsr.w	#1,d1
		add.w	d1,d0					; d0 = position within layout
		lea	(v_level_layout).w,a2
		adda.w	d0,a2					; jump to RAM address for specific tile within layout
		move.l	a2,ost_tswi_tile_ptr(a0)		; save pointer
		
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		mulu.w	#TSwi_Info_1-TSwi_Info_0,d0
		lea	TSwi_Info_0(pc,d0.w),a2
		move.b	(a2)+,d4
		move.b	(a2)+,d5
		moveq	#3-1,d1
		
	.loop:
		bsr.w	FindNextFreeObj
		bne.s	TSwi_Detect
		move.l	#TileSwitchHotspot,ost_id(a1)		; load hotspot object
		moveq	#0,d0
		move.b	(a2)+,d0
		move.w	d0,ost_x_pos(a1)
		add.w	d2,ost_x_pos(a1)
		move.b	(a2)+,d0
		move.w	d0,ost_y_pos(a1)
		add.w	d3,ost_y_pos(a1)
		move.b	d4,ost_tswi_tile_default(a1)
		move.b	d5,ost_tswi_tile_alt(a1)
		move.l	ost_tswi_tile_ptr(a0),ost_tswi_tile_ptr(a1)
		move.b	(a2)+,ost_width(a1)
		move.b	(a2)+,ost_height(a1)
		move.b	(a2)+,ost_subtype(a1)
		saveparent
		dbf	d1,.loop				; repeat for all hotspots

TSwi_Detect:	; Routine 2
		shortcut	DespawnFamily_NoDisplay
		bra.w	DespawnFamily_NoDisplay			; delete object and all hotspots if out of range

; ---------------------------------------------------------------------------
; Tile switcher hotspot object (GHZ/SLZ)

; spawned by:
;	TileSwitch
; ---------------------------------------------------------------------------

TileSwitchHotspot:
		getsonic					; a1 = OST of Sonic
		range_x_quick					; d0 = x dist
		moveq	#0,d1
		move.b	ost_width(a0),d1
		add.w	d1,d0
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.s	.outside				; branch if Sonic is outside x range
		range_y_quick					; d2 = y dist
		move.b	ost_height(a0),d1
		add.w	d1,d2
		add.w	d1,d1
		cmp.w	d1,d2
		bcc.s	.outside				; branch if Sonic is outside y range
		
		bset	#0,ost_tswi_flag(a0)
		bne.s	.already_done				; branch if hotspot has already been hit
		movea.l	ost_tswi_tile_ptr(a0),a3		; a3 = RAM address in layout
		move.b	ost_subtype(a0),d0
		move.w	Hotspot_Index(pc,d0.w),d1
		jmp	Hotspot_Index(pc,d1.w)
		
	.outside:
		clr.b	ost_tswi_flag(a0)
		
	.already_done:
		rts
; ===========================================================================
Hotspot_Index:	index *,,2
		ptr Hotspot_Default
		ptr Hotspot_Replace
		ptr Hotspot_LR
		ptr Hotspot_Delete
		
Hotspot_Default:
		move.b	ost_tswi_tile_default(a0),(a3)		; set tile to default value
		rts
		
Hotspot_LR:
		tst.w	ost_x_vel(a1)
		bpl.s	Hotspot_Default				; branch if Sonic is moving right
		
Hotspot_Replace:
		move.b	ost_tswi_tile_alt(a0),(a3)		; set tile to replacement value
		rts
		
Hotspot_Delete:
		bra.w	DeleteObject				; use id_Hotspot_Delete if you don't need 3 hotspots
		
