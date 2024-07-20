; ---------------------------------------------------------------------------
; Subroutines to load palette immediately

; input:
;	d0.w = index number for palette

;	uses d0.w, a1, a2, a3
; ---------------------------------------------------------------------------

PalLoad:
		lsl.w	#3,d0					; multiply id by 8
		lea	PalPointers(pc,d0.w),a1
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
