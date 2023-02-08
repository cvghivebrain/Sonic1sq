; ---------------------------------------------------------------------------
; Object 3E - prison capsule

; spawned by:
;	ObjPos_GHZ3, ObjPos_MZ3, ObjPos_SYZ3, ObjPos_LZ3, ObjPos_SLZ3 - subtypes 0/1
; ---------------------------------------------------------------------------

Prison:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Pri_Index(pc,d0.w),d1
		jsr	Pri_Index(pc,d1.w)
		move.w	ost_x_pos(a0),d0
		jsr	CheckActive
		bne.s	.delete
		jmp	(DisplaySprite).l

	.delete:
		jmp	(DeleteObject).l
; ===========================================================================
Pri_Index:	index *,,2
		ptr Pri_Main
		ptr Pri_Body
		ptr Pri_Switch
		ptr Pri_Explosion
		ptr Pri_Animals
		ptr Pri_EndAct
		ptr Pri_Display

		rsobj Prison
ost_prison_y_start:	rs.w 1 ; $30				; original y position (2 bytes)
ost_prison_time:	rs.w 1 ; $3E
		rsobjend
; ===========================================================================

Pri_Main:	; Routine 0
		move.l	#Map_Pri,ost_mappings(a0)
		move.w	#tile_Art_Prison,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	ost_y_pos(a0),ost_prison_y_start(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype (0 or 1)
		beq.s	.main					; branch if 0
		move.b	#id_Pri_Switch,ost_routine(a0)		; goto Pri_Switch next
		move.b	#$C,ost_displaywidth(a0)
		move.b	#$C,ost_width(a0)
		move.b	#8,ost_height(a0)
		move.b	#5,ost_priority(a0)
		move.b	#id_frame_prison_switch1,ost_frame(a0)
		rts
		
	.main:
		move.b	#id_Pri_Body,ost_routine(a0)		; goto Pri_Body next
		move.b	#$20,ost_displaywidth(a0)
		move.b	#$20,ost_width(a0)
		move.b	#$20,ost_height(a0)
		move.b	#4,ost_priority(a0)
		move.b	#id_frame_prison_capsule,ost_frame(a0)
		moveq	#id_UPLC_Prison,d0
		jmp	UncPLC					; load prison gfx
; ===========================================================================

Pri_Body:	; Routine 2
		cmpi.b	#2,(v_boss_status).w			; has prison been opened?
		beq.s	.is_open				; if yes, branch
		jmp	(SolidNew).l
; ===========================================================================

.is_open:
		tst.b	ost_solid(a0)				; is Sonic on top of the prison?
		beq.s	.not_on_top				; if not, branch
		clr.b	ost_solid(a0)
		bclr	#status_platform_bit,(v_ost_player+ost_status).w
		bset	#status_air_bit,(v_ost_player+ost_status).w

	.not_on_top:
		move.b	#id_frame_prison_broken,ost_frame(a0)	; use use broken prison frame (2)
		moveq	#id_UPLC_Prison2,d0
		jsr	UncPLC					; load new gfx
		move.b	#id_Pri_Display,ost_routine(a0)		; goto Pri_Display next

Pri_Display:	; Routine $C
		rts	
; ===========================================================================

Pri_Switch:	; Routine 4
		jsr	(SolidNew).l
		lea	(Ani_Pri).l,a1
		jsr	(AnimateSprite).l
		move.w	ost_prison_y_start(a0),ost_y_pos(a0)
		tst.b	ost_solid(a0)				; is Sonic on top of the switch?
		beq.s	.not_on_top				; if not, branch

		addq.w	#8,ost_y_pos(a0)			; move switch down 8px
		move.b	#id_Pri_Explosion,ost_routine(a0)	; goto Pri_Explosion next
		move.w	#60,ost_prison_time(a0)			; set time for explosions to 1 sec
		clr.b	(f_hud_time_update).w			; stop time counter
		clr.b	(f_boss_boundary).w			; lock screen position
		move.b	#1,(f_lock_controls).w			; lock controls
		move.w	#(btnR<<8),(v_joypad_hold).w		; make Sonic run to the right
		clr.b	ost_solid(a0)
		bclr	#status_platform_bit,(v_ost_player+ost_status).w
		bset	#status_air_bit,(v_ost_player+ost_status).w

	.not_on_top:
		rts	
; ===========================================================================

Pri_Explosion:	; Routine 6, 8, $A
		moveq	#7,d0
		and.b	(v_vblank_counter_byte).w,d0		; byte that increments every frame
		bne.s	.noexplosion				; branch if any of bits 0-2 are set

		jsr	(FindFreeObj).l				; find free OST slot
		bne.s	.noexplosion				; branch if not found
		move.l	#ExplosionBomb,ost_id(a1)		; load explosion object every 8 frames
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		jsr	(RandomNumber).l
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,ost_x_pos(a1)			; pseudorandom position
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,ost_y_pos(a1)

	.noexplosion:
		subq.w	#1,ost_prison_time(a0)			; decrement timer
		beq.s	.makeanimal				; branch if 0
		rts	
; ===========================================================================

.makeanimal:
		move.b	#2,(v_boss_status).w			; set flag for prison open
		move.b	#id_Pri_Animals,ost_routine(a0)		; goto Pri_Animals next
		move.b	#id_frame_prison_blank,ost_frame(a0)	; make switch invisible
		move.w	#150,ost_prison_time(a0)		; set time for additional animals to load to 2.5 secs
		addi.w	#$20,ost_y_pos(a0)
		moveq	#8-1,d6					; number of animals to load
		move.w	#$9A,d5					; animal jumping queue start
		moveq	#-$1C,d4				; relative x position

	.loop:
		jsr	(FindFreeObj).l				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#Animals,ost_id(a1)			; load animal object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		add.w	d4,ost_x_pos(a1)
		addq.w	#7,d4					; next animal loads 7px right
		move.w	d5,ost_animal_prison_num(a1)		; give each animal a num so it jumps at a different time
		subq.w	#8,d5					; decrement queue number
		dbf	d6,.loop				; repeat 7 more	times

	.fail:
		rts	
; ===========================================================================

Pri_Animals:	; Routine $C
		moveq	#7,d0
		and.b	(v_vblank_counter_byte).w,d0		; byte that increments every frame
		bne.s	.noanimal				; branch if any of bits 0-2 are set

		jsr	(FindFreeObj).l				; find free OST slot
		bne.s	.noanimal				; branch if not found
		move.l	#Animals,ost_id(a1)			; load animal object every 8 frames
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		jsr	(RandomNumber).l
		andi.w	#$1F,d0
		subq.w	#6,d0
		tst.w	d1
		bpl.s	.ispositive
		neg.w	d0

	.ispositive:
		add.w	d0,ost_x_pos(a1)			; pseudorandom position
		move.w	#$C,ost_animal_prison_num(a1)		; set time for animal to jump out

	.noanimal:
		subq.w	#1,ost_prison_time(a0)			; decrement timer
		bne.s	.wait					; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Pri_EndAct next

	.wait:
		rts	
; ===========================================================================

Pri_EndAct:	; Routine $E
		moveq	#$40-2,d0
		move.l	#Animals,d1
		moveq	#sizeof_ost,d2				; d2 = $40
		lea	(v_ost_player+sizeof_ost).w,a1		; start at first OST slot after Sonic

	.findanimal:
		cmp.l	ost_id(a1),d1				; is object $28	(animal) loaded?
		beq.s	.found					; if yes, branch
		adda.w	d2,a1					; next OST slot
		dbf	d0,.findanimal				; repeat $3E times (this misses the last $40 OST slots)

		jsr	(HasPassedAct).l			; load gfx, play music (see "Signpost & HasPassedAct.asm")
		addq.l	#4,sp
		jmp	(DeleteObject).l

	.found:
		rts	

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Pri:	index *
		ptr ani_prison_switchflash
		ptr ani_prison_switchflash
		
ani_prison_switchflash:
		dc.w 2
		dc.w id_frame_prison_switch1
		dc.w id_frame_prison_switch2
		dc.w id_Anim_Flag_Restart
		even
