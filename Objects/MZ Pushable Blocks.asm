; ---------------------------------------------------------------------------
; Object 33 - pushable blocks (MZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 0/$81
; ---------------------------------------------------------------------------

PushBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	PushB_Index(pc,d0.w),d1
		jmp	PushB_Index(pc,d1.w)
; ===========================================================================
PushB_Index:	index *,,2
		ptr PushB_Main
		ptr PushB_Action
		ptr PushB_Drop
		ptr PushB_Lava
		ptr PushB_Sink
		ptr PushB_WaitJump
		ptr PushB_Jump

PushB_Var:
PushB_Var_0:	dc.b $10, id_frame_pblock_single		; object width,	frame number
PushB_Var_1:	dc.b $40, id_frame_pblock_four

sizeof_PushB_Var:	equ PushB_Var_1-PushB_Var

		rsobj PushBlock
ost_pblock_time:	rs.w 1					; event timer
ost_pblock_pushed:	rs.b 1					; 0 = not pushed; -16 = pushed left; 16 = pushed right
ost_pblock_stompchk:	rs.b 1					; flag set when check for stomper has been performed
		rsobjend
; ===========================================================================

PushB_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto PushB_Action next
		move.b	#16,ost_height(a0)
		move.l	#Map_Push,ost_mappings(a0)
		move.w	#tile_Kos_MzBlock+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#3,ost_priority(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype
		andi.w	#$F,d0					; read low nybble
		beq.s	.type0					; branch if 0
		bset	#tile_hi_bit,ost_tile(a0)		; make sprite appear in foreground
		
	.type0:
		add.w	d0,d0
		lea	PushB_Var(pc,d0.w),a2			; get width & frame values from array
		move.b	(a2),ost_width(a0)
		move.b	(a2)+,ost_displaywidth(a0)
		move.b	(a2)+,ost_frame(a0)
		move.w	#2,ost_pblock_time(a0)
		bsr.w	PreventDupe				; flag object as loaded & prevent the same object loading again

PushB_Action:	; Routine 2
		tst.w	ost_linked(a0)
		bne.s	.stomper_skip				; branch if chain stomper was found
		tst.b	ost_render(a0)
		bpl.s	PushB_Display				; branch if block is off screen
		tst.b	ost_pblock_stompchk(a0)
		bne.s	.stomper_skip				; branch if chain stomper check was already done
		move.l	#CStom_Block,d0
		bsr.w	FindNearestObj				; find nearest chain stomper & save to ost_linked
		move.b	#1,ost_pblock_stompchk(a0)
		
	.stomper_skip:
		bsr.w	SolidObject
		bsr.w	PushB_Pushing
		tst.b	ost_subtype(a0)
		bmi.s	PushB_Display				; branch if subtype is +$80 (no gravity)
		bsr.w	PushB_ChkStomp
		beq.s	PushB_Display				; branch if block is on stomper
		jsr	FindFloorObj
		tst.w	d1
		beq.s	PushB_Display				; branch if block is touching the floor
		addi.b	#2,ost_routine(a0)			; goto PushB_Drop next
		move.b	ost_pblock_pushed(a0),d0
		ext.w	d0
		add.w	d0,ost_x_pos(a0)			; align with edge if pushed
		
PushB_Display:
		move.w	ost_x_pos(a0),d0
		bsr.w	CheckActive
		beq.w	DisplaySprite
		
PushB_Delete:
		bsr.w	SaveState
		beq.w	DeleteObject				; branch if not in respawn table
		bclr	#0,(a2)					; allow object to load again later
		bra.w	DeleteObject
; ===========================================================================

PushB_Drop:	; Routine 4
		;bsr.w	SolidObject
		bsr.w	PushB_ChkStomp
		bne.s	.gravity				; branch if block isn't on stomper
		subi.b	#2,ost_routine(a0)			; goto PushB_Action next
		bra.s	PushB_Display
		
	.gravity:
		update_xy_fall	$18				; update position & apply gravity
		jsr	FindFloorObj
		tst.w	d1
		bpl.s	PushB_Display				; branch if block hasn't reached floor
		add.w	d1,ost_y_pos(a0)			; align to floor
		clr.w	ost_y_vel(a0)				; stop falling
		subi.b	#2,ost_routine(a0)			; goto PushB_Action next
		move.w	(a3),d0					; get 16x16 tile the block is on
		andi.w	#$3FF,d0
		cmpi.w	#$16A,d0				; is it block $16A+ (lava)?
		bcs.s	PushB_Display				; branch if not lava
		move.b	#id_PushB_Lava,ost_routine(a0)		; goto PushB_Lava next
		move.b	ost_pblock_pushed(a0),d0
		ext.w	d0
		lsl.w	#3,d0
		move.w	d0,ost_x_vel(a0)			; start moving in direction it was pushed
		bra.s	PushB_Display
; ===========================================================================

PushB_Lava:	; Routine 6
		bsr.w	PushB_ChkGeyser
		
PushB_Move:
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		update_xy_pos
		bsr.w	SolidObject
		tst.w	ost_x_vel(a0)
		bmi.s	.moving_left				; branch if moving left
		jsr	FindWallRightObj
		bra.s	.hit_wall
		
	.moving_left:
		jsr	FindWallLeftObj
		
	.hit_wall:
		tst.w	d1
		bne.w	PushB_Display				; branch if not at wall
		move.b	#id_PushB_Sink,ost_routine(a0)		; goto PushB_Sink next
		clr.w	ost_x_vel(a0)				; stop moving
		bra.w	PushB_Display
; ===========================================================================

PushB_Sink:	; Routine 8
		bsr.w	SolidObject
		addi.l	#$2001,ost_y_pos(a0)			; sink in lava, $2001 subpixels each frame
		cmpi.b	#160,ost_y_sub+1(a0)
		bcc.s	.sunk					; branch after 160 frames
		bra.w	PushB_Display
		
	.sunk:
		bclr	#status_platform_bit,ost_status(a1)
		bra.w	PushB_Delete
; ===========================================================================

PushB_WaitJump:	; Routine $A
		tst.w	ost_linked(a0)
		bne.s	.geyser_found				; branch if geyser object exists
		move.b	#id_PushB_Lava,ost_routine(a0)		; goto PushB_Lava next
		bra.s	PushB_Lava
		
	.geyser_found:
		getlinked					; a1 = OST of geyser
		cmpi.b	#id_Fount_Make,ost_routine(a1)
		bne.w	PushB_Move				; branch if geyser is inactive
		move.w	#-$580,ost_y_vel(a0)			; make block jump
		addi.b	#2,ost_routine(a0)			; goto PushB_Jump next
		clr.w	ost_linked(a0)
		bra.w	PushB_Move
; ===========================================================================

PushB_Jump:	; Routine $C
		addi.w	#$18,ost_y_vel(a0)			; apply gravity
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		update_xy_pos
		bsr.w	SolidObject
		jsr	FindFloorObj
		tst.w	d1
		bpl.w	PushB_Display				; branch if block hasn't reached floor
		add.w	d1,ost_y_pos(a0)			; align to floor
		clr.w	ost_y_vel(a0)				; stop falling
		move.b	#id_PushB_Action,ost_routine(a0)	; goto PushB_Action next
		move.w	(a3),d0					; get 16x16 tile the block is on
		andi.w	#$3FF,d0
		cmpi.w	#$16A,d0				; is it block $16A+ (lava)?
		bcs.w	PushB_Display				; branch if not lava
		move.b	#id_PushB_Lava,ost_routine(a0)		; goto PushB_Lava next
		bra.w	PushB_Display

; ---------------------------------------------------------------------------
; Subroutine to move block when pushed
; ---------------------------------------------------------------------------

PushB_Pushing:
		clr.b	ost_pblock_pushed(a0)
		subq.w	#1,ost_pblock_time(a0)			; decrement timer
		bpl.s	.exit					; branch if time remains
		btst	#status_pushing_bit,ost_status(a1)
		beq.s	.push_reset				; branch if Sonic isn't pushing anything
		cmpi.b	#id_Walk,ost_anim(a1)
		bne.s	.push_reset				; branch if Sonic isn't trying to move
		btst	#status_pushing_bit,ost_status(a0)
		beq.s	.push_other				; branch if Sonic isn't pushing the block
		andi.b	#solid_right,d1
		beq.s	.push_left				; branch if pushing left side
		
	.push_right:
		jsr	FindWallLeftObj
		tst.w	d1
		beq.s	.exit					; branch if block is against wall
		subq.w	#1,ost_x_pos(a1)			; Sonic moves left
	.push_right2:
		subq.w	#1,ost_x_pos(a0)			; block moves left
		play.w	1, jsr, sfx_Push			; play pushing sound
		move.b	#-16,ost_pblock_pushed(a0)
		bra.s	.push_reset
		
	.push_left:
		jsr	FindWallRightObj
		tst.w	d1
		beq.s	.exit					; branch if block is against wall
		addq.w	#1,ost_x_pos(a1)			; Sonic moves right
	.push_left2:
		addq.w	#1,ost_x_pos(a0)			; block moves right
		play.w	1, jsr, sfx_Push			; play pushing sound
		move.b	#16,ost_pblock_pushed(a0)
		
	.push_reset:
		move.w	#2,ost_pblock_time(a0)			; 3 frame delay between movements
	
	.exit:
		rts
		
	.push_other:
		andi.b	#solid_top,d1
		beq.s	.exit					; branch if Sonic isn't on top
		btst	#status_xflip_bit,ost_status(a1)
		beq.s	.push_right2				; branch if Sonic is facing right
		bra.s	.push_left2
		
; ---------------------------------------------------------------------------
; Subroutine to align block with nearest chain stomper
; ---------------------------------------------------------------------------

PushB_ChkStomp:
		tst.w	ost_linked(a0)
		beq.s	.use_gravity				; branch if no chain stomper was found
		getlinked					; a1 = OST of chain stomper
		move.w	ost_y_pos(a1),d0
		sub.w	ost_y_pos(a0),d0
		cmpi.w	#-screen_height,d0
		ble.s	.use_gravity				; branch if block is > 224px below stomper
		moveq	#0,d2
		move.b	ost_height(a1),d2
		add.b	ost_height(a0),d2
		cmp.w	d0,d2
		blt.s	.use_gravity				; branch if block is above stomper (and not touching)
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0
		abs.w	d0					; d0 = x dist between block & stomper
		moveq	#0,d1
		move.b	ost_width(a1),d1
		add.b	ost_width(a0),d1
		cmp.w	d0,d1
		bcs.s	.use_gravity				; branch if block is outside width
		move.w	ost_y_pos(a1),d0
		sub.w	d2,d0
		move.w	d0,ost_y_pos(a0)			; match block y pos with stomper
		clr.w	ost_y_vel(a0)				; stop falling
		moveq	#0,d0
		rts
		
	.use_gravity:
		moveq	#1,d0					; set flag to enable gravity
		rts
		
; ---------------------------------------------------------------------------
; Subroutine to load lava geysers at specific locations
; ---------------------------------------------------------------------------

PushB_ChkGeyser:
		moveq	#0,d0
		move.b	(v_act).w,d0
		add.b	d0,d0
		move.w	GeyserList(pc,d0.w),d0
		lea	GeyserList(pc,d0.w),a2			; read from relevant list of x coords
		move.w	(a2)+,d1				; get count of x coords
		beq.s	.exit					; branch if 0
		subi.w	#1,d1					; subtract 1 for loops
		
	.loop:
		move.w	(a2)+,d0
		cmp.w	ost_x_pos(a0),d0
		beq.s	.make_geyser				; branch if block is at x pos
		dbf	d1,.loop
		
	.exit:
		rts

	.make_geyser:
		clr.w	ost_linked(a0)
		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#LavaFountain,ost_id(a1)		; load lava fountain object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		moveq	#0,d0
		move.b	ost_pblock_pushed(a0),d0
		ext.w	d0
		add.w	d0,d0
		add.w	d0,ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		addi.w	#$10,ost_y_pos(a1)			; make geyser appear below
		move.w	a1,ost_linked(a0)			; save OST for geyser

	.fail:
		move.b	#id_PushB_WaitJump,ost_routine(a0)	; goto PushB_WaitJump next
		rts

GeyserList:	index *
		ptr GeyserList_0
		ptr GeyserList_1
		ptr GeyserList_2
		
GeyserList_0:	dc.w 0
GeyserList_1:	dc.w 3, $DD0, $CC0, $BA0
GeyserList_2:	dc.w 2, $560, $5C0
