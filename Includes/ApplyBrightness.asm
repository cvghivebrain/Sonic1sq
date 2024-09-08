; ---------------------------------------------------------------------------
; Subroutine to create palette with brightness applied
; ---------------------------------------------------------------------------

ApplyBrightness:
		tst.b	(v_gamemode).w
		bmi.w	ApplyBrightness_KeepSonic		; branch if title card is shown
		moveq	#(countof_color*countof_pal)-1,d0	; number of colours to copy
		tst.b	(f_water_enable).w
		beq.s	.no_water				; branch if not in water level
		moveq	#(countof_color*countof_pal*2)-1,d0	; also do underwater palette
		
	.no_water:
		lea	(v_pal_dry).w,a0
		lea	(v_pal_dry_final).w,a1
		
ApplyBrightness_Run:
		lea	BrightLevels_Red(pc),a2
		lea	BrightLevels_Green(pc),a3
		lea	BrightLevels_Blue(pc),a4
		move.w	(v_brightness).w,d1
		bpl.s	.loop					; branch if brightness is > 0
		lea	DarkLevels_Red(pc),a2
		lea	DarkLevels_Green(pc),a3
		lea	DarkLevels_Blue(pc),a4
		neg.w	d1
		
	.loop:
		move.w	(a0)+,d2
		move.w	d2,d3
		lsl.w	#3,d3
		andi.w	#$F0,d3					; read red value
		add.w	d1,d3
		move.b	(a2,d3.w),d3				; get new red value
		
		move.w	d2,d4
		lsr.w	#1,d4
		andi.w	#$F0,d4					; read green value
		add.w	d1,d4
		move.b	(a3,d4.w),d4				; get new green value
		
		move.w	d2,d5
		lsr.w	#5,d5
		andi.w	#$F0,d5					; read blue value
		add.w	d1,d5
		move.b	(a4,d5.w),d5				; get new blue value
		
		lsl.b	#4,d4
		or.b	d4,d3					; make low byte of colour (green/red)
		
		move.b	d5,(a1)+				; write blue
		move.b	d3,(a1)+				; write green/red
		dbf	d0,.loop				; repeat for all colours
		rts
		
BrightLevels_Red:
		hex	0002020404060608080a0a0c0c0e0e0e
		hex	020404060608080a0a0c0c0e0e0e0e0e
		hex	04060608080a0a0c0c0e0e0e0e0e0e0e
		hex	0608080a0a0c0c0e0e0e0e0e0e0e0e0e
		hex	080a0a0c0c0e0e0e0e0e0e0e0e0e0e0e
		hex	0a0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e
		hex	0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
		hex	0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
		even
		
DarkLevels_Red:
		hex	00000000000000000000000000000000
		hex	02000000000000000000000000000000
		hex	04020200000000000000000000000000
		hex	06040402020000000000000000000000
		hex	08060604040202000000000000000000
		hex	0a080806060404020200000000000000
		hex	0c0a0a08080606040402020000000000
		hex	0e0c0c0a0a0808060604040202000000
		even
		
BrightLevels_Green:
		hex	000002020404060608080a0a0c0c0e0e
		hex	02020404060608080a0a0c0c0e0e0e0e
		hex	0404060608080a0a0c0c0e0e0e0e0e0e
		hex	060608080a0a0c0c0e0e0e0e0e0e0e0e
		hex	08080a0a0c0c0e0e0e0e0e0e0e0e0e0e
		hex	0a0a0c0c0e0e0e0e0e0e0e0e0e0e0e0e
		hex	0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e
		hex	0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
		even
		
DarkLevels_Green:
		hex	00000000000000000000000000000000
		hex	02020000000000000000000000000000
		hex	04040202000000000000000000000000
		hex	06060404020200000000000000000000
		hex	08080606040402020000000000000000
		hex	0a0a0808060604040202000000000000
		hex	0c0c0a0a080806060404020200000000
		hex	0e0e0c0c0a0a08080606040402020000
		even
		
BrightLevels_Blue:
		hex	00000002020404060608080a0a0c0c0e
		hex	0202020404060608080a0a0c0c0e0e0e
		hex	040404060608080a0a0c0c0e0e0e0e0e
		hex	06060608080a0a0c0c0e0e0e0e0e0e0e
		hex	0808080a0a0c0c0e0e0e0e0e0e0e0e0e
		hex	0a0a0a0c0c0e0e0e0e0e0e0e0e0e0e0e
		hex	0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e
		hex	0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
		even
		
DarkLevels_Blue:
		hex	00000000000000000000000000000000
		hex	02020200000000000000000000000000
		hex	04040402020000000000000000000000
		hex	06060604040202000000000000000000
		hex	08080806060404020200000000000000
		hex	0a0a0a08080606040402020000000000
		hex	0c0c0c0a0a0808060604040202000000
		hex	0e0e0e0c0c0a0a080806060404020200
		even

ApplyBrightness_KeepSonic:
		lea	(v_pal_dry).w,a0
		lea	(v_pal_dry_final).w,a1
		moveq	#(countof_color/2)-1,d0			; do first palette line only
		
	.loop:
		move.l	(a0)+,(a1)+				; copy palette without changing brightness
		dbf	d0,.loop
		
		moveq	#(countof_color*3)-1,d0			; remaining 3 palettes
		tst.b	(f_water_enable).w
		beq.s	.no_water				; branch if not in water level
		moveq	#(countof_color*7)-1,d0			; also do underwater palette
		
	.no_water:
		bra.w	ApplyBrightness_Run
