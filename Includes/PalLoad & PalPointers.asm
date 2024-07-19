; ---------------------------------------------------------------------------
; Subroutines to load palette immediately

; input:
;	d0.w = index number for palette

;	uses d0.w, a1, a2, a3
; ---------------------------------------------------------------------------

PalLoad:
		lea	PalPointers(pc),a1
		lsl.w	#3,d0					; multiply id by 8
		adda.w	d0,a1
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		move.w	(a1)+,d0				; get length of palette

	.loop:
		move.l	(a2)+,(a3)+				; move data to RAM
		dbf	d0,.loop
	.exit:
		rts

; ---------------------------------------------------------------------------
; Palette pointers
; ---------------------------------------------------------------------------

palp:		macro paladdress,ramaddress
		id_\paladdress:	equ (*-PalPointers)/8
		dc.l paladdress
		dc.w ramaddress, (sizeof_\paladdress/4)-1
		endm

PalPointers:
		palp	Pal_SegaBG,v_pal_dry_line1		; Sega logo
		palp	Pal_Title,v_pal_dry_line1		; title screen
		palp	Pal_LevelSel,v_pal_dry_line1		; level select
		palp	Pal_Sonic,v_pal_dry_line1		; Sonic
		palp	Pal_SonicRed,v_pal_dry_line1+4		; Ketchup
		palp	Pal_SonicYellow,v_pal_dry_line1+4	; Mustard
		palp	Pal_HidCred,v_pal_dry_line3		; Hidden Japanese credits
		palp	Pal_GHZ,v_pal_dry_line2			; GHZ
		palp	Pal_LZ,v_pal_dry_line2			; LZ
		palp	Pal_MZ,v_pal_dry_line2			; MZ
		palp	Pal_SLZ,v_pal_dry_line2			; SLZ
		palp	Pal_SYZ,v_pal_dry_line2			; SYZ
		palp	Pal_SBZ1,v_pal_dry_line2		; SBZ1
		palp	Pal_SBZ2,v_pal_dry_line2		; SBZ2
		palp	Pal_SBZ3,v_pal_dry_line2		; SBZ3
		palp	Pal_Special,v_pal_dry_line1		; special stage
		palp	Pal_SSResult,v_pal_dry_line1		; special stage results
		palp	Pal_Continue,v_pal_dry_line1		; special stage results continue
		palp	Pal_Ending,v_pal_dry_line1		; ending sequence
		even

; ---------------------------------------------------------------------------
; Subroutine to generate water palette at the start of a level

; input:
;	d1.w = number of colours to process
;	a0 = address of first colour in palette to process (v_pal_dry for all)

;	uses d0.l, d1.w, d2.w, d3.l, a0, a1, a2
; ---------------------------------------------------------------------------

WaterFilter:
		moveq	#0,d0
		move.b	(v_waterfilter_id).w,d0			; get filter id
		add.w	d0,d0					; multiply by 2
		move.w	Filter_Index(pc,d0.w),d0

		subq.w	#1,d1					; subtract 1 for loops
		bmi.s	.exit					; branch if it was 0
		lea	v_pal_water-v_pal_dry(a0),a1		; a1 = address of water palette
		lea	Filter_KeepList(pc),a2
		moveq	#0,d3

	.loop:
		move.w	(a0)+,d2				; get colour
		tst.b	(a2,d3.w)				; check keeplist
		bne.s	.keepcolour				; branch if 1
		jsr	Filter_Index(pc,d0.w)
	.keepcolour:
		move.w	d2,(a1)+				; write colour
		addq.w	#1,d3					; increment counter
		dbf	d1,.loop				; repeat for all colours
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Functions applied to each colour

; input:
;	d2.w = single colour

; output:
;	d2.w = updated colour
; ---------------------------------------------------------------------------

Filter_Index:	index *
		ptr Filter_LZ
		ptr Filter_SBZ3

Filter_LZ:
		andi.w	#$CE2,d2				; remove most red & some blue
		rts

Filter_SBZ3:
		andi.w	#$E0E,d2				; remove green
		rts

; ---------------------------------------------------------------------------
; Array listing which colours are filtered and which are kept
; ---------------------------------------------------------------------------

Filter_KeepList:
		dc.b 1,1,0,0,0,0,1,1,1,1,0,0,0,0,0,1		; 0 = filter colour; 1 = keep colour
		dc.b 1,1,0,0,0,0,1,1,1,1,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		even

