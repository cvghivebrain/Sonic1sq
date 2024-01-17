; ---------------------------------------------------------------------------
; Subroutine to	decompress Kosinski graphics $1000 bytes per frame

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
		
; ---------------------------------------------------------------------------
; Subroutine to	do the actual decompression

;	uses d0.l, d1.l, d2.l, a0, a1, a2, a3, a4
; ---------------------------------------------------------------------------

ProcessSlowPLC:
		lea	(v_slowplc_ptr).w,a4
		move.l	(a4),d0
		beq.s	.exit					; branch if SlowPLC isn't active
		movea.l	d0,a3
		move.l	(a3)+,d0
		bmi.s	.end_of_splc				; branch if SlowPLC is finished
		movea.l	d0,a0					; get gfx source address
		lea	(v_slowplc_buffer).w,a1			; gfx buffer address in RAM
		jsr	(KosDec).w				; decompress to RAM
		
		move.l	(a3)+,d1				; get destination VRAM address
		move.l	(a3)+,d2				; get size of gfx
		lea	SPLC_Src(pc),a2				; get RAM buffer address
		jsr	(AddDMA).w				; DMA gfx to VRAM on next VBlank
		move.w	(a3)+,d1				; get tile setting
		move.w	(a3)+,d0				; get RAM address to save tile setting
		beq.s	.no_tile				; branch if tile setting shouldn't be saved
		movea.l	d0,a3
		move.w	d1,(a3)					; save tile setting to RAM
		
	.no_tile:
		moveq	#16,d0
		add.l	d0,(a4)					; next SlowPLC on next frame
		
	.exit:
		rts
		
	.end_of_splc:
		moveq	#0,d0
		move.l	d0,(a4)					; clear pointer
		rts

SPLC_Src:	set_dma_src v_slowplc_buffer

splcheader:	macro *,vram
		\*: equ *
		last_vram: = vram				; start address in VRAM
		last_label: equs "\*"
		endm

splc:		macro gfx,tileram
		dc.l \gfx					; source in ROM
		set_dma_dest last_vram				; destination in VRAM
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
		if sizeof_\gfx > $1000
		inform	3,"\gfx in SlowLoadCue \last_label exceeds maximum size of $1000 bytes."
		endc
		endm
		
; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------

SlowLoadCues:
		index *
		ptr SPLC_Test
		
SPLC_Test:	splcheader 0
		splc Kos_HSpring
		splc Kos_VSpring
		dc.w -1
		
