; ---------------------------------------------------------------------------
; Object 56 - floating blocks (SYZ/SLZ)

; spawned by:
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_SYZ3 - subtypes 0/1/2/$13/$17/$20/$37/$A0
;	ObjPos_SLZ2, ObjPos_SLZ3 - subtypes $58-$5B
; ---------------------------------------------------------------------------

FloatingBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	FBlock_Index(pc,d0.w),d1
		jmp	FBlock_Index(pc,d1.w)
; ===========================================================================
FBlock_Index:	index *
		ptr FBlock_Main
		ptr FBlock_Action

FBlock_Var:	; width/2, height/2
		dc.b  $10, $10					; subtype 0x/8x
		dc.b  $20, $20					; subtype 1x/9x
		dc.b  $10, $20					; subtype 2x/Ax
		dc.b  $20, $1A					; subtype 3x/Bx
		dc.b  $10, $27					; subtype 4x/Cx - unused
		dc.b  $10, $10					; subtype 5x/Dx
		dc.b	8, $20					; subtype 6x/Ex
		dc.b  $40, $10					; subtype 7x/Fx

		rsobj FloatingBlock
ost_fblock_y_start:	rs.w 1					; original y position (2 bytes)
ost_fblock_x_start:	rs.w 1					; original x position (2 bytes)
ost_fblock_move_dist:	rs.w 1					; distance to move (2 bytes)
ost_fblock_move_flag:	rs.b 1					; 1 = block/door is moving
ost_fblock_btn_num:	rs.b 1					; which button the block is linked to
		rsobjend
; ===========================================================================

FBlock_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto FBlock_Action next
		move.l	#Map_FBlock,ost_mappings(a0)
		move.w	#0+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#3,ost_priority(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype
		lsr.w	#3,d0
		andi.w	#$E,d0					; read only bits 4-6 (high nybble sans high bit)
		lea	FBlock_Var(pc,d0.w),a2			; get size data
		move.b	(a2),ost_width(a0)
		move.b	(a2)+,ost_displaywidth(a0)
		move.b	(a2),ost_height(a0)
		lsr.w	#1,d0
		move.b	d0,ost_frame(a0)			; set frame as high nybble of subtype
		move.w	ost_x_pos(a0),ost_fblock_x_start(a0)
		move.w	ost_y_pos(a0),ost_fblock_y_start(a0)
		moveq	#0,d0
		move.b	(a2),d0					; get height from size list
		add.w	d0,d0
		move.w	d0,ost_fblock_move_dist(a0)		; set full height
		cmpi.b	#type_fblock_syzrect2x2+type_fblock_farrightbutton,ost_subtype(a0) ; is the subtype $37? (used once in SYZ3)
		bne.s	.dontdelete				; if not, branch
		cmpi.w	#$1BB8,ost_x_pos(a0)			; is object in its start position?
		bne.s	.notatpos				; if not, branch
		tst.b	(f_fblock_finish).w			; has similar object reached its destination?
		beq.s	.dontdelete				; if not, branch
		jmp	(DeleteObject).l
	.notatpos:
		clr.b	ost_subtype(a0)				; stop object moving
		tst.b	(f_fblock_finish).w
		bne.s	.dontdelete
		jmp	(DeleteObject).l
	.dontdelete:
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; SYZ/SLZ specific code
		andi.w	#$F,d0					; read low nybble of subtype
		subq.w	#8,d0					; subtract 8
		bcs.s	.not_syzslz				; branch if low nybble was > 8
		lsl.w	#2,d0					; multiply by 4
		lea	(v_oscillating_0_to_40_alt+2).w,a2
		lea	(a2,d0.w),a2				; read oscillating value
		tst.w	(a2)
		bpl.s	.not_syzslz				; branch if not -ve
		bchg	#status_xflip_bit,ost_status(a0)	; xflip object

	.not_syzslz:
		move.b	ost_subtype(a0),d0			; get subtype
		bpl.s	FBlock_Action				; if subtype is 0-$7F, branch
		andi.b	#$F,d0					; read low nybble
		move.b	d0,ost_fblock_btn_num(a0)		; save to variable
		move.b	#id_FBlock_UpButton,ost_subtype(a0)	; force subtype to 5 (moves up when button is pressed)
		lea	(v_respawn_list).w,a2
		moveq	#0,d0
		move.b	ost_respawn(a0),d0
		beq.s	FBlock_Action
		bclr	#7,2(a2,d0.w)
		btst	#0,2(a2,d0.w)
		beq.s	FBlock_Action
		addq.b	#1,ost_subtype(a0)			; change subtype to 6 or $D if previously activated
		clr.w	ost_fblock_move_dist(a0)

FBlock_Action:	; Routine 2
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get object subtype (changed if original was $80+)
		andi.w	#$F,d0					; read only the	low nybble
		add.w	d0,d0
		move.w	FBlock_Types(pc,d0.w),d1
		jsr	FBlock_Types(pc,d1.w)			; update position
		tst.b	ost_render(a0)
		bpl.s	.chkdel
		bsr.w	SolidObject				; detect collision

	.chkdel:
		move.w	ost_fblock_x_start(a0),d0
		bsr.w	CheckActive
		bne.s	.chkdel2
	.display:
		bra.w	DisplaySprite
	.chkdel2:
		cmpi.b	#type_fblock_syzrect2x2+type_fblock_farrightbutton,ost_subtype(a0)
		bne.s	.delete
		tst.b	ost_fblock_move_flag(a0)
		bne.s	.display
	.delete:
		jmp	(DeleteObject).l
; ===========================================================================
FBlock_Types:	index *
		ptr FBlock_Still				; 0
		ptr FBlock_LeftRight				; 1
		ptr FBlock_LeftRightWide			; 2
		ptr FBlock_UpDown				; 3
		ptr FBlock_UpDownWide				; 4 - unused
		ptr FBlock_UpButton				; 5
		ptr FBlock_DownButton				; 6 - used, but never activated
		ptr FBlock_FarRightButton			; 7
		ptr FBlock_SquareSmall				; 8
		ptr FBlock_SquareMedium				; 9
		ptr FBlock_SquareBig				; $A
		ptr FBlock_SquareBiggest			; $B
		ptr FBlock_LeftButton				; $C
		ptr FBlock_RightButton				; $D - used, but never activated
; ===========================================================================

; Type 0 - doesn't move
FBlock_Still:
		rts	
; ===========================================================================

; Type 1 - moves side-to-side
FBlock_LeftRight:
		move.w	#$40,d1					; set move distance
		moveq	#0,d0
		move.b	(v_oscillating_0_to_40).w,d0
		bra.s	FBlock_LeftRight_Move
; ===========================================================================

; Type 2 - moves side-to-side
FBlock_LeftRightWide:
		move.w	#$80,d1					; set move distance
		moveq	#0,d0
		move.b	(v_oscillating_0_to_80).w,d0

FBlock_LeftRight_Move:
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip
		neg.w	d0
		add.w	d1,d0

	.noflip:
		move.w	ost_fblock_x_start(a0),d1
		sub.w	d0,d1
		move.w	d1,ost_x_pos(a0)			; move object horizontally
		rts	
; ===========================================================================

; Type 3 - moves up/down
FBlock_UpDown:
		move.w	#$40,d1					; set move distance
		moveq	#0,d0
		move.b	(v_oscillating_0_to_40).w,d0
		bra.s	FBlock_UpDown_Move
; ===========================================================================

; Type 4 - moves up/down
FBlock_UpDownWide:
		move.w	#$80,d1					; set move distance
		moveq	#0,d0
		move.b	(v_oscillating_0_to_80).w,d0

FBlock_UpDown_Move:
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip
		neg.w	d0
		add.w	d1,d0

	.noflip:
		move.w	ost_fblock_y_start(a0),d1
		sub.w	d0,d1
		move.w	d1,ost_y_pos(a0)			; move object vertically
		rts	
; ===========================================================================

; Type 5 - moves up when a button is pressed
FBlock_UpButton:
		tst.b	ost_fblock_move_flag(a0)		; is object moving?
		bne.s	.chk_distance				; if yes, branch
		lea	(v_button_state).w,a2
		moveq	#0,d0
		move.b	ost_fblock_btn_num(a0),d0
		btst	#0,(a2,d0.w)				; check status of linked button
		beq.s	.not_pressed				; branch if not pressed
		move.b	#1,ost_fblock_move_flag(a0)		; flag object as moving

	.chk_distance:
		tst.w	ost_fblock_move_dist(a0)		; is remaining distance = 0?
		beq.s	.finish					; if yes, branch
		subq.w	#2,ost_fblock_move_dist(a0)		; decrement distance

	.not_pressed:
		move.w	ost_fblock_move_dist(a0),d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d0					; invert if xflipped

	.no_xflip:
		move.w	ost_fblock_y_start(a0),d1
		add.w	d0,d1					; add distance to start position
		move.w	d1,ost_y_pos(a0)			; update y pos
		rts	
; ===========================================================================

.finish:
		addq.b	#1,ost_subtype(a0)			; convert to type 6
		clr.b	ost_fblock_move_flag(a0)		; clear movement flag
		lea	(v_respawn_list).w,a2
		moveq	#0,d0
		move.b	ost_respawn(a0),d0
		beq.s	.not_pressed
		bset	#0,2(a2,d0.w)
		bra.s	.not_pressed
; ===========================================================================

; Type 6 - moves down when button is pressed
FBlock_DownButton:
		tst.b	ost_fblock_move_flag(a0)		; is object moving?
		bne.s	.chk_distance				; if yes, branch
		lea	(v_button_state).w,a2
		moveq	#0,d0
		move.b	ost_fblock_btn_num(a0),d0
		tst.b	(a2,d0.w)				; check status of linked button (unused button subtype $4x)
		bpl.s	.not_pressed				; branch if not pressed
		move.b	#1,ost_fblock_move_flag(a0)

	.chk_distance:
		moveq	#0,d0
		move.b	ost_height(a0),d0
		add.w	d0,d0
		cmp.w	ost_fblock_move_dist(a0),d0		; has object moved distance equal to its height?
		beq.s	.finish					; if yes, branch
		addq.w	#2,ost_fblock_move_dist(a0)		; increment distance

	.not_pressed:
		move.w	ost_fblock_move_dist(a0),d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d0					; invert if xflipped

	.no_xflip:
		move.w	ost_fblock_y_start(a0),d1
		add.w	d0,d1					; add distance to start position
		move.w	d1,ost_y_pos(a0)			; update y pos
		rts	
; ===========================================================================

.finish:
		subq.b	#1,ost_subtype(a0)			; convert to type 5
		clr.b	ost_fblock_move_flag(a0)		; clear movement flag
		lea	(v_respawn_list).w,a2
		moveq	#0,d0
		move.b	ost_respawn(a0),d0
		beq.s	.not_pressed
		bclr	#0,2(a2,d0.w)
		bra.s	.not_pressed
; ===========================================================================

; Type 7 - moves far right when button $F is pressed
FBlock_FarRightButton:
		tst.b	ost_fblock_move_flag(a0)		; is object moving already?
		bne.s	.chk_distance				; if yes, branch
		tst.b	(v_button_state+$F).w			; has button number $F been pressed?
		beq.s	.end					; if not, branch
		move.b	#1,ost_fblock_move_flag(a0)
		clr.w	ost_fblock_move_dist(a0)

	.chk_distance:
		addq.w	#1,ost_x_pos(a0)			; move object right
		move.w	ost_x_pos(a0),ost_fblock_x_start(a0)
		addq.w	#1,ost_fblock_move_dist(a0)		; increment movement counter
		cmpi.w	#$380,ost_fblock_move_dist(a0)		; has object moved $380 pixels?
		bne.s	.end					; if not, branch
		move.b	#1,(f_fblock_finish).w
		clr.b	ost_fblock_move_flag(a0)
		clr.b	ost_subtype(a0)				; stop object moving

	.end:
		rts	
; ===========================================================================

; Type $C - moves left when button is pressed
FBlock_LeftButton:
		tst.b	ost_fblock_move_flag(a0)		; is object moving?
		bne.s	.chk_distance				; if yes, branch
		lea	(v_button_state).w,a2
		moveq	#0,d0
		move.b	ost_fblock_btn_num(a0),d0
		btst	#0,(a2,d0.w)				; check status of linked button
		beq.s	.not_pressed				; branch if not pressed
		move.b	#1,ost_fblock_move_flag(a0)		; flag object as moving

	.chk_distance:
		tst.w	ost_fblock_move_dist(a0)		; is remaining distance = 0?
		beq.s	.finish					; if yes, branch
		subq.w	#2,ost_fblock_move_dist(a0)		; decrement distance

	.not_pressed:
		move.w	ost_fblock_move_dist(a0),d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d0					; invert if xflipped
		addi.w	#$80,d0

	.no_xflip:
		move.w	ost_fblock_x_start(a0),d1
		add.w	d0,d1					; add distance to start position
		move.w	d1,ost_x_pos(a0)			; update x pos
		rts	
; ===========================================================================

.finish:
		addq.b	#1,ost_subtype(a0)			; convert to type $D
		clr.b	ost_fblock_move_flag(a0)		; clear movement flag
		lea	(v_respawn_list).w,a2
		moveq	#0,d0
		move.b	ost_respawn(a0),d0
		beq.s	.not_pressed
		bset	#0,2(a2,d0.w)
		bra.s	.not_pressed
; ===========================================================================

; Type $D - moves right when button is pressed
FBlock_RightButton:
		tst.b	ost_fblock_move_flag(a0)		; is object moving?
		bne.s	.chk_distance				; if yes, branch
		lea	(v_button_state).w,a2
		moveq	#0,d0
		move.b	ost_fblock_btn_num(a0),d0
		tst.b	(a2,d0.w)				; check status of linked button (unused button subtype $4x)
		bpl.s	.not_pressed				; branch if not pressed
		move.b	#1,ost_fblock_move_flag(a0)

	.chk_distance:
		move.w	#$80,d0
		cmp.w	ost_fblock_move_dist(a0),d0		; has object moved 128px?
		beq.s	.finish					; if yes, branch
		addq.w	#2,ost_fblock_move_dist(a0)		; increment distance

	.not_pressed:
		move.w	ost_fblock_move_dist(a0),d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d0					; invert if xflipped
		addi.w	#$80,d0

	.no_xflip:
		move.w	ost_fblock_x_start(a0),d1
		add.w	d0,d1					; add distance to start position
		move.w	d1,ost_x_pos(a0)			; update x pos
		rts	
; ===========================================================================

.finish:
		subq.b	#1,ost_subtype(a0)			; convert to type $C
		clr.b	ost_fblock_move_flag(a0)		; clear movement flag
		lea	(v_respawn_list).w,a2
		moveq	#0,d0
		move.b	ost_respawn(a0),d0
		beq.s	.not_pressed
		bclr	#0,2(a2,d0.w)
		bra.s	.not_pressed
; ===========================================================================

; Type 8 - moves around in a square
FBlock_SquareSmall:
FBlock_SquareMedium:
FBlock_SquareBig:
FBlock_SquareBiggest:
		rts	
