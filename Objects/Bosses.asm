; ---------------------------------------------------------------------------
; Bosses

; spawned by:
;	ObjPos_GHZ3, ObjPos_MZ3

; subtypes:
;	%ITTTTTTT
;	I - 1 to ignore x pos check and boundary changes
;	TTTTTTT - type
; ---------------------------------------------------------------------------

Boss:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Boss_Index(pc,d0.w),d1
		jmp	Boss_Index(pc,d1.w)
; ===========================================================================
Boss_Index:	index *,,2
		ptr Boss_Main
		ptr Boss_Wait
		ptr Boss_Move
		ptr Boss_Explode
		ptr Boss_Drop
		ptr Boss_Recover
		ptr Boss_Escape

		rsobj Boss2
ost_boss2_y_normal:	rs.l 1					; y position without wobble
ost_boss2_time:		rs.w 1					; time until next action
ost_boss2_cam_start:	equ ost_boss2_time			; camera x pos where boss activates
ost_boss2_wobble:	rs.b 1					; wobble counter
ost_boss2_flags:	rs.b 1					; flag bitfield from Boss_MoveList
		rsobjend

Boss_CamXPos:	dc.w $2960					; camera x pos where the boss becomes active
		dc.w $1800
Boss_InitMode:	dc.b (Boss_MoveGHZ-Boss_MoveList)/sizeof_bmove	; initial mode for each boss
		dc.b (Boss_MoveMZ-Boss_MoveList)/sizeof_bmove
		even

bmove:		macro xvel,yvel,time,loadobj,flags,next
		dc.w xvel, yvel, time
		dc.l loadobj
		dc.b flags, next
		endm

bmove_xflip_bit:	equ 0
bmove_laugh_bit:	equ 1
bmove_nowobble_bit:	equ 2
bmove_freezehit_bit:	equ 3
bmove_hazard_bit:	equ 4
bmove_xflip:		equ 1<<bmove_xflip_bit			; boss faces right
bmove_laugh:		equ 1<<bmove_laugh_bit			; boss laughs
bmove_nowobble:		equ 1<<bmove_nowobble_bit		; boss doesn't wobble
bmove_freezehit:	equ 1<<bmove_freezehit_bit		; boss freezes when hit
bmove_hazard:		equ 1<<bmove_hazard_bit			; hazards activate

Boss_MoveList:	; x speed, y speed, duration, object to load, flags, value to add to mode
Boss_MoveGHZ:	bmove 0, $100, $B8, 0, 0, 1
sizeof_bmove:	equ *-Boss_MoveGHZ
		bmove -$100, -$40, $60, 0, 0, 1
		bmove 0, 0, 128, BossBall, bmove_laugh, 1
		bmove -$40, 0, 128, 0, 0, 1
		bmove 0, 0, 63, 0, bmove_xflip, 1
		bmove $100, 0, 63, 0, bmove_xflip, 1
		bmove 0, 0, 63, 0, 0, 1
		bmove -$100, 0, 63, 0, 0, -3

Boss_MoveMZ:	bmove -$100, 0, $E0, BossNozzle, 0, 1
		bmove 0, 0, 15, 0, bmove_nowobble, 1
		bmove -$200, $40, 72, 0, bmove_nowobble+bmove_freezehit+bmove_hazard, 1
		bmove -$200, -$40, 40, 0, bmove_nowobble+bmove_freezehit+bmove_hazard, 1
		bmove 0, -$40, 32, 0, bmove_nowobble, 1
		bmove 0, 0, 80, BossFire, bmove_xflip+bmove_nowobble+bmove_laugh, 1
		bmove $200, $40, 72, 0, bmove_xflip+bmove_nowobble+bmove_freezehit+bmove_hazard, 1
		bmove $200, -$40, 40, 0, bmove_xflip+bmove_nowobble+bmove_freezehit+bmove_hazard, 1
		bmove 0, -$40, 32, 0, bmove_xflip+bmove_nowobble, 1
		bmove 0, 0, 80, BossFire, bmove_nowobble+bmove_laugh, -7
; ===========================================================================

Boss_Main:	; Routine 0
		move.w	a0,(v_boss_ost_ptr).w
		addq.b	#2,ost_routine(a0)			; goto Boss_Wait next
		move.l	#Map_Bosses,ost_mappings(a0)
		move.w	#tile_Art_Eggman,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.b	#StrId_Boss,ost_name(a0)
		move.w	#priority_3,ost_priority(a0)
		move.b	#id_React_Boss,ost_col_type(a0)
		move.b	#24,ost_col_width(a0)
		move.b	#24,ost_col_height(a0)
		move.b	#hitcount_ghz,ost_col_property(a0)	; set number of hits to 8
		move.w	ost_y_pos(a0),ost_boss2_y_normal(a0)
		clr.b	(v_boss_flash).w
		move.b	ost_subtype(a0),d0
		andi.w	#$7F,d0
		lea	Boss_InitMode,a2
		move.b	(a2,d0.w),ost_mode(a0)
		tst.b	ost_subtype(a0)
		bmi.s	.ignore_cam				; branch if high bit of subtype is set
		add.w	d0,d0
		lea	Boss_CamXPos,a2
		move.w	(a2,d0.w),ost_boss2_cam_start(a0)
		play.w	0, jsr, mus_Boss			; play boss music
		move.b	#1,(f_boss_loaded).w			; lock screen
		move.w	(v_camera_x_pos).w,(v_boundary_left).w	; set boundary to current position

	.ignore_cam:
		moveq	#id_UPLC_Boss,d0
		jsr	UncPLC
		jsr	FindNextFreeObj
		bne.s	Boss_Wait
		move.l	#BossExhaust,ost_id(a1)
		saveparent
		jsr	FindNextFreeObj
		bne.s	Boss_Wait
		move.l	#BossCockpit,ost_id(a1)
		saveparent

Boss_Wait:	; Routine 2
		move.w	ost_boss2_cam_start(a0),d0
		cmp.w	(v_camera_x_pos).w,d0
		bls.s	.activate				; branch if camera reaches position
		jmp	DisplaySprite

	.activate:
		tst.b	ost_subtype(a0)
		bmi.s	.keep_boundaries			; branch if high bit of subtype is set
		move.w	(v_camera_x_pos).w,d0
		move.w	d0,(v_boundary_left).w			; set boundary to current position
		move.w	d0,(v_boundary_right).w			; lock screen
		move.w	d0,(v_boundary_right_next).w

	.keep_boundaries:
		addq.b	#2,ost_routine(a0)			; goto Boss_Move next
		bsr.w	Boss_SetMode
		jmp	DisplaySprite

; ===========================================================================

Boss_Move:	; Routine 4
		subq.w	#1,ost_boss2_time(a0)			; decrement timer
		bpl.s	.continue				; branch if time remains
		bsr.w	Boss_SetMode

	.continue:
		move.b	ost_boss2_flags(a0),d2
		btst	#bmove_freezehit_bit,d2
		beq.s	.nofreezehit				; branch if freeze on hit flag isn't set
		cmpi.b	#$18,(v_boss_flash).w
		bcc.s	.skip_wobble				; branch if boss was recently hit

	.nofreezehit:
		update_x_pos
		move.w	ost_y_vel(a0),d0			; load vertical speed
		ext.l	d0
		asl.l	#8,d0					; multiply speed by $100
		add.l	d0,ost_boss2_y_normal(a0)		; update y position

		move.b	ost_boss2_wobble(a0),d0			; get wobble byte
		btst	#bmove_nowobble_bit,d2
		beq.s	.wobble					; branch if wobble is enabled
		move.b	d0,d1
		andi.b	#$7F,d1
		bne.s	.wobble					; continue wobble until it evens out
		move.w	ost_boss2_y_normal(a0),ost_y_pos(a0)	; update y pos
		bra.s	.skip_wobble

	.wobble:
		jsr	(CalcSine).w				; convert to sine
		asr.w	#6,d0					; divide by 64
		add.w	ost_boss2_y_normal(a0),d0		; add y pos
		move.w	d0,ost_y_pos(a0)			; update actual y pos
		addq.b	#2,ost_boss2_wobble(a0)			; increment wobble (wraps to 0 after $FE)

	.skip_wobble:
		tst.b	ost_status(a0)
		bmi.s	.beaten					; branch if boss has been beaten
		tst.b	ost_col_type(a0)
		bne.s	.no_flash				; branch if not flashing
		eori.w	#cWhite,(v_pal_dry_line2+2).w		; toggle black/white on palette line 2 colour 2
		subq.b	#1,(v_boss_flash).w			; decrement flash counter
		bne.s	.no_flash				; branch if not 0
		move.b	#id_React_Boss,ost_col_type(a0)		; enable boss collision again

	.no_flash:
		jmp	DisplaySprite

	.beaten:
		moveq	#100,d0
		jsr	(AddPoints).w				; give Sonic 1000 points
		addq.b	#2,ost_routine(a0)			; goto Boss_Explode next
		move.w	#179,ost_boss2_time(a0)			; set timer to 3 seconds
		move.w	#0,ost_x_vel(a0)
		move.w	#0,ost_y_vel(a0)
		move.b	#0,ost_boss2_flags(a0)
		jmp	DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to load info for and update the boss mode
; ---------------------------------------------------------------------------

Boss_SetMode:
		moveq	#0,d0
		move.b	ost_mode(a0),d0
		mulu.w	#sizeof_bmove,d0
		lea	Boss_MoveList,a2
		adda.l	d0,a2
		move.w	(a2)+,ost_x_vel(a0)
		move.w	(a2)+,ost_y_vel(a0)
		move.w	(a2)+,ost_boss2_time(a0)
		move.l	(a2)+,d1
		beq.s	.skip_object				; branch if no object should be loaded
		jsr	FindNextFreeObj				; find free OST slot
		bne.s	.skip_object				; branch if not found
		move.l	d1,ost_id(a1)				; load object
		saveparent

	.skip_object:
		move.b	(a2)+,d0				; get flags
		bclr	#render_xflip_bit,ost_render(a0)	; assume facing left
		bclr	#status_xflip_bit,ost_status(a0)
		btst	#bmove_xflip_bit,d0
		beq.s	.noflip					; branch if xflip bit isn't set
		bset	#render_xflip_bit,ost_render(a0)	; face right
		bset	#status_xflip_bit,ost_status(a0)

	.noflip:
		move.b	d0,ost_boss2_flags(a0)			; save flags
		move.b	(a2)+,d0
		add.b	d0,ost_mode(a0)				; next mode
		rts
; ===========================================================================

Boss_Explode:	; Routine 6
		subq.w	#1,ost_boss2_time(a0)			; decrement timer
		bmi.s	.done					; branch if time hits -1
		moveq	#0,d0
		moveq	#7,d1
		bsr.w	Exploding				; create explosions every 8th frame
		jmp	DisplaySprite

	.done:
		move.w	#38,ost_boss2_time(a0)			; set timer to 0.6 seconds
		addq.b	#2,ost_routine(a0)			; goto Boss_Drop next
		move.b	#1,(v_boss_status).w			; set boss beaten flag
		bset	#render_xflip_bit,ost_render(a0)	; face right
		bset	#status_xflip_bit,ost_status(a0)

Boss_Drop:	; Routine 8
		subq.w	#1,ost_boss2_time(a0)			; decrement timer
		beq.s	.stop_falling				; branch if timer hits 0
		update_y_fall	$18				; update position & apply gravity
		jmp	DisplaySprite

	.stop_falling:
		clr.w	ost_y_vel(a0)				; stop falling
		move.w	#56,ost_boss2_time(a0)			; set timer to 1 second
		addq.b	#2,ost_routine(a0)			; goto Boss_Recover next

Boss_Recover:	; Routine $A
		subq.w	#1,ost_boss2_time(a0)			; decrement timer
		beq.s	.escape					; branch if timer hits 0
		cmpi.w	#8,ost_boss2_time(a0)
		bls.s	.skip_rising				; branch if timer is <= 8
		update_y_fall	-8				; update position & rise faster

	.skip_rising:
		jmp	DisplaySprite

	.escape:
		addq.b	#2,ost_routine(a0)			; goto Boss_Escape next
		move.b	(v_bgm).w,d0
		jsr	(PlaySound0).w				; play level music
		move.w	#$400,ost_x_vel(a0)			; move ship right
		move.w	#-$40,ost_y_vel(a0)			; move ship upwards

Boss_Escape:	; Routine $C
		addi.w	#$600,(v_boundary_right_next).w		; allow screen to scroll right
		shortcut
		update_xy_pos					; update position
		tst.b	ost_render(a0)
		bpl.s	.delete					; branch if off screen
		jmp	DisplaySprite

	.delete:
		jmp	DeleteFamily				; delete ship, cockpit & flame objects

; ---------------------------------------------------------------------------
; Boss exhaust flame

; spawned by:
;	Boss
; ---------------------------------------------------------------------------

BossExhaust:
		move.l	#Map_Exhaust,ost_mappings(a0)
		move.w	#vram_exhaust/sizeof_cell,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.b	#StrId_Boss,ost_name(a0)
		move.w	#priority_3,ost_priority(a0)
		move.b	#id_ani_exhaust_flame1,ost_anim(a0)

		shortcut
		getparent					; a1 = OST of boss ship
		tst.w	ost_x_vel(a1)
		beq.s	.hide					; branch if boss isn't moving
		tst.b	ost_subtype(a0)
		bne.s	.skip_chk				; branch if escape flag is set
		cmpi.b	#id_Boss_Escape,ost_routine(a1)
		bne.s	.skip_chk				; branch if not escaping
		move.b	#id_ani_exhaust_bigflame,ost_anim(a0)	; use big flame
		move.b	#1,ost_subtype(a0)			; don't check again

	.skip_chk:
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		move.b	ost_status(a1),ost_status(a0)
		move.b	ost_render(a1),ost_render(a0)
		lea	Ani_Exhaust(pc),a1
		jsr	AnimateSprite
		set_dma_dest vram_exhaust,d1			; set VRAM address to write gfx
		jsr	DPLCSprite				; write gfx if frame has changed
		jmp	DisplaySprite

	.hide:
		rts

; ---------------------------------------------------------------------------
; Boss cockpit and Eggman

; spawned by:
;	Boss
; ---------------------------------------------------------------------------

BossCockpit:
		move.l	#Map_Face,ost_mappings(a0)
		move.w	#vram_face/sizeof_cell,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.b	#StrId_Boss,ost_name(a0)
		move.w	#priority_3,ost_priority(a0)

		shortcut
		getparent					; a1 = OST of boss ship
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		move.b	ost_status(a1),ost_status(a0)
		move.b	ost_render(a1),ost_render(a0)
		cmpi.b	#id_Sonic_Hurt,(v_ost_player+ost_routine).w
		bcc.s	.laugh					; branch if Sonic is hit
		btst	#bmove_laugh_bit,ost_boss2_flags(a1)
		bne.s	.laugh					; branch if boss is set to laugh
		cmpi.b	#id_Boss_Explode,ost_routine(a1)
		beq.s	.hit					; branch if boss is exploding
		cmpi.b	#id_Boss_Escape,ost_routine(a1)
		beq.s	.panic					; branch if boss is escaping
		cmpi.b	#id_Boss_Drop,ost_routine(a1)
		bcc.s	.defeat					; branch if boss is dropping/recovering
		tst.b	(v_boss_flash).w
		bne.s	.hit					; branch if boss is flashing
		moveq	#id_ani_face_face1,d0

	.animate:
		set_anim					; update animation if different from last frame
		lea	Ani_Face,a1
		jsr	AnimateSprite
		set_dma_dest vram_face,d1			; set VRAM address to write gfx
		jsr	DPLCSprite				; write gfx if frame has changed
		jmp	DisplaySprite

	.hit:
		moveq	#id_ani_face_hit,d0
		bra.s	.animate

	.laugh:
		moveq	#id_ani_face_laugh,d0
		bra.s	.animate

	.panic:
		moveq	#id_ani_face_panic,d0
		bra.s	.animate

	.defeat:
		moveq	#id_ani_face_defeat,d0
		bra.s	.animate

; ---------------------------------------------------------------------------
; Boss MZ/SLZ nozzles

; spawned by:
;	Boss
; ---------------------------------------------------------------------------

BossNozzle:
		move.l	#Map_BossItems,ost_mappings(a0)
		move.w	#(vram_weapon/sizeof_cell)+tile_pal2,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#StrId_Boss,ost_name(a0)
		move.w	#priority_2,ost_priority(a0)
		move.b	#id_frame_boss_pipe,ost_frame(a0)
		moveq	#id_UPLC_MZPipe,d0
		jsr	UncPLC					; load gfx

		shortcut
		getparent					; a1 = OST of boss ship
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		move.b	ost_status(a1),ost_status(a0)
		move.b	ost_render(a1),ost_render(a0)
		jmp	DisplaySprite
