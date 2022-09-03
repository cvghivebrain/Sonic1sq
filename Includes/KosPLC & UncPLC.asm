; ---------------------------------------------------------------------------
; Subroutine to	decompress Kosinski graphics

; input:
;	d0 = KPLC index id

; uses d0, a0, a1, a2
; ---------------------------------------------------------------------------

KosPLC:
		lea	KosLoadCues(pc),a2
		add.w	d0,d0
		move.w	(a2,d0.w),d0
		lea	(a2,d0.w),a2				; jump to relevant KPLC
		move.w	(a2)+,d0				; get length of KPLC
		bmi.s	.exit					; branch if empty
		movem.l	d1-d2,-(sp)				; save d1 and d2 to stack

	.loop:
		lea	($FF0000).l,a1				; RAM buffer start address
		adda.w	(a2)+,a1				; jump to current position in buffer
		movea.l	(a2)+,a0				; get pointer for compressed gfx
		jsr	KosDec					; decompress
		move.w	(a2)+,d1				; get tile setting
		moveq	#-1,d2
		move.w	(a2)+,d2				; get RAM address to save tile setting
		tst.w	d2
		beq.s	.skip_tileram				; branch if tile setting shouldn't be saved
		movea.l	d2,a0
		move.w	d1,(a0)					; save tile setting to RAM
	
	.skip_tileram:
		dbf	d0,.loop				; repeat for length of KPLC
		
		move.l	#$40000080,d1				; destination = 0 in VRAM
		move.l	(a2),d2					; read size from end of KPLC
		lea	KPLC_Src(pc),a2				; source = $FF0000 in RAM
		jsr	AddDMA					; add to DMA queue
		jsr	ProcessDMA				; process queue now
		movem.l	(sp)+,d1-d2
	
	.exit:
		rts

KPLC_Src:	set_dma_src $FF0000

kplcheader:	macro *
		\*: equ *
		kplc_count\@: equ (.end-*-2)/10			; number if items in KPLC
		dc.w kplc_count\@-1				; number of loops
		last_vram: = 0					; start address in VRAM
		last_label: equs "\*"
		endm

kplc:		macro gfx,tileram
		dc.w last_vram					; RAM address to use as buffer
		dc.l gfx					; pointer to compressed gfx
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

; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------

KosLoadCues:
		index *
		ptr KPLC_GHZ
		ptr KPLC_MZ
		ptr KPLC_SYZ
		ptr KPLC_LZ
		ptr KPLC_SLZ
		ptr KPLC_SBZ
		ptr KPLC_SBZ3
		ptr KPLC_FZ
		ptr KPLC_Title
		ptr KPLC_End
		ptr KPLC_HiddenCredits
		ptr KPLC_Sega
		ptr KPLC_Special

KPLC_GHZ:	kplcheader
		kplc Kos_GHZ_1st
		kplc Kos_GHZ_2nd
		kplc Kos_GhzEdgeWall
		kplc Kos_Swing,v_tile_swing
		kplc Kos_Bridge
		kplc Kos_SpikePole
		kplc Kos_PurpleRock
		kplc Kos_Crabmeat,v_tile_crabmeat
		kplc Kos_Buzz,v_tile_buzzbomber
		kplc Kos_Chopper,v_tile_chopper
		kplc Kos_Newtron,v_tile_newtron
		kplc Kos_Motobug,v_tile_motobug
		kplc Kos_GhzSmashWall,v_tile_wall
		kplc Kos_Lamp,v_tile_lamppost
		kplc Kos_Points,v_tile_points
		kplc Kos_Ring,v_tile_rings
		kplc Kos_Spikes,v_tile_spikes
		kplc Kos_HSpring,v_tile_hspring
		kplc Kos_VSpring,v_tile_vspring			; $A5C0 used
	.end:
		set_dma_size last_vram

KPLC_MZ:	kplcheader
		kplc Kos_MZ
		kplc Kos_MzBlock
		kplc Kos_Swing,v_tile_swing
		kplc Kos_MzMetal
		kplc Kos_Fireball,v_tile_fireball
		kplc Kos_MzGlass
		kplc Kos_Lava
		kplc Kos_Buzz,v_tile_buzzbomber
		kplc Kos_Batbrain,v_tile_batbrain
		kplc Kos_Cater,v_tile_caterkiller
		kplc Kos_MzButton,v_tile_button
		kplc Kos_Lamp,v_tile_lamppost
		kplc Kos_Points,v_tile_points
		kplc Kos_Ring,v_tile_rings
		kplc Kos_Spikes,v_tile_spikes
		kplc Kos_HSpring,v_tile_hspring
		kplc Kos_VSpring,v_tile_vspring			; $9820 used
	.end:
		set_dma_size last_vram

KPLC_SYZ:	kplcheader
		kplc Kos_SYZ
		kplc Kos_Bumper,v_tile_bumper
		kplc Kos_BigSpike,v_tile_spikeball
		kplc Kos_SmallSpike,v_tile_spikechain
		kplc Kos_Button,v_tile_button
		kplc Kos_Crabmeat,v_tile_crabmeat
		kplc Kos_Buzz,v_tile_buzzbomber
		kplc Kos_Yadrin,v_tile_yadrin
		kplc Kos_Roller,v_tile_roller
		kplc Kos_Lamp,v_tile_lamppost
		kplc Kos_Points,v_tile_points
		kplc Kos_Ring,v_tile_rings
		kplc Kos_Spikes,v_tile_spikes
		kplc Kos_HSpring,v_tile_hspring
		kplc Kos_VSpring,v_tile_vspring			; $A160 used
	.end:
		set_dma_size last_vram

KPLC_LZ:	kplcheader
		KPLC_LZ_common:	macro				; these gfx are also used in SBZ3
		kplc Kos_LZ
		kplc Kos_LzBlock
		kplc Kos_Splash
		kplc Kos_Water
		kplc Kos_Gargoyle
		kplc Kos_LzSpikeBall,v_tile_spikechain
		kplc Kos_FlapDoor
		kplc Kos_Bubbles
		kplc Kos_LzHalfBlock
		kplc Kos_LzDoorV
		kplc Kos_Harpoon
		kplc Kos_LzDoorH
		kplc Kos_LzPlatform
		endm
		KPLC_LZ_common
		kplc Kos_LzPole
		kplc Kos_LzWheel
		kplc Kos_Cork
		kplc Kos_Burrobot,v_tile_burrobot
		kplc Kos_Orbinaut,v_tile_orbinaut
		kplc Kos_Jaws,v_tile_jaws
		kplc Kos_Button,v_tile_button
		kplc Kos_Lamp,v_tile_lamppost
		kplc Kos_Points,v_tile_points
		kplc Kos_Ring,v_tile_rings
		kplc Kos_Spikes,v_tile_spikes
		kplc Kos_HSpring,v_tile_hspring
		kplc Kos_VSpring,v_tile_vspring			; $9740 used
	.end:
		set_dma_size last_vram

KPLC_SLZ:	kplcheader
		kplc Kos_SLZ
		kplc Kos_Seesaw
		kplc Kos_SlzSpike
		kplc Kos_Bomb,v_tile_bomb
		kplc Kos_Fan
		kplc Kos_Pylon
		kplc Kos_SlzSwing,v_tile_swing
		kplc Kos_SlzCannon
		kplc Kos_Orbinaut,v_tile_orbinaut
		kplc Kos_Fireball,v_tile_fireball
		kplc Kos_SlzBlock
		kplc Kos_SlzWall,v_tile_wall
		kplc Kos_Lamp,v_tile_lamppost
		kplc Kos_Points,v_tile_points
		kplc Kos_Ring,v_tile_rings
		kplc Kos_Spikes,v_tile_spikes
		kplc Kos_HSpring,v_tile_hspring
		kplc Kos_VSpring,v_tile_vspring			; $9BE0 used
	.end:
		set_dma_size last_vram

KPLC_SBZ:	kplcheader
		kplc Kos_SBZ
		kplc Kos_Button,v_tile_button
		kplc Kos_SbzBlock
		kplc Kos_Stomper
		kplc Kos_SbzDoorV
		kplc Kos_Girder
		kplc Kos_SbzDisc
		kplc Kos_SbzJunction
		kplc Kos_BigSpike,v_tile_spikeball
		kplc Kos_Cutter
		kplc Kos_FlamePipe
		kplc Kos_SbzFloor
		kplc Kos_SlideFloor
		kplc Kos_SbzDoorH
		kplc Kos_Electric
		kplc Kos_TrapDoor
		kplc Kos_SpinPlatform
		kplc Kos_BallHog,v_tile_ballhog
		kplc Kos_Cater,v_tile_caterkiller
		kplc Kos_Bomb,v_tile_bomb
		kplc Kos_Lamp,v_tile_lamppost
		kplc Kos_Points,v_tile_points
		kplc Kos_Ring,v_tile_rings
		kplc Kos_Spikes,v_tile_spikes
		kplc Kos_HSpring,v_tile_hspring
		kplc Kos_VSpring,v_tile_vspring			; $A4C0 used
	.end:
		set_dma_size last_vram

KPLC_SBZ3:	kplcheader
		KPLC_LZ_common					; same as LZ
		kplc Kos_Sbz3HugeDoor
		kplc Kos_Burrobot,v_tile_burrobot
		kplc Kos_Orbinaut,v_tile_orbinaut
		kplc Kos_Jaws,v_tile_jaws
		kplc Kos_Button,v_tile_button
		kplc Kos_Lamp,v_tile_lamppost
		kplc Kos_Points,v_tile_points
		kplc Kos_Ring,v_tile_rings
		kplc Kos_Spikes,v_tile_spikes
		kplc Kos_HSpring,v_tile_hspring
		kplc Kos_VSpring,v_tile_vspring			; $9840 used
	.end:
		set_dma_size last_vram

KPLC_FZ:	kplcheader
		kplc Kos_SBZ
		kplc Kos_FzBoss
		kplc Kos_FzEggman
	.end:
		set_dma_size last_vram

KPLC_End:	kplcheader
		kplc Kos_GHZ_1st
		kplc Kos_GHZ_2nd
		kplc Kos_EndFlower
		kplc Kos_EndEm,v_tile_emeralds
		kplc Kos_EndSonic
	.end:
		set_dma_size last_vram

KPLC_Title:	kplcheader
		kplc Kos_GHZ_1st
		kplc Kos_TitleFg
		kplc Kos_TitleSonic
		kplc Kos_TitleTM
		kplc Kos_Text
	.end:
		set_dma_size last_vram

KPLC_HiddenCredits:	kplcheader
		kplc Kos_JapNames
	.end:
		set_dma_size last_vram

KPLC_Sega:	kplcheader
		kplc Kos_SegaLogo
	.end:
		set_dma_size last_vram

KPLC_Special:	kplcheader
		kplc Kos_SSBgCloud
		kplc Kos_SSBgFish
		kplc Kos_SSWalls
		kplc Kos_Bumper
		kplc Kos_SSGOAL
		kplc Kos_SSUpDown
	.end:
		set_dma_size last_vram

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed graphics

; input:
;	d0 = UPLC index id

; uses d0, d1, d2, a1, a2, a3
; ---------------------------------------------------------------------------

UncPLC:
		lea	UncLoadCues(pc),a2
		move.w	d0,d2
		add.w	d2,d2
		move.w	(a2,d2.w),d2
		lea	(a2,d2.w),a2				; jump to relevant UPLC
		move.w	(a2)+,d2				; get length of UPLC
		bmi.s	.exit					; branch if empty

	.loop:
		move.l	(a2)+,d1				; get destination VRAM address
		jsr	AddDMA2					; add to DMA queue (source/size already in a2)
		move.w	(a2)+,d1				; get tile setting
		moveq	#-1,d0
		move.w	(a2)+,d0				; get RAM address to save tile setting
		tst.w	d0
		beq.s	.skip_tileram				; branch if tile setting shouldn't be saved
		movea.l	d0,a3
		move.w	d1,(a3)					; save tile setting to RAM
	
	.skip_tileram:
		dbf	d2,.loop				; repeat for length of UPLC
	
	.exit:
		rts

uplcheader:	macro *,vram
		\*: equ *
		uplc_count\@: equ (.end-*-2)/18			; number if items in UPLC
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

; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------

UncLoadCues:
		index *
		ptr UPLC_HUD
		ptr UPLC_TitleCard
		ptr UPLC_GameOver
		ptr UPLC_Explode
		ptr UPLC_Stars
		ptr UPLC_Bonus
		ptr UPLC_SSResult
		ptr UPLC_Warp
		ptr UPLC_Credits

UPLC_HUD:	uplcheader $D940
		uplc Art_HUDMain,v_tile_hud
	.end:

UPLC_TitleCard:	uplcheader $B000
		uplc Art_TitleCard,v_tile_titlecard
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
		uplc Art_TitleCard,v_tile_titlecard
		uplc Art_HUDMain,v_tile_hud
		uplc Art_MiniSonic
		uplc Art_ResultEm
	.end:

UPLC_Warp:	uplcheader vram_shield
		uplc Art_Warp
	.end:

UPLC_Credits:	uplcheader $20
		uplc Art_CreditText
	.end:
