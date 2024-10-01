; ---------------------------------------------------------------------------
; Object 55 - Batbrain enemy (MZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3
; ---------------------------------------------------------------------------

Batbrain:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Bat_Index(pc,d0.w),d1
		jmp	Bat_Index(pc,d1.w)
; ===========================================================================
Bat_Index:	index *,,2
		ptr Bat_Main
		ptr Bat_Hang
		ptr Bat_Drop
		ptr Bat_Flap
		ptr Bat_FlyUp
		
bat_height:	equ $C
; ===========================================================================

Bat_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Bat_Hang next
		move.l	#Map_Bat,ost_mappings(a0)
		move.w	(v_tile_batbrain).w,ost_tile(a0)
		addi.w	#tile_hi,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#bat_height,ost_height(a0)
		move.w	#priority_2,ost_priority(a0)
		move.b	#id_React_Enemy,ost_col_type(a0)
		move.b	#8,ost_col_width(a0)
		move.b	#8,ost_col_height(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#StrId_Batbrain,ost_name(a0)

Bat_Hang:	; Routine 2
		getsonic					; a1 = OST of Sonic
		range_y_quick
		bmi.w	DespawnObject				; branch if Sonic is above
		cmpi.w	#128,d2
		bge.w	DespawnObject				; branch if > 128px below
		range_x_test	128
		bcc.w	DespawnObject				; branch if > 128px away
		tst.w	(v_debug_active).w
		bne.w	DespawnObject				; branch if debug mode is in use

		move.b	#id_frame_bat_fly1,ost_frame(a0)
		addq.b	#2,ost_routine(a0)			; goto Bat_Drop next
		bset	#status_xflip_bit,ost_status(a0)	; face right
		tst.w	d0
		bpl.w	DespawnObject				; branch if Sonic is right
		bclr	#status_xflip_bit,ost_status(a0)	; face left
		bra.w	DespawnObject
; ===========================================================================

Bat_Drop:	; Routine 4
		update_xy_fall	$18				; update position & apply gravity
		getsonic					; a1 = OST of Sonic
		range_y_quick
		bmi.s	.chkdel					; branch if Sonic is above
		cmpi.w	#16,d2
		bcc.w	DespawnObject				; branch if > 16px below
		move.w	#$100,d1				; batbrain will fly right
		btst	#status_xflip_bit,ost_status(a0)
		bne.s	.noflip					; branch if facing right
		neg.w	d1					; batbrain will fly left

	.noflip:
		move.w	d1,ost_x_vel(a0)			; make batbrain fly horizontally
		move.w	#0,ost_y_vel(a0)			; stop batbrain falling
		move.b	#id_ani_bat_fly,ost_anim(a0)
		addq.b	#2,ost_routine(a0)			; goto Bat_Flap next
		bra.w	DespawnObject

	.chkdel:
		tst.b	ost_render(a0)
		bpl.w	DeleteObject				; branch if batbrain is off screen
		bra.w	DespawnObject
; ===========================================================================

Bat_Flap:	; Routine 6
		lea	Ani_Bat(pc),a1
		bsr.w	AnimateSprite
		move.b	(v_vblank_counter_byte).w,d3		; get byte that increments every frame
		andi.b	#$F,d3					; read only low nybble
		bne.s	.nosound				; branch if not 0
		play_sound sfx_basaran				; play flapping sound every 16th frame

	.nosound:
		update_x_pos					; update position
		getsonic
		range_x
		cmp.w	#128,d1
		blt.w	DespawnObject				; branch if < 128px away
		add.b	d7,d3					; add OST index number (so each batbrain updates on a different frame)
		andi.b	#7,d3					; read only bits 0-2
		bne.w	DespawnObject				; branch if any are set
		addq.b	#2,ost_routine(a0)			; goto Bat_FlyUp next
		bra.w	DespawnObject
; ===========================================================================

Bat_FlyUp:	; Routine 8
		update_xy_fall	-$18				; make batbrain fly upwards
		getpos_top bat_height				; d0 = x pos; d1 = y pos of top
		moveq	#1,d6
		bsr.w	CeilingDist
		tst.w	d5					; has batbrain hit the ceiling?
		bpl.w	DespawnObject				; if not, branch
		sub.w	d5,ost_y_pos(a0)			; align to ceiling
		andi.w	#$FFF8,ost_x_pos(a0)			; snap to tile
		clr.w	ost_x_vel(a0)				; stop batbrain moving
		clr.w	ost_y_vel(a0)
		move.b	#id_frame_bat_hanging,ost_frame(a0)
		move.b	#id_Bat_Hang,ost_routine(a0)		; goto Bat_Hang next
		bra.w	DespawnObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Bat:	index *
		ptr ani_bat_fly

ani_bat_fly:	dc.w 3
		dc.w id_frame_bat_fly1
		dc.w id_frame_bat_fly2
		dc.w id_frame_bat_fly3
		dc.w id_frame_bat_fly2
		dc.w id_Anim_Flag_Restart
