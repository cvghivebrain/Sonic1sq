; ---------------------------------------------------------------------------
; Subroutine to load zone/act data
; ---------------------------------------------------------------------------

LoadPerZone:
		moveq	#0,d0
		move.b	(v_zone).w,d0				; get zone number
		mulu.w	#ZoneDefs_size-ZoneDefs,d0		; get offset for zone
		lea	(ZoneDefs).l,a2
		adda.l	d0,a2					; jump to relevant zone data
		
		move.l	(a2)+,(v_16x16_ptr).w			; load 16x16 mappings pointer
		movea.l	(a2)+,a0				; load 256x256 mappings pointer
		lea	(v_256x256_tiles).l,a1			; RAM address for 256x256 mappings
		bsr.w	KosDec					; decompress
		move.l	(a2)+,(v_collision_index_ptr).w		; load collision index pointer
		
		moveq	#0,d0
		movea.l	(a2)+,a1				; get pointer for palette id list
		move.b	(v_act).w,d0
		move.b	(a1,d0.w),d0				; get palette id
		bsr.w	PalLoad_Next				; load palette
		rts
		
; ---------------------------------------------------------------------------
; Zone definitions
; ---------------------------------------------------------------------------

ZoneDefs:	; Green Hill Zone
		dc.l Blk16_GHZ					; 16x16 mappings
		dc.l Blk256_GHZ					; 256x256 mappings
		dc.l Col_GHZ					; collision index
		dc.l Zone_Pal_GHZ				; palette id list
		even
	ZoneDefs_size:

		; Labyrinth Zone
		dc.l Blk16_LZ
		dc.l Blk256_LZ
		dc.l Col_LZ
		dc.l Zone_Pal_LZ
		even
		
		; Marble Zone
		dc.l Blk16_MZ
		dc.l Blk256_MZ
		dc.l Col_MZ
		dc.l Zone_Pal_MZ
		even
		
		; Star Light Zone
		dc.l Blk16_SLZ
		dc.l Blk256_SLZ
		dc.l Col_SLZ
		dc.l Zone_Pal_SLZ
		even
		
		; Spring Yard Zone
		dc.l Blk16_SYZ
		dc.l Blk256_SYZ
		dc.l Col_SYZ
		dc.l Zone_Pal_SYZ
		even
		
		; Scrap Brain Zone
		dc.l Blk16_SBZ
		dc.l Blk256_SBZ
		dc.l Col_SBZ
		dc.l Zone_Pal_SBZ
		even
		
		; Ending
		dc.l Blk16_GHZ
		dc.l Blk256_GHZ
		dc.l Col_GHZ
		dc.l Zone_Pal_End
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
		even
