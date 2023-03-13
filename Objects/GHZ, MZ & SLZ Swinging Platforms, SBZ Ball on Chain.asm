; ---------------------------------------------------------------------------
; Object 15 - swinging platforms (GHZ, MZ, SLZ)
;	    - spiked ball on a chain (SBZ)

; spawned by:
;	ObjPosGHZ2, ObjPosGHZ3 - subtypes 6/7/8
;	ObjPosMZ2, ObjPosMZ3 - subtypes 4/5
;	ObjPosSLZ3 - subtype $27
;	ObjPosSBZ2 - subtypes $36/$37
; ---------------------------------------------------------------------------

SwingingPlatform:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Swing_Index(pc,d0.w),d1
		jmp	Swing_Index(pc,d1.w)
; ===========================================================================
Swing_Index:	index *,,2
		ptr Swing_Main
		ptr Swing_Anchor
		ptr Swing_Platform
		ptr Swing_Chain

		rsobj SwingingPlatform
ost_swing_sine:		rs.w 1
ost_swing_cosine:	rs.w 1
ost_swing_radius:	rs.b 1					; distance of chainlink from anchor
		rsobjend
		
Swing_Info_0:	; $0x - normal swinging platform
		dc.l Map_Swing_GHZ				; mappings (anchor/chain)
		dc.l v_tile_swing				; tile setting
		dc.w tile_pal3					; value added to tile setting
		dc.l Map_Swing_GHZ				; mappings (platform)
		dc.l v_tile_swing				; tile setting
		dc.w tile_pal3					; value added to tile setting
		dc.b id_Swing_Platform				; routine
		dc.b id_frame_swing_block			; frame
		dc.b 0						; collision type
		dc.b 24						; width
		dc.b 8						; height
		even
Swing_Info_1:	; $1x - GHZ swinging ball
		dc.l Map_Swing_GHZ				; mappings (anchor/chain)
		dc.l v_tile_swing				; tile setting
		dc.w tile_pal3					; value added to tile setting
		dc.l Map_GBall					; mappings (ball)
		dc.l vram_ball/sizeof_cell			; tile setting
		dc.w tile_pal3					; value added to tile setting
		dc.b id_Swing_Chain				; routine
		dc.b id_frame_ball_check1			; frame
		dc.b id_col_20x20+id_col_hurt			; collision type
		dc.b 24						; width
		dc.b 24						; height
		even
Swing_Info_2:	; $2x - SLZ spiked platform
		dc.l Map_Swing_SLZ				; mappings (anchor/chain)
		dc.l v_tile_swing				; tile setting
		dc.w tile_pal3					; value added to tile setting
		dc.l Map_Swing_SLZ				; mappings (spiked platform)
		dc.l v_tile_swing				; tile setting
		dc.w tile_pal3					; value added to tile setting
		dc.b id_Swing_Platform				; routine
		dc.b id_frame_swing_slz_block			; frame
		dc.b id_col_32x8+id_col_hurt			; collision type
		dc.b 32						; width
		dc.b 16						; height
		even
Swing_Info_3:	; $3x - SBZ spiked ball
		dc.l Map_BBall					; mappings (anchor/chain)
		dc.l v_tile_spikeball				; tile setting
		dc.w tile_pal3					; value added to tile setting
		dc.l Map_BBall					; mappings (spiked ball)
		dc.l v_tile_spikeball				; tile setting
		dc.w 0						; value added to tile setting
		dc.b id_Swing_Chain				; routine
		dc.b id_frame_bball_ball			; frame
		dc.b id_col_16x16+id_col_hurt			; collision type
		dc.b 24						; width
		dc.b 24						; height
		even
; ===========================================================================

Swing_Main:	; Routine 0
		move.w	ost_y_pos(a0),d0
		sub.w	(v_camera_y_pos).w,d0			; d0 = -ve if object is above screen
		cmpi.w	#-256,d0
		ble.w	DespawnQuick_NoDisplay			; branch if anchor is 256px+ above screen
		cmpi.w	#screen_height,d0
		bge.w	DespawnQuick_NoDisplay			; branch if anchor is below screen
		
		addq.b	#2,ost_routine(a0)			; goto Swing_Anchor next
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		lsr.b	#4,d0					; read high nybble
		mulu.w	#Swing_Info_1-Swing_Info_0,d0
		lea	Swing_Info_0,a2
		adda.l	d0,a2
		move.l	(a2)+,ost_mappings(a0)
		move.l	(a2)+,d0
		bpl.s	.tile_asis				; branch if tile setting isn't a RAM address
		movea.l	d0,a3
		move.w	(a3),d0					; get actual tile setting from RAM
	.tile_asis:
		add.w	(a2)+,d0
		move.w	d0,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#3,ost_priority(a0)
		move.b	#$18,ost_displaywidth(a0)
		move.b	#id_frame_swing_anchor,ost_frame(a0)
		
		bsr.w	FindNextFreeObj
		bne.w	Swing_Anchor
		move.l	#SwingingPlatform,ost_id(a1)		; load platform object
		move.l	(a2)+,ost_mappings(a1)
		move.l	(a2)+,d0
		bpl.s	.tile_asis2				; branch if tile setting isn't a RAM address
		movea.l	d0,a3
		move.w	(a3),d0					; get actual tile setting from RAM
	.tile_asis2:
		add.w	(a2)+,d0
		move.w	d0,ost_tile(a1)
		move.b	(a2)+,ost_routine(a1)
		move.b	(a2)+,ost_frame(a1)
		move.b	(a2)+,ost_col_type(a1)
		move.b	(a2),ost_displaywidth(a1)
		move.b	(a2)+,ost_width(a1)
		move.b	(a2)+,ost_height(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#3,ost_priority(a1)
		moveq	#0,d1
		move.b	ost_subtype(a0),d1			; d1 = chain length
		andi.b	#$F,d1					; read low nybble
		move.w	d1,d3
		lsl.w	#4,d3					; d3 = chain length in pixels
		addq.b	#8,d3
		move.b	d3,ost_swing_radius(a1)			; position relative to anchor
		bsr.w	SaveParent
		
		subi.b	#1,d1					; subtract 1 for loops
		moveq	#16,d2					; start position for first chain link
	.loop:
		bsr.w	FindNextFreeObj
		bne.s	Swing_Anchor
		move.l	#Swing_Chain,ost_id(a1)			; load chain object
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		bclr	#tile_pal34_bit,ost_tile(a1)
		move.b	#8,ost_displaywidth(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#id_frame_swing_chain,ost_frame(a1)
		move.b	#4,ost_priority(a1)
		move.b	d2,ost_swing_radius(a1)			; position relative to anchor
		addi.b	#16,d2
		bsr.w	SaveParent
		dbf	d1,.loop				; repeat for all chain links

Swing_Anchor:	; Routine 2
		moveq	#0,d0
		move.b	(v_oscillating_0_to_80_fast).w,d0	; get value 0-$80
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d0					; invert if xflipped
		add.w	#$80,d0					; d0 = oscillating value, same for all platforms

	.no_xflip:
		bsr.w	CalcSine
		move.w	d0,ost_swing_sine(a0)			; save sine
		move.w	d1,ost_swing_cosine(a0)			; save cosine
		bra.w	DespawnFamily				; delete child objects on despawn
; ===========================================================================

Swing_Platform:	; Routine 4
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		bsr.s	Swing_Update
		bsr.w	SolidObject_TopOnly
		bra.w	DisplaySprite
; ===========================================================================

Swing_Chain:	; Routine 6
		bsr.s	Swing_Update
		bra.w	DisplaySprite
		
; ---------------------------------------------------------------------------
; Subroutine to update position of platform and chain links
; ---------------------------------------------------------------------------

Swing_Update:
		bsr.w	GetParent				; a1 = parent object
		move.w	ost_swing_sine(a1),d0
		move.w	ost_swing_cosine(a1),d1
		move.w	ost_y_pos(a1),d2
		move.w	ost_x_pos(a1),d3
		moveq	#0,d4
		move.b	ost_swing_radius(a0),d4			; get distance of object from anchor
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,ost_y_pos(a0)			; update position
		move.w	d5,ost_x_pos(a0)
		rts
		