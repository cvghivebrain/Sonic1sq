; ---------------------------------------------------------------------------
; Subroutine to load zone/act data
; ---------------------------------------------------------------------------

LoadPerZone:
		moveq	#0,d0
		move.b	(v_zone).w,d0				; get zone number
		mulu.w	#ZoneDefs_size-ZoneDefs,d0		; get offset for zone
		lea	(ZoneDefs).l,a4
		adda.l	d0,a4					; jump to relevant zone data
		
		move.l	(a4)+,(v_16x16_ptr).w			; load 16x16 mappings pointer
		movea.l	(a4)+,a0				; load 256x256 mappings pointer
		lea	(v_256x256_tiles).l,a1			; RAM address for 256x256 mappings
		bsr.w	KosDec					; decompress
		move.l	(a4)+,(v_collision_index_ptr).w		; load collision index pointer
		
		moveq	#0,d1
		moveq	#0,d0
		movea.l	(a4)+,a1				; get pointer for palette id list
		move.b	(v_act).w,d1				; d1 = act
		move.l	d1,d2
		add.l	d2,d2					; d2 = act * 2
		move.l	d2,d4
		add.l	d4,d4					; d4 = act * 4
		move.b	(a1,d1.w),d0				; get palette id
		bsr.w	PalLoad_Next				; load palette

		moveq	#0,d0
		move.w	(a4)+,d0				; get water flag
		beq.s	@no_water				; branch if 0
		move.b	d0,(f_water_enable).w			; set water enable flag
		movea.l	(a4),a1					; get pointer for water palette id list
		move.b	(a1,d1.w),d0				; get palette id
		bsr.w	PalLoad_Water_Next			; load palette
		movea.l	4(a4),a1				; get pointer for initial water height list
		move.w	(a1,d2.w),d0				; get water height
		move.w	d0,(v_water_height_actual).w		; set water heights
		move.w	d0,(v_water_height_normal).w
		move.w	d0,(v_water_height_next).w
	@no_water:
		adda.l	#8,a4

		movea.l	(a4)+,a1				; get pointer for OPL list
		move.l	(a1,d4.w),(v_opl_data_ptr).w		; get pointer for actual OPL data
		
		movea.l	(a4)+,a1				; get pointer for music list
		move.b	(a1,d1.w),(v_bgm).w			; set music id
		rts
		
; ---------------------------------------------------------------------------
; Zone definitions
; ---------------------------------------------------------------------------

ZoneDefs:	; Green Hill Zone
		dc.l Blk16_GHZ					; 16x16 mappings
		dc.l Blk256_GHZ					; 256x256 mappings
		dc.l Col_GHZ					; collision index
		dc.l Zone_Pal_GHZ				; palette id list
		dc.w 0						; 1 to enable water
		dc.l Zone_WPal_LZ				; water palette id list
		dc.l Zone_WHeight_LZ				; water height list
		dc.l Zone_OPL_GHZ				; object position list
		dc.l Zone_Music_GHZ				; background music id list
		even
	ZoneDefs_size:

		; Labyrinth Zone
		dc.l Blk16_LZ
		dc.l Blk256_LZ
		dc.l Col_LZ
		dc.l Zone_Pal_LZ
		dc.w 1
		dc.l Zone_WPal_LZ
		dc.l Zone_WHeight_LZ
		dc.l Zone_OPL_LZ
		dc.l Zone_Music_LZ
		even
		
		; Marble Zone
		dc.l Blk16_MZ
		dc.l Blk256_MZ
		dc.l Col_MZ
		dc.l Zone_Pal_MZ
		dc.w 0
		dc.l Zone_WPal_LZ
		dc.l Zone_WHeight_LZ
		dc.l Zone_OPL_MZ
		dc.l Zone_Music_MZ
		even
		
		; Star Light Zone
		dc.l Blk16_SLZ
		dc.l Blk256_SLZ
		dc.l Col_SLZ
		dc.l Zone_Pal_SLZ
		dc.w 0
		dc.l Zone_WPal_LZ
		dc.l Zone_WHeight_LZ
		dc.l Zone_OPL_SLZ
		dc.l Zone_Music_SLZ
		even
		
		; Spring Yard Zone
		dc.l Blk16_SYZ
		dc.l Blk256_SYZ
		dc.l Col_SYZ
		dc.l Zone_Pal_SYZ
		dc.w 0
		dc.l Zone_WPal_LZ
		dc.l Zone_WHeight_LZ
		dc.l Zone_OPL_SYZ
		dc.l Zone_Music_SYZ
		even
		
		; Scrap Brain Zone
		dc.l Blk16_SBZ
		dc.l Blk256_SBZ
		dc.l Col_SBZ
		dc.l Zone_Pal_SBZ
		dc.w 0
		dc.l Zone_WPal_LZ
		dc.l Zone_WHeight_LZ
		dc.l Zone_OPL_SBZ
		dc.l Zone_Music_SBZ
		even
		
		; Ending
		dc.l Blk16_GHZ
		dc.l Blk256_GHZ
		dc.l Col_GHZ
		dc.l Zone_Pal_End
		dc.w 0
		dc.l Zone_WPal_LZ
		dc.l Zone_WHeight_LZ
		dc.l Zone_OPL_End
		dc.l Zone_Music_End
		even

; ---------------------------------------------------------------------------
; Palette ids
; ---------------------------------------------------------------------------

Zone_Pal_GHZ:	dc.b id_Pal_GHZ,id_Pal_GHZ,id_Pal_GHZ
Zone_Pal_MZ:	dc.b id_Pal_MZ,id_Pal_MZ,id_Pal_MZ
Zone_Pal_SYZ:	dc.b id_Pal_SYZ,id_Pal_SYZ,id_Pal_SYZ
Zone_Pal_LZ:	dc.b id_Pal_LZ,id_Pal_LZ,id_Pal_LZ,id_Pal_SBZ3
Zone_Pal_SLZ:	dc.b id_Pal_SLZ,id_Pal_SLZ,id_Pal_SLZ
Zone_Pal_SBZ:	dc.b id_Pal_SBZ1,id_Pal_SBZ2,id_Pal_SBZ2
Zone_Pal_End:	dc.b id_Pal_Ending,id_Pal_Ending

Zone_WPal_LZ:	dc.b id_Pal_LZWater,id_Pal_LZWater,id_Pal_LZWater,id_Pal_SBZ3Water
		even

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
