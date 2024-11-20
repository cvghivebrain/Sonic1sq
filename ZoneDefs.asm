; ---------------------------------------------------------------------------
; Zone definitions
; ---------------------------------------------------------------------------

ZoneDefs:	; Green Hill Zone
		dc.l Zone_SPLC_GHZ				; SlowPLC list (act specific)
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
		dc.l Zone_Layout_GHZ				; level layout list (act specific)
		dc.l Zone_BG_GHZ				; bg layout list (act specific)
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
		dc.b id_Rabbit, id_Flicky			; animal types
		even
	ZoneDefs_size:

		; Labyrinth Zone
		dc.l Zone_SPLC_LZ
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
		dc.l Zone_Layout_LZ
		dc.l Zone_BG_LZ
		dc.l Zone_Music_LZ
		dc.l AniArt_none
		dc.l Zone_Bound_LZ
		dc.l Zone_SPos_LZ
		dc.l DebugList_LZ
		dc.l Zone_Card_LZ
		dc.l Zone_DLE_LZ
		dc.l Zone_Next_LZ
		dc.l Zone_Deform_LZ
		dc.w id_UPLC_PenguinSeal
		dc.b id_Penguin, id_Seal
		even

		; Marble Zone
		dc.l Zone_SPLC_MZ
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
		dc.l Zone_Layout_MZ
		dc.l Zone_BG_MZ
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
		dc.b id_Squirrel, id_Seal
		even

		; Star Light Zone
		dc.l Zone_SPLC_SLZ
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
		dc.l Zone_Layout_SLZ
		dc.l Zone_BG_SLZ
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
		dc.b id_Pig, id_Flicky
		even

		; Spring Yard Zone
		dc.l Zone_SPLC_SYZ
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
		dc.l Zone_Layout_SYZ
		dc.l Zone_BG_SYZ
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
		dc.b id_Pig, id_Chicken
		even

		; Scrap Brain Zone
		dc.l Zone_SPLC_SBZ
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
		dc.l Zone_Layout_SBZ
		dc.l Zone_BG_SBZ
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
		dc.b id_Rabbit, id_Chicken
		even

		; Ending
		dc.l Zone_SPLC_End
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
		dc.l Zone_Layout_End
		dc.l Zone_BG_End
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
		dc.b id_Rabbit, id_Flicky
		even

; ---------------------------------------------------------------------------
; Kosinski PLC id list
; ---------------------------------------------------------------------------

Zone_SPLC_GHZ:	dc.w id_SPLC_GHZ,id_SPLC_GHZ,id_SPLC_GHZ
Zone_SPLC_MZ:	dc.w id_SPLC_MZ,id_SPLC_MZ,id_SPLC_MZ
Zone_SPLC_SYZ:	dc.w id_SPLC_SYZ,id_SPLC_SYZ,id_SPLC_SYZ
Zone_SPLC_LZ:	dc.w id_SPLC_LZ,id_SPLC_LZ,id_SPLC_LZ,id_SPLC_SBZ3
Zone_SPLC_SLZ:	dc.w id_SPLC_SLZ,id_SPLC_SLZ,id_SPLC_SLZ
Zone_SPLC_SBZ:	dc.w id_SPLC_SBZ,id_SPLC_SBZ,id_SPLC_FZ
Zone_SPLC_End:	dc.w id_SPLC_End,id_SPLC_End

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
; Level layout list pointers
; ---------------------------------------------------------------------------

Zone_Layout_GHZ:	dc.l Level_GHZ1,Level_GHZ2,Level_GHZ3
Zone_Layout_MZ:		dc.l Level_MZ1,Level_MZ2,Level_MZ3
Zone_Layout_SYZ:	dc.l Level_SYZ1,Level_SYZ2,Level_SYZ3
Zone_Layout_LZ:		dc.l Level_LZ1,Level_LZ2,Level_LZ3,Level_SBZ3
Zone_Layout_SLZ:	dc.l Level_SLZ1,Level_SLZ2,Level_SLZ3
Zone_Layout_SBZ:	dc.l Level_SBZ1,Level_SBZ2,Level_SBZ2
Zone_Layout_End:	dc.l Level_End,Level_End

Zone_BG_GHZ:		dc.l Level_GHZ_bg,Level_GHZ_bg,Level_GHZ_bg
Zone_BG_MZ:		dc.l Level_MZ1_bg,Level_MZ2_bg,Level_MZ3_bg
Zone_BG_SYZ:		dc.l Level_SYZ_bg,Level_SYZ_bg,Level_SYZ_bg
Zone_BG_LZ:		dc.l Level_LZ_bg,Level_LZ_bg,Level_LZ_bg,Level_LZ_bg
Zone_BG_SLZ:		dc.l Level_SLZ_bg,Level_SLZ_bg,Level_SLZ_bg
Zone_BG_SBZ:		dc.l Level_SBZ1_bg,Level_SBZ2_bg,Level_SBZ2_bg
Zone_BG_End:		dc.l Level_GHZ_bg,Level_GHZ_bg

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
; Title card settings
; ---------------------------------------------------------------------------

Zone_Card_GHZ:	dc.w id_CardSet_GHZ,1,id_UPLC_GHZCard,0
		dc.w id_CardSet_GHZ,2,id_UPLC_GHZCard,0
		dc.w id_CardSet_GHZ,3,id_UPLC_GHZCard,0
Zone_Card_MZ:	dc.w id_CardSet_MZ,1,id_UPLC_MZCard,0
		dc.w id_CardSet_MZ,2,id_UPLC_MZCard,0
		dc.w id_CardSet_MZ,3,id_UPLC_MZCard,0
Zone_Card_SYZ:	dc.w id_CardSet_SYZ,1,id_UPLC_SYZCard,0
		dc.w id_CardSet_SYZ,2,id_UPLC_SYZCard,0
		dc.w id_CardSet_SYZ,3,id_UPLC_SYZCard,0
Zone_Card_LZ:	dc.w id_CardSet_LZ,1,id_UPLC_LZCard,0
		dc.w id_CardSet_LZ,2,id_UPLC_LZCard,0
		dc.w id_CardSet_LZ,3,id_UPLC_LZCard,0
		dc.w id_CardSet_SBZ,3,id_UPLC_SBZCard,0		; SBZ3
Zone_Card_SLZ:	dc.w id_CardSet_SLZ,1,id_UPLC_SLZCard,0
		dc.w id_CardSet_SLZ,2,id_UPLC_SLZCard,0
		dc.w id_CardSet_SLZ,3,id_UPLC_SLZCard,0
Zone_Card_SBZ:	dc.w id_CardSet_SBZ,1,id_UPLC_SBZCard,0
		dc.w id_CardSet_SBZ,2,id_UPLC_SBZCard,0
		dc.w id_CardSet_FZ,0,id_UPLC_FZCard,0		; FZ

; ---------------------------------------------------------------------------
; Dynamic level event list pointers
; ---------------------------------------------------------------------------

Zone_DLE_GHZ:	dc.l DLE_GHZ1,DLE_GHZ2,DLE_GHZ3
Zone_DLE_MZ:	dc.l DLE_MZ1,DLE_MZ2,DLE_MZ3
Zone_DLE_SYZ:	dc.l 0,DLE_SYZ2,DLE_SYZ3
Zone_DLE_LZ:	dc.l 0,0,DLE_LZ3,DLE_SBZ3
Zone_DLE_SLZ:	dc.l 0,0,DLE_SLZ3
Zone_DLE_SBZ:	dc.l DLE_SBZ1,DLE_SBZ2,DLE_FZ
Zone_DLE_End:	dc.l 0,0

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
