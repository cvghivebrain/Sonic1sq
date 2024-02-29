; ---------------------------------------------------------------------------
; Object 28 - animals

; spawned by:
;	ExplosionItem, Prison
; ---------------------------------------------------------------------------

Animals:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Anml_Index(pc,d0.w),d1
		jmp	Anml_Index(pc,d1.w)
; ===========================================================================
Anml_Index:	index *,,2
		ptr Anml_Main
		ptr Anml_Wait
		ptr Anml_Drop
		ptr Anml_Mammal
		ptr Anml_Bird

id_Rabbit:	equ 0
id_Chicken:	equ 1
id_Penguin:	equ 2
id_Seal:	equ 3
id_Pig:		equ 4
id_Flicky:	equ 5
id_Squirrel:	equ 6

animal_height:	equ 12

Anml_Settings:	dc.w -$200, -$400				; type 0 - rabbit, GHZ/SBZ
		dc.l Map_Animal1
		dc.l v_tile_animal1
		dc.b id_Anml_Mammal
		even
	Anml_Settings_size:
	
		dc.w -$200, -$300				; type 1 - chicken, SYZ/SBZ
		dc.l Map_Animal2
		dc.l v_tile_animal2
		dc.b id_Anml_Bird
		even
		
		dc.w -$180, -$300				; type 2 - penguin, LZ
		dc.l Map_Animal1
		dc.l v_tile_animal1
		dc.b id_Anml_Mammal
		even
		
		dc.w -$140, -$180				; type 3 - seal, MZ/LZ
		dc.l Map_Animal2
		dc.l v_tile_animal2
		dc.b id_Anml_Mammal
		even
		
		dc.w -$1C0, -$300				; type 4 - pig, SYZ/SLZ
		dc.l Map_Animal3
		dc.l v_tile_animal1
		dc.b id_Anml_Mammal
		even
		
		dc.w -$300, -$400				; type 5 - flicky, GHZ/SLZ
		dc.l Map_Animal2
		dc.l v_tile_animal2
		dc.b id_Anml_Bird
		even
		
		dc.w -$280, -$380				; type 6 - squirrel, MZ
		dc.l Map_Animal3
		dc.l v_tile_animal1
		dc.b id_Anml_Mammal
		even

		rsobj Animals
ost_animal_x_vel:	rs.w 1					; horizontal speed
ost_animal_y_vel:	rs.w 1					; vertical speed
ost_animal_delay:	rs.w 1					; time to wait before jumping
ost_animal_direction:	rs.b 1					; animal goes left/right
ost_animal_type:	rs.b 1					; routine to use after animal first hits the floor
		rsobjend
; ===========================================================================

Anml_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Anml_Wait next
		addq.b	#1,(v_animal_count).w			; increment animal counter
		lea	(v_animal_type).w,a1
		bsr.w	RandomNumber
		andi.w	#1,d0					; d0 = 0 or 1 (random)
		move.b	(a1,d0.w),d0				; get one of two types
		mulu.w	#Anml_Settings_size-Anml_Settings,d0
		lea	Anml_Settings(pc,d0.w),a1		; jump to settings for specified animal
		move.w	(a1)+,ost_x_vel(a0)			; load horizontal speed
		move.w	(a1)+,ost_animal_y_vel(a0)		; load vertical speed
		move.l	(a1)+,ost_mappings(a0)			; load mappings
		movea.l	(a1)+,a2
		move.w	(a2),ost_tile(a0)			; load VRAM setting
		move.b	(a1)+,ost_animal_type(a0)		; load routine id
		move.b	#render_rel+render_xflip+render_onscreen,ost_render(a0)
		move.b	#priority_6,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#animal_height,ost_height(a0)
		move.b	#7,ost_anim_time(a0)
		move.b	#id_frame_animal1_drop,ost_frame(a0)	; use "dropping" frame
		move.w	#-$400,ost_y_vel(a0)

Anml_Wait:	; Routine 2
		subq.w	#1,ost_animal_delay(a0)			; decrement timer
		bpl.w	DisplaySprite				; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Anml_Drop next

Anml_Drop:	; Routine 4
		tst.b	ost_render(a0)
		bmi.s	.display				; branch if on screen
		subq.b	#1,(v_animal_count).w			; decrement animal counter
		bra.w	DeleteObject
		
	.display:
		update_y_fall					; make object fall and update its position
		bmi.w	DisplaySprite				; branch if still moving upwards
		getpos_bottom animal_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		jsr	FloorDist
		tst.w	d5					; has object hit the floor?
		bpl.w	DisplaySprite				; if not, branch
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)	; reset speed
		move.b	#id_frame_animal1_flap2,ost_frame(a0)	; use flapping frame
		move.b	ost_animal_type(a0),ost_routine(a0)	; goto relevant routine next
		tst.b	(v_boss_status).w
		beq.w	DisplaySprite				; branch if not at prison capsule
		move.b	#priority_3,ost_priority(a0)		; make animal appear in front of prison
		btst	#4,(v_vblank_counter_byte).w		; check bit that changes every 16 frames
		beq.w	DisplaySprite				; branch if 0
		neg.w	ost_x_vel(a0)				; reverse direction
		bchg	#render_xflip_bit,ost_render(a0)
		bra.w	DisplaySprite
; ===========================================================================

Anml_Mammal:	; Routine 6
		shortcut
		move.b	#id_frame_animal1_flap2,ost_frame(a0)
		update_xy_fall					; make object fall and update its position
		bmi.s	.chkdel					; branch if moving upwards

		move.b	#id_frame_animal1_flap1,ost_frame(a0)
		getpos_bottom animal_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		jsr	FloorDist
		tst.w	d5					; has object hit the floor?
		bpl.s	.chkdel					; if not, branch
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)	; reset y speed

	.chkdel:
		tst.b	ost_render(a0)
		bmi.w	DisplaySprite				; branch if on screen
		subq.b	#1,(v_animal_count).w			; decrement animal counter
		bra.w	DeleteObject
; ===========================================================================

Anml_Bird:	; Routine 8
		shortcut
		update_xy_fall	$18				; update object position & apply gravity
		bmi.s	.animate				; branch if moving upwards

		getpos_bottom animal_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		jsr	FloorDist
		tst.w	d5					; has object hit the floor?
		bpl.s	.animate				; if not, branch
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)	; reset y speed

	.animate:
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bpl.s	.chkdel					; branch if time remains
		move.b	#1,ost_anim_time(a0)			; set timer to 1 frame
		bchg	#0,ost_frame(a0)			; change frame

	.chkdel:
		tst.b	ost_render(a0)
		bmi.w	DisplaySprite				; branch if on screen
		subq.b	#1,(v_animal_count).w			; decrement animal counter
		bra.w	DeleteObject
		
; ---------------------------------------------------------------------------
; Animals at ending

; spawned by:
;	ObjPos_End - subtypes 0-9

type_animal_end_flicky:		equ 0
type_animal_end_flicky_onspot:	equ 1
type_animal_end_rabbit:		equ 2
type_animal_end_rabbit_onspot:	equ 3
type_animal_end_penguin:	equ 4
type_animal_end_penguin_onspot:	equ 5
type_animal_end_seal:		equ 6
type_animal_end_pig_onspot:	equ 7
type_animal_end_chicken:	equ 8
type_animal_end_squirrel:	equ 9
; ---------------------------------------------------------------------------

AnimalsEnd:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	AnmlE_Index(pc,d0.w),d1
		jmp	AnmlE_Index(pc,d1.w)
; ===========================================================================
AnmlE_Index:	index *,,2
		ptr AnmlE_Main
		ptr AnmlE_Flicky
		ptr AnmlE_Flicky2
		ptr AnmlE_Rabbit
		ptr AnmlE_VertOnly
		ptr AnmlE_Stay
		ptr AnmlE_Chicken
		ptr AnmlE_Squirrel

AnmlE_Settings:	dc.w -$440, -$400
		dc.l Map_Animal2
		dc.w tile_Art_Flicky_UPLC_Animals
		dc.b id_AnmlE_Flicky
		even
	AnmlE_Settings_size:
		
		dc.w -$440, -$400
		dc.l Map_Animal2
		dc.w tile_Art_Flicky_UPLC_Animals
		dc.b id_AnmlE_Flicky2
		even
		
		dc.w -$300, -$400
		dc.l Map_Animal1
		dc.w tile_Art_Rabbit_UPLC_Animals
		dc.b id_AnmlE_Rabbit
		even
		
		dc.w -$300, -$400
		dc.l Map_Animal1
		dc.w tile_Art_Rabbit_UPLC_Animals
		dc.b id_AnmlE_VertOnly
		even
		
		dc.w -$180, -$300
		dc.l Map_Animal1
		dc.w tile_Art_Penguin_UPLC_Animals
		dc.b id_AnmlE_Stay
		even
		
		dc.w -$180, -$300
		dc.l Map_Animal1
		dc.w tile_Art_Penguin_UPLC_Animals
		dc.b id_AnmlE_VertOnly
		even
		
		dc.w -$140, -$180
		dc.l Map_Animal2
		dc.w tile_Art_Seal_UPLC_Animals
		dc.b id_AnmlE_Stay
		even
		
		dc.w -$1C0, -$300
		dc.l Map_Animal3
		dc.w tile_Art_Pig_UPLC_Animals
		dc.b id_AnmlE_VertOnly
		even
		
		dc.w -$200, -$300
		dc.l Map_Animal2
		dc.w tile_Art_Chicken_UPLC_Animals
		dc.b id_AnmlE_Chicken
		even
		
		dc.w -$280, -$380
		dc.l Map_Animal3
		dc.w tile_Art_Squirrel_UPLC_Animals
		dc.b id_AnmlE_Squirrel
		even
; ===========================================================================

AnmlE_Main:	; Routine 0
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		mulu.w	#AnmlE_Settings_size-AnmlE_Settings,d0
		lea	AnmlE_Settings,a2
		lea	(a2,d0.w),a2
		move.w	(a2),ost_animal_x_vel(a0)		; load horizontal speed
		move.w	(a2)+,ost_x_vel(a0)
		move.w	(a2),ost_animal_y_vel(a0)		; load vertical speed
		move.w	(a2)+,ost_y_vel(a0)
		move.l	(a2)+,ost_mappings(a0)			; get mappings pointer
		move.w	(a2)+,ost_tile(a0)			; get VRAM tile number
		move.b	(a2)+,ost_routine(a0)
		move.b	#animal_height,ost_height(a0)
		move.b	#render_rel,ost_render(a0)
		bset	#render_xflip_bit,ost_render(a0)
		move.b	#priority_6,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#7,ost_anim_time(a0)
		bra.w	DisplaySprite
; ===========================================================================

AnmlE_Flicky:	; Routine 2
		shortcut
		tst.b	ost_render(a0)
		bpl.w	DisplaySprite				; wait until on screen before moving
		shortcut
		update_xy_fall	$18				; update object position & apply gravity
		bmi.s	AnmlE_Flicky_Animate			; branch if moving upwards
		bsr.w	AnmlE_ChkFloor

AnmlE_Flicky_Animate:
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bpl.w	DespawnQuick				; branch if time remains
		move.b	#1,ost_anim_time(a0)			; set timer to 1 frame
		bchg	#0,ost_frame(a0)			; change frame
		bra.w	DespawnQuick
; ===========================================================================

AnmlE_Flicky2:	; Routine 4
		shortcut
		bsr.w	AnmlE_FaceSonic
		update_y_fall	$18				; update object position & apply gravity
		bmi.s	AnmlE_Flicky_Animate			; branch if moving upwards

		bsr.w	AnmlE_ChkFloor
		bra.w	AnmlE_Flicky_Animate
; ===========================================================================

AnmlE_Rabbit:	; Routine 6
		shortcut
		tst.b	ost_render(a0)
		bpl.w	DisplaySprite				; wait until on screen before moving
		shortcut
		move.b	#id_frame_animal1_flap2,ost_frame(a0)
		update_xy_fall					; make object fall and update its position
		bmi.w	DespawnQuick				; branch if moving upwards

		move.b	#id_frame_animal1_flap1,ost_frame(a0)
		bsr.w	AnmlE_ChkFloor
		bra.w	DespawnQuick
; ===========================================================================

AnmlE_VertOnly:	; Routine 8
		shortcut
		bsr.w	AnmlE_FaceSonic
		move.b	#id_frame_animal1_flap2,ost_frame(a0)
		update_y_fall					; make object fall and update its position
		bmi.w	DespawnQuick				; branch if moving upwards

		move.b	#id_frame_animal1_flap1,ost_frame(a0)
		bsr.w	AnmlE_ChkFloor
		bra.w	DespawnQuick
; ===========================================================================

AnmlE_Stay:	; Routine $A
		shortcut
		move.b	#id_frame_animal1_flap2,ost_frame(a0)
		update_xy_fall					; make object fall and update its position
		bmi.w	DespawnQuick				; branch if moving upwards

		move.b	#id_frame_animal1_flap1,ost_frame(a0)
		getpos_bottom animal_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		jsr	FloorDist
		tst.w	d5					; has object hit the floor?
		bpl.w	DespawnQuick				; if not, branch
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)	; reset y speed
		neg.w	ost_x_vel(a0)				; reverse direction
		bchg	#render_xflip_bit,ost_render(a0)
		bra.w	DespawnQuick
; ===========================================================================

AnmlE_Chicken:	; Routine $C
		shortcut
		tst.b	ost_render(a0)
		bpl.w	DisplaySprite				; wait until on screen before moving
		shortcut
		update_xy_fall	$18				; update object position & apply gravity
		bmi.w	AnmlE_Flicky_Animate			; branch if moving upwards

		getpos_bottom animal_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		jsr	FloorDist
		tst.w	d5					; has object hit the floor?
		bpl.w	AnmlE_Flicky_Animate			; if not, branch
		not.b	ost_animal_direction(a0)		; change direction flag
		bne.s	.no_flip				; branch if 1
		neg.w	ost_x_vel(a0)				; reverse direction
		bchg	#render_xflip_bit,ost_render(a0)

	.no_flip:
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)	; reset y speed
		bra.w	AnmlE_Flicky_Animate
; ===========================================================================

AnmlE_Squirrel:	; Routine $E
		shortcut
		tst.b	ost_render(a0)
		bpl.w	DisplaySprite				; wait until on screen before moving
		shortcut
		move.b	#id_frame_animal1_flap2,ost_frame(a0)
		update_xy_fall					; make object fall and update its position
		bmi.w	DespawnQuick				; branch if moving upwards

		move.b	#id_frame_animal1_flap1,ost_frame(a0)
		getpos_bottom animal_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		jsr	FloorDist
		tst.w	d5					; has object hit the floor?
		bpl.w	DespawnQuick				; if not, branch
		not.b	ost_animal_direction(a0)		; change direction flag
		bne.s	.no_flip				; branch if 1
		neg.w	ost_x_vel(a0)				; reverse direction
		bchg	#render_xflip_bit,ost_render(a0)

	.no_flip:
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)	; reset y speed
		bra.w	DespawnQuick

; ---------------------------------------------------------------------------
; Subroutine to set/clear xflip bit if Sonic is to the left/right respectively
; ---------------------------------------------------------------------------

AnmlE_FaceSonic:
		bset	#render_xflip_bit,ost_render(a0)	; set bit
		getsonic					; a1 = OST of Sonic
		range_x_quick
		bmi.s	.exit					; branch if Sonic is to the left
		bclr	#render_xflip_bit,ost_render(a0)	; clear bit

	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to detect collision with floor
; ---------------------------------------------------------------------------

AnmlE_ChkFloor:
		getpos_bottom animal_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		jsr	FloorDist
		tst.w	d5					; has object hit the floor?
		bpl.s	.exit					; if not, branch
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.w	ost_animal_y_vel(a0),ost_y_vel(a0)	; reset y speed
		
	.exit:
		rts
