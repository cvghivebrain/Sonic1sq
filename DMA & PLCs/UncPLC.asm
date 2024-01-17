; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed graphics

; input:
;	d0.w = UPLC index id

;	uses d0.l, d1.l, d2.w, a1, a2, a3
; ---------------------------------------------------------------------------

UncPLC:
		add.w	d0,d0
		move.w	UncLoadCues(pc,d0.w),d0
		lea	UncLoadCues(pc,d0.w),a2			; jump to relevant UPLC
		move.w	(a2)+,d2				; get length of UPLC
		bmi.s	.exit					; branch if empty
		moveq	#-1,d0					; d0 = $FFFFFFFF

	.loop:
		move.l	(a2)+,d1				; get destination VRAM address
		jsr	(AddDMA2).w				; add to DMA queue (source/size already in a2)
		move.w	(a2)+,d1				; get tile setting
		move.w	(a2)+,d0				; get RAM address to save tile setting
		beq.s	.skip_tileram				; branch if tile setting shouldn't be saved
		movea.l	d0,a3
		move.w	d1,(a3)					; save tile setting to RAM
	
	.skip_tileram:
		dbf	d2,.loop				; repeat for length of UPLC
	
	.exit:
		rts

uplcheader:	macro *,vram
		\*: equ *
		uplc_count\@: equ (.end-*-2)/18			; number of items in UPLC
		dc.w uplc_count\@-1				; number of loops
		last_vram: = vram				; start address in VRAM
		last_label: equs "\*"
		endm

uplc:		macro gfx,tileram
		set_dma_dest last_vram				; destination in VRAM
		set_dma_src \gfx				; source in ROM
		set_dma_size sizeof_\gfx			; size of gfx
		dc.w last_vram/sizeof_cell			; tile setting
		if narg=1
		dc.w 0
		else
		dc.w tileram&$FFFF				; RAM address to store tile setting
		endc
		if ~def(tile_\gfx)
		tile_\gfx: equ last_vram/sizeof_cell		; remember tile setting for gfx
		else
		tile_\gfx\_\last_label: equ last_vram/sizeof_cell
		endc
		last_vram: = last_vram+sizeof_\gfx		; update last_vram for next item
		endm
		
uplc_letters:	macro letters
		letters_\last_label: equs "\letters"
		tempchr: substr ,1,"\letters"			; read first char
		tempstr: substr 2,,"\letters"			; strip first char
		uplc Art_TitleCard\tempchr,v_tile_letters
		rept strlen("\letters")-1			; do for all chars
		tempchr: substr ,1,"\tempstr"			; read first char
		tempstr: substr 2,,"\tempstr"			; strip first char
		uplc Art_TitleCard\tempchr
		endr
		endm

; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------

UncLoadCues:
		index *
		ptr UPLC_HUD
		ptr UPLC_SonicCard
		ptr UPLC_KetchupCard
		ptr UPLC_MustardCard
		ptr UPLC_GHZCard
		ptr UPLC_MZCard
		ptr UPLC_SYZCard
		ptr UPLC_LZCard
		ptr UPLC_SLZCard
		ptr UPLC_SBZCard
		ptr UPLC_FZCard
		ptr UPLC_Act2Card
		ptr UPLC_Act3Card
		ptr UPLC_GameOver
		ptr UPLC_Explode
		ptr UPLC_Stars
		ptr UPLC_Bonus
		ptr UPLC_SSResult
		ptr UPLC_SSRSS
		ptr UPLC_SSRChaos
		ptr UPLC_SSRSonic
		ptr UPLC_SSRKetchup
		ptr UPLC_SSRMustard
		ptr UPLC_Warp
		ptr UPLC_Credits
		ptr UPLC_TryAgain
		ptr UPLC_SonicIcon
		ptr UPLC_Prison
		ptr UPLC_Prison2
		ptr UPLC_RabbitFlicky
		ptr UPLC_PenguinSeal
		ptr UPLC_SquirrelSeal
		ptr UPLC_PigFlicky
		ptr UPLC_PigChicken
		ptr UPLC_RabbitChicken
		ptr UPLC_Animals
		ptr UPLC_Boss
		ptr UPLC_MZPipe
		ptr UPLC_SLZPipe
		ptr UPLC_GHZAnchor
		ptr UPLC_SYZSpike
		ptr UPLC_Monitors
		ptr UPLC_Continue
		ptr UPLC_EggmanSBZ
		ptr UPLC_EggmanFZ
		ptr UPLC_EndStH
		ptr UPLC_Overlay

UPLC_HUD:	uplcheader $D900
		uplc Art_HUDMain,v_tile_hud
	.end:

UPLC_SonicCard:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc Art_TitleCardBonus,v_tile_bonus
		uplc_letters HASPEDONIC
	.end:

UPLC_KetchupCard:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc Art_TitleCardBonus,v_tile_bonus
		uplc_letters HASPEDKTCU
	.end:

UPLC_MustardCard:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc Art_TitleCardBonus,v_tile_bonus
		uplc_letters HASPEDMUTR
	.end:

UPLC_GHZCard:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc_letters ZONEGRHIL
	.end:

UPLC_MZCard:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc_letters ZONEMARBL
	.end:

UPLC_SYZCard:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc_letters ZONESPRIGYAD
	.end:

UPLC_LZCard:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc_letters ZONELABYRITH
	.end:

UPLC_SLZCard:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc_letters ZONESTARLIGH
	.end:

UPLC_SBZCard:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc_letters ZONESCRAPBI
	.end:

UPLC_FZCard:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc_letters ZONEFIAL
	.end:

UPLC_Act2Card:	uplcheader $B260
		uplc Art_TitleCard2
	.end:

UPLC_Act3Card:	uplcheader $B260
		uplc Art_TitleCard3
	.end:

UPLC_GameOver:	uplcheader $ABC0
		uplc Art_GameOver
	.end:

UPLC_Explode:	uplcheader $B400
		uplc Art_Explode
	.end:

UPLC_Stars:	uplcheader vram_shield
		uplc Art_Stars
	.end:

UPLC_Bonus:	uplcheader vram_bonus
		uplc Art_Bonus
	.end:

UPLC_SSResult:	uplcheader $20
		uplc Art_MiniSonic
		uplc Art_ResultEm
	.end:

UPLC_SSRSS:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc Art_TitleCardBonus,v_tile_bonus
		uplc Art_ResultCont
		uplc_letters SPECIALTG
	.end:

UPLC_SSRChaos:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc Art_TitleCardBonus,v_tile_bonus
		uplc Art_ResultCont
		uplc_letters CHAOSEMRLD
	.end:

UPLC_SSRSonic:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc Art_TitleCardBonus,v_tile_bonus
		uplc Art_ResultCont
		uplc_letters GOTHEMALSNIC
	.end:

UPLC_SSRKetchup:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc Art_TitleCardBonus,v_tile_bonus
		uplc Art_ResultCont
		uplc_letters GOTHEMALKCUP
	.end:

UPLC_SSRMustard:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_TitleCardAct,v_tile_act
		uplc Art_TitleCardBonus,v_tile_bonus
		uplc Art_ResultCont
		uplc_letters GOTHEMALUSRD
	.end:

UPLC_Warp:	uplcheader vram_shield
		uplc Art_Warp
	.end:

UPLC_Credits:	uplcheader $20
		uplc Art_CreditText,v_tile_credits
	.end:

UPLC_TryAgain:	uplcheader $2000
		uplc Art_CreditText,v_tile_credits
	.end:

UPLC_SonicIcon:	uplcheader vram_lifeicon
		uplc Art_Lives
	.end:

UPLC_Prison:	uplcheader $D000
		uplc Art_Prison
	.end:

UPLC_Prison2:	uplcheader $D000
		uplc Art_PrisonBroken
	.end:

UPLC_RabbitFlicky:	uplcheader vram_animals
		uplc Art_Rabbit,v_tile_animal1
		uplc Art_Flicky,v_tile_animal2
	.end:
	
UPLC_PenguinSeal:	uplcheader vram_animals
		uplc Art_Penguin,v_tile_animal1
		uplc Art_Seal,v_tile_animal2
	.end:
	
UPLC_SquirrelSeal:	uplcheader vram_animals
		uplc Art_Squirrel,v_tile_animal1
		uplc Art_Seal,v_tile_animal2
	.end:
	
UPLC_PigFlicky:	uplcheader vram_animals
		uplc Art_Pig,v_tile_animal1
		uplc Art_Flicky,v_tile_animal2
	.end:
	
UPLC_PigChicken:	uplcheader vram_animals
		uplc Art_Pig,v_tile_animal1
		uplc Art_Chicken,v_tile_animal2
	.end:
	
UPLC_RabbitChicken:	uplcheader vram_animals
		uplc Art_Rabbit,v_tile_animal1
		uplc Art_Chicken,v_tile_animal2
	.end:
	
UPLC_Animals:	uplcheader $AC00
		uplc Art_Rabbit
		uplc Art_Chicken
		uplc Art_Penguin
		uplc Art_Seal
		uplc Art_Pig
		uplc Art_Flicky
		uplc Art_Squirrel
	.end:
	
UPLC_Boss:	uplcheader vram_boss
		uplc Art_Eggman
	.end:
	
UPLC_MZPipe:	uplcheader vram_weapon
		uplc Art_MZPipe
	.end:
	
UPLC_SLZPipe:	uplcheader vram_weapon
		uplc Art_SLZPipe
	.end:
	
UPLC_GHZAnchor:	uplcheader vram_weapon
		uplc Art_GHZAnchor
	.end:
	
UPLC_SYZSpike:	uplcheader vram_weapon
		uplc Art_SYZSpike
	.end:
	
UPLC_Monitors:	uplcheader vram_monitors
		uplc Art_Monitors
	.end:

UPLC_Continue:	uplcheader vram_continue
		uplc_letters CONTIUE
		uplc Art_MiniSonic
		uplc Art_ContSonic
		uplc Art_HUDNums,v_tile_hud
	.end:
	
UPLC_EggmanSBZ:	uplcheader $8000
		uplc Art_Sbz2Eggman
	.end:
	
UPLC_EggmanFZ:	uplcheader $8E00
		uplc Art_Sbz2Eggman
	.end:
	
UPLC_EndStH:	uplcheader $A480
		uplc Art_EndStH
	.end:
	
UPLC_Overlay:	uplcheader vram_overlay3
		uplc Art_Overlay
	.end:
	
