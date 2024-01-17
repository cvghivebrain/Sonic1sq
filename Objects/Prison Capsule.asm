; ---------------------------------------------------------------------------
; Object 3E - prison capsule

; spawned by:
;	ObjPos_GHZ3, ObjPos_MZ3, ObjPos_SYZ3, ObjPos_LZ3, ObjPos_SLZ3
;	Prison
; ---------------------------------------------------------------------------

Prison:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Pri_Index(pc,d0.w),d1
		jmp	Pri_Index(pc,d1.w)
; ===========================================================================
Pri_Index:	index *,,2
		ptr Pri_Main
		ptr Pri_Body
		ptr Pri_Switch
		ptr Pri_Explosion
		ptr Pri_Animals
		ptr Pri_EndAct

		rsobj Prison
ost_prison_time:	rs.w 1
		rsobjend
; ===========================================================================

Pri_Main:	; Routine 0
		move.l	#Map_Pri,ost_mappings(a0)
		move.w	#tile_Art_Prison,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#id_Pri_Body,ost_routine(a0)		; goto Pri_Body next
		move.b	#$20,ost_displaywidth(a0)
		move.b	#$20,ost_width(a0)
		move.b	#$20,ost_height(a0)
		move.b	#priority_4,ost_priority(a0)
		move.b	#id_frame_prison_capsule,ost_frame(a0)
		moveq	#id_UPLC_Prison,d0
		jsr	UncPLC					; load prison gfx
		
		jsr	FindFreeObj				; find free OST slot
		bne.s	.fail
		move.l	#Prison,ost_id(a1)			; load switch object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		subi.w	#37,ost_y_pos(a1)			; switch is 37px above prison
		move.b	#id_Pri_Switch,ost_routine(a1)		; goto Pri_Switch next
		move.b	ost_render(a0),ost_render(a1)
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	#$C,ost_displaywidth(a1)
		move.b	#$C,ost_width(a1)
		move.b	#8,ost_height(a1)
		move.b	#priority_5,ost_priority(a1)
		move.b	#id_frame_prison_switch1,ost_frame(a1)
		
	.fail:
		jmp	DespawnQuick
; ===========================================================================

Pri_Body:	; Routine 2
		cmpi.b	#2,(v_boss_status).w			; has prison been opened?
		beq.s	.is_open				; if yes, branch
		tst.b	ost_subtype(a0)
		beq.s	.update_boundary
		
	.solid:
		jsr	SolidObject
		
	.skip_solid:
		jmp	DespawnQuick
		
.update_boundary:
		tst.b	ost_render(a0)
		bpl.s	.skip_solid				; branch if off screen
		cmpi.b	#1,(v_boss_status).w
		bne.s	.solid					; branch if boss isn't beaten
		move.w	ost_x_pos(a0),d0
		subi.w	#screen_width/2,d0
		move.w	d0,(v_boundary_right_next).w		; lock screen with prison in centre
		move.b	#1,ost_subtype(a0)			; don't repeat this check
		bra.s	.solid

.is_open:
		tst.b	ost_mode(a0)				; is Sonic on top of the prison?
		beq.s	.not_on_top				; if not, branch
		jsr	UnSolid

	.not_on_top:
		move.b	#id_frame_prison_broken,ost_frame(a0)	; use use broken prison frame (2)
		moveq	#id_UPLC_Prison2,d0
		jsr	UncPLC					; load new gfx
		shortcut	DespawnQuick
		jmp	DespawnQuick
; ===========================================================================

Pri_Switch:	; Routine 4
		lea	(Ani_Pri).l,a1
		jsr	AnimateSprite
		jsr	SolidObject
		andi.b	#solid_top,d1
		bne.s	.on_top					; branch if Sonic is on top of switch
		jmp	DespawnQuick

	.on_top:
		addq.w	#8,ost_y_pos(a0)			; move switch down 8px
		move.b	#id_Pri_Explosion,ost_routine(a0)	; goto Pri_Explosion next
		move.w	#60,ost_prison_time(a0)			; set time for explosions to 1 sec
		clr.b	(f_hud_time_update).w			; stop time counter
		clr.b	(f_boss_loaded).w
		move.b	#1,(f_lock_controls).w			; lock controls
		move.w	#(btnR<<8),(v_joypad_hold).w		; make Sonic run to the right
		jsr	UnSolid
		jmp	DespawnQuick
; ===========================================================================

Pri_Explosion:	; Routine 6
		subq.w	#1,ost_prison_time(a0)			; decrement timer
		beq.s	.makeanimal				; branch if 0
		moveq	#0,d0
		moveq	#7,d1
		bsr.w	Exploding				; create explosions every 8th frame
		jmp	DespawnQuick
; ===========================================================================

.makeanimal:
		move.b	#2,(v_boss_status).w			; set flag for prison open
		move.b	#id_Pri_Animals,ost_routine(a0)		; goto Pri_Animals next
		move.w	#150,ost_prison_time(a0)		; set time for additional animals to load to 2.5 secs
		addi.w	#$20,ost_y_pos(a0)
		moveq	#8-1,d6					; number of animals to load
		move.w	#$9A,d5					; animal jumping queue start
		moveq	#-$1C,d4				; relative x position

	.loop:
		jsr	FindFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#Animals,ost_id(a1)			; load animal object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		add.w	d4,ost_x_pos(a1)
		addq.w	#7,d4					; next animal loads 7px right
		move.w	d5,ost_animal_delay(a1)			; give each animal a num so it jumps at a different time
		subq.w	#8,d5					; decrement queue number
		dbf	d6,.loop				; repeat 7 more	times

	.fail:
		jmp	DespawnQuick_NoDisplay
; ===========================================================================

Pri_Animals:	; Routine 8
		moveq	#7,d0
		and.b	(v_vblank_counter_byte).w,d0		; byte that increments every frame
		bne.s	.noanimal				; branch if any of bits 0-2 are set

		jsr	(FindFreeObj).l				; find free OST slot
		bne.s	.noanimal				; branch if not found
		move.l	#Animals,ost_id(a1)			; load animal object every 8 frames
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		jsr	(RandomNumber).w
		andi.w	#$1F,d0
		subq.w	#6,d0
		tst.w	d1
		bpl.s	.ispositive
		neg.w	d0

	.ispositive:
		add.w	d0,ost_x_pos(a1)			; pseudorandom position
		move.w	#$C,ost_animal_delay(a1)		; set time for animal to jump out

	.noanimal:
		subq.w	#1,ost_prison_time(a0)			; decrement timer
		bne.s	.wait					; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Pri_EndAct next

	.wait:
		jmp	DespawnQuick_NoDisplay
; ===========================================================================

Pri_EndAct:	; Routine $A
		tst.b	(v_animal_count).w
		bne.s	.found					; branch if animals are still here
		jsr	(HasPassedAct).l			; load gfx, play music (see "Signpost & HasPassedAct.asm")
		jmp	(DeleteObject).l

	.found:
		jmp	DespawnQuick_NoDisplay

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Pri:	index *
		ptr ani_prison_switchflash
		
ani_prison_switchflash:
		dc.w 2
		dc.w id_frame_prison_switch1
		dc.w id_frame_prison_switch2
		dc.w id_Anim_Flag_Restart
