; ---------------------------------------------------------------------------
; Object 4E - advancing	wall of	lava (MZ)

; spawned by:
;	ObjPos_MZ2
;	LavaWall

; subtypes:
;	%SSSSXXXX
;	SSSS - speed (from LWall_Speeds)
;	XXXX - x pos to stop moving (from LWall_StopPos)
; ---------------------------------------------------------------------------

LavaWall:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	LWall_Index(pc,d0.w),d1
		jmp	LWall_Index(pc,d1.w)
; ===========================================================================
LWall_Index:	index *,,2
		ptr LWall_Main
		ptr LWall_Wait
		ptr LWall_Move
		ptr LWall_BackHalf
		
LWall_Speeds:	dc.w $180
LWall_StopPos:	dc.w $6A0

		rsobj LavaWall
ost_lwall_x_stop:	rs.w 1					; x position to stop moving
ost_lwall_time:		rs.w 1					; time spent moving
		rsobjend
; ===========================================================================

LWall_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto LWall_Wait next
		move.l	#Map_LWall,ost_mappings(a0)
		move.w	#tile_Kos_Lava+tile_pal4,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$50,ost_displaywidth(a0)
		move.b	#StrId_LavaWall,ost_name(a0)
		move.w	#priority_1,ost_priority(a0)
		move.b	#$28,ost_width(a0)
		move.b	#16,ost_height(a0)
		move.b	#id_React_Hurt,ost_col_type(a0)
		move.b	#64,ost_col_width(a0)
		move.b	#32,ost_col_height(a0)
		move.b	ost_subtype(a0),d0
		andi.w	#$F,d0					; read low nybble of subtype
		add.b	d0,d0
		move.w	LWall_StopPos(pc,d0.w),ost_lwall_x_stop(a0)
		
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.s	LWall_Wait
		move.l	#LavaWall,ost_id(a1)			; load back half of lava object
		move.b	#id_LWall_BackHalf,ost_routine(a1)
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	ost_displaywidth(a0),ost_displaywidth(a1)
		move.b	#StrId_LavaWall,ost_name(a1)
		move.w	ost_priority(a0),ost_priority(a1)
		move.b	ost_col_type(a0),ost_col_type(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	#id_frame_lavawall_back,ost_frame(a1)
		saveparent

LWall_Wait:	; Routine 2
		getsonic					; a1 = OST of Sonic
		range_y_test	96
		bcc.s	.wait					; branch if Sonic is > 96px on y
		range_x_test	192
		bcc.s	.wait					; branch if Sonic is > 192px on x
		addq.b	#2,ost_routine(a0)			; goto LWall_Move next
		move.b	ost_subtype(a0),d0
		andi.w	#$F0,d0
		lsr.b	#3,d0					; read high nybble of subtype
		lea	LWall_Speeds(pc),a2
		move.w	(a2,d0.w),ost_x_vel(a0)			; move right
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.wait					; branch if not xflipped
		neg.w	ost_x_vel(a0)				; move left
		
	.wait:
		lea	Ani_LWall(pc),a1
		bsr.w	AnimateSprite
		bra.w	DespawnFamily
; ===========================================================================

LWall_Move:	; Routine 4
		shortcut
		lea	Ani_LWall(pc),a1
		bsr.w	AnimateSprite
		cmpi.b	#id_Sonic_Hurt,(v_ost_player+ost_routine).w ; is Sonic hurt or dead?
		bcc.w	DisplaySprite				; if yes, branch
		bsr.w	SolidObject
		move.w	ost_lwall_x_stop(a0),d0
		beq.s	.dont_stop				; branch if no stop x pos is set
		cmp.w	ost_x_pos(a0),d0
		beq.w	DespawnFamily				; branch if at stop x pos
		
	.dont_stop:
		update_x_pos					; update position
		addq.w	#1,ost_lwall_time(a0)
		cmpi.w	#20*60,ost_lwall_time(a0)
		beq.w	DeleteFamily				; delete after moving for 20 seconds
		bra.w	DisplaySprite
; ===========================================================================

LWall_BackHalf:	; Routine 6
		shortcut
		getparent
		move.w	#-$80,d0
		btst	#status_xflip_bit,ost_status(a1)
		beq.s	.noxflip				; branch if not xflipped
		neg.w	d0
		
	.noxflip:
		add.w	ost_x_pos(a1),d0
		move.w	d0,ost_x_pos(a0)			; 128px to the left/right
		bra.w	DisplaySprite

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_LWall:	index *
		ptr ani_lavawall_0
		
ani_lavawall_0:	dc.w 9
		dc.w id_frame_lavawall_0
		dc.w id_frame_lavawall_1
		dc.w id_frame_lavawall_2
		dc.w id_frame_lavawall_3
		dc.w id_Anim_Flag_Restart
