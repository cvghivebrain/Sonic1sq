; ---------------------------------------------------------------------------
; Subroutine to create palette with brightness applied

;	uses d0.l, d1.w, d2.w, d3.w, d4.w, a1, a2, a3, a4, a5

; usage:
;	move.b	#-8,(v_brightness).w				; set brightness to 50% (min -15; max 15)
;	jsr	ApplyBrightness					; update palette
; ---------------------------------------------------------------------------

ApplyBrightness:
		tst.b	(v_gamemode).w
		bmi.w	ApplyBrightness_KeepSonic		; branch if title card is shown
		moveq	#(countof_color*countof_pal)-1,d0	; number of colours to copy
		tst.b	(f_water_enable).w
		beq.s	.no_water				; branch if not in water level
		moveq	#(countof_color*countof_pal*2)-1,d0	; also do underwater palette
		
	.no_water:
		lea	(v_pal_dry).w,a1
		lea	(v_pal_dry_final).w,a2
		
ApplyBrightness_Run:
		lea	BrightLevels_Red(pc),a3
		lea	BrightLevels_Green(pc),a4
		lea	BrightLevels_Blue(pc),a5
		move.w	(v_brightness).w,d1
		bpl.s	.loop					; branch if brightness is > 0
		lea	DarkLevels_Red(pc),a3
		lea	DarkLevels_Green(pc),a4
		lea	DarkLevels_Blue(pc),a5
		neg.w	d1
		
	.loop:
		move.b	(a1)+,d4
		lsl.w	#3,d4
		andi.w	#$F0,d4					; read blue value
		add.w	d1,d4
		move.b	(a5,d4.w),d4				; get new blue value
		
		move.b	(a1)+,d2
		move.b	d2,d3
		lsl.w	#3,d3
		andi.w	#$F0,d3					; read red value
		add.w	d1,d3
		move.b	(a3,d3.w),d3				; get new red value
		
		lsr.w	#1,d2
		andi.w	#$F0,d2					; read green value
		add.w	d1,d2
		move.b	(a4,d2.w),d2				; get new green value
		
		or.b	d2,d3					; make low byte of colour (green/red)
		
		move.b	d4,(a2)+				; write blue
		move.b	d3,(a2)+				; write green/red
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
		hex	00002020404060608080a0a0c0c0e0e0
		hex	2020404060608080a0a0c0c0e0e0e0e0
		hex	404060608080a0a0c0c0e0e0e0e0e0e0
		hex	60608080a0a0c0c0e0e0e0e0e0e0e0e0
		hex	8080a0a0c0c0e0e0e0e0e0e0e0e0e0e0
		hex	a0a0c0c0e0e0e0e0e0e0e0e0e0e0e0e0
		hex	c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
		hex	e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
		even
		
DarkLevels_Green:
		hex	00000000000000000000000000000000
		hex	20200000000000000000000000000000
		hex	40402020000000000000000000000000
		hex	60604040202000000000000000000000
		hex	80806060404020200000000000000000
		hex	a0a08080606040402020000000000000
		hex	c0c0a0a0808060604040202000000000
		hex	e0e0c0c0a0a080806060404020200000
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
		lea	(v_pal_dry).w,a1
		lea	(v_pal_dry_final).w,a2
		moveq	#(countof_color/2)-1,d0			; do first palette line only
		
	.loop:
		move.l	(a1)+,(a2)+				; copy palette without changing brightness
		dbf	d0,.loop
		
		moveq	#(countof_color*3)-1,d0			; remaining 3 palettes
		tst.b	(f_water_enable).w
		beq.s	.no_water				; branch if not in water level
		moveq	#(countof_color*7)-1,d0			; also do underwater palette
		
	.no_water:
		bra.w	ApplyBrightness_Run
