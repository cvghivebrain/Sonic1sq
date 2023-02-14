; ---------------------------------------------------------------------------
; Object 31 - stomping metal blocks on chains (MZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 2/$11/$12/$23/$80
;	ChainStomp
; ---------------------------------------------------------------------------

ChainStomp:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	CStom_Index(pc,d0.w),d1
		jmp	CStom_Index(pc,d1.w)
; ===========================================================================
CStom_Index:	index *,,2
		ptr CStom_Main
		ptr CStom_Block
		ptr CStom_Spikes
		ptr CStom_Ceiling
		ptr CStom_Chain

		rsobj ChainStomp
ost_cstomp_y_start:		rs.w 1				; original y position
ost_cstomp_chain_length:	rs.w 1				; current chain length
ost_cstomp_chain_max:		rs.w 1				; maximum chain length
ost_cstomp_delay_time:		rs.w 1				; time delay between fully extended and rising again
ost_cstomp_btn_id:		rs.b 1				; button number for the current stomper
ost_cstomp_rise_flag:		rs.b 1				; 0 = falling; 1 = rising
		rsobjend
		
CStom_Sizes:	; width, height, frame, omit spikes flag
		dc.b 56, 12, id_frame_cstomp_wideblock, 0	; $0x
		dc.b 48, 12, id_frame_cstomp_mediumblock, 0	; $1x
		dc.b 16, 12, id_frame_cstomp_smallblock, 1	; $2x
		dc.b 16, 12, id_frame_cstomp_smallblock, 1	; $3x

CStom_Lengths:	; max chain lengths *$100
		dc.w $7000, $A000, $5000, $7800			; 0-3
		dc.w $3800, $5800, $B800, $7000			; 4-7
		dc.w $3800, $5800, $B800, $7000			; 8-$B
		dc.w $3800, $5800, $B800, $7000			; $C-$F
; ===========================================================================

CStom_Main:	; Routine 0
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype
		move.l	d0,d1
		andi.b	#$30,d0					; read bits 5/4
		lsr.b	#2,d0
		lea	CStom_Sizes(pc,d0.w),a2
		move.b	(a2),ost_displaywidth(a0)
		move.b	(a2)+,ost_width(a0)
		move.b	(a2)+,ost_height(a0)
		move.b	(a2)+,ost_frame(a0)
		move.b	(a2),d2
		andi.b	#$F,d1					; read low nybble
		add.b	d1,d1					; multiply by 2
		move.w	CStom_Lengths(pc,d1.w),ost_cstomp_chain_max(a0)
		move.l	#Map_CStom,ost_mappings(a0)
		move.w	#tile_Kos_MzMetal,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	ost_y_pos(a0),ost_cstomp_y_start(a0)
		move.b	#4,ost_priority(a0)
		addi.b	#2,ost_routine(a0)			; goto CStom_Block next
		
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.w	CStom_Block
		move.l	#ChainStomp,ost_id(a1)			; load ceiling block
		move.b	#id_CStom_Ceiling,ost_routine(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		subi.w	#$10,ost_y_pos(a1)
		move.l	#Map_CStom,ost_mappings(a1)
		move.w	#tile_Kos_MzMetal,ost_tile(a1)
		move.b	#id_frame_cstomp_ceiling,ost_frame(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#4,ost_priority(a1)
		move.b	#16,ost_displaywidth(a1)
		bsr.w	SaveParent
		
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.w	CStom_Block
		move.l	#ChainStomp,ost_id(a1)			; load chain
		move.b	#id_CStom_Chain,ost_routine(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		subi.w	#$34,ost_y_pos(a1)
		move.l	#Map_CStom,ost_mappings(a1)
		move.w	#tile_Kos_MzMetal,ost_tile(a1)
		move.b	#id_frame_cstomp_chain1,ost_frame(a1)
		move.b	#render_rel+render_useheight,ost_render(a1)
		move.b	#4,ost_priority(a1)
		move.b	#16,ost_displaywidth(a1)
		move.b	#$80,ost_height(a1)
		bsr.w	SaveParent
		
		tst.b	d2
		bne.w	CStom_Block				; branch if omit spikes flag is set
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.w	CStom_Block
		move.l	#ChainStomp,ost_id(a1)			; load spikes
		move.b	#id_CStom_Spikes,ost_routine(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		addi.w	#$1C,ost_y_pos(a1)
		move.l	#Map_CStom,ost_mappings(a1)
		move.w	(v_tile_spikes).w,ost_tile(a1)
		move.b	#id_frame_cstomp_spikes,ost_frame(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#4,ost_priority(a1)
		move.b	#48,ost_displaywidth(a1)
		move.b	#id_col_40x16+id_col_hurt,ost_col_type(a1) ; make spikes harmful
		bsr.w	SaveParent

CStom_Block:	; Routine 2
		bsr.w	CStom_Types				; update speed & position
		move.w	ost_y_pos(a0),(v_cstomp_y_pos).w	; store y position for pushable green block interaction
		bsr.w	SolidNew
		andi.b	#1,d1
		beq.s	CStom_Ceiling				; branch if Sonic isn't on top
		cmpi.b	#$10,ost_cstomp_chain_length(a0)
		bcc.s	CStom_Ceiling				; branch if chain is longer than 16px
		bsr.w	ObjectKillSonic				; Sonic is crushed against ceiling
		
CStom_Ceiling:	; Routine 6
		bra.w	DespawnQuick
; ===========================================================================

CStom_Chain:	; Routine 8
		bsr.w	GetParent				; a1 = address of parent OST
		move.b	ost_cstomp_chain_length(a1),d0		; get current chain length
		lsr.b	#5,d0					; divide by $20
		addq.b	#id_frame_cstomp_chain1,d0		; convert to frame number
		move.b	d0,ost_frame(a0)			; update frame
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		subi.w	#$34,ost_y_pos(a0)
		bra.w	DespawnQuick

CStom_Spikes:	; Routine 4
		bsr.w	GetParent				; a1 = address of parent OST
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		addi.w	#$1C,ost_y_pos(a0)
		bra.w	DespawnQuick
; ===========================================================================

CStom_Types:
		move.b	ost_subtype(a0),d0			; get subtype (for button-controlled stompers this will have changed to 0)
		andi.w	#$C0,d0					; read bits 7/6
		lsr.w	#5,d0
		move.w	CStom_TypeIndex(pc,d0.w),d1
		jmp	CStom_TypeIndex(pc,d1.w)
; ===========================================================================
CStom_TypeIndex:index *
		ptr CStom_TypeNormal				; 0
		ptr CStom_TypeProx				; $40
		ptr CStom_TypeBtn				; $80
		ptr CStom_TypeBtn				; $C0
; ===========================================================================

; Type $80 - rises when button is pressed
CStom_TypeBtn:
		lea	(v_button_state).w,a2			; load button statuses
		moveq	#0,d0
		move.b	ost_cstomp_btn_id(a0),d0		; move number 0 or 1 to d0
		tst.b	(a2,d0.w)				; has button (d0) been pressed?
		beq.s	CStom_TypeBtn_Fall			; if not, branch
		tst.w	(v_cstomp_y_pos).w			; is stomper below the top edge of the level?
		bpl.s	.within_boundary			; is yes, branch
		cmpi.b	#$10,ost_cstomp_chain_length(a0)	; is chain at its shortest?
		beq.s	.stop					; if yes, branch

	.within_boundary:
		tst.w	ost_cstomp_chain_length(a0)
		beq.s	.stop
		move.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		andi.b	#$F,d0					; read low nybble
		bne.s	.skip_sound				; branch if not 0
		tst.b	ost_render(a0)
		bpl.s	.skip_sound
		play.w	1, jsr, sfx_ChainRise			; play rising chain sound every 16 frames

	.skip_sound:
		subi.w	#$80,ost_cstomp_chain_length(a0)	; shorten chain
		bcc.s	CStom_SetPos				; branch if +ve
		move.w	#0,ost_cstomp_chain_length(a0)

	.stop:
		move.w	#0,ost_y_vel(a0)			; stop stomper rising
		bra.s	CStom_SetPos
; ===========================================================================

CStom_TypeBtn_Fall:
		move.w	ost_cstomp_chain_max(a0),d1
		cmp.w	ost_cstomp_chain_length(a0),d1		; is chain at its maximum?
		beq.s	CStom_SetPos				; if yes, branch

		move.w	ost_y_vel(a0),d0
		addi.w	#$70,ost_y_vel(a0)			; make object fall
		add.w	d0,ost_cstomp_chain_length(a0)
		cmp.w	ost_cstomp_chain_length(a0),d1
		bhi.s	CStom_SetPos
		move.w	d1,ost_cstomp_chain_length(a0)
		move.w	#0,ost_y_vel(a0)			; stop object falling
		tst.b	ost_render(a0)
		bpl.s	CStom_SetPos
		play.w	1, jsr, sfx_ChainStomp			; play stomping sound

CStom_SetPos:
		moveq	#0,d0
		move.b	ost_cstomp_chain_length(a0),d0
		add.w	ost_cstomp_y_start(a0),d0		; d0 = initial y pos + chain length
		move.w	d0,ost_y_pos(a0)			; update position
		rts	
; ===========================================================================

; Type 0 - alternately rises and drops
CStom_TypeNormal:
		tst.b	ost_cstomp_rise_flag(a0)		; is stomper falling?
		beq.s	CStom_TypeNormal_Fall			; if yes, branch
		tst.w	ost_cstomp_delay_time(a0)
		beq.s	CStom_TypeNormal_Rise			; branch if timer = 0
		subq.w	#1,ost_cstomp_delay_time(a0)		; decrement timer
		bra.s	CStom_TypeNormal_SetPos
; ===========================================================================

CStom_TypeNormal_Rise:
		move.b	(v_vblank_counter_byte).w,d0
		andi.b	#$F,d0
		bne.s	.skip_sound
		tst.b	ost_render(a0)
		bpl.s	.skip_sound
		play.w	1, jsr, sfx_ChainRise			; play rising chain sound every 16 frames

	.skip_sound:
		subi.w	#$80,ost_cstomp_chain_length(a0)
		bcc.s	CStom_TypeNormal_SetPos
		move.w	#0,ost_cstomp_chain_length(a0)
		move.w	#0,ost_y_vel(a0)
		move.b	#0,ost_cstomp_rise_flag(a0)
		bra.s	CStom_TypeNormal_SetPos
; ===========================================================================

CStom_TypeNormal_Fall:
		move.w	ost_cstomp_chain_max(a0),d1
		cmp.w	ost_cstomp_chain_length(a0),d1
		beq.s	CStom_TypeNormal_SetPos
		move.w	ost_y_vel(a0),d0
		addi.w	#$70,ost_y_vel(a0)			; make object fall
		add.w	d0,ost_cstomp_chain_length(a0)
		cmp.w	ost_cstomp_chain_length(a0),d1
		bhi.s	CStom_TypeNormal_SetPos
		move.w	d1,ost_cstomp_chain_length(a0)
		move.w	#0,ost_y_vel(a0)			; stop object falling
		move.b	#1,ost_cstomp_rise_flag(a0)
		move.w	#60,ost_cstomp_delay_time(a0)
		tst.b	ost_render(a0)
		bpl.s	CStom_TypeNormal_SetPos
		play.w	1, jsr, sfx_ChainStomp			; play stomping sound

CStom_TypeNormal_SetPos:
		bra.w	CStom_SetPos
; ===========================================================================

; Type $40 - drops when Sonic is nearby
CStom_TypeProx:
		bsr.w	Range
		cmpi.w	#144,d1					; is Sonic within 144px?
		bcc.s	.over_144				; if not, branch
		andi.b	#$3F,ost_subtype(a0)			; allow stomper to drop by changing subtype

	.over_144:
		bra.w	CStom_SetPos
