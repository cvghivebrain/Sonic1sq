; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------
PatternLoadCues:
		index *
		ptr PLC_Main2
		ptr PLC_Boss
		ptr PLC_TryAgain
		ptr PLC_EggmanSBZ2
		ptr PLC_FZBoss

plcm:		macro gfx,vram,suffix
		dc.l gfx
		if strlen("\vram")>0
			plcm_vram: = \vram
		else
			plcm_vram: = last_vram
		endc
		last_vram: = plcm_vram+sizeof_\gfx
		dc.w plcm_vram
		if strlen("\suffix")>0
			tile_\gfx\_\suffix: equ plcm_vram/sizeof_cell
			vram_\gfx\_\suffix: equ plcm_vram
		else
			if ~def(tile_\gfx)
			tile_\gfx: equ plcm_vram/sizeof_cell
			vram_\gfx: equ plcm_vram
			endc
		endc
		endm

plcheader:	macro *
		\*: equ *
		plc_count\@: equ (\*_end-*-2)/sizeof_plc
		dc.w plc_count\@-1
		endm

; ---------------------------------------------------------------------------
; Pattern load cues - standard block 2
; ---------------------------------------------------------------------------
PLC_Main2:	plcheader
		plcm	Nem_Monitors, $D000			; monitors
	PLC_Main2_end:
; ---------------------------------------------------------------------------
; Pattern load cues - act 3 boss
; ---------------------------------------------------------------------------
PLC_Boss:	plcheader
		plcm	Nem_Eggman, $8000			; Eggman main patterns
		plcm	Nem_Weapons				; Eggman's weapons ($8D80)
	PLC_Boss_end:
; ---------------------------------------------------------------------------
; Pattern load cues - "TRY AGAIN" and "END" screens
; ---------------------------------------------------------------------------
PLC_TryAgain:	plcheader
		;plcm	Nem_EndEm, $78A0, TryAgain		; emeralds
		plcm	Nem_TryAgain,$7C20
		;plcm	Nem_CreditText, vram_credits		; credits alphabet ($B400)
	PLC_TryAgain_end:
; ---------------------------------------------------------------------------
; Pattern load cues - Eggman on SBZ 2
; ---------------------------------------------------------------------------
PLC_EggmanSBZ2:	plcheader
		plcm	Nem_Sbz2Eggman, $8000			; Eggman
	PLC_EggmanSBZ2_end:
; ---------------------------------------------------------------------------
; Pattern load cues - final boss
; ---------------------------------------------------------------------------
PLC_FZBoss:	plcheader
		plcm	Nem_Eggman, $8000			; Eggman main patterns
		plcm	Nem_Sbz2Eggman, $8E00, FZ		; Eggman without ship
	PLC_FZBoss_end:
		even
