; ---------------------------------------------------------------------------
; Object 28 - animals

; spawned by:
;	ExplosionItem - subtype 0
;	Prison - subtype 0
;	ObjPos_End - subtypes $A, $C-$14
; ---------------------------------------------------------------------------

Animals:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Anml_Index(pc,d0.w),d1
		jmp	Anml_Index(pc,d1.w)
; ===========================================================================
Anml_Index:	index *,,2
		ptr Anml_Main
		ptr Anml_Drop
		ptr Anml_TypeNormal
		ptr Anml_TypeBird
		ptr Anml_TypeNormal
		ptr Anml_TypeNormal
		ptr Anml_TypeNormal
		ptr Anml_Type5
		ptr Anml_TypeNormal
		ptr Anml_FromPrison
		ptr Anml_End_0A
		ptr Anml_End_0A
		ptr Anml_End_0C
		ptr Anml_End_0D
		ptr Anml_End_0E
		ptr Anml_End_0F
		ptr Anml_End_0E
		ptr Anml_End_0F
		ptr Anml_End_0E
		ptr Anml_End_13
		ptr Anml_End_14

id_Rabbit:	equ 0
id_Chicken:	equ 1
id_Penguin:	equ 2
id_Seal:	equ 3
id_Pig:		equ 4
id_Flicky:	equ 5
id_Squirrel:	equ 6

Anml_Settings:	dc.w -$200, -$400				; type 0 - rabbit, GHZ/SBZ
		dc.l Map_Animal1
		dc.l v_tile_animal1
		dc.b id_Anml_TypeNormal
		even
	Anml_Settings_size:
	
		dc.w -$200, -$300				; type 1 - chicken, SYZ/SBZ
		dc.l Map_Animal2
		dc.l v_tile_animal2
		dc.b id_Anml_TypeBird
		even
		
		dc.w -$180, -$300				; type 2 - penguin, LZ
		dc.l Map_Animal1
		dc.l v_tile_animal1
		dc.b id_Anml_TypeNormal
		even
		
		dc.w -$140, -$180				; type 3 - seal, MZ/LZ
		dc.l Map_Animal2
		dc.l v_tile_animal2
		dc.b id_Anml_TypeNormal
		even
		
		dc.w -$1C0, -$300				; type 4 - pig, SYZ/SLZ
		dc.l Map_Animal3
		dc.l v_tile_animal1
		dc.b id_Anml_TypeNormal
		even
		
		dc.w -$300, -$400				; type 5 - flicky, GHZ/SLZ
		dc.l Map_Animal2
		dc.l v_tile_animal2
		dc.b id_Anml_TypeBird
		even
		
		dc.w -$280, -$380				; type 6 - squirrel, MZ
		dc.l Map_Animal3
		dc.l v_tile_animal1
		dc.b id_Anml_TypeNormal
		even

Anml_EndSpeed:	dc.w -$440, -$400				; $A
		dc.w -$440, -$400				; $B
		dc.w -$440, -$400				; $C
		dc.w -$300, -$400				; $D
		dc.w -$300, -$400				; $E
		dc.w -$180, -$300				; $F
		dc.w -$180, -$300				; $10
		dc.w -$140, -$180				; $11
		dc.w -$1C0, -$300				; $12
		dc.w -$200, -$300				; $13
		dc.w -$280, -$380				; $14

Anml_EndMap:	dc.l Map_Animal2				; $A
		dc.l Map_Animal2				; $B - unused
		dc.l Map_Animal2				; $C
		dc.l Map_Animal1				; $D
		dc.l Map_Animal1				; $E
		dc.l Map_Animal1				; $F
		dc.l Map_Animal1				; $10
		dc.l Map_Animal2				; $11
		dc.l Map_Animal3				; $12
		dc.l Map_Animal2				; $13
		dc.l Map_Animal3				; $14

Anml_EndVram:	dc.w tile_Art_Flicky_UPLC_Animals		; $A
		dc.w tile_Art_Flicky_UPLC_Animals		; $B - unused
		dc.w tile_Art_Flicky_UPLC_Animals		; $C
		dc.w tile_Art_Rabbit_UPLC_Animals		; $D
		dc.w tile_Art_Rabbit_UPLC_Animals		; $E
		dc.w tile_Art_Penguin_UPLC_Animals		; $F
		dc.w tile_Art_Penguin_UPLC_Animals		; $10
		dc.w tile_Art_Seal_UPLC_Animals			; $11
		dc.w tile_Art_Pig_UPLC_Animals			; $12
		dc.w tile_Art_Chicken_UPLC_Animals		; $13
		dc.w tile_Art_Squirrel_UPLC_Animals		; $14

		rsobj Animals
ost_animal_direction:	rs.b 1					; animal goes left/right
ost_animal_type:	rs.b 1					; routine to use after animal first hits the floor
ost_animal_x_vel:	rs.w 1					; horizontal speed (2 bytes)
ost_animal_y_vel:	rs.w 1					; vertical speed (2 bytes)
ost_animal_delay:	rs.w 1					; time to wait before 
		rsobjend
; ===========================================================================

Anml_Main:	; Routine 0
		tst.b	ost_subtype(a0)				; did animal come from an enemy or prison capsule?
		beq.w	Anml_FromEnemy				; if yes, branch

		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; move object type to d0
		add.w	d0,d0					; multiply d0 by 2
		move.b	d0,ost_routine(a0)			; move d0 to routine counter
		subi.w	#$14,d0
		move.w	Anml_EndVram(pc,d0.w),ost_tile(a0)	; get VRAM tile number
		add.w	d0,d0
		move.l	Anml_EndMap(pc,d0.w),ost_mappings(a0)	; get mappings pointer
		lea	Anml_EndSpeed(pc),a1
		move.w	(a1,d0.w),ost_animal_x_vel(a0)		; load horizontal speed
		move.w	(a1,d0.w),ost_x_vel(a0)
		move.w	2(a1,d0.w),ost_animal_y_vel(a0)		; load vertical speed
		move.w	2(a1,d0.w),ost_y_vel(a0)
		move.b	#$C,ost_height(a0)
		move.b	#render_rel,ost_render(a0)
		bset	#render_xflip_bit,ost_render(a0)
		move.b	#6,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#7,ost_anim_time(a0)
		bra.w	DisplaySprite
; ===========================================================================

Anml_FromEnemy:
		addq.b	#2,ost_routine(a0)			; goto Anml_Drop next
		lea	(v_animal_type).w,a1
		moveq	#1,d0
		and.b	(v_frame_counter_low).w,d0		; d0 = 0 or 1 (basically random)
		move.b	(a1,d0.w),d0				; get one of two types
		mulu.w	#Anml_Settings_size-Anml_Settings,d0
		lea	Anml_Settings,a1
		adda.l	d0,a1					; jump to settings for specified animal
		move.w	(a1)+,ost_animal_x_vel(a0)		; load horizontal speed
		move.w	(a1)+,ost_animal_y_vel(a0)		; load vertical speed
		move.l	(a1)+,ost_mappings(a0)			; load mappings
		movea.l	(a1)+,a2
		move.w	(a2),ost_tile(a0)			; load VRAM setting
		move.b	(a1)+,ost_animal_type(a0)		; load routine id
		move.b	#render_rel+render_xflip,ost_render(a0)
		move.b	#6,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#$C,ost_height(a0)
		move.b	#7,ost_anim_time(a0)
		move.b	#id_frame_animal1_drop,ost_frame(a0)	; use "dropping" frame
		move.w	#-$400,ost_y_vel(a0)
		tst.w	ost_animal_delay(a0)
		bne.s	.from_prison				; branch if animal came from prison capsule
		bsr.w	FindFreeObj
		bne.w	DisplaySprite
		move.l	#Points,ost_id(a1)			; load points object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	ost_enemy_combo(a0),d0
		lsr.w	#1,d0
		move.b	d0,ost_frame(a1)
		bra.w	DisplaySprite

	.from_prison:
		move.b	#id_Anml_FromPrison,ost_routine(a0)	; goto Anml_FromPrison next
		bra.w	DisplaySprite
; ===========================================================================

Anml_Drop:	; Routine 2
		tst.b	ost_render(a0)				; is object on-screen?
		bpl.w	DeleteObject				; if not, branch
		
		update_y_fall					; make object fall and update its position
		bmi.w	DisplaySprite				; branch if still moving upwards
		tst.b	ost_mode(a0)
		beq.s	.keep_priority				; branch if animal didn't come from a prison capsule
		move.b	#3,ost_priority(a0)			; make animal appear in front of prison
		clr.b	ost_mode(a0)				; don't do this again

	.keep_priority:
		jsr	(FindFloorObj).l
		tst.w	d1					; has object hit the floor?
		bpl.w	DisplaySprite				; if not, branch

		add.w	d1,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_x_vel(a0),ost_x_vel(a0)	; reset speed
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)
		move.b	#id_frame_animal1_flap2,ost_frame(a0)	; use flapping frame
		move.b	ost_animal_type(a0),ost_routine(a0)	; goto relevant routine next
		tst.b	(v_boss_status).w			; has boss been beaten?
		beq.w	DisplaySprite				; if not, branch
		btst	#4,(v_vblank_counter_byte).w		; check bit that changes every 16 frames
		beq.w	DisplaySprite				; branch if 0
		neg.w	ost_x_vel(a0)				; reverse direction
		bchg	#render_xflip_bit,ost_render(a0)
		bra.w	DisplaySprite
; ===========================================================================

Anml_FromPrison:
		; Routine $14
		subq.w	#1,ost_animal_delay(a0)			; decrement timer
		bne.w	DisplaySprite				; branch if not 0
		move.b	#id_Anml_Drop,ost_routine(a0)		; goto Anml_Drop next
		move.b	#1,ost_mode(a0)
		bra.w	DisplaySprite
; ===========================================================================

Anml_TypeNormal:
		; Routine 6, $A, $C, $E, $12
		move.b	#id_frame_animal1_flap2,ost_frame(a0)
		update_xy_fall					; make object fall and update its position
		bmi.s	.chkdel					; branch if moving upwards

		move.b	#id_frame_animal1_flap1,ost_frame(a0)
		jsr	(FindFloorObj).l
		tst.w	d1					; has object hit the floor?
		bpl.s	.chkdel					; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)	; reset y speed

	.chkdel:
		tst.b	ost_subtype(a0)				; is this an animal from the ending?
		bne.s	Anml_End_ChkDel				; if yes, branch
		tst.b	ost_render(a0)				; is object on-screen?
		bpl.w	DeleteObject				; if not, branch
		bra.w	DisplaySprite
; ===========================================================================

Anml_TypeBird:	; Routine 8
Anml_Type5:	; Routine $10
		update_xy_fall	$18				; update object position & apply gravity
		bmi.s	.animate				; branch if moving upwards

		jsr	(FindFloorObj).l
		tst.w	d1					; has object hit the floor?
		bpl.s	.animate				; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)	; reset y speed
		move.b	ost_subtype(a0),d0
		beq.s	.animate				; branch if not an ending animal

		cmpi.b	#$A,d0
		beq.s	.animate
		neg.w	ost_x_vel(a0)
		bchg	#render_xflip_bit,ost_render(a0)

	.animate:
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bpl.s	.chkdel					; branch if time remains
		move.b	#1,ost_anim_time(a0)			; set timer to 1 frame
		bchg	#0,ost_frame(a0)			; change frame

	.chkdel:
		tst.b	ost_subtype(a0)
		bne.s	Anml_End_ChkDel
		tst.b	ost_render(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

Anml_End_ChkDel:
		move.w	ost_x_pos(a0),d0
		sub.w	(v_ost_player+ost_x_pos).w,d0		; d0 = distance between Sonic & object (+ve if Sonic is to the left)
		bcs.w	DisplaySprite				; branch if Sonic is to the right
		subi.w	#384,d0
		bpl.w	DisplaySprite				; branch if Sonic is > 384px to the left
		tst.b	ost_render(a0)				; is object on-screen?
		bpl.w	DeleteObject				; if not, branch
		bra.w	DisplaySprite
; ===========================================================================

Anml_End_0A:	; Routine $16, $18
		bsr.w	Anml_End_ChkDist
		bcc.s	Anml_End_ChkDel				; branch if Sonic is to the left, or > 184px right

		move.w	ost_animal_x_vel(a0),ost_x_vel(a0)	; reset speed
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)
		move.b	#id_Anml_Type5,ost_routine(a0)		; goto Anml_TypeBird next
		bra.w	Anml_TypeBird
; ===========================================================================

Anml_End_0C:	; Routine $1A
		bsr.w	Anml_End_ChkDist
		bpl.s	Anml_End_ChkDel				; branch if Sonic is > 184px to the right
		clr.w	ost_x_vel(a0)
		clr.w	ost_animal_x_vel(a0)
		update_xy_fall	$18
		bsr.w	Anml_End_Update
		bsr.w	Anml_End_ChkDirection
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bpl.s	Anml_End_ChkDel				; branch if time remains
		move.b	#1,ost_anim_time(a0)			; set timer to 1 frame
		addq.b	#1,ost_frame(a0)			; change frame
		andi.b	#1,ost_frame(a0)			; limit to 2 frames
		bra.w	Anml_End_ChkDel
; ===========================================================================

Anml_End_0D:	; Routine $1C
		bsr.w	Anml_End_ChkDist
		bpl.w	Anml_End_ChkDel				; branch if Sonic is > 184px to the right
		move.w	ost_animal_x_vel(a0),ost_x_vel(a0)	; reset speed
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)
		move.b	#id_Anml_TypeNormal,ost_routine(a0)		; goto Anml_TypeNormal next
		bra.w	Anml_TypeNormal
; ===========================================================================

Anml_End_14:	; Routine $2A
		move.b	#id_frame_animal1_flap2,ost_frame(a0)
		update_xy_fall					; make object fall and update position
		bmi.w	Anml_End_ChkDel				; branch if moving upwards
		move.b	#id_frame_animal1_flap1,ost_frame(a0)
		jsr	(FindFloorObj).l
		tst.w	d1					; has object hit the floor?
		bpl.w	Anml_End_ChkDel				; if not, branch
		not.b	ost_animal_direction(a0)		; change direction flag
		bne.s	.no_flip				; branch if 1
		neg.w	ost_x_vel(a0)				; reverse direction
		bchg	#render_xflip_bit,ost_render(a0)

	.no_flip:
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)	; reset y speed
		bra.w	Anml_End_ChkDel
; ===========================================================================

Anml_End_0E:	; Routine $1E, $22, $26
		bsr.w	Anml_End_ChkDist
		bpl.w	Anml_End_ChkDel				; branch if Sonic is > 184px to the right
		clr.w	ost_x_vel(a0)
		clr.w	ost_animal_x_vel(a0)
		update_y_fall					; make object fall and update position
		bsr.w	Anml_End_Update
		bsr.w	Anml_End_ChkDirection
		bra.w	Anml_End_ChkDel
; ===========================================================================

Anml_End_0F:	; Routine $20, $24
		bsr.w	Anml_End_ChkDist
		bpl.w	Anml_End_ChkDel				; branch if Sonic is > 184px to the right
		move.b	#id_frame_animal1_flap2,ost_frame(a0)
		update_xy_fall					; make object fall and update position
		bmi.w	Anml_End_ChkDel				; branch if moving upwards
		move.b	#id_frame_animal1_flap1,ost_frame(a0)
		jsr	(FindFloorObj).l
		tst.w	d1					; has object hit the floor?
		bpl.w	Anml_End_ChkDel				; if not, branch
		neg.w	ost_x_vel(a0)				; reverse direction
		bchg	#render_xflip_bit,ost_render(a0)
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)	; reset y speed
		bra.w	Anml_End_ChkDel
; ===========================================================================

Anml_End_13:	; Routine $28
		bsr.w	Anml_End_ChkDist
		bpl.w	Anml_End_ChkDel				; branch if Sonic is > 184px to the right
		update_xy_fall	$18				; update position
		bmi.s	.chk_anim				; branch if moving upwards
		jsr	(FindFloorObj).l
		tst.w	d1					; has object hit the floor?
		bpl.s	.chk_anim				; if not, branch
		not.b	ost_animal_direction(a0)		; change direction flag
		bne.s	.no_flip				; branch if 1
		neg.w	ost_x_vel(a0)				; reverse direction
		bchg	#render_xflip_bit,ost_render(a0)

	.no_flip:
		add.w	d1,ost_y_pos(a0)
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)

	.chk_anim:
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bpl.w	Anml_End_ChkDel				; branch if time remains
		move.b	#1,ost_anim_time(a0)			; set timer to 1 frame
		bchg	#0,ost_frame(a0)			; change frame
		bra.w	Anml_End_ChkDel

; ---------------------------------------------------------------------------
; Subroutine to animate and bounce on floor
; ---------------------------------------------------------------------------

Anml_End_Update:
		move.b	#id_frame_animal1_flap2,ost_frame(a0)
		tst.w	ost_y_vel(a0)				; is object currently moving upwards?
		bmi.s	.exit					; if yes, branch
		move.b	#id_frame_animal1_flap1,ost_frame(a0)
		jsr	(FindFloorObj).l
		tst.w	d1					; has object hit the floor?
		bpl.s	.exit					; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)	; reset y speed

	.exit:
		rts	

; ---------------------------------------------------------------------------
; Subroutine to set/clear xflip bit if Sonic is to the left/right respectively
; ---------------------------------------------------------------------------

Anml_End_ChkDirection:
		bset	#render_xflip_bit,ost_render(a0)	; set bit
		move.w	ost_x_pos(a0),d0
		sub.w	(v_ost_player+ost_x_pos).w,d0		; d0 = distance between Sonic & object (-ve if Sonic is to the right)
		bcc.s	.exit					; branch if Sonic is to the left
		bclr	#render_xflip_bit,ost_render(a0)	; clear bit

	.exit:
		rts	

; ---------------------------------------------------------------------------
; Subroutine to check if Sonic is more than 184px to the right

; output:
;	d0 = +ve if true; -ve if false
; ---------------------------------------------------------------------------

Anml_End_ChkDist:
		move.w	(v_ost_player+ost_x_pos).w,d0
		sub.w	ost_x_pos(a0),d0			; d0 = distance between Sonic & object (-ve if Sonic is to the left)
		subi.w	#184,d0					; d0 is -ve if Sonic is left, or < 184px right
		rts
