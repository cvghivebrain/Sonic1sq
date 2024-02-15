; ---------------------------------------------------------------------------
; Object 13 - fireball launcher (MZ, SLZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SLZ3

; subtypes:
;	%GHRRRSSS
;	G - 1 if affected by gravity
;	H - 1 if horizontal, 0 if vertical
;	RRR - firing rate (1 = 0.5 seconds)
;	SSS - initial speed (1 = $100)

type_fire_rate30:		equ (30/30)<<3			; every 0.5 seconds
type_fire_rate60:		equ (60/30)<<3			; every 1 second
type_fire_rate90:		equ (90/30)<<3			; every 1.5 seconds
type_fire_rate120:		equ (120/30)<<3			; every 2 seconds
type_fire_rate150:		equ (150/30)<<3			; every 2.5 seconds
type_fire_rate180:		equ (180/30)<<3			; every 3 seconds
type_fire_horizontal_bit:	equ 6
type_fire_gravity_bit:		equ 7
type_fire_vertical:		equ 0
type_fire_horizontal:		equ 1<<type_fire_horizontal_bit
type_fire_gravity:		equ 1<<type_fire_gravity_bit
; ---------------------------------------------------------------------------

FireMaker:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	FireM_Index(pc,d0.w),d1
		jmp	FireM_Index(pc,d1.w)
; ===========================================================================
FireM_Index:	index *,,2
		ptr FireM_Main
		ptr FireM_MakeFire

		rsobj FireMaker
ost_firem_time_master:	rs.b 1
		rsobjend
; ===========================================================================

FireM_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto FireM_MakeFire next
		move.b	ost_subtype(a0),d0
		andi.w	#%00111000,d0				; read bits for firing rate
		beq.w	DeleteObject				; delete if 0
		lsr.b	#3,d0
		mulu.w	#30,d0					; multiply by 0.5 seconds
		move.b	d0,ost_firem_time_master(a0)
		move.b	ost_firem_time_master(a0),ost_anim_time(a0) ; set time delay for fireballs

FireM_MakeFire:	; Routine 2
		shortcut
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bne.w	DespawnQuick_NoDisplay			; branch if time remains
		move.b	ost_firem_time_master(a0),ost_anim_time(a0) ; reset time delay
		bsr.w	CheckOffScreen				; is object on-screen?
		bne.w	DespawnQuick_NoDisplay			; if not, branch
		bsr.w	FindFreeObj				; find free OST slot
		bne.w	DespawnQuick_NoDisplay			; branch if not found
		move.l	#FireBall,ost_id(a1)			; load fireball object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	ost_subtype(a0),ost_subtype(a1)		; subtype = speed/direction
		move.b	ost_status(a0),ost_status(a1)
		bra.w	DespawnQuick_NoDisplay

; ---------------------------------------------------------------------------
; Fireball launcher at MZ boss (MZ)

; spawned by:
;	ObjPos_MZ3
; ---------------------------------------------------------------------------

FireMakerBoss:
		bsr.s	FireM_Random
		
		shortcut
		move.w	(v_boss_ost_ptr).w,d0
		beq.w	DespawnQuick_NoDisplay			; branch if no boss loaded
		movea.w	d0,a1
		cmpi.l	#Boss,ost_id(a1)
		bne.w	DeleteObject				; branch if boss despawned
		btst	#bmove_hazard_bit,ost_boss2_flags(a1)
		beq.w	DespawnQuick_NoDisplay			; branch if hazard flag isn't set
		
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bne.w	DespawnQuick_NoDisplay			; branch if time remains
		bsr.w	FindFreeObj				; find free OST slot
		bne.w	DespawnQuick_NoDisplay			; branch if not found
		move.l	#FireBall,ost_id(a1)			; load fireball object
		move.b	#type_fire_gravity+4,ost_subtype(a1)	; set gravity & speed
		jsr	(RandomNumber).w
		andi.w	#$3F,d0
		andi.w	#$F,d1
		add.w	d1,d0					; random value 0-$4E
		add.w	ost_x_pos(a0),d0
		move.w	d0,ost_x_pos(a1)			; randomise x pos
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	#priority_5,ost_priority(a1)
		
		bsr.s	FireM_Random
		bra.w	DespawnQuick_NoDisplay
		
FireM_Random:
		jsr	(RandomNumber).w
		andi.b	#$1F,d0
		addi.b	#$40,d0
		move.b	d0,ost_anim_time(a0)			; set new timer (random value 64-95)
		rts
