; ---------------------------------------------------------------------------
; Subroutine to	animate	a sprite using an animation script
;
; input:
;	a1 = animation script index (e.g. Ani_Crab)

; output:
;	a1 = animation script (e.g. ani_crab_stand)

;	uses d0.l, d1.l

; usage:
;		lea	(Ani_Hog).l,a1
;		bsr.w	AnimateSprite
; ---------------------------------------------------------------------------

AnimateSprite:
		moveq	#0,d0
		move.b	ost_anim(a0),d0				; get animation number
		btst	#7,d0					; is animation set to restart?
		bne.s	Anim_Run				; if not, branch

		bset	#7,ost_anim(a0)				; set to "no restart"
		move.b	#0,ost_anim_frame(a0)			; reset animation
		move.b	#0,ost_anim_time(a0)			; reset frame duration

Anim_Run:
		subq.b	#1,ost_anim_time(a0)			; subtract 1 from frame duration
		bpl.s	Anim_Wait				; if time remains, branch
		andi.b	#$7F,d0
		add.w	d0,d0
		adda.w	(a1,d0.w),a1				; jump to appropriate animation	script
		move.b	(a1),ost_anim_time(a0)			; load frame duration
		moveq	#0,d1
		move.b	ost_anim_frame(a0),d1			; load current frame number
		move.b	1(a1,d1.w),d0				; read sprite number from script
		bmi.s	Anim_Flag				; branch if an animation flag is found

Anim_Next:
		move.b	d0,d1					; copy full frame info to d1
		andi.b	#$1F,d0					; sprite number only
		move.b	d0,ost_frame(a0)			; load sprite number
		move.b	ost_status(a0),d0
		rol.b	#3,d1
		eor.b	d0,d1
		andi.b	#status_xflip+status_yflip,d1		; get x/yflip bits in d1
		andi.b	#$FF-render_xflip-render_yflip,ost_render(a0)
		or.b	d1,ost_render(a0)			; apply x/yflip bits from status
		addq.b	#1,ost_anim_frame(a0)			; next frame number

Anim_Wait:
		rts	
; ===========================================================================

Anim_Flag:
		neg.b	d0
		subq.b	#2,d0					; flags start at 2
		move.w	Anim_Flag_Index(pc,d0.w),d0
		jmp	Anim_Flag_Index(pc,d0.w)
; ===========================================================================
Anim_Flag_Index:
		index *,2,2
		ptr Anim_Flag_Restart
		ptr Anim_Flag_Back
		ptr Anim_Flag_Change
		ptr Anim_Flag_Routine
		ptr Anim_Flag_Restart2
		ptr Anim_Flag_Routine2		
; ===========================================================================

Anim_Flag_Restart:
		move.b	#0,ost_anim_frame(a0)			; restart the animation
		move.b	1(a1),d0				; read sprite number
		bra.s	Anim_Next
; ===========================================================================

Anim_Flag_Back:
		move.b	2(a1,d1.w),d0				; read the next	byte in	the script
		sub.b	d0,ost_anim_frame(a0)			; jump back d0 bytes in the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0				; read sprite number
		bra.s	Anim_Next
; ===========================================================================

Anim_Flag_Change:
		move.b	2(a1,d1.w),ost_anim(a0)			; read next byte, run that animation
		rts

Anim_Flag_Routine:
		addq.b	#2,ost_routine(a0)			; jump to next routine
		rts

Anim_Flag_Restart2:						; unused
		move.b	#0,ost_anim_frame(a0)			; reset animation
		clr.b	ost_routine2(a0)			; reset 2nd routine counter
		rts

Anim_Flag_Routine2:						; only used by EndSonic
		addq.b	#2,ost_routine2(a0)			; jump to next routine
		rts

; ---------------------------------------------------------------------------
; Subroutine to	update the animation id of an object if it changes
;
; input:
;	d0.b = new animation id

; output:
;	d1.b = previous animation id

; usage:
;		move.b	#id_ani_roll_roll,d0
;		bsr.w	NewAnim
; ---------------------------------------------------------------------------

NewAnim:
		move.b	ost_anim(a0),d1				; get previous animation id
		andi.b	#$7F,d1					; ignore high bit (the no-restart flag)
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
;		lea	(Ani_BigRing).l,a1
;		bsr.w	AnimateSprite				; update animation
;		set_dma_dest vram_giantring,d1			; set VRAM address to write gfx
;		jsr	DPLCSprite
; ---------------------------------------------------------------------------

DPLCSprite:
		move.b	(a1),d0
		cmp.b	ost_anim_time(a0),d0			; has animation just updated?
		bne.s	.exit					; branch if not
		
		move.w	ost_frame_hi(a0),d0			; get frame number
		movea.l	ost_mappings(a0),a2			; get mappings pointer
		bsr.w	SkipMappings				; jump to data after mappings (where DPLCs are stored)
		tst.w	d0
		beq.s	.exit					; branch if mappings contained 0 pieces (i.e. blank)
		jsr	AddDMA2					; add to DMA queue
		
	.exit:
		rts
