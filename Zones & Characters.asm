; ---------------------------------------------------------------------------
; Subroutine to load zone/act data
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
		lea	(ZoneDefs).l,a4
		adda.l	d0,a4					; jump to relevant zone data

		movea.l	(a4)+,a1				; get pointer for Kosinski PLC list
		cmpi.b	#id_Title,(v_gamemode).w
		beq.s	.no_kplc				; skip KPLC if on title screen
		move.w	(a1,d2.w),d0				; get id of KPLC
		jsr	KosPLC					; run KPLC

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
		adda.l	#8,a4

		movea.l	(a4)+,a1				; get pointer for OPL list
		move.l	(a1,d4.w),(v_opl_data_ptr).w		; get pointer for actual OPL data
		
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
		
		movea.l	(a4),a1					; get pointer for debug list
		move.w	(a1),(v_debug_count).w			; get number of items in list
		move.l	(a4)+,(v_debug_ptr).w
		add.l	#2,(v_debug_ptr).w			; skip to first item in list
		
		movea.l	(a4)+,a1				; get pointer for title card list
		lea	(a1,d5.w),a1
		move.w	(a1)+,(v_titlecard_zone).w		; set zone name
		move.w	(a1)+,(v_titlecard_act).w		; set act number
		move.w	(a1)+,(v_titlecard_uplc).w		; set UPLC id
		adda.l	#2,a1

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
		rts
		
; ---------------------------------------------------------------------------
; Zone definitions
; ---------------------------------------------------------------------------

ZoneDefs:	; Green Hill Zone
		dc.l Zone_KPLC_GHZ				; Kosinski PLC list (act specific)
		dc.l Blk16_GHZ					; 16x16 mappings
		dc.l Blk256_GHZ					; 256x256 mappings
		dc.l Col_GHZ					; collision index
		dc.l Zone_SPal_GHZ				; palette id list for Sonic & title cards (act specific)
		dc.l Zone_Pal_GHZ				; palette id list for level (act specific)
		dc.l Zone_PCyc_GHZ				; palette cycling routine list (act specific)
		dc.w 0						; 1 to enable water
		dc.l Zone_Filter_LZ				; water filter id list (act specific)
		dc.l Zone_WHeight_LZ				; water height list (act specific)
		dc.l Zone_OPL_GHZ				; object position list (act specific)
		dc.l Zone_Music_GHZ				; background music id list (act specific)
		dc.l AniArt_GHZ					; animated level art routine
		dc.l Zone_Bound_GHZ				; level boundary list (act specific)
		dc.l Zone_SPos_GHZ				; start position list (act specific)
		dc.l DebugList_GHZ				; debug list
		dc.l Zone_Card_GHZ				; title card list (act specific)
		dc.l Zone_DLE_GHZ				; dynamic level event list (act specific)
		dc.l Zone_Next_GHZ				; next level list (act specific)
		dc.l Zone_Deform_GHZ				; bg deformation routine list (act specific)
		dc.w id_UPLC_RabbitFlicky			; UPLC id for animal graphics
		even
	ZoneDefs_size:

		; Labyrinth Zone
		dc.l Zone_KPLC_LZ
		dc.l Blk16_LZ
		dc.l Blk256_LZ
		dc.l Col_LZ
		dc.l Zone_SPal_GHZ
		dc.l Zone_Pal_LZ
		dc.l Zone_PCyc_LZ
		dc.w 1
		dc.l Zone_Filter_LZ
		dc.l Zone_WHeight_LZ
		dc.l Zone_OPL_LZ
		dc.l Zone_Music_LZ
		dc.l AniArt_none
		dc.l Zone_Bound_LZ
		dc.l Zone_SPos_LZ
		dc.l DebugList_LZ
		dc.l Zone_Card_LZ
		dc.l Zone_DLE_LZ
		dc.l Zone_Next_LZ
		dc.l Zone_Deform_LZ
		dc.w id_UPLC_BirdSeal
		even
		
		; Marble Zone
		dc.l Zone_KPLC_MZ
		dc.l Blk16_MZ
		dc.l Blk256_MZ
		dc.l Col_MZ
		dc.l Zone_SPal_GHZ
		dc.l Zone_Pal_MZ
		dc.l Zone_PCyc_MZ
		dc.w 0
		dc.l Zone_Filter_LZ
		dc.l Zone_WHeight_LZ
		dc.l Zone_OPL_MZ
		dc.l Zone_Music_MZ
		dc.l AniArt_MZ
		dc.l Zone_Bound_MZ
		dc.l Zone_SPos_MZ
		dc.l DebugList_MZ
		dc.l Zone_Card_MZ
		dc.l Zone_DLE_MZ
		dc.l Zone_Next_MZ
		dc.l Zone_Deform_MZ
		dc.w id_UPLC_SquirrelSeal
		even
		
		; Star Light Zone
		dc.l Zone_KPLC_SLZ
		dc.l Blk16_SLZ
		dc.l Blk256_SLZ
		dc.l Col_SLZ
		dc.l Zone_SPal_GHZ
		dc.l Zone_Pal_SLZ
		dc.l Zone_PCyc_SLZ
		dc.w 0
		dc.l Zone_Filter_LZ
		dc.l Zone_WHeight_LZ
		dc.l Zone_OPL_SLZ
		dc.l Zone_Music_SLZ
		dc.l AniArt_none
		dc.l Zone_Bound_SLZ
		dc.l Zone_SPos_SLZ
		dc.l DebugList_SLZ
		dc.l Zone_Card_SLZ
		dc.l Zone_DLE_SLZ
		dc.l Zone_Next_SLZ
		dc.l Zone_Deform_SLZ
		dc.w id_UPLC_PigFlicky
		even
		
		; Spring Yard Zone
		dc.l Zone_KPLC_SYZ
		dc.l Blk16_SYZ
		dc.l Blk256_SYZ
		dc.l Col_SYZ
		dc.l Zone_SPal_GHZ
		dc.l Zone_Pal_SYZ
		dc.l Zone_PCyc_SYZ
		dc.w 0
		dc.l Zone_Filter_LZ
		dc.l Zone_WHeight_LZ
		dc.l Zone_OPL_SYZ
		dc.l Zone_Music_SYZ
		dc.l AniArt_none
		dc.l Zone_Bound_SYZ
		dc.l Zone_SPos_SYZ
		dc.l DebugList_SYZ
		dc.l Zone_Card_SYZ
		dc.l Zone_DLE_SYZ
		dc.l Zone_Next_SYZ
		dc.l Zone_Deform_SYZ
		dc.w id_UPLC_PigChicken
		even
		
		; Scrap Brain Zone
		dc.l Zone_KPLC_SBZ
		dc.l Blk16_SBZ
		dc.l Blk256_SBZ
		dc.l Col_SBZ
		dc.l Zone_SPal_GHZ
		dc.l Zone_Pal_SBZ
		dc.l Zone_PCyc_SBZ
		dc.w 0
		dc.l Zone_Filter_LZ
		dc.l Zone_WHeight_LZ
		dc.l Zone_OPL_SBZ
		dc.l Zone_Music_SBZ
		dc.l AniArt_SBZ
		dc.l Zone_Bound_SBZ
		dc.l Zone_SPos_SBZ
		dc.l DebugList_SBZ
		dc.l Zone_Card_SBZ
		dc.l Zone_DLE_SBZ
		dc.l Zone_Next_SBZ
		dc.l Zone_Deform_SBZ
		dc.w id_UPLC_RabbitChicken
		even
		
		; Ending
		dc.l Zone_KPLC_End
		dc.l Blk16_GHZ
		dc.l Blk256_GHZ
		dc.l Col_GHZ
		dc.l Zone_SPal_GHZ
		dc.l Zone_Pal_End
		dc.l Zone_PCyc_GHZ
		dc.w 0
		dc.l Zone_Filter_LZ
		dc.l Zone_WHeight_LZ
		dc.l Zone_OPL_End
		dc.l Zone_Music_End
		dc.l AniArt_Ending
		dc.l Zone_Bound_End
		dc.l Zone_SPos_End
		dc.l DebugList_Ending
		dc.l Zone_Card_GHZ
		dc.l Zone_DLE_End
		dc.l Zone_Next_End
		dc.l Zone_Deform_End
		dc.w id_UPLC_Animals
		even

; ---------------------------------------------------------------------------
; Kosinski PLC id list
; ---------------------------------------------------------------------------

Zone_KPLC_GHZ:	dc.w id_KPLC_GHZ,id_KPLC_GHZ,id_KPLC_GHZ
Zone_KPLC_MZ:	dc.w id_KPLC_MZ,id_KPLC_MZ,id_KPLC_MZ
Zone_KPLC_SYZ:	dc.w id_KPLC_SYZ,id_KPLC_SYZ,id_KPLC_SYZ
Zone_KPLC_LZ:	dc.w id_KPLC_LZ,id_KPLC_LZ,id_KPLC_LZ,id_KPLC_SBZ3
Zone_KPLC_SLZ:	dc.w id_KPLC_SLZ,id_KPLC_SLZ,id_KPLC_SLZ
Zone_KPLC_SBZ:	dc.w id_KPLC_SBZ,id_KPLC_SBZ,id_KPLC_FZ
Zone_KPLC_End:	dc.w id_KPLC_End,id_KPLC_End

; ---------------------------------------------------------------------------
; Palette ids
; ---------------------------------------------------------------------------

Zone_SPal_GHZ:	dc.b id_Pal_Sonic,id_Pal_Sonic,id_Pal_Sonic,id_Pal_Sonic

Zone_Pal_GHZ:	dc.b id_Pal_GHZ,id_Pal_GHZ,id_Pal_GHZ
Zone_Pal_MZ:	dc.b id_Pal_MZ,id_Pal_MZ,id_Pal_MZ
Zone_Pal_SYZ:	dc.b id_Pal_SYZ,id_Pal_SYZ,id_Pal_SYZ
Zone_Pal_LZ:	dc.b id_Pal_LZ,id_Pal_LZ,id_Pal_LZ,id_Pal_SBZ3
Zone_Pal_SLZ:	dc.b id_Pal_SLZ,id_Pal_SLZ,id_Pal_SLZ
Zone_Pal_SBZ:	dc.b id_Pal_SBZ1,id_Pal_SBZ2,id_Pal_SBZ2
Zone_Pal_End:	dc.b id_Pal_Ending,id_Pal_Ending

Zone_Filter_LZ:
		dc.b id_Filter_LZ,id_Filter_LZ,id_Filter_LZ,id_Filter_SBZ3
		even

; ---------------------------------------------------------------------------
; Palette cycling routine pointers
; ---------------------------------------------------------------------------

Zone_PCyc_GHZ:	dc.l PCycle_GHZ,PCycle_GHZ,PCycle_GHZ
Zone_PCyc_MZ:	dc.l PCycle_MZ,PCycle_MZ,PCycle_MZ
Zone_PCyc_SYZ:	dc.l PCycle_SYZ,PCycle_SYZ,PCycle_SYZ
Zone_PCyc_LZ:	dc.l PCycle_LZ,PCycle_LZ,PCycle_LZ,PCycle_SBZ3
Zone_PCyc_SLZ:	dc.l PCycle_SLZ,PCycle_SLZ,PCycle_SLZ
Zone_PCyc_SBZ:	dc.l PCycle_SBZ,PCycle_SBZ2,PCycle_SBZ2

; ---------------------------------------------------------------------------
; Water heights
; ---------------------------------------------------------------------------

Zone_WHeight_LZ:
		dc.w $B8, $328, $900, $228
		even

; ---------------------------------------------------------------------------
; Object position list pointers
; ---------------------------------------------------------------------------

Zone_OPL_GHZ:	dc.l ObjPos_GHZ1,ObjPos_GHZ2,ObjPos_GHZ3
Zone_OPL_MZ:	dc.l ObjPos_MZ1,ObjPos_MZ2,ObjPos_MZ3
Zone_OPL_SYZ:	dc.l ObjPos_SYZ1,ObjPos_SYZ2,ObjPos_SYZ3
Zone_OPL_LZ:	dc.l ObjPos_LZ1,ObjPos_LZ2,ObjPos_LZ3,ObjPos_SBZ3
Zone_OPL_SLZ:	dc.l ObjPos_SLZ1,ObjPos_SLZ2,ObjPos_SLZ3
Zone_OPL_SBZ:	dc.l ObjPos_SBZ1,ObjPos_SBZ2,ObjPos_FZ
Zone_OPL_End:	dc.l ObjPos_Ending,ObjPos_Ending

; ---------------------------------------------------------------------------
; Background music ids
; ---------------------------------------------------------------------------

Zone_Music_GHZ:	dc.b mus_GHZ,mus_GHZ,mus_GHZ
Zone_Music_MZ:	dc.b mus_MZ,mus_MZ,mus_MZ
Zone_Music_SYZ:	dc.b mus_SYZ,mus_SYZ,mus_SYZ
Zone_Music_LZ:	dc.b mus_LZ,mus_LZ,mus_LZ,mus_SBZ
Zone_Music_SLZ:	dc.b mus_SLZ,mus_SLZ,mus_SLZ
Zone_Music_SBZ:	dc.b mus_SBZ,mus_SBZ,mus_FZ
Zone_Music_End:	dc.b mus_Ending,mus_Ending
		even

; ---------------------------------------------------------------------------
; Level boundaries

; v_boundary_left, v_boundary_right, v_boundary_top, v_boundary_bottom
; ---------------------------------------------------------------------------

Zone_Bound_GHZ:	dc.w $0000, $24BF, $0000, $0300
		dc.w $0000, $1EBF, $0000, $0300
		dc.w $0000, $2960, $0000, $0300
Zone_Bound_LZ:	dc.w $0000, $19BF, $0000, $0530
		dc.w $0000, $10AF, $0000, $0720
		dc.w $0000, $202F, $FF00, $0800
		dc.w $0000, $20BF, $0000, $0720			; SBZ3
Zone_Bound_MZ:	dc.w $0000, $17BF, $0000, $01D0
		dc.w $0000, $17BF, $0000, $0520
		dc.w $0000, $1800, $0000, $0720
Zone_Bound_SLZ:	dc.w $0000, $1FBF, $0000, $0640
		dc.w $0000, $1FBF, $0000, $0640
		dc.w $0000, $2000, $0000, $06C0
Zone_Bound_SYZ:	dc.w $0000, $22C0, $0000, $0420
		dc.w $0000, $28C0, $0000, $0520
		dc.w $0000, $2C00, $0000, $0620
Zone_Bound_SBZ:	dc.w $0000, $21C0, $0000, $0720
		dc.w $0000, $1E40, $FF00, $0800
		dc.w $2080, $2460, $0510, $0510			; FZ
Zone_Bound_End:	dc.w $0000, $0500, $0110, $0110
		dc.w $0000, $0DC0, $0110, $0110
		even

; ---------------------------------------------------------------------------
; Start positions
; ---------------------------------------------------------------------------

Zone_SPos_GHZ:	dc.w $0050, $03B0
		dc.w $0050, $00FC
		dc.w $0050, $03B0
Zone_SPos_LZ:	dc.w $0060, $006C
		dc.w $0050, $00EC
		dc.w $0050, $02EC
		dc.w $0B80, $0000				; SBZ3
Zone_SPos_MZ:	dc.w $0030, $0266
		dc.w $0030, $0266
		dc.w $0030, $0166
Zone_SPos_SLZ:	dc.w $0040, $02CC
		dc.w $0040, $014C
		dc.w $0040, $014C
Zone_SPos_SYZ:	dc.w $0030, $03BD
		dc.w $0030, $01BD
		dc.w $0030, $00EC
Zone_SPos_SBZ:	dc.w $0030, $048C
		dc.w $0030, $074C
		dc.w $2140, $05AC				; FZ
Zone_SPos_End:	dc.w $0620, $016B
		dc.w $0EE0, $016C
		even

; ---------------------------------------------------------------------------
; Title card ids
; ---------------------------------------------------------------------------

Zone_Card_GHZ:	dc.w id_CardSet_GHZ,id_frame_card_act1,id_UPLC_GHZCard,0
		dc.w id_CardSet_GHZ,id_frame_card_act2,id_UPLC_GHZCard,0
		dc.w id_CardSet_GHZ,id_frame_card_act3,id_UPLC_GHZCard,0
Zone_Card_MZ:	dc.w id_CardSet_MZ,id_frame_card_act1,id_UPLC_MZCard,0
		dc.w id_CardSet_MZ,id_frame_card_act2,id_UPLC_MZCard,0
		dc.w id_CardSet_MZ,id_frame_card_act3,id_UPLC_MZCard,0
Zone_Card_SYZ:	dc.w id_CardSet_SYZ,id_frame_card_act1,id_UPLC_SYZCard,0
		dc.w id_CardSet_SYZ,id_frame_card_act2,id_UPLC_SYZCard,0
		dc.w id_CardSet_SYZ,id_frame_card_act3,id_UPLC_SYZCard,0
Zone_Card_LZ:	dc.w id_CardSet_LZ,id_frame_card_act1,id_UPLC_LZCard,0
		dc.w id_CardSet_LZ,id_frame_card_act2,id_UPLC_LZCard,0
		dc.w id_CardSet_LZ,id_frame_card_act3,id_UPLC_LZCard,0
		dc.w id_CardSet_SBZ,id_frame_card_act3,id_UPLC_SBZCard,0 ; SBZ3
Zone_Card_SLZ:	dc.w id_CardSet_SLZ,id_frame_card_act1,id_UPLC_SLZCard,0
		dc.w id_CardSet_SLZ,id_frame_card_act2,id_UPLC_SLZCard,0
		dc.w id_CardSet_SLZ,id_frame_card_act3,id_UPLC_SLZCard,0
Zone_Card_SBZ:	dc.w id_CardSet_SBZ,id_frame_card_act1,id_UPLC_SBZCard,0
		dc.w id_CardSet_SBZ,id_frame_card_act2,id_UPLC_SBZCard,0
		dc.w id_CardSet_FZ,id_frame_card_act1,id_UPLC_SBZCard,0 ; FZ

; ---------------------------------------------------------------------------
; Dynamic level event list pointers
; ---------------------------------------------------------------------------

Zone_DLE_GHZ:	dc.l DLE_GHZ1,DLE_GHZ2,DLE_GHZ3
Zone_DLE_MZ:	dc.l DLE_MZ1,DLE_MZ2,DLE_MZ3
Zone_DLE_SYZ:	dc.l DLE_SYZ1,DLE_SYZ2,DLE_SYZ3
Zone_DLE_LZ:	dc.l DLE_LZ12,DLE_LZ12,DLE_LZ3,DLE_SBZ3
Zone_DLE_SLZ:	dc.l DLE_SLZ12,DLE_SLZ12,DLE_SLZ3
Zone_DLE_SBZ:	dc.l DLE_SBZ1,DLE_SBZ2,DLE_FZ
Zone_DLE_End:	dc.l DLE_Ending,DLE_Ending

; ---------------------------------------------------------------------------
; Next level list
; ---------------------------------------------------------------------------

Zone_Next_GHZ:	dc.w id_GHZ_act2,id_GHZ_act3,id_MZ_act1
Zone_Next_MZ:	dc.w id_MZ_act2,id_MZ_act3,id_SYZ_act1
Zone_Next_SYZ:	dc.w id_SYZ_act2,id_SYZ_act3,id_LZ_act1
Zone_Next_LZ:	dc.w id_LZ_act2,id_LZ_act3,id_SLZ_act1,id_FZ	; SBZ3 -> FZ
Zone_Next_SLZ:	dc.w id_SLZ_act2,id_SLZ_act3,id_SBZ_act1
Zone_Next_SBZ:	dc.w id_SBZ_act2,id_SBZ_act3,id_GHZ_act1
Zone_Next_End:	dc.w id_GHZ_act1,id_GHZ_act1

; ---------------------------------------------------------------------------
; Background deformation routine pointers
; ---------------------------------------------------------------------------

Zone_Deform_GHZ:	dc.l Deform_GHZ,Deform_GHZ,Deform_GHZ
Zone_Deform_MZ:		dc.l Deform_MZ,Deform_MZ,Deform_MZ
Zone_Deform_SYZ:	dc.l Deform_SYZ,Deform_SYZ,Deform_SYZ
Zone_Deform_LZ:		dc.l Deform_LZ,Deform_LZ,Deform_LZ,Deform_LZ ; SBZ3
Zone_Deform_SLZ:	dc.l Deform_SLZ,Deform_SLZ,Deform_SLZ
Zone_Deform_SBZ:	dc.l Deform_SBZ1,Deform_SBZ2,Deform_SBZ2 ; FZ
Zone_Deform_End:	dc.l Deform_GHZ,Deform_GHZ

; ---------------------------------------------------------------------------
; Subroutine to load character data
; ---------------------------------------------------------------------------

LoadPerCharacter:
		moveq	#0,d0
		move.w	(v_character1).w,d0			; get character number
		mulu.w	#CharDefs_size-CharDefs,d0		; get offset for character
		lea	(CharDefs).l,a4
		adda.l	d0,a4					; jump to relevant character data
		
		move.l	(a4),(v_ost_player).w			; load player object
		move.l	(a4)+,(v_player1_ptr).w			; save pointer to player object
		cmp.b	#id_Special,(v_gamemode).w
		bne.s	.not_special				; branch if not on Special Stage
		move.l	(a4),(v_ost_player).w			; load Special Stage player object
	.not_special:
		lea	4(a4),a4
		
		move.w	(a4)+,d0
		bmi.s	.skip_pal
		bsr.w	PalLoad					; load character palette
		
	.skip_pal:
		move.w	(a4)+,d0
		jsr	UncPLC					; load life icon graphics
		
		move.w	(a4)+,(v_haspassed_character).w		; set mappings frame for "Sonic has passed"
		
		moveq	#0,d0
		move.b	(a4)+,(v_player1_width).w		; set width
		move.b	(a4),d0
		move.b	(a4)+,(v_player1_height).w		; set height
		move.b	(a4)+,(v_player1_width_roll).w		; set width (rolling/jumping)
		sub.b	(a4),d0
		move.w	d0,(v_player1_height_diff).w		; set height difference
		move.b	(a4)+,(v_player1_height_roll).w		; set height (rolling/jumping)
		
		rts

CharDefs:
		; Sonic
		dc.l SonicPlayer				; object pointer for level
		dc.l SonicSpecial				; object pointer for Special Stage
		dc.w -1						; palette patch id (actual palette is loaded by LoadPerZone; use -1 to skip)
		dc.w id_UPLC_SonicIcon				; life icon graphics
		dc.w id_frame_has_sonichas			; "Sonic has passed" mappings frame
		dc.b 18/2, 38/2					; width, height (standing/running etc.)
		dc.b 14/2, 28/2					; width, height (rolling/jumping)
	CharDefs_size:

		; Red Sonic
		dc.l SonicPlayer
		dc.l SonicSpecial
		dc.w id_Pal_SonicRed
		dc.w id_UPLC_SonicIcon
		dc.w id_frame_has_ketchuphas
		dc.b 18/2, 38/2
		dc.b 14/2, 28/2

		; Yellow Sonic
		dc.l SonicPlayer
		dc.l SonicSpecial
		dc.w id_Pal_SonicYellow
		dc.w id_UPLC_SonicIcon
		dc.w id_frame_has_mustardhas
		dc.b 18/2, 38/2
		dc.b 14/2, 28/2
		
; ---------------------------------------------------------------------------
; Subroutine to load demo data
; ---------------------------------------------------------------------------

LoadPerDemo:
		moveq	#0,d0
		move.w	(v_demo_num).w,d0			; get demo number
		mulu.w	#DemoDefs_size-DemoDefs,d0		; get offset for particular demo
		lea	(DemoDefs).l,a4
		adda.l	d0,a4					; jump to relevant demo data
		
		move.w	(a4)+,d0				; get zone number
		move.b	d0,(v_zone).w
		move.w	(a4)+,d0				; get act number
		move.b	d0,(v_act).w
		
		move.w	(a4)+,(v_character1).w			; get character id
		
		move.l	(a4)+,(v_demo_ptr).w			; get pointer for demo data
		
		move.l	(a4)+,(v_demo_x_start).w		; get start position
		
		rts
		
countof_demo:		equ (DemoDefs_Credits-DemoDefs)/(DemoDefs_size-DemoDefs) ; number of regular demos (4)
countof_credits:	equ (DemoDefs_end-DemoDefs_Credits)/(DemoDefs_size-DemoDefs) ; number of credits demos (8)
		
DemoDefs:
		dc.w id_GHZ					; zone
		dc.w 0						; act
		dc.w 0						; character
		dc.l Demo_GHZ					; pointer for demo control data
		dc.w 0,0					; start position (0,0 to use default level start)
	DemoDefs_size:
	
		dc.w id_MZ
		dc.w 0
		dc.w 1
		dc.l Demo_MZ
		dc.w 0,0
	
		dc.w id_SYZ
		dc.w 0
		dc.w 2
		dc.l Demo_SYZ
		dc.w 0,0
	
		; Special Stage
		dc.w -1
		dc.w 0
		dc.w 0
		dc.l Demo_SS
		dc.w 0,0
		
DemoDefs_Credits:
		dc.w id_GHZ
		dc.w 0
		dc.w 0
		dc.l Demo_EndGHZ1
		dc.w $0050, $03B0
		
		dc.w id_MZ
		dc.w 1
		dc.w 1
		dc.l Demo_EndMZ
		dc.w $0EA0, $046C
		
		dc.w id_SYZ
		dc.w 2
		dc.w 0
		dc.l Demo_EndSYZ
		dc.w $1750, $00BD
		
		dc.w id_LZ
		dc.w 2
		dc.w 0
		dc.l Demo_EndLZ
		dc.w $0A00, $062C
		
		dc.w id_SLZ
		dc.w 2
		dc.w 0
		dc.l Demo_EndSLZ
		dc.w $0BB0, $004C
		
		dc.w id_SBZ
		dc.w 0
		dc.w 0
		dc.l Demo_EndSBZ1
		dc.w $1570, $016C
		
		dc.w id_SBZ
		dc.w 1
		dc.w 0
		dc.l Demo_EndSBZ2
		dc.w $01B0, $072C
		
		dc.w id_GHZ
		dc.w 0
		dc.w 0
		dc.l Demo_EndGHZ2
		dc.w $1400, $02AC
	DemoDefs_end: