; ---------------------------------------------------------------------------
; Object 5E - seesaws (SLZ)

; spawned by:
;	ObjPos_SLZ2, ObjPos_SLZ3 - subtypes 0/$FF
;	Seesaw - routine 6 (spikeball)
; ---------------------------------------------------------------------------

Seesaw:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	See_Index(pc,d0.w),d1
		jmp	See_Index(pc,d1.w)
; ===========================================================================
See_Index:	index *,,2
		ptr See_Main
		ptr See_Detect
		ptr See_Stand
		ptr See_Ball
		ptr See_BallAir

		rsobj Seesaw
ost_seesaw_impact:	rs.w 1					; speed Sonic hits the seesaw
ost_seesaw_side:	rs.b 1					; Sonic's position on seesaw (0 = none; 1 = left; 2 = right; 4 = middle)
		rsobjend
; ===========================================================================

See_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto See_Detect next
		move.l	#Map_Seesaw,ost_mappings(a0)
		move.w	#tile_Kos_Seesaw,ost_tile(a0)
		move.b	ost_status(a0),ost_render(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#priority_4,ost_priority(a0)
		move.b	#$30,ost_displaywidth(a0)
		move.b	#$30,ost_width(a0)
		move.b	#$15,ost_height(a0)
		tst.b	ost_subtype(a0)
		bmi.w	See_Detect				; branch if subtype is -1
		
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.w	See_Detect				; branch if not found
		move.l	#Seesaw,ost_id(a1)			; load spikeball object
		move.b	#id_See_Ball,ost_routine(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		addi.w	#$28,ost_x_pos(a1)			; move spikeball to right side
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		subq.w	#8,ost_y_pos(a1)
		move.b	ost_status(a0),ost_status(a1)
		move.l	#Map_SSawBall,ost_mappings(a1)
		move.w	#tile_Kos_SlzSpike,ost_tile(a1)
		ori.b	#render_rel,ost_render(a1)
		move.b	#priority_4,ost_priority(a1)
		move.b	#id_React_Hurt,ost_col_type(a1)
		move.b	#8,ost_col_width(a1)
		move.b	#8,ost_col_height(a1)
		move.b	#$C,ost_displaywidth(a1)
		move.b	#id_frame_seesaw_silver,ost_frame(a1)
		move.b	#2,ost_subtype(a1)
		saveparent
		btst	#render_xflip_bit,ost_render(a0)
		beq.s	See_Detect				; branch if not xflipped
		subi.w	#$50,ost_x_pos(a1)			; move spikeball to left side
		move.b	#1,ost_subtype(a1)

See_Detect:	; Routine 2
		bsr.s	See_Solid
		tst.b	d1
		bne.s	.collision				; branch if Sonic lands on the seesaw
		move.b	#0,ost_seesaw_side(a0)
		bra.w	DespawnFamily
		
	.collision:
		move.w	ost_sonic_impact(a1),ost_seesaw_impact(a0)
		bsr.s	See_SetSide				; update sidedness based on where Sonic landed
		lea	See_DataSlope,a2
		btst	#render_xflip_bit,ost_render(a0)
		beq.s	.noflip					; branch if not xflipped
		lea	See_DataFlip,a2
		
	.noflip:
		lsr.w	#1,d4
		moveq	#0,d0
		move.b	(a2,d4.w),d0				; get height byte from heightmap
		move.b	ost_solid_y_pos(a0),d1
		move.b	d0,ost_solid_y_pos(a0)			; save new height
		sub.b	d1,d0					; height diff (+ve if reduced)
		sub.w	d0,ost_y_pos(a1)			; update Sonic's y pos
		addq.b	#2,ost_routine(a0)			; goto See_Stand next
		bra.w	DespawnFamily
; ===========================================================================

See_Stand:	; Routine 4
		bsr.s	See_Solid
		tst.b	d1
		beq.s	.leave					; branch if Sonic leaves seesaw
		bsr.s	See_SetSide
		bra.w	DespawnFamily
		
	.leave:
		subq.b	#2,ost_routine(a0)			; goto See_Detect next
		bra.w	DespawnFamily
		
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
		
; ---------------------------------------------------------------------------
; Subroutine to set seesaw frame based on where Sonic is
; ---------------------------------------------------------------------------

See_SetSide:
		move.w	d4,d5
		subi.w	#$28,d5
		bcs.s	.left					; branch if on left side
		subi.w	#$10,d5
		bcs.s	.middle					; branch if in middle
		bclr	#render_xflip_bit,ost_render(a0)	; left side up, right side down
		move.b	#id_frame_seesaw_sloping_leftup,ost_frame(a0)
		move.b	#2,ost_seesaw_side(a0)
		rts
		
	.left:
		bset	#render_xflip_bit,ost_render(a0)	; right side up, left side down
		move.b	#id_frame_seesaw_sloping_leftup,ost_frame(a0)
		move.b	#1,ost_seesaw_side(a0)
		rts
		
	.middle:
		bclr	#render_xflip_bit,ost_render(a0)
		move.b	#id_frame_seesaw_flat,ost_frame(a0)
		move.b	#4,ost_seesaw_side(a0)
		rts
; ===========================================================================
	
See_Ball:	; Routine 6
		getparent					; a1 = OST of seesaw object
		tst.b	ost_mode(a1)
		beq.w	DisplaySprite				; branch if Sonic isn't on the seesaw
		move.b	ost_seesaw_side(a1),d0
		cmp.b	ost_subtype(a0),d0
		beq.w	DisplaySprite				; branch if Sonic is on same side as spikeball
		
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

See_BallAir:	; Routine 8
		update_xy_fall					; update position & apply gravity
		bmi.w	DisplaySprite				; branch if spikeball is moving upwards
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
		bgt.w	DisplaySprite				; branch if spikeball is above seesaw
		
		subq.b	#2,ost_routine(a0)			; goto See_Ball next
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)		; reset position to match seesaw
		subq.w	#8,ost_y_pos(a0)
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
		move.b	ost_seesaw_side(a1),d0			; side of seesaw Sonic is on (0 = none; 1 = left; 2 = right; 4 = middle)
		beq.w	DisplaySprite				; branch if 0
		cmp.b	ost_subtype(a0),d0
		beq.w	DisplaySprite				; branch if Sonic is on same side as spikeball
		getsonic a2					; a2 = OST of Sonic
		move.w	ost_y_vel(a0),d0			; bounce Sonic with same speed the spikeball fell
		neg.w	d0					; spikeball down, Sonic up
		move.w	d0,ost_y_vel(a2)
		bset	#status_air_bit,ost_status(a2)
		bclr	#status_platform_bit,ost_status(a2)
		move.b	#id_Spring,ost_anim(a2)			; Sonic uses spring animation
		move.b	#id_Sonic_Control,ost_routine(a2)
		play.w	1, jsr, sfx_Spring			; play spring sound
		subq.b	#2,ost_routine(a1)			; reset seesaw to See_Detect
		bra.w	DisplaySprite
