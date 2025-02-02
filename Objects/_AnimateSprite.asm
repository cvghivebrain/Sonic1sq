; ---------------------------------------------------------------------------
; Subroutine to	animate	a sprite using an animation script
;
; input:
;	a1 = animation script index (e.g. Ani_Crab)

; output:
;	a1 = animation script (e.g. ani_crab_stand)

;	uses d0.l, d1.l, d2.l, a2

; usage:
;		lea	Ani_Hog(pc),a1
;		bsr.w	AnimateSprite
; ---------------------------------------------------------------------------

AnimateSprite:
		moveq	#status_xflip+status_yflip,d2		; use x/yflip from status and flags
		move.b	ost_anim(a0),d0				; get animation number
		bmi.s	Anim_Run				; branch if animation isn't set to restart

		bset	#7,ost_anim(a0)				; set to "no restart"
		clr.b	ost_anim_frame(a0)			; reset animation
		clr.b	ost_anim_time(a0)			; reset frame duration

Anim_Run:
		subq.b	#1,ost_anim_time(a0)			; subtract 1 from frame duration
		bpl.s	Anim_Wait				; if time remains, branch
		andi.w	#$7F,d0
		add.w	d0,d0
		adda.w	(a1,d0.w),a1				; jump to appropriate animation	script
		move.w	(a1),d0
		bmi.s	Anim_Flag				; branch if there's a flag instead of time
		move.b	d0,ost_anim_time(a0)			; load frame duration
		moveq	#0,d1
		move.b	ost_anim_frame(a0),d1			; load current frame number
		move.w	2(a1,d1.w),d0				; read sprite number from script
		bmi.s	Anim_Flag				; branch if an animation flag is found

Anim_Next:
		move.w	d0,d1					; copy full frame info to d1
		andi.w	#$1FFF,d0				; sprite number only
		move.w	d0,ost_frame_hi(a0)			; load sprite number
		move.b	ost_status(a0),d0
		rol.w	#3,d1
		eor.b	d0,d1
		and.b	d2,d1					; get x/yflip bits in d1
		andi.b	#$FF-render_xflip-render_yflip,ost_render(a0)
		or.b	d1,ost_render(a0)			; apply x/yflip bits from status
		addq.b	#2,ost_anim_frame(a0)			; next frame number

Anim_Wait:
		rts	
; ===========================================================================

Anim_Flag:
		neg.w	d0
		move.w	Anim_Flag_Index(pc,d0.w),d0
		jmp	Anim_Flag_Index(pc,d0.w)
; ===========================================================================
Anim_Flag_Index:
		index *,0,-2
		ptr Anim_Flag_0
		ptr Anim_Flag_Restart
		ptr Anim_Flag_Back
		ptr Anim_Flag_Stop
		ptr Anim_Flag_Change
		ptr Anim_Flag_Routine
		ptr Anim_Flag_Restart2
		ptr Anim_Flag_Routine2
		ptr Anim_Flag_WalkRun
		ptr Anim_Flag_Roll
		ptr Anim_Flag_Push
		ptr Anim_Flag_Restart_Sonic
; ===========================================================================

Anim_Flag_0:
Anim_Flag_Restart:
		move.b	#0,ost_anim_frame(a0)			; restart the animation
		move.w	2(a1),d0				; read sprite number
		bra.s	Anim_Next
; ===========================================================================

Anim_Flag_Restart_Sonic:
		move.b	#0,ost_anim_frame(a0)			; restart the animation
		move.w	2(a1),d0				; read sprite number
		move.w	d0,ost_frame_hi(a0)			; load sprite number
		addq.b	#2,ost_anim_frame(a0)			; next frame number
		rts
; ===========================================================================

Anim_Flag_Back:
		move.w	4(a1,d1.w),d0				; read the next	word in	the script
		add.w	d0,d0
		sub.b	d0,d1
		move.b	d1,ost_anim_frame(a0)			; jump back d0 bytes in the script
		move.w	2(a1,d1.w),d0				; read sprite number
		bra.s	Anim_Next
; ===========================================================================

Anim_Flag_Stop:
		rts
; ===========================================================================

Anim_Flag_Change:
		move.w	4(a1,d1.w),d0
		move.b	d0,ost_anim(a0)				; read next byte, run that animation
		rts

Anim_Flag_Routine:
		addq.b	#2,ost_routine(a0)			; jump to next routine
		rts

Anim_Flag_Restart2:						; unused
		move.b	#0,ost_anim_frame(a0)			; reset animation
		clr.b	ost_mode(a0)				; reset 2nd routine counter
		rts

Anim_Flag_Routine2:						; only used by EndSonic
		addq.b	#2,ost_mode(a0)				; jump to next routine
		rts

Anim_Flag_WalkRun:
		btst	#status_pushing_bit,ost_status(a0)
		bne.w	Anim_Flag_Push				; branch if Sonic is pushing
		
		exg	a1,a2					; a1 = Ani_Sonic
		moveq	#0,d0
		move.b	ost_angle(a0),d0			; get Sonic's angle
		moveq	#status_xflip,d2
		and.b	ost_status(a0),d2
		beq.s	.noxflip				; branch if Sonic isn't xflipped
		not.b	d0					; reverse angle
	.noxflip:
		lsr.b	#2,d0					; divide angle by 4
		
		lea	Anim_WalkList(pc),a2
		move.w	ost_inertia(a0),d1			; get Sonic's speed
		bpl.s	.speed_ok
		neg.w	d1					; absolute speed
	.speed_ok:
		cmpi.w	#sonic_max_speed,d1
		bcs.s	.walking				; branch if Sonic is below max speed
		lea	Anim_RunList(pc),a2			; use running animation
	.walking:
		neg.w	d1
		addi.w	#$800,d1				; d1 = $800 minus Sonic's speed
		bpl.s	.belowmax				; branch if speed is below $800
		moveq	#0,d1					; max animation speed
	.belowmax:
		lsr.w	#8,d1
		move.b	d1,ost_anim_time(a0)			; set frame duration
		
		andi.b	#$FF-render_xflip-render_yflip,ost_render(a0) ; clear x/yflip flags
		move.b	(a2,d0.w),d0				; get animation for specified angle
		bpl.s	.noinvert				; branch if invert flag is not set
		ori.b	#render_xflip+render_yflip,ost_render(a0) ; x/yflip sprite
		andi.b	#$7F,d0					; remove invert flag
	.noinvert:
		eor.b	d2,ost_render(a0)			; apply xflip from status

Anim_Sonic_Update:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1				; jump to appropriate animation	script
		moveq	#0,d1
		move.b	ost_anim_frame(a0),d1			; load current frame number
		move.w	2(a1,d1.w),d0				; read sprite number from script
		bmi.w	Anim_Flag				; branch if an animation flag is found
		move.w	d0,ost_frame_hi(a0)			; load sprite number
		addq.b	#2,ost_anim_frame(a0)			; next frame number
		rts
		
Anim_Flag_Roll:
		exg	a1,a2					; a1 = Ani_Sonic
		move.w	ost_inertia(a0),d1			; get Sonic's speed
		bpl.s	.speed_ok
		neg.w	d1					; absolute speed
	.speed_ok:
		moveq	#id_Roll2,d0				; use fast animation
		cmpi.w	#sonic_max_speed,d1			; is Sonic moving fast?
		bcc.s	.rollfast				; if yes, branch
		moveq	#id_Roll,d0				; use slower animation
	.rollfast:
		neg.w	d1
		addi.w	#$400,d1				; d1 = $400 minus Sonic's speed
		bpl.s	.belowmax				; branch if speed is below $400
		moveq	#0,d1					; max animation speed
	.belowmax:
		lsr.w	#8,d1
		bra.s	Anim_Sonic_Update2
		
Anim_Flag_Push:
		moveq	#id_Pushing,d0
		exg	a1,a2					; a1 = Ani_Sonic
		move.w	ost_inertia(a0),d1			; get Sonic's speed
		bmi.s	.speed_ok
		neg.w	d1
	.speed_ok:
		addi.w	#$800,d1				; d2 = $800 minus Sonic's speed
		bpl.s	.belowmax				; branch if speed is below $800
		moveq	#0,d1					; max animation speed
	.belowmax:
		lsr.w	#6,d1
		
Anim_Sonic_Update2:
		move.b	d1,ost_anim_time(a0)			; set frame duration
		moveq	#status_xflip,d1
		and.b	ost_status(a0),d1			; read xflip from status
		andi.b	#$FF-render_xflip-render_yflip,ost_render(a0)
		or.b	d1,ost_render(a0)			; apply xflip from status
		bra.w	Anim_Sonic_Update
		
; ---------------------------------------------------------------------------
; List of animations to be used at every possible angle. Angles are always
; multiples of 4 (the lower 2 bits are used as flags).

; +$80 = xflip+yflip sprites for ceiling angles
; ---------------------------------------------------------------------------

Anim_WalkList:	dc.b id_Walk,id_Walk,id_Walk,id_Walk		; angles 0-$C
		dc.b id_Walk4+$80,id_Walk4+$80,id_Walk4+$80,id_Walk4+$80 ; angles $10-$1C
		dc.b id_Walk4+$80,id_Walk4+$80,id_Walk4+$80,id_Walk4+$80 ; angles $20-$2C
		dc.b id_Walk3+$80,id_Walk3+$80,id_Walk3+$80,id_Walk3+$80 ; angles $30-$3C
		dc.b id_Walk3+$80,id_Walk3+$80,id_Walk3+$80,id_Walk3+$80 ; angles $40-$4C
		dc.b id_Walk2+$80,id_Walk2+$80,id_Walk2+$80,id_Walk2+$80 ; angles $50-$5C
		dc.b id_Walk2+$80,id_Walk2+$80,id_Walk2+$80,id_Walk2+$80 ; angles $60-$6C
		dc.b id_Walk+$80,id_Walk+$80,id_Walk+$80,id_Walk+$80 ; angles $70-$7C
		dc.b id_Walk+$80,id_Walk+$80,id_Walk+$80,id_Walk+$80 ; angles $80-$8C
		dc.b id_Walk4,id_Walk4,id_Walk4,id_Walk4	; angles $90-$9C
		dc.b id_Walk4,id_Walk4,id_Walk4,id_Walk4	; angles $A0-$AC
		dc.b id_Walk3,id_Walk3,id_Walk3,id_Walk3	; angles $B0-$BC
		dc.b id_Walk3,id_Walk3,id_Walk3,id_Walk3	; angles $C0-$CC
		dc.b id_Walk2,id_Walk2,id_Walk2,id_Walk2	; angles $D0-$DC
		dc.b id_Walk2,id_Walk2,id_Walk2,id_Walk2	; angles $E0-$EC
		dc.b id_Walk,id_Walk,id_Walk,id_Walk		; angles $F0-$FC
		even
		
Anim_RunList:	dc.b id_Run,id_Run,id_Run,id_Run		; angles 0-$C
		dc.b id_Run4+$80,id_Run4+$80,id_Run4+$80,id_Run4+$80 ; angles $10-$1C
		dc.b id_Run4+$80,id_Run4+$80,id_Run4+$80,id_Run4+$80 ; angles $20-$2C
		dc.b id_Run3+$80,id_Run3+$80,id_Run3+$80,id_Run3+$80 ; angles $30-$3C
		dc.b id_Run3+$80,id_Run3+$80,id_Run3+$80,id_Run3+$80 ; angles $40-$4C
		dc.b id_Run2+$80,id_Run2+$80,id_Run2+$80,id_Run2+$80 ; angles $50-$5C
		dc.b id_Run2+$80,id_Run2+$80,id_Run2+$80,id_Run2+$80 ; angles $60-$6C
		dc.b id_Run+$80,id_Run+$80,id_Run+$80,id_Run+$80 ; angles $70-$7C
		dc.b id_Run+$80,id_Run+$80,id_Run+$80,id_Run+$80 ; angles $80-$8C
		dc.b id_Run4,id_Run4,id_Run4,id_Run4		; angles $90-$9C
		dc.b id_Run4,id_Run4,id_Run4,id_Run4		; angles $A0-$AC
		dc.b id_Run3,id_Run3,id_Run3,id_Run3		; angles $B0-$BC
		dc.b id_Run3,id_Run3,id_Run3,id_Run3		; angles $C0-$CC
		dc.b id_Run2,id_Run2,id_Run2,id_Run2		; angles $D0-$DC
		dc.b id_Run2,id_Run2,id_Run2,id_Run2		; angles $E0-$EC
		dc.b id_Run,id_Run,id_Run,id_Run		; angles $F0-$FC
		even

; ---------------------------------------------------------------------------
; Subroutine to	update the animation id of an object if it changes
;
; input:
;	d0.b = new animation id

; output:
;	d1.b = previous animation id

;	uses d1.l

; usage:
;		move.b	#id_ani_roll_roll,d0
;		bsr.w	NewAnim
; ---------------------------------------------------------------------------

NewAnim:
		moveq	#$7F,d1
		and.b	ost_anim(a0),d1				; get previous animation id without high bit (the no-restart flag)
		cmp.b	d0,d1					; compare with new id
		beq.s	.keepanim				; branch if same
		move.b	d0,ost_anim(a0)				; update animation id (and clear high bit)

	.keepanim:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	run DPLC when an object's animation updates
;
; input:
;	d1.l = destination address (as DMA instruction)
;	a1 = animation script (e.g. ani_crab_stand)

; output:
;	uses d0.w, d1.l, d2.w, a1, a2

; usage:
;		lea	Ani_BigRing(pc),a1
;		bsr.w	AnimateSprite				; update animation
;		set_dma_dest vram_giantring,d1			; set VRAM address to write gfx
;		jsr	DPLCSprite
; ---------------------------------------------------------------------------

DPLCSprite:
		move.w	(a1),d0
		cmp.b	ost_anim_time(a0),d0			; has animation just updated?
		bne.s	.exit					; branch if not
		
		move.w	ost_frame_hi(a0),d0			; get frame number
		movea.l	ost_mappings(a0),a2			; get mappings pointer
		bsr.w	SkipMappings				; jump to data after mappings (where DPLCs are stored)
		tst.w	d0
		beq.s	.exit					; branch if mappings contained 0 pieces (i.e. blank)
		jmp	(AddDMA2).w				; add to DMA queue
		
	.exit:
		rts
