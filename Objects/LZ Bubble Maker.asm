; ---------------------------------------------------------------------------
; Bubble maker that sits on the floor and spits out bubbles (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3, ObjPos_SBZ3 - subtypes 0/1/2

; subtypes:
;	%0000NNNN
;	NNNN - number of bubble cycles that don't have a large bubble
; ---------------------------------------------------------------------------

BubbleMaker:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	BubM_Index(pc,d0.w),d1
		jmp	BubM_Index(pc,d1.w)
; ===========================================================================
BubM_Index:	index *,,2
		ptr BubM_Main
		ptr BubM_Wait
		ptr BubM_Active

		rsobj BubbleMaker
ost_bubble_freq:	rs.b 1					; number of cycles between large bubbles
ost_bubble_mini_count:	rs.b 1					; number of smaller bubbles to spawn
ost_bubble_wait_time:	rs.w 1					; general timer
ost_bubble_flag:	rs.b 1					; flag set when a big bubble has spawned
ost_bubble_mini_index:	rs.b 1					; position within bubble type list
		rsobjend
; ===========================================================================

BubM_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto BubM_Wait next
		move.l	#Map_Bub,ost_mappings(a0)
		move.w	(v_tile_bubbles).w,ost_tile(a0)
		ori.w	#tile_hi,ost_tile(a0)
		move.b	#render_onscreen+render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#1,ost_priority(a0)
		move.b	#id_ani_bubble_bubmaker,ost_anim(a0)
		move.b	ost_subtype(a0),d0
		andi.b	#$F,d0					; low nybble of subtype
		move.b	d0,ost_bubble_freq(a0)			; set as frequency
		
BubM_Wait:	; Routine 2
		move.w	(v_water_height_actual).w,d0
		cmp.w	ost_y_pos(a0),d0
		bcc.w	DespawnQuick_NoDisplay			; branch if not underwater
		
		subq.w	#1,ost_bubble_wait_time(a0)		; decrement timer
		bpl.s	.animate				; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto BubM_Active next

	.rand_0_to_5:
		jsr	(RandomNumber).l
		andi.w	#7,d0					; d0 = random 0-7
		cmpi.w	#6,d0
		bcc.s	.rand_0_to_5				; branch if 6 or 7
		move.b	d0,ost_bubble_mini_count(a0)		; set number of bubbles to spawn
		andi.w	#$C,d1					; read only bits 2-3 of random number
		move.b	d1,ost_bubble_mini_index(a0)		; set bubble pattern
		clr.w	ost_bubble_wait_time(a0)		; first bubble spawns immediately
		clr.b	ost_bubble_flag(a0)
		
	.animate:
		lea	(Ani_BubM).l,a1
		jsr	(AnimateSprite).l
		bra.w	DespawnQuick
; ===========================================================================
		
BubM_Active:	; Routine 4
		move.w	(v_water_height_actual).w,d0
		cmp.w	ost_y_pos(a0),d0
		bcc.w	DespawnQuick_NoDisplay			; branch if not underwater
		
		subq.w	#1,ost_bubble_wait_time(a0)		; decrement timer
		bpl.w	.animate				; branch if time remains
		jsr	(RandomNumber).l
		andi.w	#$1F,d0
		move.w	d0,ost_bubble_wait_time(a0)		; set next time (0-31 frames)
		bsr.w	FindFreeObj				; find free OST slot
		bne.w	.fail					; branch if not found
		move.l	#Bubble,ost_id(a1)			; load mini bubble object
		andi.w	#$F,d1
		subq.w	#8,d1					; d1 = random number between -8 and 8
		add.w	ost_x_pos(a0),d1
		move.w	d1,ost_x_pos(a1)			; x pos is within 8px either side of start
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		moveq	#0,d0
		move.b	ost_bubble_mini_index(a0),d0
		move.b	BubM_Mini_List(pc,d0.w),ost_subtype(a1)	; get subtype from list based on random number
		addq.b	#1,ost_bubble_mini_index(a0)
		
		tst.b	ost_bubble_freq(a0)
		bne.s	.fail					; branch if current sequence shouldn't contain a big bubble
		tst.b	ost_bubble_flag(a0)
		bne.s	.fail					; branch if big bubble already spawned
		tst.b	ost_bubble_mini_count(a0)
		beq.s	.force_big				; branch if this is the last bubble
		move.b	(v_frame_counter_low).w,d0
		andi.b	#3,d0
		bne.s	.fail					; branch if two random bits aren't both 0
		
	.force_big:
		move.b	#2,ost_subtype(a1)			; convert mini bubble to big bubble
		move.b	#1,ost_bubble_flag(a0)			; don't spawn another big bubble
		
	.fail:
		subq.b	#1,ost_bubble_mini_count(a0)		; decrement bubble counter
		bpl.s	.animate				; branch if not -1
		subq.b	#2,ost_routine(a0)			; goto BubM_Wait next
		subq.b	#1,ost_bubble_freq(a0)			; decrement frequency counter
		bpl.s	.keep_freq				; branch if frequency is 0+
		move.b	ost_subtype(a0),d0
		andi.b	#$F,d0					; low nybble of subtype
		move.b	d0,ost_bubble_freq(a0)			; set as frequency
		
	.keep_freq:
		jsr	(RandomNumber).l
		andi.w	#$7F,d0
		addi.w	#$80,d0
		move.w	d0,ost_bubble_wait_time(a0)		; set time until next sequence
		
	.animate:
		lea	Ani_BubM(pc),a1
		jsr	(AnimateSprite).l
		bra.w	DespawnQuick
		
BubM_Mini_List:	dc.b 0, 1, 0, 0, 0, 0				; 0 = small, 1 = medium
		dc.b 1, 0, 0, 0, 0, 1
		dc.b 0, 1, 0, 0, 1, 0
		even

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_BubM:	index *
		ptr ani_bubble_bubmaker
		
ani_bubble_bubmaker:						; bubble maker on the floor
		dc.w $F
		dc.w id_frame_bubble_bubmaker1
		dc.w id_frame_bubble_bubmaker2
		dc.w id_frame_bubble_bubmaker3
		dc.w id_Anim_Flag_Restart
