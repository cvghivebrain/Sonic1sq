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

	@loop:
		lea	($FF0000).l,a1				; RAM buffer start address
		adda.w	(a2)+,a1				; jump to current position in buffer
		movea.l	(a2)+,a0				; get pointer for compressed gfx
		jsr	KosDec					; decompress
		dbf	d0,@loop				; repeat for length of KPLC
		
		movem.l	d1-d2,-(sp)
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
		kplc_count\@: equ (\*_end-*-2)/6		; number if items in KPLC
		dc.w kplc_count\@-1				; number of loops
		last_vram: = 0					; start address in VRAM
		endm

kplc:		macro gfx
		dc.w last_vram					; RAM address to use as buffer
		dc.l gfx					; pointer to compressed gfx
		if ~def(tile_\gfx)
		tile_\gfx: equ last_vram/sizeof_cell		; remember tile setting for gfx
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
	KPLC_GHZ_end:
		set_dma_size last_vram

KPLC_MZ:	kplcheader
		kplc Kos_MZ
	KPLC_MZ_end:
		set_dma_size last_vram

KPLC_SYZ:	kplcheader
		kplc Kos_SYZ
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