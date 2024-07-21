; ---------------------------------------------------------------------------
; Subroutine to generate water palette at the start of a level

; input:
;	d1.w = offset within palette (WaterFilter_SkipOffset only; a4 still needed)
;	d4.w = number of colours to process
;	a4.w = address of palette to process (e.g. v_pal_dry_line1)

;	uses d1.w, d4.w, d5.l, a4, a5, a6
; ---------------------------------------------------------------------------

WaterFilter:
		move.w	a4,d1					; copy palette address
		subi.w	#(v_pal_dry&$FFFF),d1			; d1 = offset within palette
		
WaterFilter_SkipOffset:
		moveq	#0,d5
		move.b	(v_waterfilter_id).w,d5			; get filter id
		add.w	d5,d5					; multiply by 2
		move.w	Filter_Index(pc,d5.w),d5

		subq.w	#1,d4					; subtract 1 for loops
		bmi.s	.exit					; branch if it was 0
		lea	v_pal_water-v_pal_dry(a4),a5		; a5 = address of water palette
		lea	Filter_KeepList(pc,d1.w),a6		; jump to relevant position within keeplist

	.loop:
		move.w	(a4)+,d1				; get colour
		tst.w	(a6)+					; check keeplist
		bne.s	.keepcolour				; branch if 1
		jsr	Filter_Index(pc,d5.w)
	.keepcolour:
		move.w	d1,(a5)+				; write colour
		dbf	d4,.loop				; repeat for all colours
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Functions applied to each colour

; input:
;	d1.w = single colour

; output:
;	d1.w = updated colour
; ---------------------------------------------------------------------------

Filter_Index:	index *
		ptr Filter_LZ
		ptr Filter_SBZ3

Filter_LZ:
		andi.w	#$CE2,d1				; remove most red & some blue
		rts

Filter_SBZ3:
		andi.w	#$E0E,d1				; remove green
		rts

; ---------------------------------------------------------------------------
; Array listing which colours are filtered and which are kept
; ---------------------------------------------------------------------------

Filter_KeepList:
		dc.w 1,1,0,0,0,0,1,1,1,1,0,0,0,0,0,1		; 0 = filter colour; 1 = keep colour
		dc.w 1,1,0,0,0,0,1,1,1,1,0,0,0,0,0,0
		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		even
		