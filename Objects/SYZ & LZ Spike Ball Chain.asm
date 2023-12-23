; ---------------------------------------------------------------------------
; Object 57 - spiked balls (SYZ, LZ)

; spawned by:
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_SYZ3 - subtype $5C
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3 - subtypes $26/$45/$54/$65/$B5/$C4/$C5/$D4/$D5
;	ObjPos_SBZ3 - subtypes $34/$35/$44/$45/$C3/$C4/$C5/$D4/$D5

; subtypes:
;	%SSSSTLLL
;	SSSS - rotation speed (1-7 = clockwise; 8-$F = anticlockwise)
;	T - type (0 = LZ spikeball; 1 = SYZ spike chain)
;	LLL - length (1-7; excluding centre piece)

type_sball_chain_bit:	equ 3
type_sball_chain:	equ 1<<type_sball_chain_bit		; 8 - SYZ spike chain
; ---------------------------------------------------------------------------

SpikeBall:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	SBall_Index(pc,d0.w),d1
		jmp	SBall_Index(pc,d1.w)
; ===========================================================================
SBall_Index:	index *,,2
		ptr SBall_Main
		ptr SBall_Move

		rsobj SpikeBall
ost_sball_speed:	rs.w 1					; rate of spin
ost_sball_radius:	rs.b 1					; radius
		rsobjend
		
SBall_Settings:	dc.l Map_SBall2					; mappings
		dc.b 0, 0, 0, id_frame_sball_base		; collision/frame for base
		dc.b 0, 0, 0, id_frame_sball_chain		; collision/frame for chain
		dc.b id_React_Hurt, 8, 8, id_frame_sball_spikeball ; collision/frame for last piece
		even
	SBall_Settings_end:
		dc.l Map_SBall
		dc.b id_React_Hurt, 4, 4, id_frame_sball_syz
		dc.b id_React_Hurt, 4, 4, id_frame_sball_syz
		dc.b id_React_Hurt, 4, 4, id_frame_sball_syz
		even
; ===========================================================================

SBall_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto SBall_Move next
		move.w	(v_tile_spikechain).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		
		move.b	ost_subtype(a0),d0
		move.b	d0,d1
		move.b	d0,d2
		andi.w	#type_sball_chain,d0			; read bit 3 of subtype
		lsr.w	#3,d0
		mulu.w	#SBall_Settings_end-SBall_Settings,d0
		lea	SBall_Settings(pc,d0.w),a2
		move.l	(a2)+,ost_mappings(a0)
		move.b	(a2)+,ost_col_type(a0)			; set collision for base
		move.b	(a2)+,ost_col_width(a0)
		move.b	(a2)+,ost_col_height(a0)
		move.b	(a2)+,ost_frame(a0)			; set frame id for base
		
		andi.b	#$F0,d1					; read high nybble of subtype
		ext.w	d1
		asl.w	#3,d1					; multiply by 8
		move.w	d1,ost_sball_speed(a0)			; set object twirl speed
		
		move.b	ost_status(a0),d0
		andi.b	#status_yflip+status_xflip,d0		; read only x/y flip bits
		ror.b	#2,d0					; move bits 0-1 into bits 6-7
		move.b	d0,ost_angle(a0)			; use those as the starting angle
		
		andi.w	#7,d2					; read only bits 0-2 of subtype
		subq.b	#1,d2					; subtract 1 for loops
		bcs.s	SBall_Move				; branch if length was 0
		moveq	#0,d3

	.loop:
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.s	SBall_Move				; branch if not found
		move.l	#ChainPiece,ost_id(a1)
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	ost_priority(a0),ost_priority(a1)
		move.b	ost_displaywidth(a0),ost_displaywidth(a1)
		saveparent
		move.b	(a2),ost_col_type(a1)
		move.b	1(a2),ost_frame(a1)
		addi.b	#16,d3					; each piece is 16px further from centre
		move.b	d3,ost_sball_radius(a1)
		dbf	d2,.loop				; repeat for length of chain
		move.b	2(a2),ost_col_type(a1)			; final piece has different collision/frame
		move.b	3(a2),ost_frame(a1)

SBall_Move:	; Routine 2
		shortcut
		move.w	ost_sball_speed(a0),d0
		add.w	d0,ost_angle(a0)			; add spin speed to angle
		bra.w	DespawnFamily				; display or delete all pieces
		
; ---------------------------------------------------------------------------
; Individual chain piece object
; ---------------------------------------------------------------------------

ChainPiece:
		getparent					; a1 = OST of parent object
		move.b	ost_angle(a1),d0			; get updated angle
		jsr	(CalcSine).l				; convert to sine/cosine
		move.w	ost_y_pos(a1),d2			; get position of chain base
		move.w	ost_x_pos(a1),d3
		moveq	#0,d4
		move.b	ost_sball_radius(a0),d4			; get radius for that object
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,ost_y_pos(a0)			; update position
		move.w	d5,ost_x_pos(a0)
		bra.w	DisplaySprite
