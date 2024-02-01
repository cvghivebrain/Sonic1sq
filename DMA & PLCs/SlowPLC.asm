; ---------------------------------------------------------------------------
; Subroutine to decompress Kosinski graphics $1000 bytes per frame

;	uses d0.l, d1.l, d2.l, d3.w, a0, a1, a2, a3, a4
; ---------------------------------------------------------------------------

ProcessSlowPLC:
		tst.l	(v_slowplc_ptr).w
		bne.s	ProcessSlowPLC_SkipChk			; branch if SlowPLC is active
		rts
		
ProcessSlowPLC_SkipChk:
		lea	(v_slowplc_ptr).w,a4
		movea.l	(a4),a3					; a3 = current SlowPLC
		move.l	(a3)+,d0
		bmi.s	.end_of_splc				; branch if SlowPLC is finished
		movea.l	d0,a5					; get gfx source address
		move.w	(v_slowplc_module).w,d3			; current module index
		move.w	d3,d0
		add.w	d0,d0
		addq.w	#2,d0
		move.w	(a5,d0.w),d0				; read pointer from header
		lea	(a5,d0.w),a0				; jump to actual compressed gfx module
		lea	(v_slowplc_buffer).w,a1			; gfx buffer address in RAM
		jsr	(KosDec).w				; decompress to RAM
		
		cmp.w	(a5),d3
		beq.s	.last_module				; branch if current module is last one
		addq.w	#1,(v_slowplc_module).w			; increment module counter
		set_dma_size	sizeof_slowplc_buffer,d2	; size of gfx = whole buffer ($1000)
		
	.dma_dest:
		moveq	#0,d1
		move.w	(a3)+,d1				; get destination VRAM address
		ror.w	#4,d3
		add.w	d3,d1					; add module index * $1000
		lsl.l	#2,d1					; move top 2 bits into hi word
		lsr.w	#2,d1					; return other bits to correct position
		swap	d1					; swap hi/low words
		ori.l	#$40000080,d1				; set VRAM write
		lea	SPLC_Src(pc),a2				; get RAM buffer address
		jmp	(AddDMA).w				; DMA gfx to VRAM on next VBlank
		
	.last_module:
		moveq	#0,d2
		move.w	d2,(v_slowplc_module).w			; reset module counter
		move.w	d3,d0
		add.w	d0,d0
		addq.w	#4,d0
		move.w	(a5,d0.w),d2				; read size of last module from header
		lsl.l	#7,d2
		lsr.w	#8,d2
		ori.l	#$94009300,d2				; set DMA length
		bsr.s	.dma_dest				; set DMA destination & add to queue
		
		move.w	(a3)+,d0				; get RAM address to save tile setting
		beq.s	.no_tile				; branch if tile setting shouldn't be saved
		movea.w	d0,a2
		move.w	(a3)+,(a2)				; save tile setting to RAM
		
	.no_tile:
		moveq	#sizeof_SPLC,d0
		add.l	d0,(a4)					; next SlowPLC on next frame
		rts
		
	.end_of_splc:
		moveq	#0,d0
		move.l	d0,(a4)					; clear pointer
		move.w	d0,(v_slowplc_module).w			; reset module counter
		rts

SPLC_Src:	set_dma_src v_slowplc_buffer

; ---------------------------------------------------------------------------
; Subroutine to process all SlowPLCs without stopping music (game is otherwise frozen)

; input:
;	d0.w = SPLC index id
; ---------------------------------------------------------------------------

SlowPLC_Now:
		bsr.s	SlowPLC
		
	.loop:
		tst.l	(v_slowplc_ptr).w
		beq.s	.exit					; branch if SlowPLCs are complete
		bsr.w	ProcessSlowPLC_SkipChk
		move.b	#id_VBlank_Fade,(v_vblank_routine).w	
		jsr	WaitForVBlank				; wait for frame to end
		bra.s	.loop
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	trigger processing of a specified SlowPLC

; input:
;	d0.w = SPLC index id

;	uses d0.w, d1.l
; ---------------------------------------------------------------------------

SlowPLC:
		add.w	d0,d0
		moveq	#0,d1
		move.w	SlowLoadCues(pc,d0.w),d1
		addi.l	#SlowLoadCues,d1
		move.l	d1,(v_slowplc_ptr).w			; save address
		rts

splcheader:	macro *,vram
		\*: equ *
		last_vram: = vram				; start address in VRAM
		last_label: equs "\*"
		endm

splc:		macro gfx,tileram
		dc.l \gfx					; source in ROM
		dc.w last_vram					; destination in VRAM
		if narg=1
		dc.w 0
		else
		dc.w tileram&$FFFF				; RAM address to store tile setting
		endc
		dc.w last_vram/sizeof_cell			; tile setting
		
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

SlowLoadCues:
		index *
		ptr SPLC_Title
		ptr SPLC_Sega
		ptr SPLC_HiddenCredits
		ptr SPLC_GHZ
		ptr SPLC_MZ
		ptr SPLC_SYZ
		ptr SPLC_LZ
		ptr SPLC_SLZ
		ptr SPLC_SBZ
		ptr SPLC_SBZ3
		ptr SPLC_FZ
		ptr SPLC_End
		ptr SPLC_TryAgain
		ptr SPLC_Special
		
SPLC_Title:	splcheader 0
		splc Kos_GHZ_1st
sizeof_SPLC:	equ *-SPLC_Title
		splc Kos_TitleFg
		splc Kos_TitleSonic
		splc Kos_TitleTM
		splc Kos_Text
		dc.w -1

SPLC_Sega:	splcheader 0
		splc Kos_SegaLogo
		dc.w -1

SPLC_HiddenCredits:	splcheader 0
		splc Kos_JapNames
		dc.w -1
		
SPLC_GHZ:	splcheader 0
		splc Kos_GHZ_1st
		splc Kos_GHZ_2nd
		splc Kos_GhzEdgeWall
		splc Kos_Swing,v_tile_swing
		splc Kos_Bridge
		splc Kos_SpikePole
		splc Kos_PurpleRock
		splc Kos_Crabmeat,v_tile_crabmeat
		splc Kos_Buzz,v_tile_buzzbomber
		splc Kos_Chopper,v_tile_chopper
		splc Kos_Newtron,v_tile_newtron
		splc Kos_Motobug,v_tile_motobug
		splc Kos_GhzSmashWall,v_tile_wall
		splc Kos_Lamp,v_tile_lamppost
		splc Kos_Points,v_tile_points
		splc Kos_Ring,v_tile_rings
		splc Kos_Spikes,v_tile_spikes
		splc Kos_HSpring,v_tile_hspring
		splc Kos_VSpring,v_tile_vspring
		dc.w -1

SPLC_MZ:	splcheader 0
		splc Kos_MZ
		splc Kos_MzBlock,v_tile_floor
		splc Kos_Swing,v_tile_swing
		splc Kos_MzMetal
		splc Kos_Fireball,v_tile_fireball
		splc Kos_MzGlass
		splc Kos_Lava
		splc Kos_Buzz,v_tile_buzzbomber
		splc Kos_Batbrain,v_tile_batbrain
		splc Kos_Cater,v_tile_caterkiller
		splc Kos_Splats,v_tile_splats
		splc Kos_MzButton,v_tile_button
		splc Kos_Lamp,v_tile_lamppost
		splc Kos_Points,v_tile_points
		splc Kos_Ring,v_tile_rings
		splc Kos_Spikes,v_tile_spikes
		splc Kos_HSpring,v_tile_hspring
		splc Kos_VSpring,v_tile_vspring
		dc.w -1

SPLC_SYZ:	splcheader 0
		splc Kos_SYZ
		splc Kos_Bumper,v_tile_bumper
		splc Kos_BigSpike,v_tile_spikeball
		splc Kos_SmallSpike,v_tile_spikechain
		splc Kos_Button,v_tile_button
		splc Kos_Crabmeat,v_tile_crabmeat
		splc Kos_Buzz,v_tile_buzzbomber
		splc Kos_Yadrin,v_tile_yadrin
		splc Kos_Roller,v_tile_roller
		splc Kos_Lamp,v_tile_lamppost
		splc Kos_Points,v_tile_points
		splc Kos_Ring,v_tile_rings
		splc Kos_Spikes,v_tile_spikes
		splc Kos_HSpring,v_tile_hspring
		splc Kos_VSpring,v_tile_vspring
		dc.w -1

SPLC_LZ:	splcheader 0
		SPLC_LZ_common:	macro				; these gfx are also used in SBZ3
		splc Kos_LZ
		splc Kos_LzBlock
		splc Kos_Splash
		splc Kos_Water
		splc Kos_Gargoyle
		splc Kos_LzSpikeBall,v_tile_spikechain
		splc Kos_FlapDoor
		splc Kos_Bubbles,v_tile_bubbles
		splc Kos_LzHalfBlock
		splc Kos_LzDoorV
		splc Kos_Harpoon
		splc Kos_LzDoorH
		splc Kos_LzPlatform
		endm
		SPLC_LZ_common
		splc Kos_LzPole
		splc Kos_LzWheel
		splc Kos_Cork
		splc Kos_Burrobot,v_tile_burrobot
		splc Kos_Orbinaut,v_tile_orbinaut
		splc Kos_Jaws,v_tile_jaws
		splc Kos_Button,v_tile_button
		splc Kos_Lamp,v_tile_lamppost
		splc Kos_Points,v_tile_points
		splc Kos_Ring,v_tile_rings
		splc Kos_Spikes,v_tile_spikes
		splc Kos_HSpring,v_tile_hspring
		splc Kos_VSpring,v_tile_vspring
		dc.w -1

SPLC_SLZ:	splcheader 0
		splc Kos_SLZ
		splc Kos_Seesaw
		splc Kos_SlzSpike
		splc Kos_Bomb,v_tile_bomb
		splc Kos_Fan
		splc Kos_Pylon
		splc Kos_SlzSwing,v_tile_swing
		splc Kos_SlzCannon
		splc Kos_Orbinaut,v_tile_orbinaut
		splc Kos_Fireball,v_tile_fireball
		splc Kos_SlzBlock,v_tile_floor
		splc Kos_SlzWall,v_tile_wall
		splc Kos_Lamp,v_tile_lamppost
		splc Kos_Points,v_tile_points
		splc Kos_Ring,v_tile_rings
		splc Kos_Spikes,v_tile_spikes
		splc Kos_HSpring,v_tile_hspring
		splc Kos_VSpring,v_tile_vspring
		dc.w -1

SPLC_SBZ:	splcheader 0
		splc Kos_SBZ
		splc Kos_Button,v_tile_button
		splc Kos_SbzBlock
		splc Kos_Stomper
		splc Kos_SbzDoorV
		splc Kos_Girder
		splc Kos_SbzDisc
		splc Kos_SbzJunction
		splc Kos_BigSpike,v_tile_spikeball
		splc Kos_Cutter
		splc Kos_FlamePipe
		splc Kos_SbzFloor,v_tile_floor
		splc Kos_SlideFloor
		splc Kos_SbzDoorH
		splc Kos_Electric
		splc Kos_TrapDoor
		splc Kos_SpinPlatform
		splc Kos_BallHog,v_tile_ballhog
		splc Kos_Cater,v_tile_caterkiller
		splc Kos_Bomb,v_tile_bomb
		splc Kos_Lamp,v_tile_lamppost
		splc Kos_Points,v_tile_points
		splc Kos_Ring,v_tile_rings
		splc Kos_Spikes,v_tile_spikes
		splc Kos_HSpring,v_tile_hspring
		splc Kos_VSpring,v_tile_vspring
		dc.w -1

SPLC_SBZ3:	splcheader 0
		SPLC_LZ_common					; same as LZ
		splc Kos_Sbz3HugeDoor
		splc Kos_Burrobot,v_tile_burrobot
		splc Kos_Orbinaut,v_tile_orbinaut
		splc Kos_Jaws,v_tile_jaws
		splc Kos_Button,v_tile_button
		splc Kos_Lamp,v_tile_lamppost
		splc Kos_Points,v_tile_points
		splc Kos_Ring,v_tile_rings
		splc Kos_Spikes,v_tile_spikes
		splc Kos_HSpring,v_tile_hspring
		splc Kos_VSpring,v_tile_vspring
		dc.w -1

SPLC_FZ:	splcheader 0
		splc Kos_SBZ
		splc Kos_FzBoss
		splc Kos_FzEggman
		dc.w -1

SPLC_End:	splcheader 0
		splc Kos_GHZ_1st
		splc Kos_GHZ_2nd
		splc Kos_EndFlower
		splc Kos_EndEm,v_tile_emeralds
		splc Kos_EndSonic
		dc.w -1

SPLC_TryAgain:	splcheader 0
		splc Kos_TryAgain
		splc Kos_EndEm,v_tile_emeralds
		dc.w -1

SPLC_Special:	splcheader 0
		splc Kos_SSBgCloud
		splc Kos_SSBgFish
		splc Kos_SSWalls
		splc Kos_Bumper
		splc Kos_SSGOAL
		splc Kos_SSUpDown
		splc Kos_SSRBlock
		splc Kos_SS1UpBlock
		splc Kos_SSEmStars
		splc Kos_SSRedWhite
		splc Kos_SSGhost
		splc Kos_SSWBlock
		splc Kos_SSGlass
		splc Kos_SSEmerald
		splc Kos_SSZone1
		splc Kos_SSZone2
		splc Kos_SSZone3
		splc Kos_SSZone4
		splc Kos_SSZone5
		splc Kos_SSZone6
		splc Kos_Ring
		dc.w -1
