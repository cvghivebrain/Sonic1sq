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
		bmi.s	@exit					; branch if empty
		movem.l	d1-d2,-(sp)				; save d1 and d2 to stack

	@loop:
		lea	($FF0000).l,a1				; RAM buffer start address
		adda.w	(a2)+,a1				; jump to current position in buffer
		movea.l	(a2)+,a0				; get pointer for compressed gfx
		jsr	KosDec					; decompress
		move.w	(a2)+,d1				; get tile setting
		moveq	#-1,d2
		move.w	(a2)+,d2				; get RAM address to save tile setting
		tst.w	d2
		beq.s	@skip_tileram				; branch if tile setting shouldn't be saved
		movea.l	d2,a0
		move.w	d1,(a0)					; save tile setting to RAM
	
	@skip_tileram:
		dbf	d0,@loop				; repeat for length of KPLC
		
		move.l	#$40000080,d1				; destination = 0 in VRAM
		move.l	(a2),d2					; read size from end of KPLC
		lea	KPLC_Src(pc),a2				; source = $FF0000 in RAM
		jsr	AddDMA					; add to DMA queue
		jsr	ProcessDMA				; process queue now
		movem.l	(sp)+,d1-d2
	
	@exit:
		rts

KPLC_Src:	set_dma_src $FF0000

kplcheader:	macro *
		\*: equ *
		kplc_count\@: equ (\*_end-*-2)/10		; number if items in KPLC
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
		ptr KPLC_Title
		ptr KPLC_End

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
		kplc Kos_GhzSmashWall
		kplc Kos_Spikes,v_tile_spikes
		kplc Kos_HSpring,v_tile_hspring
		kplc Kos_VSpring,v_tile_vspring			; $A1A0 used
	KPLC_GHZ_end:
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
		kplc Kos_Spikes,v_tile_spikes
		kplc Kos_HSpring,v_tile_hspring
		kplc Kos_VSpring,v_tile_vspring			; $9400 used
	KPLC_MZ_end:
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
		kplc Kos_Spikes,v_tile_spikes
		kplc Kos_HSpring,v_tile_hspring
		kplc Kos_VSpring,v_tile_vspring			; $9D40 used
	KPLC_SYZ_end:
		set_dma_size last_vram

KPLC_LZ:	kplcheader
		kplc Kos_LZ
	KPLC_LZ_end:
		set_dma_size last_vram

KPLC_SLZ:	kplcheader
		kplc Kos_SLZ
	KPLC_SLZ_end:
		set_dma_size last_vram

KPLC_SBZ:	kplcheader
		kplc Kos_SBZ
	KPLC_SBZ_end:
		set_dma_size last_vram

KPLC_End:	kplcheader
		kplc Kos_GHZ_1st
		kplc Kos_GHZ_2nd
	KPLC_End_end:
		set_dma_size last_vram

KPLC_Title:	kplcheader
		kplc Kos_GHZ_1st
	KPLC_Title_end:
		set_dma_size last_vram