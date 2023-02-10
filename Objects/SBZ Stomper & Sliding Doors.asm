; ---------------------------------------------------------------------------
; Object 6B - stomper and sliding door (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2 - subtypes $13/$24/$34/$80/$81/$83/$88
;	ObjPos_SBZ3 - subtypes $40/$CB
; ---------------------------------------------------------------------------

ScrapStomp:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Sto_Index(pc,d0.w),d1
		jmp	Sto_Index(pc,d1.w)
; ===========================================================================
Sto_Index:	index *,,2
		ptr Sto_Main
		ptr Sto_Action

Sto_Var:	; width, height, tile setting, move distance, type number
Sto_Var_0:	dc.b $40, $C					; $0x/$8x - door
		dc.w tile_Kos_SbzDoorH+tile_pal2
		dc.b $80, id_Sto_SlideOpen
Sto_Var_1:	dc.b $1C, $20					; $1x - stomper
		dc.w tile_Kos_Stomper+tile_pal2
		dc.b $38, id_Sto_Drop_RiseSlow
Sto_Var_2:	dc.b $1C, $20					; $2x - stomper
		dc.w tile_Kos_Stomper+tile_pal2
		dc.b $40, id_Sto_Drop_RiseFast
Sto_Var_3:	dc.b $1C, $20					; $3x - stomper
		dc.w tile_Kos_Stomper+tile_pal2
		dc.b $60, id_Sto_Drop_RiseFast

sizeof_Sto_Var:	equ Sto_Var_1-Sto_Var

		rsobj ScrapStomp
ost_stomp_y_start:	rs.w 1 ; $30				; original y-axis position (2 bytes)
ost_stomp_x_start:	rs.w 1 ; $34				; original x-axis position (2 bytes)
ost_stomp_wait_time:	rs.w 1 ; $36				; time until next action (2 bytes)
ost_stomp_flag:		rs.b 1 ; $38				; flag set when associated button is pressed
ost_stomp_moved:	rs.w 1 ; $3A				; distance moved (2 bytes)
ost_stomp_distance:	rs.w 1 ; $3C				; distance to move (2 bytes)
ost_stomp_button_num:	rs.b 1 ; $3E				; button number associated with door
		rsobjend
; ===========================================================================

Sto_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Sto_Action next
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype
		andi.w	#$70,d0					; read only high nybble without bit 7
		lsr.w	#4,d0
		move.b	d0,ost_frame(a0)			; high nybble without bit 7 = frame
		mulu.w	#6,d0
		lea	Sto_Var(pc,d0.w),a3			; get variables from list
		move.b	(a3)+,ost_displaywidth(a0)
		move.b	(a3)+,ost_height(a0)
		move.w	(a3)+,ost_tile(a0)
		move.l	#Map_Stomp,ost_mappings(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.w	ost_x_pos(a0),ost_stomp_x_start(a0)
		move.w	ost_y_pos(a0),ost_stomp_y_start(a0)
		moveq	#0,d0
		move.b	(a3)+,d0
		move.w	d0,ost_stomp_distance(a0)		; set distance to move
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype
		bpl.s	Sto_Action				; branch if 0-$7F
		
		andi.b	#$F,d0					; read only low nybble
		move.b	d0,ost_stomp_button_num(a0)		; copy to ost_stomp_button_num
		move.b	(a3),ost_subtype(a0)			; update subtype with value from list
		lea	(v_respawn_list).w,a2
		moveq	#0,d0
		move.b	ost_respawn(a0),d0
		beq.s	Sto_Action
		bclr	#7,2(a2,d0.w)

Sto_Action:	; Routine 2
		move.w	ost_x_pos(a0),-(sp)			; save x pos to stack
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype (not the same as starting subtype)
		andi.w	#$F,d0					; read only low nybble
		add.w	d0,d0
		move.w	Sto_Type_Index(pc,d0.w),d1
		jsr	Sto_Type_Index(pc,d1.w)
		move.w	(sp)+,d4				; retrieve x pos from stack
		tst.b	ost_render(a0)
		bpl.s	.chkdel
		moveq	#0,d1
		move.b	ost_displaywidth(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	ost_height(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		bsr.w	SolidObject

	.chkdel:
		move.w	ost_stomp_x_start(a0),d0
		bsr.w	CheckActive
		bne.s	.chkgone
		jmp	(DisplaySprite).l

	.chkgone:
		jmp	(DeleteObject).l
; ===========================================================================
Sto_Type_Index:
		index *
		ptr Sto_Still
		ptr Sto_SlideOpen
		ptr Sto_SlideClose
		ptr Sto_Drop_RiseSlow
		ptr Sto_Drop_RiseFast
; ===========================================================================

; Type 0
Sto_Still:
		rts
; ===========================================================================

; Type 1
; Horizonal door, opens when button (ost_stomp_button_num) is pressed
Sto_SlideOpen:
		tst.b	ost_stomp_flag(a0)			; has door been activated?
		bne.s	.isactive01				; if yes, branch
		lea	(v_button_state).w,a2
		moveq	#0,d0
		move.b	ost_stomp_button_num(a0),d0
		btst	#0,(a2,d0.w)				; has button been pressed?
		beq.s	.update_pos				; if not, branch
		move.b	#1,ost_stomp_flag(a0)

	.isactive01:
		move.w	ost_stomp_distance(a0),d0		; get target distance
		cmp.w	ost_stomp_moved(a0),d0			; has door moved that distance?
		beq.s	.finished01				; if yes, branch
		addq.w	#2,ost_stomp_moved(a0)			; move 2px

.update_pos:
		move.w	ost_stomp_moved(a0),d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip01
		neg.w	d0
		addi.w	#$80,d0

	.noflip01:
		move.w	ost_stomp_x_start(a0),d1		; get initial x pos
		sub.w	d0,d1					; apply difference
		move.w	d1,ost_x_pos(a0)			; update position
		rts	
; ===========================================================================

.finished01:
		addq.b	#1,ost_subtype(a0)			; change type to 2
		move.w	#180,ost_stomp_wait_time(a0)		; set timer to 3 seconds
		clr.b	ost_stomp_flag(a0)			; clear active flag
		lea	(v_respawn_list).w,a2
		moveq	#0,d0
		move.b	ost_respawn(a0),d0
		beq.s	.update_pos
		bset	#0,2(a2,d0.w)
		bra.s	.update_pos
; ===========================================================================

; Type 2
; Horizonal door, returns to its original position after 3 seconds
Sto_SlideClose:
		tst.b	ost_stomp_flag(a0)			; has door been activated?
		bne.s	.isactive02				; if yes, branch
		subq.w	#1,ost_stomp_wait_time(a0)		; decrement timer
		bne.s	.update_pos				; branch if time remains
		move.b	#1,ost_stomp_flag(a0)

	.isactive02:
		tst.w	ost_stomp_moved(a0)			; has door reached its original position?
		beq.s	.finished02				; if yes, branch
		subq.w	#2,ost_stomp_moved(a0)			; move back 2px

.update_pos:
		move.w	ost_stomp_moved(a0),d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip02
		neg.w	d0
		addi.w	#$80,d0

	.noflip02:
		move.w	ost_stomp_x_start(a0),d1		; get initial x pos
		sub.w	d0,d1					; apply difference
		move.w	d1,ost_x_pos(a0)			; update position
		rts	
; ===========================================================================

.finished02:
		subq.b	#1,ost_subtype(a0)			; change back to type 1
		clr.b	ost_stomp_flag(a0)			; clear active flag
		lea	(v_respawn_list).w,a2
		moveq	#0,d0
		move.b	ost_respawn(a0),d0
		beq.s	.update_pos
		bclr	#0,2(a2,d0.w)
		bra.s	.update_pos
; ===========================================================================

; Type 3
; Stomper, drops quickly and rises slowly
Sto_Drop_RiseSlow:
		tst.b	ost_stomp_flag(a0)
		bne.s	.isactive03
		tst.w	ost_stomp_moved(a0)			; has stomper started moving?
		beq.s	.wait					; if not, branch
		subq.w	#1,ost_stomp_moved(a0)			; move up 1px
		bra.s	.update_pos
; ===========================================================================

.wait:
		subq.w	#1,ost_stomp_wait_time(a0)		; decrement wait time
		bpl.s	.update_pos				; branch if time remains
		move.w	#60,ost_stomp_wait_time(a0)		; set wait time to 1 second
		move.b	#1,ost_stomp_flag(a0)

.isactive03:
		addq.w	#8,ost_stomp_moved(a0)			; move down 8px
		move.w	ost_stomp_moved(a0),d0
		cmp.w	ost_stomp_distance(a0),d0		; has stomper reached maximum distance?
		bne.s	.update_pos				; if not, branch
		clr.b	ost_stomp_flag(a0)

.update_pos:
		move.w	ost_stomp_moved(a0),d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip03
		neg.w	d0
		addi.w	#$38,d0

	.noflip03:
		move.w	ost_stomp_y_start(a0),d1		; get initial y pos
		add.w	d0,d1					; apply difference
		move.w	d1,ost_y_pos(a0)			; update position
		rts	
; ===========================================================================

; Type 4
; Stomper, drops quickly and rises quickly
Sto_Drop_RiseFast:
		tst.b	ost_stomp_flag(a0)
		bne.s	.isactive04
		tst.w	ost_stomp_moved(a0)			; has stomper started moving?
		beq.s	.wait					; if not, branch
		subq.w	#8,ost_stomp_moved(a0)			; move up 8px
		bra.s	.update_pos
; ===========================================================================

.wait:
		subq.w	#1,ost_stomp_wait_time(a0)		; decrement wait time
		bpl.s	.update_pos				; branch if time remains
		move.w	#60,ost_stomp_wait_time(a0)		; set wait time to 1 second
		move.b	#1,ost_stomp_flag(a0)

.isactive04:
		move.w	ost_stomp_moved(a0),d0
		cmp.w	ost_stomp_distance(a0),d0		; has stomper reached maximum distance?
		beq.s	.wait2					; if not, branch
		addq.w	#8,ost_stomp_moved(a0)			; move down 8px
		bra.s	.update_pos
; ===========================================================================

.wait2:
		subq.w	#1,ost_stomp_wait_time(a0)		; decrement wait time
		bpl.s	.update_pos				; branch if time remains
		move.w	#60,ost_stomp_wait_time(a0)		; set wait time to 1 second
		clr.b	ost_stomp_flag(a0)

.update_pos:
		move.w	ost_stomp_moved(a0),d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip04
		neg.w	d0
		addi.w	#$38,d0

	.noflip04:
		move.w	ost_stomp_y_start(a0),d1		; get initial y pos
		add.w	d0,d1					; apply difference
		move.w	d1,ost_y_pos(a0)			; update position
		rts
