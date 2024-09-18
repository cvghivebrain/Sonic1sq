; ---------------------------------------------------------------------------
; Spawner for spinning platforms that move around a conveyor belt (SBZ)

; spawned by:
;	ObjPos_SBZ1 - subtypes 0-5
; ---------------------------------------------------------------------------

SpinConvey:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	SpinC_Index(pc,d0.w),d1
		jmp	SpinC_Index(pc,d1.w)
; ===========================================================================
SpinC_Index:	index *,,2
		ptr SpinC_Main
		ptr SpinC_ChkDist
; ===========================================================================

SpinC_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto SpinC_ChkDist next
		move.b	ost_subtype(a0),d0
		add.w	d0,d0
		add.w	d0,d0
		lea	(ObjPosSBZPlatform_Index).l,a2
		movea.l	(a2,d0.w),a2				; get address of platform position data
		move.w	(a2)+,d1				; get object count

	.loop:
		jsr	FindNextFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#SpinConveyPlatform,ost_id(a1)		; load platform object
		move.w	(a2)+,ost_x_pos(a1)
		move.w	(a2)+,ost_y_pos(a1)
		move.w	(a2)+,d0
		move.b	d0,ost_subtype(a1)
		move.w	ost_y_pos(a0),ost_spinc_parent_y_pos(a1)
		saveparent

	.fail:
		dbf	d1,.loop				; repeat for number of objects
		rts
; ===========================================================================

SpinC_ChkDist:	; Routine 2
		getsonic					; a1 = OST of Sonic
		range_x_test	256+160
		bcs.s	.exit					; branch if Sonic is nearby
		moveq	#0,d0
		move.b	ost_respawn(a0),d0			; get respawn id
		beq.s	.delete					; branch if not set
		lea	(v_respawn_list).w,a2
		bclr	#7,2(a2,d0.w)				; allow object to respawn later

	.delete:
		jmp	DeleteFamily				; delete the object and all platforms
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Object 6F - spinning platforms that move around a conveyor belt (SBZ)

; spawned by:
;	SpinConvey - subtypes 0-$53
; ---------------------------------------------------------------------------

SpinConveyPlatform:
		move.w	ost_spinc_parent_y_pos(a0),d0
		waitvisible 100,200				; don't run if not near screen
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	SpinCP_Index(pc,d0.w),d1
		jmp	SpinCP_Index(pc,d1.w)
; ===========================================================================
SpinCP_Index:	index *,,2
		ptr SpinCP_Main
		ptr SpinCP_Solid
		ptr SpinCP_Spin

		rsobj SpinConveyPlatform
ost_spinc_corner_ptr:	rs.l 1					; address of corner position data
ost_spinc_corner_x_pos:	rs.w 1					; x position of next corner
ost_spinc_corner_y_pos:	rs.w 1					; y position of next corner
ost_spinc_parent_y_pos:	rs.w 1					; y position of parent
ost_spinc_corner_next:	rs.w 1					; index of next corner
ost_spinc_corner_count:	equ __rs-1				; total number of corners +1, times 4
		rsobjend
; ===========================================================================

SpinCP_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto SpinCP_Solid next
		move.l	#Map_Spin,ost_mappings(a0)
		move.w	#tile_Kos_SpinPlatform,ost_tile(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#16,ost_width(a0)
		move.b	#7,ost_height(a0)
		ori.b	#render_rel,ost_render(a0)
		move.w	#priority_4,ost_priority(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype (not the same as initial subtype)
		move.w	d0,d1
		lsr.w	#3,d0
		andi.w	#$1E,d0					; read high nybble of subtype
		lea	SpinC_Corner_Data(pc),a2
		adda.w	(a2,d0.w),a2				; get address of corner data
		move.w	(a2)+,ost_spinc_corner_count-1(a0)	; get corner count
		move.l	a2,ost_spinc_corner_ptr(a0)		; pointer to corner x/y values
		andi.w	#$F,d1					; read low nybble of subtype
		lsl.w	#2,d1					; multiply by 4
		move.b	d1,ost_spinc_corner_next(a0)
		move.w	(a2,d1.w),ost_spinc_corner_x_pos(a0)	; get corner position data
		move.w	2(a2,d1.w),ost_spinc_corner_y_pos(a0)
		cmpi.w	#8,d1
		bcs.w	SpinCP_Platform_Move			; branch if on top or left side of conveyor
		addq.b	#2,ost_routine(a0)			; goto SpinCP_Spin next
		bra.w	SpinCP_Platform_Move			; begin platform moving
; ===========================================================================

SpinCP_Solid:	; Routine 2
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		bsr.s	SpinCP_Update
		bsr.w	SolidObject				; make platform solid on flat frame
		jmp	DisplaySprite
; ===========================================================================

SpinCP_Spin:	; Routine 4
		lea	Ani_SpinConvey(pc),a1
		jsr	(AnimateSprite).l
		bsr.s	SpinCP_Update
		jmp	DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to get next corner coordinates and update platform position
; ---------------------------------------------------------------------------

SpinCP_Update:
		move.w	ost_x_pos(a0),d0
		cmp.w	ost_spinc_corner_x_pos(a0),d0		; is platform at corner?
		bne.s	.not_at_corner				; if not, branch
		move.w	ost_y_pos(a0),d0
		cmp.w	ost_spinc_corner_y_pos(a0),d0
		bne.s	.not_at_corner

		moveq	#0,d1
		move.b	ost_spinc_corner_next(a0),d1
		addq.b	#4,d1
		cmp.b	ost_spinc_corner_count(a0),d1		; is next corner valid?
		bcs.s	.is_valid				; if yes, branch
		move.b	d1,d0
		moveq	#0,d1					; reset corner counter to 0
		tst.b	d0
		bpl.s	.is_valid
		move.b	ost_spinc_corner_count(a0),d1
		subq.b	#4,d1

	.is_valid:
		move.b	d1,ost_spinc_corner_next(a0)
		movea.l	ost_spinc_corner_ptr(a0),a1
		move.w	(a1,d1.w),ost_spinc_corner_x_pos(a0)	; get corner position data
		move.w	2(a1,d1.w),ost_spinc_corner_y_pos(a0)
		cmpi.w	#8,d1
		bcs.s	.not_spinning				; branch if on top or left side of conveyor
		move.b	#id_SpinCP_Spin,ost_routine(a0)		; use spinning animation
		bsr.w	UnSolid
		bsr.s	SpinCP_Platform_Move			; set direction and speed
		update_xy_pos					; update position
		rts
		
	.not_spinning:
		move.b	#id_SpinCP_Solid,ost_routine(a0)	; use still animation
		move.b	#id_frame_spin_flat,ost_frame(a0)
		bsr.s	SpinCP_Platform_Move			; set direction and speed

	.not_at_corner:
		update_xy_pos					; update position
		rts

; ---------------------------------------------------------------------------
; Subroutine to set direction and speed of platform
; ---------------------------------------------------------------------------

SpinCP_Platform_Move:
		moveq	#0,d0
		move.w	#-$100,d2
		move.w	ost_x_pos(a0),d0
		sub.w	ost_spinc_corner_x_pos(a0),d0		; d0 = x distance between platform & corner
		bcc.s	.is_right				; branch if +ve (platform is right of corner)
		neg.w	d0					; make d0 +ve
		neg.w	d2					; d2 = $100

	.is_right:
		moveq	#0,d1
		move.w	#-$100,d3
		move.w	ost_y_pos(a0),d1
		sub.w	ost_spinc_corner_y_pos(a0),d1		; d1 = y distance between platform & corner
		bcc.s	.is_below				; branch if +ve (platform is below corner)
		neg.w	d1					; make d1 +ve
		neg.w	d3					; d3 = $100

	.is_below:
		cmp.w	d0,d1					; is platform nearer corner on y axis?
		bcs.s	.nearer_y				; if yes, branch
		move.w	ost_x_pos(a0),d0
		sub.w	ost_spinc_corner_x_pos(a0),d0		; d0 = x distance between platform & corner
		beq.s	.match_x				; branch if 0
		ext.l	d0
		asl.l	#8,d0					; multiply by $100
		divs.w	d1,d0					; divide by y distance
		neg.w	d0

	.match_x:
		move.w	d0,ost_x_vel(a0)
		move.w	d3,ost_y_vel(a0)
		swap	d0
		move.w	d0,ost_x_sub(a0)
		clr.w	ost_y_sub(a0)
		rts	
; ===========================================================================

.nearer_y:
		move.w	ost_y_pos(a0),d1
		sub.w	ost_spinc_corner_y_pos(a0),d1
		beq.s	.match_y
		ext.l	d1
		asl.l	#8,d1
		divs.w	d0,d1
		neg.w	d1

	.match_y:
		move.w	d1,ost_y_vel(a0)
		move.w	d2,ost_x_vel(a0)
		swap	d1
		move.w	d1,ost_y_sub(a0)
		clr.w	ost_x_sub(a0)
		rts

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_SpinConvey:	index *
		ptr ani_spinc_spin
		
ani_spinc_spin:
		dc.w 0
		dc.w id_frame_spin_flat
		dc.w id_frame_spin_1
		dc.w id_frame_spin_2
		dc.w id_frame_spin_3
		dc.w id_frame_spin_4
		dc.w id_frame_spin_3+afyflip
		dc.w id_frame_spin_2+afyflip
		dc.w id_frame_spin_1+afyflip
		dc.w id_frame_spin_flat+afyflip
		dc.w id_frame_spin_1+afxflip+afyflip
		dc.w id_frame_spin_2+afxflip+afyflip
		dc.w id_frame_spin_3+afxflip+afyflip
		dc.w id_frame_spin_4+afxflip+afyflip
		dc.w id_frame_spin_3+afxflip
		dc.w id_frame_spin_2+afxflip
		dc.w id_frame_spin_1+afxflip
		dc.w id_frame_spin_flat
		dc.w id_Anim_Flag_Restart

; ---------------------------------------------------------------------------
; Corner data
; ---------------------------------------------------------------------------

SpinC_Corner_Data:
		index *
		ptr SpinC_Corners_0
		ptr SpinC_Corners_1
		ptr SpinC_Corners_2
		ptr SpinC_Corners_3
		ptr SpinC_Corners_4
		ptr SpinC_Corners_5
SpinC_Corners_0:
		dc.w .end-(*+2)
		dc.w $E14, $370					; top left corner
		dc.w $EEF, $302					; top right corner
		dc.w $EEF, $340					; bottom right corner
		dc.w $E14, $3AE					; bottom left corner
	.end:

SpinC_Corners_1:
		dc.w .end-(*+2)
		dc.w $F14, $2E0
		dc.w $FEF, $272
		dc.w $FEF, $2B0
		dc.w $F14, $31E
	.end:

SpinC_Corners_2:
		dc.w .end-(*+2)
		dc.w $1014, $270
		dc.w $10EF, $202
		dc.w $10EF, $240
		dc.w $1014, $2AE
	.end:

SpinC_Corners_3:
		dc.w .end-(*+2)
		dc.w $F14, $570
		dc.w $FEF, $502
		dc.w $FEF, $540
		dc.w $F14, $5AE
	.end:

SpinC_Corners_4:
		dc.w .end-(*+2)
		dc.w $1B14, $670
		dc.w $1BEF, $602
		dc.w $1BEF, $640
		dc.w $1B14, $6AE
	.end:

SpinC_Corners_5:
		dc.w .end-(*+2)
		dc.w $1C14, $5E0
		dc.w $1CEF, $572
		dc.w $1CEF, $5B0
		dc.w $1C14, $61E
	.end:
