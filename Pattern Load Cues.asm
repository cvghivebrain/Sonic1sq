; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------
PatternLoadCues:
		index *
		ptr PLC_Main
		ptr PLC_Main2
		ptr PLC_Boss
		ptr PLC_SpecialStage
PLC_Animals:
		ptr PLC_GHZAnimals
		ptr PLC_LZAnimals
		ptr PLC_MZAnimals
		ptr PLC_SLZAnimals
		ptr PLC_SYZAnimals
		ptr PLC_SBZAnimals
		ptr PLC_Ending
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
; Pattern load cues - standard block 1
; ---------------------------------------------------------------------------
PLC_Main:	plcheader
		plcm	Nem_Lives, $FA80			; lives	counter
	PLC_Main_end:
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
		plcm	Nem_Prison, $93A0			; prison capsule
		plcm	Nem_Exhaust, $A540			; exhaust flame
	PLC_Boss_end:
; ---------------------------------------------------------------------------
; Pattern load cues - special stage
; ---------------------------------------------------------------------------
PLC_SpecialStage:	plcheader
		plcm	Nem_SSBgCloud, 0			; bubble and cloud background
		plcm	Nem_SSBgFish				; bird and fish	background ($A20)
		plcm	Nem_SSWalls				; walls ($2840)
		;plcm	Nem_Bumper,,SS				; bumper ($4760)
		plcm	Nem_SSGOAL				; GOAL block ($4A20)
		plcm	Nem_SSUpDown				; UP and DOWN blocks ($4C60)
		plcm	Nem_SSRBlock, $5E00			; R block
		plcm	Nem_SS1UpBlock, $6E00			; 1UP block
		plcm	Nem_SSEmStars, $7E00			; emerald collection stars
		plcm	Nem_SSRedWhite, $8E00			; red and white	block
		plcm	Nem_SSGhost, $9E00			; ghost	block
		plcm	Nem_SSWBlock, $AE00			; W block
		plcm	Nem_SSGlass, $BE00			; glass	block
		plcm	Nem_SSEmerald, $EE00			; emeralds
		plcm	Nem_SSZone1, $F2E0			; ZONE 1 block
		plcm	Nem_SSZone2				; ZONE 2 block ($F400)
		plcm	Nem_SSZone3				; ZONE 3 block ($F520)
	PLC_SpecialStage_end:
		plcm	Nem_SSZone4, $F2E0			; ZONE 4 block
		plcm	Nem_SSZone5				; ZONE 5 block ($F400)
		plcm	Nem_SSZone6				; ZONE 6 block ($F520)
; ---------------------------------------------------------------------------
; Pattern load cues - GHZ animals
; ---------------------------------------------------------------------------
PLC_GHZAnimals:	plcheader
		plcm	Nem_Rabbit, vram_animal1		; rabbit ($B000)
		plcm	Nem_Flicky, vram_animal2		; flicky ($B240)
	PLC_GHZAnimals_end:
; ---------------------------------------------------------------------------
; Pattern load cues - LZ animals
; ---------------------------------------------------------------------------
PLC_LZAnimals:	plcheader
		plcm	Nem_BlackBird, vram_animal1		; blackbird ($B000)
		plcm	Nem_Seal, vram_animal2			; seal ($B240)
	PLC_LZAnimals_end:
; ---------------------------------------------------------------------------
; Pattern load cues - MZ animals
; ---------------------------------------------------------------------------
PLC_MZAnimals:	plcheader
		plcm	Nem_Squirrel, vram_animal1		; squirrel ($B000)
		plcm	Nem_Seal, vram_animal2			; seal ($B240)
	PLC_MZAnimals_end:
; ---------------------------------------------------------------------------
; Pattern load cues - SLZ animals
; ---------------------------------------------------------------------------
PLC_SLZAnimals:	plcheader
		plcm	Nem_Pig, vram_animal1			; pig ($B000)
		plcm	Nem_Flicky, vram_animal2		; flicky ($B240)
	PLC_SLZAnimals_end:
; ---------------------------------------------------------------------------
; Pattern load cues - SYZ animals
; ---------------------------------------------------------------------------
PLC_SYZAnimals:	plcheader
		plcm	Nem_Pig, vram_animal1			; pig ($B000)
		plcm	Nem_Chicken, vram_animal2		; chicken ($B240)
	PLC_SYZAnimals_end:
; ---------------------------------------------------------------------------
; Pattern load cues - SBZ animals
; ---------------------------------------------------------------------------
PLC_SBZAnimals:	plcheader
		plcm	Nem_Rabbit, vram_animal1		; rabbit ($B000)
		plcm	Nem_Chicken, vram_animal2		; chicken ($B240)
	PLC_SBZAnimals_end:
; ---------------------------------------------------------------------------
; Pattern load cues - ending sequence
; ---------------------------------------------------------------------------
PLC_Ending:	plcheader
		plcm	Nem_Rabbit, $AA60, End			; rabbit
		plcm	Nem_Chicken,, End			; chicken ($ACA0)
		plcm	Nem_BlackBird,, End			; blackbird ($AE60)
		plcm	Nem_Seal,, End				; seal ($B0A0)
		plcm	Nem_Pig,, End				; pig ($B260)
		plcm	Nem_Flicky,, End			; flicky ($B4A0)
		plcm	Nem_Squirrel,, End			; squirrel ($B660)
		plcm	Nem_EndStH				; "SONIC THE HEDGEHOG" ($B8A0)
	PLC_Ending_end:
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
		plcm	Nem_Exhaust, $A540			; exhaust flame
	PLC_FZBoss_end:
		even
