; ---------------------------------------------------------------------------
; Subroutine to decompress Kosinski graphics $1000 bytes per frame

;	uses d0.l, d1.l, d2.l, d3.w, a0, a1, a2, a3, a4
; ---------------------------------------------------------------------------

ProcessSlowPLC:
		tst.l	(v_slowplc_ptr).w
		beq.s	.exit					; branch if SlowPLC isn't active
		lea	(v_slowplc_ptr).w,a4
		movea.l	(a4),a3					; a3 = current SlowPLC
		move.l	(a3)+,d0
		bmi.s	.end_of_splc				; branch if SlowPLC is finished
		movea.l	d0,a5					; get gfx source address
		move.w	(v_slowplc_module).w,d0			; current module index
		move.w	d0,d3
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
		addi.l	#$40000080,d1				; set VRAM write
		lea	SPLC_Src(pc),a2				; get RAM buffer address
		jmp	(AddDMA).w				; DMA gfx to VRAM on next VBlank
		
	.last_module:
		move.w	#0,(v_slowplc_module).w			; reset module counter
		move.w	d3,d0
		add.w	d0,d0
		addq.w	#4,d0
		moveq	#0,d2
		move.w	(a5,d0.w),d2				; read size of last module from header
		lsr.w	#1,d2					; divide by 2
		lsl.l	#8,d2
		lsr.w	#8,d2
		addi.l	#$94009300,d2				; set DMA length
		bsr.s	.dma_dest				; set DMA destination & add to queue
		
		move.w	(a3)+,d1				; get tile setting
		move.w	(a3)+,d0				; get RAM address to save tile setting
		beq.s	.no_tile				; branch if tile setting shouldn't be saved
		movea.l	d0,a3
		move.w	d1,(a3)					; save tile setting to RAM
		
	.no_tile:
		moveq	#10,d0
		add.l	d0,(a4)					; next SlowPLC on next frame
		
	.exit:
		rts
		
	.end_of_splc:
		moveq	#0,d0
		move.l	d0,(a4)					; clear pointer
		move.w	d0,(v_slowplc_module).w			; reset module counter
		rts

SPLC_Src:	set_dma_src v_slowplc_buffer

; ---------------------------------------------------------------------------
; Subroutine to process all SlowPLCs while still playing music
; ---------------------------------------------------------------------------

ProcessSlowPLC_All:
		tst.l	(v_slowplc_ptr).w
		beq.s	.exit					; branch if SlowPLCs are complete
		bsr.w	ProcessSlowPLC
		move.b	#id_VBlank_Fade,(v_vblank_routine).w	
		jsr	WaitForVBlank				; wait for frame to end
		bra.s	ProcessSlowPLC_All
		
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

SlowLoadCues:
		index *
		ptr SPLC_Title
		
SPLC_Title:	splcheader 0
		splc Kos_GHZ_1st_
		splc Kos_TitleFg
		splc Kos_TitleSonic
		splc Kos_TitleTM
		splc Kos_Text
		dc.w -1
		
