; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------
PatternLoadCues:
		index *
		ptr PLC_Main
		ptr PLC_Main2
		ptr PLC_Explode
		ptr PLC_GameOver
PLC_Levels:
		ptr PLC_GHZ
		ptr PLC_GHZ2
		ptr PLC_LZ
		ptr PLC_LZ2
		ptr PLC_MZ
		ptr PLC_MZ2
		ptr PLC_SLZ
		ptr PLC_SLZ2
		ptr PLC_SYZ
		ptr PLC_SYZ2
		ptr PLC_SBZ
		ptr PLC_SBZ2
		zonewarning PLC_Levels,4
		ptr PLC_TitleCard
		ptr PLC_Boss
		ptr PLC_Signpost
		ptr PLC_Warp
		ptr PLC_SpecialStage
PLC_Animals:
		ptr PLC_GHZAnimals
		ptr PLC_LZAnimals
		ptr PLC_MZAnimals
		ptr PLC_SLZAnimals
		ptr PLC_SYZAnimals
		ptr PLC_SBZAnimals
		zonewarning PLC_Animals,2
		ptr PLC_SSResult
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
		plcm	Nem_Lamp, $F400				; lamppost
		plcm	Nem_Hud, $D940				; HUD
		plcm	Nem_Lives, $FA80			; lives	counter
		plcm	Nem_Ring, $F640				; rings
		plcm	Nem_Points, $F2E0			; points from enemy
	PLC_Main_end:
; ---------------------------------------------------------------------------
; Pattern load cues - standard block 2
; ---------------------------------------------------------------------------
PLC_Main2:	plcheader
		plcm	Nem_Monitors, $D000			; monitors
		plcm	Nem_Shield, $A820			; shield
		plcm	Nem_Stars				; invincibility	stars ($AB80)
	PLC_Main2_end:
; ---------------------------------------------------------------------------
; Pattern load cues - explosion
; ---------------------------------------------------------------------------
PLC_Explode:	plcheader
		plcm	Nem_Explode, $B400			; explosion
	PLC_Explode_end:
; ---------------------------------------------------------------------------
; Pattern load cues - game/time	over
; ---------------------------------------------------------------------------
PLC_GameOver:	plcheader
		plcm	Nem_GameOver, $ABC0			; game/time over
	PLC_GameOver_end:
; ---------------------------------------------------------------------------
; Pattern load cues - Green Hill
; ---------------------------------------------------------------------------
PLC_GHZ:	plcheader
	PLC_GHZ_end:

PLC_GHZ2:	plcheader
		;plcm	Nem_Ball				; giant	ball ($7540)
	PLC_GHZ2_end:
; ---------------------------------------------------------------------------
; Pattern load cues - Labyrinth
; ---------------------------------------------------------------------------
PLC_LZ:		plcheader
	PLC_LZ_end:

PLC_LZ2:	plcheader
	PLC_LZ2_end:
; ---------------------------------------------------------------------------
; Pattern load cues - Marble
; ---------------------------------------------------------------------------
PLC_MZ:		plcheader
	PLC_MZ_end:

PLC_MZ2:	plcheader
	PLC_MZ2_end:
; ---------------------------------------------------------------------------
; Pattern load cues - Star Light
; ---------------------------------------------------------------------------
PLC_SLZ:	plcheader
	PLC_SLZ_end:

PLC_SLZ2:	plcheader
	PLC_SLZ2_end:
; ---------------------------------------------------------------------------
; Pattern load cues - Spring Yard
; ---------------------------------------------------------------------------
PLC_SYZ:	plcheader
	PLC_SYZ_end:

PLC_SYZ2:	plcheader
	PLC_SYZ2_end:
; ---------------------------------------------------------------------------
; Pattern load cues - Scrap Brain
; ---------------------------------------------------------------------------
PLC_SBZ:	plcheader
	PLC_SBZ_end:

PLC_SBZ2:	plcheader
	PLC_SBZ2_end:
; ---------------------------------------------------------------------------
; Pattern load cues - title card
; ---------------------------------------------------------------------------
PLC_TitleCard:	plcheader
		plcm	Nem_TitleCard, $B000
	PLC_TitleCard_end:
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
; Pattern load cues - act 1/2 signpost
; ---------------------------------------------------------------------------
PLC_Signpost:	plcheader
		plcm	Nem_SignPost, $D000			; signpost
		plcm	Nem_Bonus, $96C0			; hidden bonus points
		plcm	Nem_BigFlash, $8C40			; giant	ring flash effect
	PLC_Signpost_end:
; ---------------------------------------------------------------------------
; Pattern load cues - beta special stage warp effect
; ---------------------------------------------------------------------------
		if Revision=0
PLC_Warp:	plcheader
		plcm	Nem_Warp, $A820
		else
PLC_Warp:
		endc
	PLC_Warp_end:
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
; Pattern load cues - special stage results screen
; ---------------------------------------------------------------------------
PLC_SSResult:	plcheader
		plcm	Nem_ResultEm, $A820			; emeralds
		plcm	Nem_MiniSonic				; mini Sonic ($AA20)
	PLC_SSResult_end:
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
		plcm	Nem_CreditText, vram_credits		; credits alphabet ($B400)
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
