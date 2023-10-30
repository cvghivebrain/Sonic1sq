; ---------------------------------------------------------------------------
; Object 5E - seesaws (SLZ)

; spawned by:
;	ObjPos_SLZ2, ObjPos_SLZ3 - subtypes 0/$FF
;	Seesaw - routine 4 (spikeball)
; ---------------------------------------------------------------------------

Seesaw:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	See_Index(pc,d0.w),d1
		jmp	See_Index(pc,d1.w)
; ===========================================================================
See_Index:	index *,,2
		ptr See_Main
		ptr See_Action
		ptr See_Ball
		ptr See_BallAir

		rsobj Seesaw
ost_seesaw_impact:	rs.w 1					; speed Sonic hits the seesaw
ost_seesaw_side:	rs.b 1					; Sonic's position on seesaw (0 = none; 1 = left; 2 = right; 5 = middle left; 6 = middle right)
		rsobjend
; ===========================================================================

See_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto See_Action next
		move.l	#Map_Seesaw,ost_mappings(a0)
		move.w	#tile_Kos_Seesaw,ost_tile(a0)
		move.b	ost_status(a0),ost_render(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#$30,ost_displaywidth(a0)
		move.b	#$30,ost_width(a0)
		move.b	#$15,ost_height(a0)
		tst.b	ost_subtype(a0)
		bmi.s	See_Action				; branch if subtype is -1
		
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.s	See_Action				; branch if not found
		move.l	#Seesaw,ost_id(a1)			; load spikeball object
		move.b	#id_See_Ball,ost_routine(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		addi.w	#$28,ost_x_pos(a1)			; move spikeball to right side
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		subi.w	#8,ost_y_pos(a1)
		move.b	ost_status(a0),ost_status(a1)
		move.l	#Map_SSawBall,ost_mappings(a1)
		move.w	#tile_Kos_SlzSpike,ost_tile(a1)
		ori.b	#render_rel,ost_render(a1)
		move.b	#4,ost_priority(a1)
		move.b	#id_col_8x8+id_col_hurt,ost_col_type(a1)
		move.b	#$C,ost_displaywidth(a1)
		move.b	#id_frame_seesaw_silver,ost_frame(a1)
		move.b	#2,ost_subtype(a1)
		saveparent
		btst	#render_xflip_bit,ost_render(a0)
		beq.s	See_Action				; branch if not xflipped
		subi.w	#$50,ost_x_pos(a1)			; move spikeball to left side
		move.b	#1,ost_subtype(a1)

See_Action:	; Routine 2
		shortcut
		bsr.s	See_Solid
		moveq	#0,d0
		tst.b	d1
		beq.s	.no_collision				; branch if Sonic isn't on the seesaw
		move.w	ost_sonic_impact(a1),ost_seesaw_impact(a0)
		move.b	#id_frame_seesaw_sloping_leftup,ost_frame(a0)
		moveq	#1,d0					; collision flag
		bset	#render_xflip_bit,ost_render(a0)	; right side up, left side down
		cmpi.w	#$38,d4
		blt.s	.not_right				; branch if Sonic isn't on right side
		bclr	#render_xflip_bit,ost_render(a0)	; left side up, right side down
		addq.b	#1,d0
		move.b	d0,ost_seesaw_side(a0)			; remember which side Sonic is on
		bra.w	DespawnQuick
		
	.not_right:
		cmpi.w	#$28,d4
		ble.s	.no_collision				; branch if Sonic isn't in the middle
		move.b	#id_frame_seesaw_flat,ost_frame(a0)
		addq.b	#4,d0
		
	.no_collision:
		move.b	d0,ost_seesaw_side(a0)			; remember which side Sonic is on
		bra.w	DespawnQuick
		
; ---------------------------------------------------------------------------
; Subroutine to make seesaw solid
; ---------------------------------------------------------------------------

See_Solid:
		tst.b	ost_frame(a0)
		bne.w	SolidObject_TopOnly			; branch if seesaw is flat
		moveq	#1,d6					; 1 byte in heightmap = 2px
		lea	See_DataSlope,a2
		btst	#render_xflip_bit,ost_render(a0)
		beq.w	SolidObject_TopOnly_Heightmap		; branch if not xflipped
		lea	See_DataFlip,a2
		bra.w	SolidObject_TopOnly_Heightmap
; ===========================================================================
	
See_Ball:	; Routine 4
		getparent					; a1 = OST of seesaw object
		tst.b	ost_mode(a1)
		beq.w	DespawnQuick				; branch if Sonic isn't on the seesaw
		move.b	ost_seesaw_side(a1),d0
		cmp.b	ost_subtype(a0),d0
		beq.w	DespawnQuick				; branch if Sonic is on same side as spikeball
		
		move.w	#-$818,d1				; spikeball speed from flat seesaw
		move.w	#-$114,d2
		andi.b	#4,d0
		bne.s	.launch_spikeball			; branch if seesaw is flat
		move.w	#-$AF0,d1				; moderate spikeball speed
		move.w	#-$CC,d2
		cmpi.w	#$A00,ost_seesaw_impact(a1)
		blt.s	.launch_spikeball			; branch if Sonic landed with low y speed
		move.w	#-$E00,d1				; max spikeball speed
		move.w	#-$A0,d2

	.launch_spikeball:
		move.w	d1,ost_y_vel(a0)			; set spikeball speed
		cmpi.b	#1,ost_subtype(a0)
		bne.s	.from_right				; branch if spikeball was on right side
		neg.w	d2
		
	.from_right:
		move.w	d2,ost_x_vel(a0)
		addq.b	#2,ost_routine(a0)			; goto See_BallAir next

See_BallAir:	; Routine 6
		update_xy_fall					; update position & apply gravity
		bmi.w	DespawnQuick				; branch if spikeball is moving upwards
		getparent					; a1 = OST of seesaw object
		moveq	#$1C,d1
		cmpi.b	#id_frame_seesaw_flat,ost_frame(a1)
		beq.s	.flat_seesaw				; branch if seesaw is flat
		move.b	ost_render(a1),d1
		andi.b	#render_xflip,d1
		add.b	ost_subtype(a0),d1			; combine seesaw orientation with spikeball sidedness
		andi.b	#1,d1
		move.b	.heightlist(pc,d1.w),d1			; set height accordingly
		
	.flat_seesaw:
		move.w	ost_y_pos(a1),d0
		sub.w	d1,d0
		cmp.w	ost_y_pos(a0),d0
		bgt.w	DespawnQuick				; branch if spikeball is above seesaw
		
		subq.b	#2,ost_routine(a0)			; goto See_Ball next
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)		; reset position to match seesaw
		subi.w	#8,ost_y_pos(a0)
		move.b	#id_frame_seesaw_sloping_leftup,ost_frame(a1)
		cmpi.b	#1,ost_subtype(a0)
		beq.s	.from_left				; branch if spikeball is coming from the left side
		subi.w	#$28,ost_x_pos(a0)
		move.b	#1,ost_subtype(a0)
		bset	#render_xflip_bit,ost_render(a1)
		bra.s	.chk_sonic
		
.heightlist:	dc.b $2F, 8
		
	.from_left:
		addi.w	#$28,ost_x_pos(a0)
		move.b	#2,ost_subtype(a0)
		bclr	#render_xflip_bit,ost_render(a1)
		
	.chk_sonic:
		move.b	ost_seesaw_side(a1),d0			; side of seesaw Sonic is on (0 = none; 1 = left; 2 = right; 4/5 = middle)
		beq.w	DespawnQuick				; branch if 0
		cmp.b	ost_subtype(a0),d0
		beq.w	DespawnQuick				; branch if Sonic is on same side as spikeball
		getsonic a2					; a2 = OST of Sonic
		move.w	ost_y_vel(a0),d0			; bounce Sonic with same speed the spikeball fell
		neg.w	d0					; spikeball down, Sonic up
		move.w	d0,ost_y_vel(a2)
		bset	#status_air_bit,ost_status(a2)
		bclr	#status_platform_bit,ost_status(a2)
		clr.b	ost_sonic_jump(a2)
		move.b	#id_Spring,ost_anim(a2)			; Sonic uses spring animation
		move.b	#id_Sonic_Control,ost_routine(a2)
		play.w	1, jsr, sfx_Spring			; play spring sound
		bra.w	DespawnQuick
