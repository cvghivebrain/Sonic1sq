; ---------------------------------------------------------------------------
; Object 01 - Sonic

; spawned by:
;	GM_Level, GM_Ending, VanishSonic
; ---------------------------------------------------------------------------

SonicPlayer:
		tst.w	(v_debug_active).w			; is debug mode	being used?
		beq.s	Sonic_Normal				; if not, branch
		jmp	(DebugMode).l
; ===========================================================================

Sonic_Normal:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Sonic_Index(pc,d0.w),d1
		jmp	Sonic_Index(pc,d1.w)
; ===========================================================================
Sonic_Index:	index *,,2
		ptr Sonic_Main
		ptr Sonic_Control
		ptr Sonic_Hurt
		ptr Sonic_Death
		ptr Sonic_ResetLevel
; ===========================================================================

Sonic_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Sonic_Control next
		move.b	(v_player1_height).w,ost_height(a0)
		move.b	(v_player1_width).w,ost_width(a0)
		move.l	#Map_Sonic,ost_mappings(a0)
		move.w	#tile_sonic,ost_tile(a0)
		move.b	#priority_2,ost_priority(a0)
		move.b	#$18,ost_displaywidth(a0)
		move.b	#render_rel+render_xshift,ost_render(a0)
		move.w	#sonic_max_speed,(v_sonic_max_speed).w	; Sonic's top speed
		move.w	#sonic_acceleration,(v_sonic_acceleration).w ; Sonic's acceleration
		move.w	#sonic_deceleration,(v_sonic_deceleration).w ; Sonic's deceleration
		move.b	#btnABC,ost_sonic_jumpmask(a0)		; A, B or C jumps
		tst.w	(f_debug_enable).w
		beq.s	Sonic_Control				; branch if debug mode is off
		move.b	#btnC,ost_sonic_jumpmask(a0)		; only C jumps

Sonic_Control:	; Routine 2
		tst.w	(f_debug_enable).w			; is debug cheat enabled?
		beq.s	.no_debug				; if not, branch
		btst	#bitB,(v_joypad_press_actual).w		; is button B pressed?
		beq.s	.no_debug				; if not, branch
		move.w	#1,(v_debug_active).w			; change Sonic into a ring/item
		clr.b	(f_lock_controls).w
		rts
; ===========================================================================

.no_debug:
		tst.b	(f_lock_controls).w			; are controls locked?
		bne.s	.lock					; if yes, branch
		move.w	(v_joypad_hold_actual).w,(v_joypad_hold).w ; enable joypad control

	.lock:
		btst	#0,(v_lock_multi).w			; are controls and position locked?
		bne.s	.lock2					; if yes, branch
		move.b	ost_status(a0),d0
		andi.w	#status_air+status_jump,d0		; read status bits 1 and 2
		move.w	Sonic_Modes(pc,d0.w),d1
		jsr	Sonic_Modes(pc,d1.w)			; controls, physics, update position

	.lock2:
		bsr.s	Sonic_Display				; display sprite, update invincibility/speed shoes
		bsr.w	Sonic_RecordPosition			; save position for invincibility stars
		bsr.w	Sonic_Water				; water physics, drowning, splashes
		move.b	(v_angle_right).w,ost_sonic_angle_right(a0)
		move.b	(v_angle_left).w,ost_sonic_angle_left(a0)
		tst.b	(f_water_tunnel_now).w			; is Sonic in a LZ water tunnel?
		beq.s	.no_tunnel				; if not, branch
		tst.b	ost_anim(a0)				; is Sonic using walking animation?
		bne.s	.no_tunnel				; if not, branch
		move.b	ost_sonic_anim_next(a0),ost_anim(a0)	; update animation

	.no_tunnel:
		bsr.w	Sonic_Animate
		tst.b	(v_lock_multi).w			; is object collision disabled?
		bmi.s	.no_collision				; if yes, branch
		jsr	(ReactToItem).l				; run collisions with enemies or anything that uses ost_col_type

	.no_collision:
		btst	#flags_forceroll_bit,ost_sonic_flags(a0)
		beq.w	Sonic_LoadGfx				; branch if not forced to roll
		bsr.w	Sonic_ChkRoll				; make Sonic roll
		bra.w	Sonic_LoadGfx				; load new gfx when Sonic's frame changes

; ===========================================================================
Sonic_Modes:	index *,,2
		ptr Sonic_Mode_Normal				; status_jump_bit = 0; status_air_bit = 0
		ptr Sonic_Mode_Air				; status_jump_bit = 0; status_air_bit = 1
		ptr Sonic_Mode_Roll				; status_jump_bit = 1; status_air_bit = 0
		ptr Sonic_Mode_Jump				; status_jump_bit = 1; status_air_bit = 1

; ---------------------------------------------------------------------------
; Subroutine to display Sonic and update invincibility/speed shoes
; ---------------------------------------------------------------------------

Sonic_Display:
		move.w	ost_sonic_flash_time(a0),d0		; is Sonic flashing?
		beq.s	.display				; if not, branch
		subq.w	#1,ost_sonic_flash_time(a0)		; decrement timer
		andi.w	#3,d0					; are any of bits 0-2 set?
		beq.s	.chkinvincible				; if not, branch (Sonic is invisible every 8th frame)

	.display:
		jsr	(DisplaySprite).l

	.chkinvincible:
		tst.w	(v_invincibility).w			; does Sonic have invincibility?
		beq.s	.chkshoes				; if not, branch
		subq.w	#1,(v_invincibility).w			; decrement timer
		bne.s	.chkshoes				; if not 0, branch
		tst.b	(f_boss_loaded).w
		bne.s	.chkshoes				; branch if at a boss
		cmpi.b	#air_alert,(v_air).w			; is air < $C?
		bcs.s	.chkshoes				; if yes, branch
		move.b	(v_bgm).w,d0
		jsr	(PlaySound0).w				; play normal music

	.chkshoes:
		tst.w	(v_shoes).w				; does Sonic have speed	shoes?
		beq.s	.exit					; if not, branch
		subq.w	#1,(v_shoes).w				; decrement timer
		bne.s	.exit					; branch if time remains
		move.w	#sonic_max_speed,(v_sonic_max_speed).w	; restore Sonic's speed
		move.w	#sonic_acceleration,(v_sonic_acceleration).w ; restore Sonic's acceleration
		move.w	#sonic_deceleration,(v_sonic_deceleration).w ; restore Sonic's deceleration
		play.w	0, jmp, cmd_Slowdown			; run music at normal speed

	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	record Sonic's previous positions for invincibility stars
; ---------------------------------------------------------------------------

Sonic_RecordPosition:
		move.w	(v_sonic_pos_tracker_num).w,d0
		lea	(v_sonic_pos_tracker).w,a1		; address to record data to
		lea	(a1,d0.w),a1				; jump to current index
		move.w	ost_x_pos(a0),(a1)+			; save x/y position
		move.w	ost_y_pos(a0),(a1)+
		addq.b	#4,(v_sonic_pos_tracker_num_low).w	; next index (wraps to 0 after $FC)
		rts

; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

Sonic_Water:
		tst.b	(f_water_enable).w
		bne.s	.waterok				; branch if water is enabled

	.exit:
		rts
; ===========================================================================

	.waterok:
		move.w	(v_water_height_actual).w,d0
		cmp.w	ost_y_pos(a0),d0			; is Sonic above the water?
		bge.s	.abovewater				; if yes, branch
		bset	#status_underwater_bit,ost_status(a0)	; set underwater flag in status
		bne.s	.exit					; branch if already set

		bsr.w	ResumeMusic

	.fail:
		move.w	#sonic_max_speed_water,(v_sonic_max_speed).w ; change Sonic's top speed
		move.w	#sonic_acceleration_water,(v_sonic_acceleration).w ; change Sonic's acceleration
		move.w	#sonic_deceleration_water,(v_sonic_deceleration).w ; change Sonic's deceleration
		asr	ost_x_vel(a0)
		asr	ost_y_vel(a0)
		asr	ost_y_vel(a0)				; slow Sonic
		beq.s	.exit					; branch if Sonic stops moving
		tst.b	(f_splash).w
		bne.s	.exit					; branch if splash is already loaded
		bsr.w	FindFreeInert
		bne.s	.fail2
		move.l	#Splash,ost_id(a1)			; load splash object
		move.b	#1,(f_splash).w

	.fail2:
		play.w	1, jmp, sfx_Splash			; play splash sound
; ===========================================================================

.abovewater:
		bclr	#status_underwater_bit,ost_status(a0)	; clear underwater flag in status
		beq.s	.exit					; branch if already clear

		bsr.w	ResumeMusic
		move.w	#sonic_max_speed,(v_sonic_max_speed).w	; restore Sonic's speed
		move.w	#sonic_acceleration,(v_sonic_acceleration).w ; restore Sonic's acceleration
		move.w	#sonic_deceleration,(v_sonic_deceleration).w ; restore Sonic's deceleration
		asl	ost_y_vel(a0)
		beq.w	.exit
		tst.b	(f_splash).w
		bne.w	.exit					; branch if splash is already loaded
		bsr.w	FindFreeInert
		bne.s	.fail3
		move.l	#Splash,ost_id(a1)			; load splash object
		move.b	#1,(f_splash).w

	.fail3:
		cmpi.w	#-sonic_max_speed_surface,ost_y_vel(a0)
		bgt.s	.belowmaxspeed
		move.w	#-sonic_max_speed_surface,ost_y_vel(a0)	; set maximum speed on leaving water

	.belowmaxspeed:
		play.w	1, jmp, sfx_Splash			; play splash sound

; ---------------------------------------------------------------------------
; Modes	for controlling	Sonic
; ---------------------------------------------------------------------------

Sonic_Mode_Normal:
		bsr.w	Sonic_Jump
		bsr.w	Sonic_SlopeResist
		bsr.w	Sonic_Move
		bsr.w	Sonic_Roll
		bsr.w	Sonic_LevelBound
		update_xy_pos
		bsr.w	Sonic_AnglePos
		bra.w	Sonic_SlopeRepel
; ===========================================================================

Sonic_Mode_Air:
		cmpi.w	#-$FC0,ost_y_vel(a0)
		bge.s	.below_max
		move.w	#-$FC0,ost_y_vel(a0)			; cap upward speed

	.below_max:
		bsr.w	Sonic_JumpDirection
		bsr.w	Sonic_LevelBound
		update_xy_fall					; update position & apply gravity
		btst	#status_underwater_bit,ost_status(a0)	; is Sonic underwater?
		beq.s	.notwater				; if not, branch
		subi.w	#sonic_buoyancy,ost_y_vel(a0)		; apply upward force

	.notwater:
		bsr.w	Sonic_JumpAngle
		bra.w	Sonic_JumpCollision
; ===========================================================================

Sonic_Mode_Roll:
		bsr.w	Sonic_Jump
		bsr.w	Sonic_RollRepel
		bsr.w	Sonic_RollSpeed
		bsr.w	Sonic_LevelBound
		update_xy_pos
		bsr.w	Sonic_AnglePos
		bra.w	Sonic_SlopeRepel
; ===========================================================================

Sonic_Mode_Jump:
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_JumpDirection
		bsr.w	Sonic_LevelBound
		update_xy_fall					; update position & apply gravity
		btst	#status_underwater_bit,ost_status(a0)	; is Sonic underwater?
		beq.w	Sonic_JumpCollision			; if not, branch
		subi.w	#sonic_buoyancy,ost_y_vel(a0)		; apply upward force
		;bsr.w	Sonic_JumpAngle
		bra.w	Sonic_JumpCollision

; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk/run
; ---------------------------------------------------------------------------

Sonic_Move:
		move.w	(v_sonic_max_speed).w,d6
		move.w	(v_sonic_acceleration).w,d5
		move.w	(v_sonic_deceleration).w,d4
		btst	#flags_jumponly_bit,ost_sonic_flags(a0)
		bne.w	Sonic_InertiaLR				; branch if d-pad is disabled
		tst.w	ost_sonic_lock_time(a0)			; are controls locked?
		bne.w	Sonic_ResetScr				; if yes, branch
		btst	#bitL,(v_joypad_hold).w			; is left being pressed?
		beq.s	.notleft				; if not, branch
		bsr.w	Sonic_MoveLeft

	.notleft:
		btst	#bitR,(v_joypad_hold).w			; is right being pressed?
		beq.s	.notright				; if not, branch
		bsr.w	Sonic_MoveRight

	.notright:
		move.b	ost_angle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0					; is Sonic on a	slope?
		bne.w	Sonic_ResetScr				; if yes, branch
		tst.w	ost_inertia(a0)				; is Sonic moving?
		bne.w	Sonic_ResetScr				; if yes, branch
		bclr	#status_pushing_bit,ost_status(a0)
		move.b	#id_Wait,ost_anim(a0)			; use "standing" animation
		btst	#status_platform_bit,ost_status(a0)	; is Sonic on a platform?
		beq.s	Sonic_Balance				; if not, branch

		movea.w	ost_sonic_on_obj(a0),a1			; get OST of platform or object
		tst.b	ost_status(a1)				; has object been broken?
		bmi.s	Sonic_LookUp				; if yes, branch

		moveq	#0,d1
		move.b	ost_displaywidth(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2					; d2 = width of platform -4
		add.w	ost_x_pos(a0),d1
		sub.w	ost_x_pos(a1),d1			; d1 = Sonic's position - object's position + half object's width
		cmpi.w	#4,d1					; is Sonic within 4px of left edge?
		blt.s	Sonic_BalLeft				; if yes, branch
		cmp.w	d2,d1					; is Sonic within 4px of right edge?
		bge.s	Sonic_BalRight				; if yes, branch
		bra.s	Sonic_LookUp
; ===========================================================================

Sonic_Balance:
		getpos_bottom					; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		jsr	FloorDist
		cmpi.w	#$C,d5
		blt.s	Sonic_LookUp				; branch if drop is not found
		cmpi.b	#3,ost_sonic_angle_right(a0)		; check for edge to the right
		bne.s	Sonic_BalLeftChk			; branch if not found

	Sonic_BalRight:
		bclr	#status_xflip_bit,ost_status(a0)
		move.b	#id_Balance,ost_anim(a0)		; use "balancing" animation
		bra.s	Sonic_ResetScr
; ===========================================================================

	Sonic_BalLeftChk:
		cmpi.b	#3,ost_sonic_angle_left(a0)		; check for edge to the left
		bne.s	Sonic_LookUp				; branch if not found

	Sonic_BalLeft:
		bset	#status_xflip_bit,ost_status(a0)
		move.b	#id_Balance,ost_anim(a0)		; use "balancing" animation
		bra.s	Sonic_ResetScr
; ===========================================================================

Sonic_LookUp:
		btst	#bitUp,(v_joypad_hold).w		; is up being pressed?
		beq.s	Sonic_Duck				; if not, branch
		move.b	#id_LookUp,ost_anim(a0)			; use "looking up" animation
		cmpi.w	#camera_y_shift_up,(v_camera_y_shift).w	; $C8
		beq.s	Sonic_ScrOk				; branch if screen is at max y scroll
		addq.w	#2,(v_camera_y_shift).w			; scroll up 2px
		bra.s	Sonic_ScrOk
; ===========================================================================

Sonic_Duck:
		btst	#bitDn,(v_joypad_hold).w		; is down being pressed?
		beq.s	Sonic_ResetScr				; if not, branch
		move.b	#id_Duck,ost_anim(a0)			; use "ducking" animation
		cmpi.w	#camera_y_shift_down,(v_camera_y_shift).w ; 8
		beq.s	Sonic_ScrOk				; branch if screen is at min y scroll
		subq.w	#2,(v_camera_y_shift).w			; scroll down 2px
		bra.s	Sonic_ScrOk
; ===========================================================================

Sonic_ResetScr:
		cmpi.w	#camera_y_shift_default,(v_camera_y_shift).w ; is screen in its default position? ($60)
		beq.s	Sonic_ScrOk				; if yes, branch
		bcc.s	Sonic_HighScr				; branch if screen is higher
		addq.w	#4,(v_camera_y_shift).w			; move screen back 4px to default (actually 2px because of next line)

	Sonic_HighScr:
		subq.w	#2,(v_camera_y_shift).w			; move screen back 2px to default

	Sonic_ScrOk:

Sonic_Inertia:
		move.b	(v_joypad_hold).w,d0
		andi.b	#btnL+btnR,d0				; is left/right	pressed?
		bne.s	Sonic_InertiaLR				; if yes, branch
		move.w	ost_inertia(a0),d0			; get Sonic's inertia
		beq.s	Sonic_InertiaLR				; if 0, branch
		bmi.s	.inertia_neg				; if negative, branch
		sub.w	d5,d0					; subtract acceleration
		bcc.s	.inertia_not_0				; branch if inertia is larger
		moveq	#0,d0

	.inertia_not_0:
		move.w	d0,ost_inertia(a0)			; update inertia
		bra.s	Sonic_InertiaLR
; ===========================================================================

	.inertia_neg:
		add.w	d5,d0
		bcc.s	.inertia_not_0_
		moveq	#0,d0

	.inertia_not_0_:
		move.w	d0,ost_inertia(a0)			; update inertia

Sonic_InertiaLR:
		move.b	ost_angle(a0),d0
		jsr	(CalcSine).w
		muls.w	ost_inertia(a0),d1
		asr.l	#8,d1
		move.w	d1,ost_x_vel(a0)
		muls.w	ost_inertia(a0),d0
		asr.l	#8,d0
		move.w	d0,ost_y_vel(a0)

Sonic_StopAtWall:
		move.b	ost_angle(a0),d3
		move.b	d3,d4
		addi.b	#$40,d3					; d3 = angle with clockwise 90-degree rotation
		bmi.w	.exit					; branch if angle was $40-$BF (upper semicircle of angles)
		tst.w	ost_inertia(a0)
		beq.w	.exit					; branch if inertia is 0
		bmi.s	.neginertia				; branch if negative
		subi.b	#$80,d3					; d3 = angle with anticlockwise 90-degree rotation

	.neginertia:
		move.l	ost_x_pos(a0),d0
		move.l	ost_y_pos(a0),d1
		move.w	ost_x_vel(a0),d2
		ext.l	d2
		asl.l	#8,d2
		add.l	d2,d0					; d0 = predicted x pos. at next frame
		move.w	ost_y_vel(a0),d2
		ext.l	d2
		asl.l	#8,d2
		add.l	d2,d1					; d1 = predicted y pos. at next frame
		swap	d1
		swap	d0
		moveq	#1,d6
		
		addi.b	#$20,d3
		andi.b	#$C0,d3
		beq.s	.wall_below				; branch if wall is below
		cmpi.b	#$80,d3
		beq.s	.wall_above				; branch if wall is above
		tst.b	d4
		bne.s	.notflat				; branch if floor isn't perfectly flat
		addq.w	#8,d1					; lower detection hotspot
		btst	#status_jump_bit,ost_status(a0)
		beq.s	.notflat				; branch if not rolling
		subq.w	#5,d1					; not so low when rolling
		
	.notflat:
		cmpi.b	#$40,d3
		beq.s	.wall_left				; branch if wall is left

	.wall_right:
		addi.w	#sonic_average_radius,d0
		jsr	WallRightDist
		tst.w	d5
		bpl.s	.exit					; branch if no wall found
		asl.w	#8,d5
		add.w	d5,ost_x_vel(a0)
		bset	#status_pushing_bit,ost_status(a0)	; start pushing when Sonic hits a wall
		clr.w	ost_inertia(a0)				; stop Sonic moving
		rts
; ===========================================================================

	.wall_above:
		subi.w	#sonic_average_radius,d1
		jsr	CeilingDist
		tst.w	d5
		bpl.s	.exit					; branch if no wall found
		asl.w	#8,d5
		sub.w	d5,ost_y_vel(a0)
		rts
; ===========================================================================

	.wall_left:
		subi.w	#sonic_average_radius,d0
		jsr	WallLeftDist
		tst.w	d5
		bpl.s	.exit					; branch if no wall found
		asl.w	#8,d5
		sub.w	d5,ost_x_vel(a0)
		bset	#status_pushing_bit,ost_status(a0)
		clr.w	ost_inertia(a0)
		rts
; ===========================================================================

	.wall_below:
		addi.w	#sonic_average_radius,d1
		jsr	FloorDist
		tst.w	d5
		bpl.s	.exit					; branch if no wall found
		asl.w	#8,d5
		add.w	d5,ost_y_vel(a0)

.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk to the left
; ---------------------------------------------------------------------------

Sonic_MoveLeft:
		move.w	ost_inertia(a0),d0
		beq.s	.inertia0				; branch if inertia is 0
		bpl.s	.inertia_pos				; branch if inertia is positive

	.inertia0:
		bset	#status_xflip_bit,ost_status(a0)	; make Sonic face left
		bne.s	.alreadyleft				; branch if already facing left
		bclr	#status_pushing_bit,ost_status(a0)
		move.b	#id_Run,ost_sonic_anim_next(a0)		; restart animation

	.alreadyleft:
		sub.w	d5,d0					; d0 = inertia minus acceleration
		move.w	d6,d1					; d1 = max speed
		neg.w	d1					; negative for left direction
		cmp.w	d1,d0
		bgt.s	.below_max				; branch if Sonic is moving below max speed
		move.w	d1,d0					; apply speed limit

	.below_max:
		move.w	d0,ost_inertia(a0)
		move.b	#id_Walk,ost_anim(a0)			; use walking animation
		rts
; ===========================================================================

.inertia_pos:
		sub.w	d4,d0					; d0 = inertia minus deceleration
		bcc.s	.inertia_pos_				; branch if inertia is still positive
		moveq	#-$80,d0

	.inertia_pos_:
		move.w	d0,ost_inertia(a0)
		move.b	ost_angle(a0),d1
		addi.b	#$20,d1
		andi.b	#$C0,d1
		bne.s	.exit					; branch if Sonic is running on a wall or ceiling
		cmpi.w	#$400,d0
		blt.s	.exit
		move.b	#id_Stop,ost_anim(a0)			; use "stopping" animation
		bclr	#status_xflip_bit,ost_status(a0)	; make Sonic face right
		play.w	1, jmp, sfx_Skid			; play stopping sound

	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk to the right
; ---------------------------------------------------------------------------

Sonic_MoveRight:
		move.w	ost_inertia(a0),d0
		bmi.s	.inertia_neg				; branch if inertia is negative
		bclr	#status_xflip_bit,ost_status(a0)	; make Sonic face right
		beq.s	.alreadyright				; branch if already facing right
		bclr	#status_pushing_bit,ost_status(a0)
		move.b	#id_Run,ost_sonic_anim_next(a0)		; restart animation

	.alreadyright:
		add.w	d5,d0					; d0 = inertia plus acceleration
		cmp.w	d6,d0
		blt.s	.below_max				; branch if Sonic is moving below max speed
		move.w	d6,d0					; apply speed limit

	.below_max:
		move.w	d0,ost_inertia(a0)
		move.b	#id_Walk,ost_anim(a0)			; use walking animation
		rts
; ===========================================================================

.inertia_neg:
		add.w	d4,d0					; d0 = inertia plus deceleration
		bcc.s	.inertia_neg_				; branch if inertia is still negative
		move.w	#$80,d0

	.inertia_neg_:
		move.w	d0,ost_inertia(a0)
		move.b	ost_angle(a0),d1
		addi.b	#$20,d1
		andi.b	#$C0,d1
		bne.s	.exit					; branch if Sonic is running on a wall or ceiling
		cmpi.w	#-$400,d0
		bgt.s	.exit
		move.b	#id_Stop,ost_anim(a0)			; use "stopping" animation
		bset	#status_xflip_bit,ost_status(a0)	; make Sonic face left
		play.w	1, jmp, sfx_Skid			; play stopping sound

	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	update Sonic's speed as he rolls
; ---------------------------------------------------------------------------

Sonic_RollSpeed:
		move.w	(v_sonic_max_speed).w,d6
		asl.w	#1,d6
		move.w	(v_sonic_acceleration).w,d5
		asr.w	#1,d5
		move.w	(v_sonic_deceleration).w,d4
		asr.w	#2,d4
		btst	#flags_jumponly_bit,ost_sonic_flags(a0)	; are controls except jump locked?
		bne.w	.update_speed				; if yes, branch
		tst.w	ost_sonic_lock_time(a0)			; are controls temporarily locked?
		bne.s	.notright				; is yes, branch

		btst	#bitL,(v_joypad_hold).w			; is left being pressed?
		beq.s	.notleft				; if not, branch
		bsr.w	Sonic_RollLeft

	.notleft:
		btst	#bitR,(v_joypad_hold).w			; is right being pressed?
		beq.s	.notright				; if not, branch
		bsr.w	Sonic_RollRight

	.notright:
		move.w	ost_inertia(a0),d0
		beq.s	.chk_stop				; branch if inertia is 0
		bmi.s	.inertia_neg				; branch if inertia is negative

		sub.w	d5,d0					; d0 = inertia minus acceleration
		bcc.s	.inertia_pos				; branch if inertia is still positive
		moveq	#0,d0

	.inertia_pos:
		move.w	d0,ost_inertia(a0)
		bra.s	.chk_stop
; ===========================================================================

.inertia_neg:
		add.w	d5,d0					; d0 = inertia plus acceleration
		bcc.s	.inertia_neg_				; branch if inertia is still negative
		moveq	#0,d0

	.inertia_neg_:
		move.w	d0,ost_inertia(a0)			; update inertia

.chk_stop:
		tst.w	ost_inertia(a0)				; is Sonic moving?
		bne.s	.update_speed				; if yes, branch
		bclr	#status_jump_bit,ost_status(a0)
		move.b	(v_player1_height).w,ost_height(a0)
		move.b	(v_player1_width).w,ost_width(a0)
		move.b	#id_Wait,ost_anim(a0)			; use "standing" animation
		move.w	(v_player1_height_diff).w,d0
		sub.w	d0,ost_y_pos(a0)

.update_speed:
		move.b	ost_angle(a0),d0
		jsr	(CalcSine).w				; convert angle to sine/cosine
		muls.w	ost_inertia(a0),d0
		asr.l	#8,d0
		move.w	d0,ost_y_vel(a0)			; update y speed
		muls.w	ost_inertia(a0),d1
		asr.l	#8,d1
		cmpi.w	#sonic_max_speed_roll,d1		; is Sonic rolling at max speed?
		ble.s	.below_max				; if not, branch
		move.w	#sonic_max_speed_roll,d1		; set max

	.below_max:
		cmpi.w	#-sonic_max_speed_roll,d1
		bge.s	.below_max_
		move.w	#-sonic_max_speed_roll,d1

	.below_max_:
		move.w	d1,ost_x_vel(a0)			; update x speed
		bra.w	Sonic_StopAtWall

; ---------------------------------------------------------------------------
; Subroutine to	update Sonic's speed when rolling and moving left
; ---------------------------------------------------------------------------

Sonic_RollLeft:
		move.w	ost_inertia(a0),d0
		beq.s	.no_change				; branch if inertia is 0
		bpl.s	.inertia_pos				; branch if inertia is positive

	.no_change:
		bset	#status_xflip_bit,ost_status(a0)	; face Sonic left
		move.b	#id_Roll,ost_anim(a0)			; use "rolling" animation
		rts
; ===========================================================================

.inertia_pos:
		sub.w	d4,d0					; d0 = inertia minus deceleration
		bcc.s	.inertia_pos_				; branch if inertia is still positive
		moveq	#-$80,d0

	.inertia_pos_:
		move.w	d0,ost_inertia(a0)			; update inertia
		rts

; ---------------------------------------------------------------------------
; Subroutine to	update Sonic's speed when rolling and moving right
; ---------------------------------------------------------------------------

Sonic_RollRight:
		move.w	ost_inertia(a0),d0
		bmi.s	.inertia_neg				; branch if inertia is negative

		bclr	#status_xflip_bit,ost_status(a0)	; face Sonic left
		move.b	#id_Roll,ost_anim(a0)			; use "rolling" animation
		rts
; ===========================================================================

.inertia_neg:
		add.w	d4,d0					; d0 = inertia plus deceleration
		bcc.s	.inertia_neg_				; branch if inertia is still negative
		move.w	#$80,d0

	.inertia_neg_:
		move.w	d0,ost_inertia(a0)			; update inertia
		rts

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's direction while jumping
; ---------------------------------------------------------------------------

Sonic_JumpDirection:
		move.w	(v_sonic_max_speed).w,d6
		move.w	(v_sonic_acceleration).w,d5
		asl.w	#1,d5
		btst	#status_rolljump_bit,ost_status(a0)	; is Sonic jumping while rolling?
		bne.s	.chk_camera				; if yes, branch

		move.w	ost_x_vel(a0),d0
		btst	#bitL,(v_joypad_hold).w			; is left being pressed?
		beq.s	.not_left				; if not, branch

		bset	#status_xflip_bit,ost_status(a0)	; face Sonic left
		sub.w	d5,d0					; d0 = speed minus acceleration
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0					; does new speed exceed max?
		bgt.s	.not_left				; if not, branch
		move.w	d1,d0					; set max speed

	.not_left:
		btst	#bitR,(v_joypad_hold).w			; is right being pressed?
		beq.s	.update_speed				; if not, branch

		bclr	#status_xflip_bit,ost_status(a0)	; face Sonic right
		add.w	d5,d0					; d0 = speed plus acceleration
		cmp.w	d6,d0					; does new speed exceed max?
		blt.s	.update_speed				; if not, branch
		move.w	d6,d0					; set max speed

	.update_speed:
		move.w	d0,ost_x_vel(a0)			; update x speed

.chk_camera:
		cmpi.w	#camera_y_shift_default,(v_camera_y_shift).w ; is the screen in its default position? ($60)
		beq.s	.camera_ok				; if yes, branch
		bcc.s	.camera_high				; branch if higher
		addq.w	#4,(v_camera_y_shift).w

	.camera_high:
		subq.w	#2,(v_camera_y_shift).w			; move camera back 2px

	.camera_ok:
		cmpi.w	#-$400,ost_y_vel(a0)			; is Sonic moving faster than -$400 upwards?
		bcs.s	.exit					; if yes, branch
		move.w	ost_x_vel(a0),d0
		move.w	d0,d1
		asr.w	#5,d1					; d1 = x speed / 32
		beq.s	.exit					; branch if 0
		bmi.s	.moving_left				; branch if moving left
		sub.w	d1,d0					; subtract d1 from x speed
		bcc.s	.speed_pos
		moveq	#0,d0

	.speed_pos:
		move.w	d0,ost_x_vel(a0)			; apply air drag
		rts
; ===========================================================================

.moving_left:
		sub.w	d1,d0					; subtract d1 from x speed
		bcs.s	.speed_neg
		moveq	#0,d0

	.speed_neg:
		move.w	d0,ost_x_vel(a0)			; apply air drag

.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	prevent	Sonic leaving the boundaries of	a level
; ---------------------------------------------------------------------------

Sonic_LevelBound:
		move.l	ost_x_pos(a0),d1			; get x pos including subpixel
		move.w	ost_x_vel(a0),d0
		ext.l	d0
		asl.l	#8,d0					; d0 = x speed * $100
		add.l	d0,d1					; add d0 to x pos
		swap	d1					; d1 = updated x pos
		move.w	(v_boundary_left).w,d0
		addi.w	#16,d0
		cmp.w	d1,d0					; has Sonic touched the	left boundary?
		bhi.s	.sides					; if yes, branch
		move.w	(v_boundary_right).w,d0
		addi.w	#296,d0
		tst.b	(f_boss_loaded).w			; is screen locked at boss?
		bne.s	.screenlocked				; if yes, branch
		addi.w	#64,d0

	.screenlocked:
		cmp.w	d1,d0					; has Sonic touched the	right boundary?
		bls.s	.sides					; if yes, branch

	.chkbottom:
		move.w	(v_boundary_bottom_next).w,d0
                cmp.w   (v_boundary_bottom).w,d0
                bcc.s   .use_next_boundary		        ; branch if screen is moving down to next boundary
                move.w  (v_boundary_bottom).w,d0		; use actual boundary instead
		
	.use_next_boundary:
		addi.w	#screen_height,d0
		cmp.w	ost_y_pos(a0),d0			; has Sonic touched the bottom boundary?
		blt.s	.bottom					; if yes, branch
		rts
; ===========================================================================

.bottom:
		cmpi.w	#id_SBZ_act2,(v_zone).w			; is level SBZ2 ?
		bne.s	.kill					; if not, kill Sonic
		cmpi.w	#$2000,(v_ost_player+ost_x_pos).w	; has Sonic reached $2000 on x axis?
		bcs.s	.kill					; if not, kill Sonic
		clr.b	(v_last_lamppost).w			; clear	lamppost counter
		move.w	#1,(f_restart).w			; restart the level
		move.w	#id_SBZ_act3,(v_zone).w			; set level to SBZ3 (LZ4)
		rts

.kill:
		jmp	SelfKillSonic
; ===========================================================================

.sides:
		move.w	d0,ost_x_pos(a0)			; align to boundary
		moveq	#0,d0
		move.w	d0,ost_x_sub(a0)
		move.w	d0,ost_x_vel(a0)			; stop Sonic moving
		move.w	d0,ost_inertia(a0)
		bra.s	.chkbottom

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to roll when he's moving
; ---------------------------------------------------------------------------

Sonic_Roll:
		btst	#flags_jumponly_bit,ost_sonic_flags(a0)
		bne.s	.noroll					; branch if controls except jump are locked
		move.b	(v_joypad_hold).w,d0
		btst	#bitDn,d0
		beq.s	.noroll					; branch if down isn't pressed
		andi.b	#btnL+btnR,d0
		bne.s	.noroll					; branch if left/right is pressed
		mvabs.w	ost_inertia(a0),d0			; get inertia (absolute +ve)
		cmpi.w	#sonic_min_speed_roll,d0
		bhi.s	Sonic_ChkRoll				; branch if Sonic is moving at roll threshold speed
		move.b	#id_Duck,ost_anim(a0)			; use ducking animation

	.noroll:
		rts
; ===========================================================================

Sonic_ChkRoll:
		btst	#status_jump_bit,ost_status(a0)		; is Sonic already rolling or jumping?
		beq.s	.roll					; if not, branch
		rts
; ===========================================================================

.roll:
		bset	#status_jump_bit,ost_status(a0)		; set rolling/jumping flag
		move.b	(v_player1_height_roll).w,ost_height(a0)
		move.b	(v_player1_width_roll).w,ost_width(a0)
		move.b	#id_Roll,ost_anim(a0)			; use "rolling" animation
		move.w	(v_player1_height_diff).w,d0
		add.w	d0,ost_y_pos(a0)
		play.w	1, jsr, sfx_Roll			; play rolling sound
		tst.w	ost_inertia(a0)
		bne.s	.ismoving
		move.w	#$200,ost_inertia(a0)			; set inertia if 0

	.ismoving:
		rts

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

Sonic_Jump:
		move.b	(v_joypad_press).w,d0
		and.b	ost_sonic_jumpmask(a0),d0		; is A, B or C pressed?
		beq.w	.exit					; if not, branch
		move.b	ost_angle(a0),d0			; get floor angle
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	.chkceiling				; branch if on ground
		cmpi.b	#$40,d0
		beq.w	.chkwallright				; branch if on left wall
		cmpi.b	#$C0,d0
		beq.w	.chkwallleft				; branch if on right wall
		
	.chkfloor:
		getpos_bottomleft
		moveq	#1,d6
		jsr	FloorDist				; get distance to floor
		cmpi.w	#6,d5
		blt.w	.exit					; branch if floor is within 6px
		getpos_bottomright
		moveq	#1,d6
		jsr	FloorDist
		cmpi.w	#6,d5
		blt.w	.exit
		bra.w	.jump_ok
		
	.chkceiling:
		getpos_topleft
		moveq	#1,d6
		jsr	CeilingDist				; get distance to ceiling
		cmpi.w	#6,d5
		blt.w	.exit					; branch if ceiling is within 6px
		getpos_topright
		moveq	#1,d6
		jsr	CeilingDist
		cmpi.w	#6,d5
		blt.w	.exit
		bra.w	.jump_ok
		
	.chkwallright:
		moveq	#0,d0
		move.b	ost_height(a0),d0
		add.w	ost_x_pos(a0),d0
		moveq	#0,d1
		move.b	ost_width(a0),d1
		neg.w	d1
		add.w	ost_y_pos(a0),d1
		moveq	#1,d6
		jsr	WallRightDist				; get distance to wall
		cmpi.w	#6,d5
		blt.w	.exit					; branch if wall is within 6px
		moveq	#0,d0
		move.b	ost_height(a0),d0
		add.w	ost_x_pos(a0),d0
		moveq	#0,d1
		move.b	ost_width(a0),d1
		add.w	ost_y_pos(a0),d1
		moveq	#1,d6
		jsr	WallRightDist
		cmpi.w	#6,d5
		blt.w	.exit
		bra.s	.jump_ok
		
	.chkwallleft:
		moveq	#0,d0
		move.b	ost_height(a0),d0
		neg.w	d0
		add.w	ost_x_pos(a0),d0
		moveq	#0,d1
		move.b	ost_width(a0),d1
		neg.w	d1
		add.w	ost_y_pos(a0),d1
		moveq	#1,d6
		jsr	WallLeftDist				; get distance to wall
		cmpi.w	#6,d5
		blt.w	.exit					; branch if wall is within 6px
		moveq	#0,d0
		move.b	ost_height(a0),d0
		neg.w	d0
		add.w	ost_x_pos(a0),d0
		moveq	#0,d1
		move.b	ost_width(a0),d1
		add.w	ost_y_pos(a0),d1
		moveq	#1,d6
		jsr	WallLeftDist
		cmpi.w	#6,d5
		blt.w	.exit
		
	.jump_ok:
		move.w	#sonic_jump_power,d2			; jump strength
		btst	#status_underwater_bit,ost_status(a0)	; is Sonic underwater?
		beq.s	.not_underwater				; if not, branch
		move.w	#sonic_jump_power_water,d2		; underwater jump strength

	.not_underwater:
		move.b	ost_angle(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).w
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,ost_x_vel(a0)			; make Sonic jump
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,ost_y_vel(a0)			; make Sonic jump
		bset	#status_air_bit,ost_status(a0)
		bclr	#status_pushing_bit,ost_status(a0)
		addq.l	#4,sp					; return to earlier position in Sonic_Control
		bclr	#flags_stuck_bit,ost_sonic_flags(a0)
		play.w	1, jsr, sfx_Jump			; play jumping sound
		bset	#status_jump_bit,ost_status(a0)
		bne.s	.is_rolling				; branch if Sonic was rolling
		move.b	(v_player1_height_roll).w,ost_height(a0)
		move.b	(v_player1_width_roll).w,ost_width(a0)
		move.b	#id_Roll,ost_anim(a0)			; use "jumping" animation
		move.w	(v_player1_height_diff).w,d0
		add.w	d0,ost_y_pos(a0)

	.exit:
		rts
; ===========================================================================

.is_rolling:
		bset	#status_rolljump_bit,ost_status(a0)	; set flag for jumping while rolling
		rts

; ---------------------------------------------------------------------------
; Subroutine limiting Sonic's jump height when A/B/C is released
; ---------------------------------------------------------------------------

Sonic_JumpHeight:
		move.w	#-sonic_jump_release,d1			; jump power after A/B/C is released
		btst	#status_underwater_bit,ost_status(a0)	; is Sonic underwater?
		beq.s	.not_underwater				; if not, branch
		move.w	#-sonic_jump_release_water,d1

	.not_underwater:
		cmp.w	ost_y_vel(a0),d1
		ble.s	.keep_speed				; branch if jump power is less than post-A/B/C value
		move.b	(v_joypad_hold).w,d0
		and.b	ost_sonic_jumpmask(a0),d0		; is A, B or C pressed?
		bne.s	.keep_speed				; if yes, branch
		move.w	d1,ost_y_vel(a0)			; update y speed with smaller jump power

	.keep_speed:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	slow Sonic walking up a	slope
; ---------------------------------------------------------------------------

Sonic_SlopeResist:
		move.b	ost_angle(a0),d0
		move.b	d0,d1
		addi.b	#$60,d1
		cmpi.b	#$C0,d1
		bcc.s	.no_change				; branch if Sonic is on ceiling
		jsr	(CalcSine).w				; convert angle to sine
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	ost_inertia(a0)
		beq.s	.no_change				; branch if Sonic has no inertia
		bmi.s	.inertia_neg				; branch if Sonic has negative inertia
		tst.w	d0
		beq.s	.no_change
		add.w	d0,ost_inertia(a0)			; update Sonic's inertia
		rts
; ===========================================================================

.inertia_neg:
		add.w	d0,ost_inertia(a0)

.no_change:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope	while he's rolling
; ---------------------------------------------------------------------------

Sonic_RollRepel:
		move.b	ost_angle(a0),d0
		move.b	d0,d1
		addi.b	#$60,d1
		cmpi.b	#$C0,d1
		bcc.s	.no_change				; branch if Sonic is on ceiling
		jsr	(CalcSine).w				; convert angle to sine
		muls.w	#$50,d0
		asr.l	#8,d0
		tst.w	ost_inertia(a0)
		bmi.s	.inertia_neg				; branch if Sonic has negative inertia
		tst.w	d0
		bpl.s	.sine_pos				; branch sine is positive
		asr.l	#2,d0

	.sine_pos:
		add.w	d0,ost_inertia(a0)			; update Sonic's inertia
		rts
; ===========================================================================

.inertia_neg:
		tst.w	d0
		bmi.s	.sine_neg				; branch sine is negative
		asr.l	#2,d0

	.sine_neg:
		add.w	d0,ost_inertia(a0)			; update Sonic's inertia

.no_change:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope
; ---------------------------------------------------------------------------

Sonic_SlopeRepel:
		nop
		btst	#flags_stuck_bit,ost_sonic_flags(a0)	; is Sonic on a SBZ disc?
		bne.s	.exit					; if yes, branch
		tst.w	ost_sonic_lock_time(a0)			; are controls temporarily locked?
		bne.s	.locked					; if yes, branch
		move.b	ost_angle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	.exit					; branch if slope is 0 +-$20
		move.w	ost_inertia(a0),d0
		bpl.s	.inertia_pos				; branch if inertia is positive
		neg.w	d0

	.inertia_pos:
		cmpi.w	#sonic_min_speed_slope,d0
		bcc.s	.exit					; branch if inertia is at least $280
		clr.w	ost_inertia(a0)				; set Sonic's inertia to 0
		bset	#status_air_bit,ost_status(a0)
		move.w	#30,ost_sonic_lock_time(a0)		; lock controls for half a second

	.exit:
		rts
; ===========================================================================

.locked:
		subq.w	#1,ost_sonic_lock_time(a0)		; decrement timer
		rts

; ---------------------------------------------------------------------------
; Subroutine to	return Sonic's angle to 0 as he jumps
; ---------------------------------------------------------------------------

Sonic_JumpAngle:
		tst.b	ost_angle(a0)
		beq.s	.exit					; branch if 0
		bpl.s	.angle_pos				; branch if 1-$7F
		addq.b	#2,ost_angle(a0)
		
	.exit:
		rts

	.angle_pos:
		subq.b	#2,ost_angle(a0)
		rts

; ---------------------------------------------------------------------------
; Subroutine for Sonic to interact with floor/walls after jumping/falling
; ---------------------------------------------------------------------------

Sonic_JumpCollision:
		move.w	ost_x_vel(a0),d1
		move.w	ost_y_vel(a0),d2
                bpl.s	.down					; branch if moving down
                cmp.w	d1,d2
                bgt.w	Sonic_JumpCollision_Left		; branch if moving left
                neg.w	d1
                cmp.w	d1,d2
                bge.w	Sonic_JumpCollision_Right		; branch if moving right
                bra.w	Sonic_JumpCollision_Up			; moving upwards
 
	.down:
                cmp.w	d1,d2
                blt.w	Sonic_JumpCollision_Right		; branch if moving right
                neg.w	d1
                cmp.w	d1,d2
                ble.w	Sonic_JumpCollision_Left		; branch if moving left

Sonic_JumpCollision_Down:
		getpos						; d0 = x pos; d1 = y pos
		subi.w	#sonic_average_radius,d0
		moveq	#1,d6
		jsr	WallLeftDist
		tst.w	d5
		bpl.s	.no_wallleft				; branch if Sonic hasn't hit left wall
		sub.w	d5,ost_x_pos(a0)			; align to wall
		clr.w	ost_x_vel(a0)				; stop moving left
		bra.s	.no_wallright

	.no_wallleft:
		move.w	ost_x_pos(a0),d0
		addi.w	#sonic_average_radius,d0
		moveq	#1,d6
		jsr	WallRightDist
		tst.w	d5
		bpl.s	.no_wallright				; branch if Sonic hasn't hit right wall
		add.w	d5,ost_x_pos(a0)			; align to wall
		clr.w	ost_x_vel(a0)				; stop moving right

	.no_wallright:
		bsr.w	Sonic_Floor
		tst.w	d5
		bpl.s	.exit					; branch if Sonic hasn't hit floor
		move.b	ost_y_vel(a0),d0
		addq.b	#8,d0
		neg.b	d0
		cmp.b	d0,d5
		bge.s	.on_floor
		cmp.b	d0,d4
		blt.s	.exit

	.on_floor:
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.b	d2,ost_angle(a0)			; save floor angle
		bsr.w	Sonic_ResetOnFloor			; reset Sonic's flags
		move.b	#id_Walk,ost_anim(a0)			; use walking animation
		move.b	d2,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	.steep					; branch if floor is steep slope (over 45 degrees)
		move.b	d2,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	.flat					; branch if floor is flat (or almost)
		asr	ost_y_vel(a0)
		bra.s	.y_to_inertia
; ===========================================================================

.flat:
		clr.w	ost_y_vel(a0)				; stop Sonic falling
		move.w	ost_x_vel(a0),ost_inertia(a0)
		rts
; ===========================================================================

.steep:
		clr.w	ost_x_vel(a0)				; stop Sonic moving left/right
		cmpi.w	#$FC0,ost_y_vel(a0)
		ble.s	.y_to_inertia				; branch if y speed is below max
		move.w	#$FC0,ost_y_vel(a0)			; set max speed

.y_to_inertia:
		move.w	ost_y_vel(a0),ost_inertia(a0)
		tst.b	d2
		bpl.s	.exit
		neg.w	ost_inertia(a0)

.exit:
		rts
; ===========================================================================

Sonic_JumpCollision_Left:
		getpos						; d0 = x pos; d1 = y pos
		subi.w	#sonic_average_radius,d0
		moveq	#1,d6
		jsr	WallLeftDist
		tst.w	d5
		bpl.s	.no_wallleft				; branch if Sonic hasn't hit left wall
		sub.w	d5,ost_x_pos(a0)			; align to wall
		clr.w	ost_x_vel(a0)				; stop moving left
		move.w	ost_y_vel(a0),ost_inertia(a0)
		rts
; ===========================================================================

.no_wallleft:
		move.w	ost_x_pos(a0),d0
		subi.w	#sonic_average_radius,d1
		moveq	#1,d6
		jsr	CeilingDist
		tst.w	d5
		bpl.s	.no_ceiling				; branch if Sonic hasn't hit ceiling
		sub.w	d5,ost_y_pos(a0)			; align to ceiling
		tst.w	ost_y_vel(a0)
		bpl.s	.moving_down				; branch if Sonic is moving down
		clr.w	ost_y_vel(a0)				; stop moving up

	.moving_down:
		rts
; ===========================================================================

.no_ceiling:
		tst.w	ost_y_vel(a0)
		bmi.s	.exit					; branch if Sonic is moving up
		bsr.w	Sonic_Floor
		tst.w	d5
		bpl.s	.exit					; branch if Sonic hasn't hit the floor
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.b	d2,ost_angle(a0)			; save floor angle
		bsr.w	Sonic_ResetOnFloor			; reset Sonic's flags
		move.b	#id_Walk,ost_anim(a0)			; use walking animation
		clr.w	ost_y_vel(a0)
		move.w	ost_x_vel(a0),ost_inertia(a0)

	.exit:
		rts
; ===========================================================================

Sonic_JumpCollision_Up:
		getpos						; d0 = x pos; d1 = y pos
		subi.w	#sonic_average_radius,d0
		moveq	#1,d6
		jsr	WallLeftDist
		tst.w	d5
		bpl.s	.no_wallleft				; branch if Sonic hasn't hit left wall
		sub.w	d5,ost_x_pos(a0)			; align to wall
		clr.w	ost_x_vel(a0)				; stop moving left
		bra.s	.no_wallright

	.no_wallleft:
		move.w	ost_x_pos(a0),d0
		addi.w	#sonic_average_radius,d0
		moveq	#1,d6
		jsr	WallRightDist
		tst.w	d5
		bpl.s	.no_wallright				; branch if Sonic hasn't hit right wall
		add.w	d5,ost_x_pos(a0)			; align to wall
		clr.w	ost_x_vel(a0)				; stop moving right

	.no_wallright:
		bsr.w	Sonic_Ceiling
		tst.w	d5
		bpl.s	.exit					; branch if Sonic hasn't hit ceiling
		sub.w	d5,ost_y_pos(a0)			; align to ceiling
		move.b	d2,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	.steep					; branch if ceiling is almost-vertical slope
		clr.w	ost_y_vel(a0)
		rts
; ===========================================================================

.steep:
		move.b	d2,ost_angle(a0)			; save floor angle
		bsr.w	Sonic_ResetOnFloor			; reset Sonic's flags
		move.w	ost_y_vel(a0),ost_inertia(a0)
		tst.b	d2
		bpl.s	.exit
		neg.w	ost_inertia(a0)

.exit:
		rts
; ===========================================================================

Sonic_JumpCollision_Right:
		getpos						; d0 = x pos; d1 = y pos
		addi.w	#sonic_average_radius,d0
		moveq	#1,d6
		jsr	WallRightDist
		tst.w	d5
		bpl.s	.no_wallright				; branch if Sonic hasn't hit right wall
		add.w	d5,ost_x_pos(a0)			; align to wall
		clr.w	ost_x_vel(a0)				; stop moving right
		move.w	ost_y_vel(a0),ost_inertia(a0)
		rts
; ===========================================================================

.no_wallright:
		move.w	ost_x_pos(a0),d0
		subi.w	#sonic_average_radius,d1
		moveq	#1,d6
		jsr	CeilingDist
		tst.w	d5
		bpl.s	.no_ceiling				; branch if Sonic hasn't hit ceiling
		sub.w	d5,ost_y_pos(a0)			; align to ceiling
		tst.w	ost_y_vel(a0)
		bpl.s	.moving_down				; branch if Sonic is moving down
		clr.w	ost_y_vel(a0)				; stop moving up

	.moving_down:
		rts
; ===========================================================================

.no_ceiling:
		tst.w	ost_y_vel(a0)
		bmi.s	.exit					; branch if Sonic is moving up
		bsr.w	Sonic_Floor
		tst.w	d5
		bpl.s	.exit					; branch if Sonic hasn't hit the floor
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.b	d2,ost_angle(a0)			; save floor angle
		bsr.w	Sonic_ResetOnFloor			; reset Sonic's flags
		move.b	#id_Walk,ost_anim(a0)			; use walking animation
		clr.w	ost_y_vel(a0)
		move.w	ost_x_vel(a0),ost_inertia(a0)

.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	reset Sonic's mode when he lands on the floor
; ---------------------------------------------------------------------------

Sonic_ResetOnFloor:
		btst	#status_jump_bit,ost_status(a0)		; is Sonic jumping/rolling?
		beq.s	.no_jump				; if not, branch
		move.b	(v_player1_height).w,ost_height(a0)
		move.b	(v_player1_width).w,ost_width(a0)
		move.b	#id_Walk,ost_anim(a0)			; use running/walking animation
		move.w	(v_player1_height_diff).w,d0
		sub.w	d0,ost_y_pos(a0)

	.no_jump:
		andi.b	#$FF-status_pushing-status_air-status_rolljump-status_jump,ost_status(a0) ; clear some status flags
		clr.w	(v_enemy_combo).w			; reset counter for points for breaking multiple enemies
		rts

; ---------------------------------------------------------------------------
; Sonic	when he	gets hurt
; ---------------------------------------------------------------------------

Sonic_Hurt:	; Routine 4
		update_xy_fall $30				; update position & apply gravity
		btst	#status_underwater_bit,ost_status(a0)
		beq.s	.not_underwater				; branch if Sonic isn't underwater
		subi.w	#$20,ost_y_vel(a0)			; apply less gravity (net $10)

	.not_underwater:
		bsr.w	Sonic_HurtStop
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_RecordPosition
		bsr.w	Sonic_Animate
		bsr.w	Sonic_LoadGfx
		jmp	(DisplaySprite).l

; ---------------------------------------------------------------------------
; Subroutine to	stop Sonic falling after he's been hurt
; ---------------------------------------------------------------------------

Sonic_HurtStop:
		move.w	(v_boundary_bottom).w,d0
		addi.w	#screen_height,d0
		cmp.w	ost_y_pos(a0),d0
		bcs.w	SelfKillSonic				; branch if Sonic falls below level boundary
		bsr.w	Sonic_JumpCollision			; floor/wall collision
		btst	#status_air_bit,ost_status(a0)
		bne.s	.no_floor				; branch if Sonic is still in the air
		moveq	#0,d0
		move.w	d0,ost_y_vel(a0)			; stop moving
		move.w	d0,ost_x_vel(a0)
		move.w	d0,ost_inertia(a0)
		move.b	#id_Walk,ost_anim(a0)			; use walking animation
		subq.b	#2,ost_routine(a0)			; goto Sonic_Control next
		move.w	#sonic_flash_time,ost_sonic_flash_time(a0) ; set invincibility timer to 2 seconds

	.no_floor:
		rts

; ---------------------------------------------------------------------------
; Sonic	when he	dies
; ---------------------------------------------------------------------------

Sonic_Death:	; Routine 6
		bsr.w	GameOver
		update_xy_fall					; update position & apply gravity
		bsr.w	Sonic_RecordPosition
		bsr.w	Sonic_Animate
		bsr.w	Sonic_LoadGfx
		jmp	(DisplaySprite).l

; ---------------------------------------------------------------------------
; Subroutine to check for game over
; ---------------------------------------------------------------------------

GameOver:
		move.w	(v_boundary_bottom).w,d0
		addi.w	#screen_height+32,d0
		cmp.w	ost_y_pos(a0),d0			; has Sonic fallen more than 32px off screen after dying
		bcc.w	.exit					; if not, branch
		addq.b	#2,ost_routine(a0)			; goto Sonic_ResetLevel next
		clr.b	(f_hud_time_update).w			; stop time counter
		addq.b	#1,(f_hud_lives_update).w		; update lives counter
		subq.b	#1,(v_lives).w				; subtract 1 from number of lives
		bne.s	.lives_remain				; branch if some lives are remaining
		clr.w	ost_sonic_restart_time(a0)
		bsr.w	FindFreeInert
		bne.s	.fail
		move.l	#GameOverCard,ost_id(a1)		; load GAME object
		bsr.w	FindFreeInert
		bne.s	.fail
		move.l	#GameOverCard,ost_id(a1)		; load OVER object
		move.b	#id_frame_gameover_over,ost_frame(a1)	; set OVER object to correct frame

	.fail:
		clr.b	(f_time_over).w

.music_gfx:
		play.w	0, jmp, mus_GameOver			; play game over music
; ===========================================================================

.lives_remain:
		move.w	#60,ost_sonic_restart_time(a0)		; set time delay to 1 second
		tst.b	(f_time_over).w				; is TIME OVER tag set?
		beq.s	.exit					; if not, branch
		clr.w	ost_sonic_restart_time(a0)
		bsr.w	FindFreeInert
		bne.s	.music_gfx
		move.l	#GameOverCard,ost_id(a1)		; load TIME object
		move.b	#id_frame_gameover_time,ost_frame(a1)
		bsr.w	FindFreeInert
		bne.s	.music_gfx
		move.l	#GameOverCard,ost_id(a1)		; load OVER object
		move.b	#id_frame_gameover_over2,ost_frame(a1)
		bra.s	.music_gfx
; ===========================================================================

.exit:
		rts

; ---------------------------------------------------------------------------
; Sonic	when the level is restarted
; ---------------------------------------------------------------------------

Sonic_ResetLevel:
		; Routine 8
		tst.w	ost_sonic_restart_time(a0)
		beq.s	.exit					; branch if timer is on 0
		subq.w	#1,ost_sonic_restart_time(a0)		; decrement timer
		bne.s	.exit					; branch if timer isn't on 0
		move.w	#1,(f_restart).w			; restart the level

	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	animate	Sonic's sprites
; ---------------------------------------------------------------------------

Sonic_Animate:
		lea	Ani_Sonic(pc),a1
		movea.l	a1,a2
		moveq	#status_xflip,d2
		move.b	ost_anim(a0),d0
		cmp.b	ost_sonic_anim_next(a0),d0		; is animation set to restart?
		beq.w	Anim_Run				; if not, branch

		move.b	d0,ost_sonic_anim_next(a0)		; set to "no restart"
		clr.b	ost_anim_frame(a0)			; reset animation
		clr.b	ost_anim_time(a0)			; reset frame duration
		bra.w	Anim_Run

; ---------------------------------------------------------------------------
; Subroutine to load Sonic's graphics to RAM
; ---------------------------------------------------------------------------

Sonic_LoadGfx:
		moveq	#0,d0
		move.b	ost_frame(a0),d0			; load frame number
		cmp.b	(v_sonic_last_frame_id).w,d0		; has frame changed?
		beq.s	.nochange				; if not, branch

		move.b	d0,(v_sonic_last_frame_id).w
		lea	(SonicDynPLC).l,a2			; load PLC script
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1				; read "number of entries" value
		subq.b	#1,d1					; minus 1 for number of loops
		bmi.s	.nochange				; if zero, branch
		lea	(v_sonic_gfx_buffer).w,a3		; RAM address to write gfx

	.loop_entry:
		moveq	#0,d2
		move.b	(a2)+,d2				; get 1st byte of entry
		move.w	d2,d0
		lsr.b	#4,d0					; read high nybble of byte (number of tiles)
		lsl.w	#8,d2					; move 1st byte into high byte
		move.b	(a2)+,d2				; get 2nd byte
		lsl.w	#5,d2					; multiply by 32 (also clears high nybble)
		lea	(Art_Sonic).l,a1
		adda.l	d2,a1					; jump to relevant gfx

	.loop_tile:
		movem.l	(a1)+,d2-d6/a4-a6			; copy tile to registers
		movem.l	d2-d6/a4-a6,(a3)			; copy registers to RAM
		lea	sizeof_cell(a3),a3			; next tile
		dbf	d0,.loop_tile				; repeat for number of tiles

		dbf	d1,.loop_entry				; repeat for number of entries
		lea	DMA_Sonic(pc),a2
		move.l	(a2)+,d1
		move.l	(a2)+,d2
		jsr	(AddDMA).w

	.nochange:
		rts

DMA_Sonic:
		dc.l $40000080+((vram_sonic&$3FFF)<<16)+((vram_sonic&$C000)>>14)
		dc.l $93009400+(((sizeof_vram_sonic>>1)&$FF)<<16)+(((sizeof_vram_sonic>>1)&$FF00)>>8)
		dc.w $9500+((v_sonic_gfx_buffer>>1)&$FF)
		dc.w $9600+(((v_sonic_gfx_buffer>>1)&$FF00)>>8)
		dc.w $9700+(((v_sonic_gfx_buffer>>1)&$7F0000)>>16)

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's angle & position as he walks along the floor
; ---------------------------------------------------------------------------

Sonic_AnglePos:
		btst	#status_platform_bit,ost_status(a0)
		beq.s	.not_on_platform			; branch if Sonic isn't on a platform
		moveq	#0,d0
		move.b	d0,(v_angle_right).w			; clear angle hotspots
		move.b	d0,(v_angle_left).w
		rts
; ===========================================================================

.not_on_platform:
		moveq	#3,d0
		move.b	d0,(v_angle_right).w
		move.b	d0,(v_angle_left).w
		move.b	ost_angle(a0),d0			; get last angle
		addi.b	#$20,d0
		bpl.s	.floor_or_left				; branch if angle is (generally) flat or left vertical
		move.b	ost_angle(a0),d0
		bpl.s	.angle_pos				; branch if angle is between $60 and $7F
		subq.b	#1,d0					; subtract 1 if $80-$DF

	.angle_pos:
		addi.b	#$20,d0					; d0 = angle + ($1F or $20)
		bra.s	.chk_surface
; ===========================================================================

.floor_or_left:
		move.b	ost_angle(a0),d0
		bpl.s	.angle_pos_				; branch if angle is between 0 and $60
		addq.b	#1,d0					; add 1 if $E0-$FF

	.angle_pos_:
		addi.b	#$1F,d0					; d0 = angle + ($1F or $20)

.chk_surface:
		andi.b	#$C0,d0					; read only bits 6-7 of angle
		cmpi.b	#$40,d0
		beq.w	Sonic_WalkVertL				; branch if on left vertical
		cmpi.b	#$80,d0
		beq.w	Sonic_WalkCeiling			; branch if on ceiling
		cmpi.b	#$C0,d0
		beq.w	Sonic_WalkVertR				; branch if on right vertical

		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_height(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos of bottom edge of Sonic
		move.b	ost_width(a0),d0
		ext.w	d0
		add.w	d0,d3					; d3 = x pos of right edge of Sonic
		lea	(v_angle_right).w,a4			; write angle here
		move.w	#0,d6
		moveq	#tilemap_solid_top_bit,d5		; bit to test for solidness (top solid)
		bsr.w	FindFloor
		move.w	d1,-(sp)				; save d1 (distance to floor) to stack

		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_height(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos of bottom edge of Sonic
		move.b	ost_width(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d3					; d3 = x pos of left edge of Sonic
		lea	(v_angle_left).w,a4			; write angle here
		move.w	#0,d6
		moveq	#tilemap_solid_top_bit,d5		; bit to test for solidness (top solid)
		bsr.w	FindFloor				; d1 = distance to floor left side
		move.w	(sp)+,d0				; d0 = distance to floor right side
		bsr.w	Sonic_Angle				; update angle
		tst.w	d1
		beq.s	.on_floor				; branch if Sonic is 0px from floor
		bpl.s	.above_floor				; branch if Sonic is above floor
		cmpi.w	#-$E,d1
		blt.s	Sonic_BelowFloor			; branch if Sonic is > 14px below floor
		add.w	d1,ost_y_pos(a0)			; align to floor

	.on_floor:
		rts
; ===========================================================================

.above_floor:
		cmpi.w	#$E,d1
		bgt.s	.in_air					; branch if Sonic is > 14px above floor

.on_disc:
		add.w	d1,ost_y_pos(a0)			; align to floor
		rts
; ===========================================================================

.in_air:
		btst	#flags_stuck_bit,ost_sonic_flags(a0)
		bne.s	.on_disc				; branch if Sonic is on a SBZ disc
		bset	#status_air_bit,ost_status(a0)
		bclr	#status_pushing_bit,ost_status(a0)
		move.b	#id_Run,ost_sonic_anim_next(a0)
		rts
; ===========================================================================

Sonic_BelowFloor:
Sonic_InsideWall:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	update Sonic's angle

; input:
;	d0 = distance to floor right side
;	d1 = distance to floor left side

; output:
;	d1 = shortest distance to floor (either side)
;	d2 = angle
; ---------------------------------------------------------------------------

Sonic_Angle:
		move.b	(v_angle_left).w,d2			; use left side angle
		cmp.w	d0,d1
		ble.s	.left_nearer				; branch if floor is nearer on left side
		move.b	(v_angle_right).w,d2			; use right side angle
		move.w	d0,d1					; use distance of right side

	.left_nearer:
		btst	#0,d2
		bne.s	.snap_angle				; branch if bit 0 of angle is set
		move.b	d2,ost_angle(a0)			; update angle
		rts
; ===========================================================================

.snap_angle:
		move.b	ost_angle(a0),d2
		addi.b	#$20,d2
		andi.b	#$C0,d2					; snap to nearest 90 degree angle
		move.b	d2,ost_angle(a0)			; update angle
		rts

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to	his right
; ---------------------------------------------------------------------------

Sonic_WalkVertR:
		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_width(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d2					; d2 = y pos of upper edge of Sonic (i.e. his front or back)
		move.b	ost_height(a0),d0
		ext.w	d0
		add.w	d0,d3					; d3 = x pos of bottom edge of Sonic (i.e. his feet)
		lea	(v_angle_right).w,a4			; write angle here
		move.w	#0,d6
		moveq	#tilemap_solid_top_bit,d5		; bit to test for solidness (top solid)
		bsr.w	FindWall
		move.w	d1,-(sp)				; save d1 (distance to wall) to stack

		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_width(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos of lower edge of Sonic (i.e. his front or back)
		move.b	ost_height(a0),d0
		ext.w	d0
		add.w	d0,d3					; d3 = x pos of bottom edge of Sonic (i.e. his feet)
		lea	(v_angle_left).w,a4			; write angle here
		move.w	#0,d6
		moveq	#tilemap_solid_top_bit,d5		; bit to test for solidness (top solid)
		bsr.w	FindWall				; d1 = distance to wall lower side
		move.w	(sp)+,d0				; d0 = distance to wall upper side
		bsr.w	Sonic_Angle				; update angle
		tst.w	d1
		beq.s	.on_wall				; branch if Sonic is 0px from wall
		bpl.s	.outside_wall				; branch if Sonic is outside wall
		cmpi.w	#-$E,d1
		blt.w	Sonic_InsideWall			; branch if Sonic is > 14px inside wall
		add.w	d1,ost_x_pos(a0)			; align to wall

	.on_wall:
		rts
; ===========================================================================

.outside_wall:
		cmpi.w	#$E,d1
		bgt.s	.in_air					; branch if Sonic is > 14px outside wall

.on_disc:
		add.w	d1,ost_x_pos(a0)			; align to wall
		rts
; ===========================================================================

.in_air:
		btst	#flags_stuck_bit,ost_sonic_flags(a0)
		bne.s	.on_disc				; branch if Sonic is on a SBZ disc
		bset	#status_air_bit,ost_status(a0)
		bclr	#status_pushing_bit,ost_status(a0)
		move.b	#id_Run,ost_sonic_anim_next(a0)
		rts

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk upside-down
; ---------------------------------------------------------------------------

Sonic_WalkCeiling:
		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_height(a0),d0
		ext.w	d0
		sub.w	d0,d2					; d2 = y pos of top edge of Sonic (i.e. his feet)
		eori.w	#$F,d2					; add some amount
		move.b	ost_width(a0),d0
		ext.w	d0
		add.w	d0,d3					; d3 = x pos of right edge of Sonic
		lea	(v_angle_right).w,a4			; write angle here
		move.w	#tilemap_yflip,d6			; yflip tile
		moveq	#tilemap_solid_top_bit,d5		; bit to test for solidness (top solid)
		bsr.w	FindCeiling
		move.w	d1,-(sp)				; save d1 (distance to ceiling) to stack

		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_height(a0),d0
		ext.w	d0
		sub.w	d0,d2					; d2 = y pos of top edge of Sonic (i.e. his feet)
		eori.w	#$F,d2
		move.b	ost_width(a0),d0
		ext.w	d0
		sub.w	d0,d3					; d3 = x pos of left edge of Sonic
		lea	(v_angle_left).w,a4			; write angle here
		move.w	#tilemap_yflip,d6			; yflip tile
		moveq	#tilemap_solid_top_bit,d5		; bit to test for solidness (top solid)
		bsr.w	FindCeiling				; d1 = distance to ceiling left side
		move.w	(sp)+,d0				; d0 = distance to ceiling right side
		bsr.w	Sonic_Angle				; update angle
		tst.w	d1
		beq.s	.on_ceiling				; branch if Sonic is 0px from ceiling
		bpl.s	.below_ceiling				; branch if Sonic is below ceiling
		cmpi.w	#-$E,d1
		blt.w	Sonic_BelowFloor			; branch if Sonic is > 14px inside ceiling
		sub.w	d1,ost_y_pos(a0)			; align to ceiling

	.on_ceiling:
		rts
; ===========================================================================

.below_ceiling:
		cmpi.w	#$E,d1
		bgt.s	.in_air					; branch if Sonic is > 14px below ceiling

.on_disc:
		sub.w	d1,ost_y_pos(a0)			; align to ceiling
		rts
; ===========================================================================

.in_air:
		btst	#flags_stuck_bit,ost_sonic_flags(a0)
		bne.s	.on_disc				; branch if Sonic is on a SBZ disc
		bset	#status_air_bit,ost_status(a0)
		bclr	#status_pushing_bit,ost_status(a0)
		move.b	#id_Run,ost_sonic_anim_next(a0)
		rts

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to	his left
; ---------------------------------------------------------------------------

Sonic_WalkVertL:
		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_width(a0),d0
		ext.w	d0
		sub.w	d0,d2					; d2 = y pos of upper edge of Sonic (i.e. his front or back)
		move.b	ost_height(a0),d0
		ext.w	d0
		sub.w	d0,d3					; d3 = x pos of bottom edge of Sonic (i.e. his feet)
		eori.w	#$F,d3					; add some amount
		lea	(v_angle_right).w,a4			; write angle here
		move.w	#tilemap_xflip,d6			; xflip tile
		moveq	#tilemap_solid_top_bit,d5		; bit to test for solidness (top solid)
		bsr.w	FindWallLeft
		move.w	d1,-(sp)				; save d1 (distance to wall) to stack

		move.w	ost_y_pos(a0),d2
		move.w	ost_x_pos(a0),d3
		moveq	#0,d0
		move.b	ost_width(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos of lower edge of Sonic (i.e. his front or back)
		move.b	ost_height(a0),d0
		ext.w	d0
		sub.w	d0,d3					; d3 = x pos of bottom edge of Sonic (i.e. his feet)
		eori.w	#$F,d3
		lea	(v_angle_left).w,a4			; write angle here
		move.w	#tilemap_xflip,d6			; xflip tile
		moveq	#tilemap_solid_top_bit,d5		; bit to test for solidness (top solid)
		bsr.w	FindWallLeft				; d1 = distance to wall lower side
		move.w	(sp)+,d0				; d0 = distance to wall upper side
		bsr.w	Sonic_Angle				; update angle
		tst.w	d1
		beq.s	.on_wall				; branch if Sonic is 0px from wall
		bpl.s	.outside_wall				; branch if Sonic is outside wall
		cmpi.w	#-$E,d1
		blt.w	Sonic_InsideWall			; branch if Sonic is > 14px inside wall
		sub.w	d1,ost_x_pos(a0)			; align to wall

	.on_wall:
		rts
; ===========================================================================

.outside_wall:
		cmpi.w	#$E,d1
		bgt.s	.in_air					; branch if Sonic is > 14px outside wall

.on_disc:
		sub.w	d1,ost_x_pos(a0)			; align to wall
		rts
; ===========================================================================

.in_air:
		btst	#flags_stuck_bit,ost_sonic_flags(a0)
		bne.s	.on_disc				; branch if Sonic is on a SBZ disc
		bset	#status_air_bit,ost_status(a0)
		bclr	#status_pushing_bit,ost_status(a0)
		move.b	#id_Run,ost_sonic_anim_next(a0)
		rts

; ---------------------------------------------------------------------------
; Subroutine to	find distance to floor to left/right of Sonic

; output:
;	d2.b = angle on shortest side
;	d3.b = angle on shortest side snapped to 90 degrees
;	d4.w = longest distance to floor (-ve if below floor)
;	d5.w = shortest distance to floor (-ve if below floor)
;	a2 = address within level layout
;	(a2).b = 256x256 chunk id
;	a3 = address within 256x256 mappings
;	(a3).w = 16x16 tile id & flags

;	uses d1.w, d2.l, d3.l, d4.l, d5.l, d6.w, a4, a5, a6
; ---------------------------------------------------------------------------

Sonic_Floor:
		getpos_bottomleft				; d0 = x pos; d1 = y pos
		moveq	#1,d6
		jsr	FloorDist				; d5 = dist to floor on left side
		movea.w	d5,a6					; save to a6
		jsr	FloorAngle
		move.b	d2,(v_angle_left).w
		getpos_bottomright				; d0 = x pos; d1 = y pos
		moveq	#1,d6
		jsr	FloorDist				; d5 = dist to floor on right side
		jsr	FloorAngle
		move.b	d2,(v_angle_right).w
		move.w	a6,d4					; retrieve left dist
		cmp.w	d4,d5
		ble.s	.use_right				; branch if d4 > d5 (right dist is shorter)
		exg	d4,d5					; use left dist
		move.b	(v_angle_left).w,d2			; use left angle
		
	.use_right:
		move.b	d2,d3
		addi.b	#$20,d3
		andi.b	#$C0,d3					; snap to 90 degree angle
		rts
		
; ---------------------------------------------------------------------------
; As above, but for the ceiling
; ---------------------------------------------------------------------------

Sonic_Ceiling:
		getpos_topleft					; d0 = x pos; d1 = y pos
		moveq	#1,d6
		jsr	CeilingDist				; d5 = dist to ceiling on left side
		movea.w	d5,a6					; save to a6
		jsr	FloorAngle
		move.b	d2,(v_angle_left).w
		getpos_topright					; d0 = x pos; d1 = y pos
		moveq	#1,d6
		jsr	CeilingDist				; d5 = dist to ceiling on right side
		jsr	FloorAngle
		move.b	d2,(v_angle_right).w
		move.w	a6,d4					; retrieve left dist
		cmp.w	d4,d5
		ble.s	.use_right				; branch if d4 > d5 (right dist is shorter)
		exg	d4,d5					; use left dist
		move.b	(v_angle_left).w,d2			; use left angle
		
	.use_right:
		move.b	d2,d3
		addi.b	#$20,d3
		andi.b	#$C0,d3					; snap to 90 degree angle
		rts
