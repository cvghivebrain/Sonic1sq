; ---------------------------------------------------------------------------
; Subroutine to collide Sonic with objects using ost_col_type(a0)

; input:
;	a0 = address of OST of Sonic

; output:
;	a2 = address of OST of object hurting/killing Sonic

;	uses d0.l, d1.l, d2.w, d3.w, d4.w, d5.l, d6.l, a1
; ---------------------------------------------------------------------------

ReactToItem:	
		move.w	ost_x_pos(a0),d2
		move.w	ost_y_pos(a0),d3
		moveq	#0,d4
		moveq	#0,d5
		move.b	(v_player1_hitbox_width).w,d4
		move.b	(v_player1_hitbox_height).w,d5
		cmpi.b	#id_Roll,ost_anim(a0)
		bne.s	.not_rolling				; branch if Sonic isn't rolling/jumping
		move.b	(v_player1_hitbox_width_roll).w,d4
		move.b	(v_player1_hitbox_height_roll).w,d5
		
	.not_rolling:
		cmpi.b	#id_Duck,ost_anim(a0)
		bne.s	.not_ducking				; branch if Sonic isn't ducking
		addi.w	#6,d3
		subi.b	#6,d5					; smaller hitbox when ducking
		
	.not_ducking:
		lea	(v_ost_level_obj).w,a1			; first OST slot for interactable objects
		move.w	#countof_ost_ert-1,d6			; number of interactable objects

React_Loop:
		tst.b	ost_render(a1)
		bpl.s	React_Next				; branch if object is off screen
		move.b	ost_col_type(a1),d0
		beq.s	React_Next				; branch if collision type is 0
		move.b	d0,d1
		andi.w	#$3F,d0					; read only bits 0-5
		add.w	d0,d0
		add.w	d0,d0
		lea	React_Sizes(pc,d0.w),a2			; jump to relevant dimensions
		move.w	ost_x_pos(a1),d0
		sbabs.w	d2,d0					; d0 = x dist between Sonic & object
		sub.w	d4,d0
		sub.w	(a2)+,d0
		bpl.s	React_Next				; branch if dist is > sum of widths
		move.w	ost_y_pos(a1),d0
		sbabs.w	d3,d0					; d0 = y dist between Sonic & object
		sub.w	d5,d0
		sub.w	(a2)+,d0
		bpl.s	React_Next				; branch if dist is > sum of heights
		andi.w	#$C0,d1					; read bits 6-7 of collision type
		lsr.b	#5,d1
		move.w	React_Index(pc,d1.w),d1
		jmp	React_Index(pc,d1.w)			; collision successful, exit loop

	React_Next:
		lea	sizeof_ost(a1),a1			; next OST slot
		dbf	d6,React_Loop				; repeat $5F more times
		rts	
; ===========================================================================
React_Index:	index *,,2
		ptr React_Enemy
		ptr React_Item
		ptr React_ChkHurt
		ptr React_Special

colid:		macro *
		id_\*: equ (*-React_Sizes)/4
		dc.w \1,\2
		endm

id_col_enemy:	equ 0						; enemies
id_col_item:	equ $40						; monitors, rings, giant rings
id_col_hurt:	equ $80						; hurts Sonic when touched
id_col_custom:	equ $C0						; enemies with spikes (yadrin, caterkiller), SYZ bumper

React_Sizes:	;   width, height
col_0x0:	colid  0, 0					; $00
col_20x20:	colid  $14, $14					; $01 - GHZ ball
col_12x20:	colid   $C, $14					; $02 - Splats
col_20x12:	colid  $14,  $C					; $03
col_4x16:	colid	4,  $10					; $04 - GHZ spike pole, SYZ boss spike
col_12x18:	colid   $C, $12					; $05 - Ball Hog, Burrobot
col_16x16:	colid  $10, $10					; $06 - SBZ spikeball, Crabmeat, Monitor, SYZ spikeball, Prison
col_6x6:	colid	6,    6					; $07 - Cannonball, Crab/Buzz missile, Ring
col_24x12:	colid  $18,  $C					; $08 - Buzz Bomber
col_12x16:	colid   $C, $10					; $09 - Chopper
col_16x12:	colid  $10,  $C					; $0A - Jaws
col_8x8:	colid	8,    8					; $0B - MZ fire, Fireball, Batbrain, LZ spikeball, SLZ seesaw spike, Orbinaut, Caterkiller
col_20x16:	colid  $14, $10					; $0C - Newtron, Motobug, Yadrin
col_20x8:	colid  $14,   8					; $0D - Newtron
col_14x14:	colid   $E,  $E					; $0E - Roller
col_24x24:	colid  $18, $18					; $0F - Bosses
col_40x16:	colid  $28, $10					; $10 - MZ stomper
col_16x24:	colid  $10, $18					; $11 - MZ stomper
col_8x16:	colid	8,  $10					; $12 - Giant ring
col_32x112:	colid  $20, $70					; $13 - MZ geyser
col_64x32:	colid  $40, $20					; $14 - MZ lava wall, MZ lava tag
col_128x32:	colid  $80, $20					; $15 - MZ lava tag
col_32x32:	colid  $20, $20					; $16 - MZ lava tag
col_8x8_2:	colid	8,    8					; $17 - SYZ bumper
col_4x4:	colid	4,    4					; $18 - SYZ spike chain, Bomb shrapnel, Orbinaut spike, LZ gargoyle fire
col_32x8:	colid  $20,   8					; $19 - SLZ swing
col_12x12:	colid   $C,  $C					; $1A - Bomb enemy, FZ plasma
col_8x4:	colid	8,    4					; $1B - LZ harpoon
col_24x4:	colid  $18,   4					; $1C - LZ harpoon
col_40x4:	colid  $28,   4					; $1D - LZ harpoon
col_4x8:	colid	4,    8					; $1E - LZ harpoon
col_4x24:	colid	4,  $18					; $1F - LZ harpoon
col_4x40:	colid	4,  $28					; $20 - LZ harpoon
col_4x32:	colid	4,  $20					; $21 - LZ pole
col_24x24_2:	colid  $18, $18					; $22 - SBZ saw
col_12x24:	colid   $C, $18					; $23 - SBZ flamethrower
col_72x8:	colid  $48,   8					; $24 - SBZ electric
; ===========================================================================

React_Item:	; ost_col_type is $40-$7F (monitor, ring, giant ring)
		cmpi.w	#sonic_flash_time-ring_delay,ost_sonic_flash_time(a0) ; has Sonic been hit recently?
		bcc.s	.no_collide				; if yes, branch
		addq.b	#2,ost_routine(a1)			; goto Ring_Collect (if ring), RLoss_Collect (if bouncing ring), GRing_Collect (if giant ring) next

	.no_collide:
		rts
; ===========================================================================

React_Enemy:
		tst.b	(v_invincibility).w			; is Sonic invincible?
		bne.s	.donthurtsonic				; if yes, branch
		cmpi.b	#id_Roll,ost_anim(a0)			; is Sonic rolling/jumping?
		bne.w	React_ChkHurt				; if not, branch

	.donthurtsonic:
		tst.b	ost_col_property(a1)
		beq.s	React_Enemy_Break			; branch if it's not a boss

		neg.w	ost_x_vel(a0)				; repel Sonic
		neg.w	ost_y_vel(a0)
		asr	ost_x_vel(a0)
		asr	ost_y_vel(a0)
		move.b	#0,ost_col_type(a1)			; temporarily make boss harmless
		subq.b	#1,ost_col_property(a1)			; decrement hit counter
		bne.s	.flagnotclear				; branch if not 0
		bset	#status_broken_bit,ost_status(a1)	; set flag for boss beaten

	.flagnotclear:
		rts	
; ===========================================================================

React_Enemy_Break:
		move.w	(v_enemy_combo).w,d0
		addq.w	#2,(v_enemy_combo).w			; add 2 to item bonus counter
		cmpi.w	#Enemy_Points_end-Enemy_Points-2,d0
		bcs.s	.bonusokay
		moveq	#Enemy_Points_end-Enemy_Points-2,d0	; max bonus is #6 (1000 points)

	.bonusokay:
		move.w	d0,ost_enemy_combo(a1)			; set frame for points object (spawned by animal object)
		move.w	Enemy_Points(pc,d0.w),d0
		cmpi.w	#combo_max,(v_enemy_combo).w		; have 16 enemies been destroyed?
		bcs.s	.lessthan16				; if not, branch
		move.w	#combo_max_points,d0			; fix bonus to 10000
		move.w	#id_frame_points_10k*2,ost_enemy_combo(a1) ; use 10k frame for points object

	.lessthan16:
		jsr	AddPoints				; update score
		move.l	#ExplosionItem,ost_id(a1)		; change object to explosion
		move.b	#id_ExItem_Animal,ost_routine(a1)	; explosion also spawns an animal
		tst.w	ost_y_vel(a0)
		bmi.s	.bouncedown				; branch if Sonic is moving upwards
		cmp.w	ost_y_pos(a1),d3			; d3 = Sonic's y pos
		bcc.s	.bounceup				; branch if Sonic is below enemy
		neg.w	ost_y_vel(a0)
		rts	
; ===========================================================================

	.bouncedown:
		addi.w	#$100,ost_y_vel(a0)
		rts	

	.bounceup:
		subi.w	#$100,ost_y_vel(a0)
		rts	

Enemy_Points:	dc.w 100/10
		dc.w 200/10
		dc.w 500/10
		dc.w 1000/10
	Enemy_Points_end:

; ===========================================================================

React_Caterkiller:
		tst.b	(v_invincibility).w
		bne.s	.break_caterkiller			; branch if Sonic is invincible
		cmpi.b	#id_Roll,ost_anim(a0)
		beq.s	.break_caterkiller			; branch if Sonic is rolling/jumping
		move.b	#id_Cat_Split,ost_mode(a1)		; caterkiller splits apart
		bra.s	React_Hurt
		
	.break_caterkiller:
		pushr	a0-a1
		movea.l	a1,a0					; a0 = OST of caterkiller
		bsr.w	DeleteChildren				; delete caterkiller segments
		popr	a0-a1
		bra.w	React_Enemy_Break
; ===========================================================================

React_ChkHurt:
		tst.b	(v_invincibility).w			; is Sonic invincible?
		beq.s	React_Hurt				; if not, branch

	React_Exit:
		rts	
; ===========================================================================

React_Hurt:
		nop	
		tst.w	ost_sonic_flash_time(a0)		; is Sonic flashing?
		bne.s	React_Exit				; if yes, branch
		movea.l	a1,a2

; continue straight to HurtSonic

; ---------------------------------------------------------------------------
; Hurting Sonic	subroutine

; input:
;	a0 = address of OST of Sonic
;	a2 = address of OST of object hurting Sonic

; output:
;	d0.l = -1
;	a1 = address of OST of ring loss object (if Sonic had rings)
; ---------------------------------------------------------------------------

HurtSonic:
		tst.b	(v_shield).w
		bne.s	.hasshield				; branch if Sonic has a shield
		tst.w	(v_rings).w
		beq.w	.norings				; branch if Sonic has no rings

		jsr	(FindFreeObj).l				; find free OST slot
		bne.s	.hasshield				; branch if not found
		move.l	#RingLoss,ost_id(a1)			; load bouncing multi rings object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)

	.hasshield:
		move.b	#0,(v_shield).w				; remove shield
		move.b	#id_Sonic_Hurt,ost_routine(a0)		; run hurt animation/action
		bsr.w	Sonic_ResetOnFloor			; reset several of Sonic's flags
		bset	#status_air_bit,ost_status(a0)
		move.w	#-$400,ost_y_vel(a0)			; make Sonic bounce away from the object
		move.w	#-$200,ost_x_vel(a0)
		btst	#status_underwater_bit,ost_status(a0)	; is Sonic underwater?
		beq.s	.isdry					; if not, branch

		move.w	#-$200,ost_y_vel(a0)			; slower bounce
		move.w	#-$100,ost_x_vel(a0)

	.isdry:
		move.w	ost_x_pos(a0),d0
		cmp.w	ost_x_pos(a2),d0
		bcs.s	.isleft					; if Sonic is left of the object, branch
		neg.w	ost_x_vel(a0)				; if Sonic is right of the object, reverse

	.isleft:
		move.w	#0,ost_inertia(a0)
		move.b	#id_Hurt,ost_anim(a0)
		move.w	#sonic_flash_time,ost_sonic_flash_time(a0) ; set temp invincible time to 2 seconds
		move.w	#sfx_Death,d0				; load normal damage sound
		cmp.l	#Spikes,ost_id(a2)			; was damage caused by spikes?
		bne.s	.sound					; if not, branch
		cmp.l	#Harpoon,ost_id(a2)			; was damage caused by LZ harpoon?
		bne.s	.sound					; if not, branch
		move.w	#sfx_SpikeHit,d0			; load spikes damage sound

	.sound:
		jsr	(PlaySound1).l
		rts	
; ===========================================================================

.norings:
		tst.w	(f_debug_enable).w			; is debug mode	cheat on?
		bne.w	.hasshield				; if yes, branch

; continue straight into KillSonic

; ---------------------------------------------------------------------------
; Subroutine to	kill Sonic

; input:
;	a0 = address of OST of Sonic
;	a2 = address of OST of object killing Sonic

; output:
;	d0.l = -1
; ---------------------------------------------------------------------------

KillSonic:
		tst.w	(v_debug_active).w			; is debug mode	active?
		bne.s	.dontdie				; if yes, branch
		move.b	#0,(v_invincibility).w			; remove invincibility
		move.b	#0,(f_hud_time_update).w		; stop HUD time counter
		move.b	#id_Sonic_Death,ost_routine(a0)		; run death animation/action
		bsr.w	Sonic_ResetOnFloor			; reset several of Sonic's flags
		bset	#status_air_bit,ost_status(a0)
		move.w	#-$700,ost_y_vel(a0)			; move Sonic up
		move.w	#0,ost_x_vel(a0)
		move.w	#0,ost_inertia(a0)
		move.b	#id_Death,ost_anim(a0)
		bset	#tile_hi_bit,ost_tile(a0)
		move.w	#sfx_Death,d0				; play normal death sound
		cmpi.l	#Spikes,ost_id(a2)			; check	if you were killed by spikes
		bne.s	.sound
		move.w	#sfx_SpikeHit,d0			; play spikes death sound

	.sound:
		jsr	(PlaySound1).l

	.dontdie:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	kill Sonic (from object)

; input:
;	a0 = address of OST of object killing Sonic

; output:
;	d0.l = -1
;	a2 = address of OST of Sonic
; ---------------------------------------------------------------------------

ObjectKillSonic:
		movea.l	a0,a2					; object which killed Sonic
		lea	(v_ost_player).w,a0			; make Sonic the current object
		bsr.s	KillSonic				; kill Sonic
		exg	a0,a2					; restore current object
		rts
		
; ===========================================================================

React_Special:
		move.b	ost_col_type(a1),d1			; get collision type
		andi.b	#$3F,d1					; read only bits 0-5 (size)
		cmpi.b	#id_col_8x8,d1
		beq.w	React_Caterkiller			; branch if $CB (caterkiller)
		cmpi.b	#id_col_20x16,d1
		beq.s	.yadrin					; branch if $CC (yadrin)
		cmpi.b	#id_col_8x8_2,d1
		beq.s	.D7orE1					; branch if $D7 (SYZ bumper)
		cmpi.b	#id_col_4x32,d1
		beq.s	.D7orE1					; branch if $E1 (LZ pole)
		rts	
; ===========================================================================

.yadrin:
		sub.w	d0,d5					; d5 = Sonic's height, minus y dist between Sonic & yadrin
		cmpi.w	#8,d5
		bcc.s	.normalenemy				; branch if Sonic is below spike level
		move.w	ost_x_pos(a1),d0
		subq.w	#4,d0
		btst	#status_xflip_bit,ost_status(a1)
		beq.s	.no_xflip
		subi.w	#$10,d0

	.no_xflip:
		sub.w	d2,d0					; d0 = x pos of yadrin's face, minus x pos of Sonic's left edge
		bcc.s	.sonic_left				; branch if Sonic is left of the yadrin
		addi.w	#$18,d0
		bcs.s	.within_x				; branch if Sonic is inside the yadrin
		bra.s	.normalenemy
; ===========================================================================

.sonic_left:
		cmp.w	d4,d0
		bhi.s	.normalenemy				; branch if Sonic is outside the yadrin

.within_x:
		bra.w	React_ChkHurt				; check for invincibility, then hurt Sonic
; ===========================================================================

	.normalenemy:
		bra.w	React_Enemy				; treat like a normal enemy
; ===========================================================================

.D7orE1:
		addq.b	#1,ost_col_property(a1)			; set flag for Sonic touching bumper/pole
		rts
