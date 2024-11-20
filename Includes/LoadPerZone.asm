; ---------------------------------------------------------------------------
; Subroutine to load zone/act data

;	uses d0.l, d1.l, d2.l, d4.l, d5.l, a0, a1, a2, a3, a4
; ---------------------------------------------------------------------------

LoadPerZone:
		moveq	#0,d0
		move.b	(v_zone).w,d0				; get zone number
		moveq	#0,d1
		move.b	(v_act).w,d1				; d1 = act
		move.l	d1,d2
		add.l	d2,d2					; d2 = act * 2
		move.l	d2,d4
		add.l	d4,d4					; d4 = act * 4
		move.l	d4,d5
		add.l	d5,d5					; d5 = act * 8
		mulu.w	#ZoneDefs_size-ZoneDefs,d0		; get offset for zone
		lea	ZoneDefs,a4
		adda.l	d0,a4					; jump to relevant zone data

		movea.l	(a4)+,a1				; get pointer for SlowPLC list
		cmpi.b	#id_Title,(v_gamemode).w
		beq.s	.no_kplc				; skip SPLC if on title screen
		pushr	d1-d3/a4
		move.w	(a1,d2.w),d0				; get id of SPLC
		jsr	SlowPLC_Now				; load gfx
		popr	d1-d3/a4

	.no_kplc:
		move.l	(a4)+,(v_16x16_ptr).w			; load 16x16 mappings pointer
		movea.l	(a4)+,a0				; load 256x256 mappings pointer
		lea	(v_256x256_tiles).l,a1			; RAM address for 256x256 mappings
		bsr.w	KosDec					; decompress
		move.l	(a4)+,(v_collision_index_ptr).w		; load collision index pointer

		moveq	#0,d0
		movea.l	(a4)+,a1				; get pointer for palette id list for Sonic & title cards
		move.b	(a1,d1.w),d0				; get palette id
		bsr.w	PalLoad					; load palette
		moveq	#0,d0
		movea.l	(a4)+,a1				; get pointer for palette id list for level
		move.b	(a1,d1.w),d0				; get palette id
		bsr.w	PalLoad					; load palette

		movea.l	(a4)+,a1				; get pointer for palette cycling routine list
		move.l	(a1,d4.w),(v_palcycle_ptr).w		; get pointer for palette cycling routine

		moveq	#0,d0
		move.w	(a4)+,d0				; get water flag
		beq.s	.no_water				; branch if 0
		move.b	d0,(f_water_enable).w			; set water enable flag
		movea.l	(a4),a1					; get pointer for water filter id list
		move.b	(a1,d1.w),(v_waterfilter_id).w		; set water filter id

		movea.l	4(a4),a1				; get pointer for initial water height list
		move.w	(a1,d2.w),d0				; get water height
		move.w	d0,(v_water_height_actual).w		; set water heights
		move.w	d0,(v_water_height_normal).w
		move.w	d0,(v_water_height_next).w
	.no_water:
		addq.l	#8,a4

		movea.l	(a4)+,a1				; get pointer for OPL list
		move.l	(a1,d4.w),(v_opl_data_ptr).w		; get pointer for actual OPL data

		movea.l	(a4)+,a1				; get pointer for level layout list
		movea.l	(a1,d4.w),a1				; get pointer for actual level layout
		lea	(v_level_layout).w,a2
		pushr	d1/a4
		bsr.w	HiveDec					; load level layout
		popr	d1/a4
		movea.l	(a4)+,a1				; get pointer for bg layout list
		movea.l	(a1,d4.w),a1				; get pointer for actual bg layout
		lea	(v_bg_layout).w,a2
		pushr	d1/a4
		bsr.w	HiveDec					; load bg layout
		popr	d1/a4

		movea.l	(a4)+,a1				; get pointer for music list
		move.b	(a1,d1.w),(v_bgm).w			; set music id

		move.l	(a4)+,(v_aniart_ptr).w			; load animated level art routine pointer

		movea.l	(a4)+,a1				; get pointer for level boundary list
		lea	(a1,d5.w),a1
		move.l	(a1),(v_boundary_left).w		; set left & right boundaries
		move.l	(a1)+,(v_boundary_left_next).w
		move.l	(a1),(v_boundary_top).w			; set top & bottom boundaries
		move.l	(a1)+,(v_boundary_top_next).w

		movea.l	(a4)+,a1				; get pointer for start position list
		lea	(a1,d4.w),a1
		move.w	(a1)+,(v_ost_player+ost_x_pos).w	; set Sonic's x pos
		move.w	(a1)+,(v_ost_player+ost_y_pos).w	; set Sonic's y pos

		movea.l	(a4)+,a1				; get pointer for debug list
		move.w	(a1)+,(v_debug_lastitem).w
		move.l	a1,(v_debug_ptr).w			; save address of first item in list

		movea.l	(a4)+,a1				; get pointer for title card list
		lea	(a1,d5.w),a1
		move.w	(a1)+,(v_titlecard_zone).w		; set zone name
		move.w	(a1)+,(v_titlecard_act).w		; set act number
		move.w	(a1)+,(v_titlecard_uplc).w		; set UPLC id
		addq.l	#2,a1

		movea.l	(a4)+,a1				; get pointer for DLE list
		move.l	(a1,d4.w),(v_dle_ptr).w			; get pointer for DLE routine

		movea.l	(a4)+,a1				; get pointer for next level list
		move.w	(a1,d2.w),(v_zone_next).w		; set next level

		movea.l	(a4)+,a1				; get pointer for bg deformation routine list
		move.l	(a1,d4.w),(v_deformlayer_ptr).w		; get pointer for bg deformation routine

		move.w	(a4)+,d0				; get id for animal graphics
		pushr	d1-d2
		jsr	UncPLC					; load animal graphics
		popr	d1-d2
		move.w	(a4)+,(v_animal_type).w			; get ids for animal types
		rts
