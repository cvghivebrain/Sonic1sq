; ---------------------------------------------------------------------------
; Object 0D - signpost at the end of a level

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_MZ1, ObjPos_MZ2
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_LZ1, ObjPos_LZ2
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SBZ1, ObjPos_SBZ2
; ---------------------------------------------------------------------------

Signpost:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Sign_Index(pc,d0.w),d1
		jmp	Sign_Index(pc,d1.w)
; ===========================================================================
Sign_Index:	index *,,2
		ptr Sign_Main
		ptr Sign_Touch
		ptr Sign_Spin
		ptr Sign_SonicRun
		ptr Sign_Exit

		rsobj Signpost
ost_sign_spin_time:	rs.w 1					; time for signpost to spin (2 bytes)
ost_sign_sparkle_time:	rs.w 1					; time between sparkles (2 bytes)
ost_sign_sparkle_id:	rs.b 1					; counter to keep track of sparkles
		rsobjend
; ===========================================================================

Sign_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Sign_Touch next
		move.l	#Map_Sign,ost_mappings(a0)
		move.w	#vram_signpost/sizeof_cell,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$18,ost_displaywidth(a0)
		move.b	#4,ost_priority(a0)
		moveq	#id_UPLC_Bonus,d0
		jsr	UncPLC					; load hidden bonus gfx
		lea	Ani_Sign(pc),a1
		bsr.w	AnimateSprite
		set_dma_dest vram_signpost,d1
		jsr	DPLCSprite				; load first frame of gfx

Sign_Touch:	; Routine 2
		getsonic					; a1 = OST of Sonic
		range_x
		cmpi.w	#32,d0					; is Sonic within 32px of right?
		bcc.w	DespawnQuick				; if not, branch

		play.w	0, jsr, sfx_Signpost			; play signpost sound
		clr.b	(f_hud_time_update).w			; stop time counter
		move.w	(v_boundary_right).w,(v_boundary_left).w ; lock screen position
		addq.b	#2,ost_routine(a0)			; goto Sign_Spin next
		bra.w	DespawnQuick
; ===========================================================================

Sign_Spin:	; Routine 4
		subq.w	#1,ost_sign_spin_time(a0)		; decrement spin timer
		bpl.s	.chksparkle				; if time remains, branch
		move.w	#60,ost_sign_spin_time(a0)		; set spin cycle time to 1 second
		addq.b	#1,ost_anim(a0)				; next spin cycle
		bclr	#7,ost_anim(a0)				; restart animation
		cmpi.b	#id_ani_sign_sonic,ost_anim(a0)		; have 3 spin cycles completed?
		bne.s	.chksparkle				; if not, branch
		addq.b	#2,ost_routine(a0)			; goto Sign_SonicRun next

	.chksparkle:
		subq.w	#1,ost_sign_sparkle_time(a0)		; decrement sparkle timer
		bpl.s	.fail					; if time remains, branch
		move.w	#11,ost_sign_sparkle_time(a0)		; set time between sparkles to 12 frames
		moveq	#0,d0
		move.b	ost_sign_sparkle_id(a0),d0		; get sparkle id
		addq.b	#2,ost_sign_sparkle_id(a0)		; increment sparkle counter
		andi.b	#$E,ost_sign_sparkle_id(a0)
		lea	Sign_SparkPos(pc,d0.w),a2		; load sparkle position data
		bsr.w	FindFreeInert				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#Rings,ost_id(a1)			; load rings object
		move.b	#id_Ring_Sparkle,ost_routine(a1)	; jump to ring sparkle subroutine
		move.b	(a2)+,d0				; get relative x position
		ext.w	d0
		add.w	ost_x_pos(a0),d0			; add to signpost x position
		move.w	d0,ost_x_pos(a1)			; update sparkle position
		move.b	(a2)+,d0
		ext.w	d0
		add.w	ost_y_pos(a0),d0
		move.w	d0,ost_y_pos(a1)
		move.l	#Map_Ring,ost_mappings(a1)
		move.w	(v_tile_rings).w,ost_tile(a1)
		add.w	#tile_pal2,ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#2,ost_priority(a1)
		move.b	#8,ost_displaywidth(a1)

	.fail:
		lea	Ani_Sign(pc),a1
		bsr.w	AnimateSprite
		set_dma_dest vram_signpost,d1			; set VRAM address to write gfx
		jsr	DPLCSprite				; write gfx if frame has changed
		bra.w	DespawnQuick
; ===========================================================================
Sign_SparkPos:	; x pos, y pos
		dc.b -$18,-$10
		dc.b	8,   8
		dc.b -$10,   0
		dc.b  $18,  -8
		dc.b	0,  -8
		dc.b  $10,   0
		dc.b -$18,   8
		dc.b  $18, $10
; ===========================================================================

Sign_SonicRun:	; Routine 6
		tst.w	(v_debug_active).w			; is debug mode	on?
		bne.w	DespawnQuick				; if yes, branch
		getsonic					; a1 = OST of Sonic
		btst	#status_air_bit,ost_status(a1)		; is Sonic in the air?
		bne.s	.wait_to_land				; if yes, branch
		move.b	#1,(f_lock_controls).w			; lock controls
		move.w	#btnR<<8,(v_joypad_hold).w		; make Sonic run to the right

	.wait_to_land:
		tst.l	ost_id(a1)				; is Sonic object still loaded?
		beq.s	.skip_boundary_chk			; if not, branch
		move.w	ost_x_pos(a1),d0
		move.w	(v_boundary_right).w,d1
		addi.w	#$128,d1
		cmp.w	d1,d0					; has Sonic passed 296px outside right level boundary?
		bcs.w	DespawnQuick				; if not, branch

	.skip_boundary_chk:
		addq.b	#2,ost_routine(a0)			; goto Sign_Exit next
		bsr.s	HasPassedAct
		bra.w	DespawnQuick
; ===========================================================================

Sign_Exit:	; Routine 8
		shortcut	DespawnQuick
		bra.w	DespawnQuick

; ---------------------------------------------------------------------------
; Subroutine to	set up bonuses at the end of an	act
; ---------------------------------------------------------------------------

HasPassedAct:
		tst.b	(v_haspassed_state).w			; has "Sonic Has Passed" title card loaded?
		bne.s	.exit					; if yes, branch

		move.w	(v_boundary_right).w,(v_boundary_left).w
		clr.w	(v_invincibility).w			; disable invincibility
		clr.b	(f_hud_time_update).w			; stop time counter
		bsr.w	FindFreeInert
		bne.s	.fail
		move.l	#HasPassedCard,ost_id(a1)		; load "Sonic Has Passed" title card
		
	.fail:
		move.b	#1,(f_pass_bonus_update).w
		moveq	#0,d0
		move.b	(v_time_min).w,d0
		mulu.w	#60,d0					; convert minutes to seconds
		moveq	#0,d1
		move.b	(v_time_sec).w,d1
		add.w	d1,d0					; d0 = total seconds
		divu.w	#15,d0					; divide by 15
		moveq	#(WorstTime-TimeBonuses)/2,d1
		cmp.w	d1,d0					; is time 5 minutes or higher?
		bcs.s	.hastimebonus				; if not, branch
		move.w	d1,d0					; use minimum time bonus (0)

	.hastimebonus:
		add.w	d0,d0
		move.w	TimeBonuses(pc,d0.w),(v_time_bonus).w	; set time bonus
		move.w	(v_rings).w,d0				; load number of rings
		mulu.w	#10,d0					; multiply by 10
		move.w	d0,(v_ring_bonus).w			; set ring bonus
		play.w	1, jsr, mus_HasPassed			; play "Sonic Has Passed" music
		
	.exit:
		rts

; ===========================================================================
TimeBonuses:	dc.w   5000
		dc.w   5000					; < 0:30 = 50000
		dc.w   1000					; < 0:45 = 10000
		dc.w    500					; < 1:00 = 5000
		dc.w    400
		dc.w    400					; < 1:30 = 4000
		dc.w    300
		dc.w    300					; < 2:00 = 3000
		dc.w    200
		dc.w    200
		dc.w    200
		dc.w    200					; < 3:00 = 2000
		dc.w    100
		dc.w    100
		dc.w    100
		dc.w    100					; < 4:00 = 1000
		dc.w     50
		dc.w     50
		dc.w     50
		dc.w     50					; < 5:00 = 500
WorstTime:	dc.w      0					; 5:00+ = 0

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Sign:	index *
		ptr ani_sign_eggman
		ptr ani_sign_spin1
		ptr ani_sign_spin2
		ptr ani_sign_sonic
		
ani_sign_eggman:
		dc.w $F
		dc.w id_frame_sign_eggman
		dc.w id_Anim_Flag_Restart

ani_sign_spin1:
		dc.w 1
		dc.w id_frame_sign_eggman
		dc.w id_frame_sign_spin1
		dc.w id_frame_sign_spin2
		dc.w id_frame_sign_spin3
		dc.w id_Anim_Flag_Restart

ani_sign_spin2:
		dc.w 1
		dc.w id_frame_sign_sonic
		dc.w id_frame_sign_spin1
		dc.w id_frame_sign_spin2
		dc.w id_frame_sign_spin3
		dc.w id_Anim_Flag_Restart

ani_sign_sonic:
		dc.w $F
		dc.w id_frame_sign_sonic
		dc.w id_Anim_Flag_Restart
