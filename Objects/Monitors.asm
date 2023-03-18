; ---------------------------------------------------------------------------
; Object 26 - monitors

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3 - subtypes 2/3/4/5/6
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 2/3/4/5/6
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_SYZ3 - subtypes 2/3/4/5/6
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3 - subtypes 2/4/5/6
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SLZ3 - subtypes 2/4/5/6
;	ObjPos_SBZ1, ObjPos_SBZ2, ObjPos_SBZ3 - subtypes 2/4/5/6
; ---------------------------------------------------------------------------

Monitor:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Mon_Index(pc,d0.w),d1
		jmp	Mon_Index(pc,d1.w)
; ===========================================================================
Mon_Index:	index *,,2
		ptr Mon_Main
		ptr Mon_Solid
		ptr Mon_Break
		ptr Mon_Animate
		ptr Mon_Display
		ptr Mon_Drop

		rsobj Monitor
ost_monitor_slot:	rs.b 1					; slot used by monitor (0-7; -1 if none)
		rsobjend
; ===========================================================================

Mon_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Mon_Solid next
		move.b	#$E,ost_height(a0)
		move.b	#$E,ost_width(a0)
		move.l	#Map_Monitor,ost_mappings(a0)
		move.w	#tile_Art_Monitors,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#3,ost_priority(a0)
		move.b	#$F,ost_displaywidth(a0)
		move.b	#-1,ost_monitor_slot(a0)		; assume there are no free slots
		bsr.w	GetState
		andi.b	#1,d0
		beq.s	.not_broken				; branch if monitor wasn't broken
		move.b	#id_Mon_Display,ost_routine(a0)		; goto Mon_Display next
		move.b	#id_frame_monitor_broken,ost_frame(a0)	; use broken monitor frame
		rts	
; ===========================================================================

	.not_broken:
		cmp.b	#type_monitor_1up,ost_subtype(a0)
		bne.s	.not_1up				; branch if monitor isn't a 1-up
		move.b	#id_ani_monitor_sonic,ost_anim(a0)	; use 1-up animation
		bra.s	Mon_Solid				; skip slot check
		
	.not_1up:
		bsr.w	Mon_FindSlot

Mon_Solid:	; Routine 2
		bsr.w	Mon_Solid_Detect
		cmpi.b	#solid_bottom,d1
		beq.s	.drop					; branch if hit from bottom
		cmpi.b	#4,ost_solid(a0)
		beq.s	.break					; branch if monitor was jumped on
		andi.b	#solid_left+solid_right,d1
		beq.w	Mon_Animate				; branch if no collision
		tst.w	ost_x_vel(a1)
		beq.w	Mon_Animate				; branch if Sonic isn't moving sideways
		tst.w	ost_y_vel(a1)
		bmi.w	Mon_Animate				; branch if Sonic is moving upwards
		cmpi.b	#id_Roll,ost_anim(a1)
		bne.w	Mon_Animate				; branch if Sonic isn't rolling/jumping
		
	.break:
		neg.w	ost_y_vel(a1)				; reverse Sonic's y speed
		addq.b	#2,ost_routine(a0)			; goto Mon_Break next
		bra.w	Mon_Animate
		
	.drop:
		move.w	#-$180,ost_y_vel(a0)			; move monitor upwards
		move.b	#id_Mon_Drop,ost_routine(a0)		; goto Mon_Drop next
		bra.w	Mon_Animate
; ===========================================================================

Mon_Break:	; Routine 4
		addq.b	#2,ost_routine(a0)			; goto Mon_Animate next
		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#PowerUp,ost_id(a1)			; load monitor contents object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	ost_subtype(a0),ost_subtype(a1)		; inherit subtype
		move.b	ost_monitor_slot(a0),ost_pow_slot(a1)
		move.b	#id_frame_monitor_static1,ost_frame(a1)	; use static icon by default
		cmp.b	#type_monitor_1up,ost_subtype(a0)
		bne.s	.not_1up				; branch if not 1-up
		move.b	#id_frame_monitor_sonic,ost_frame(a1)	; use 1-up icon instead
		
	.not_1up:
		tst.b	ost_monitor_slot(a0)
		bmi.s	.no_slot				; branch if monitor isn't using a slot
		move.b	ost_monitor_slot(a0),ost_frame(a1)

	.no_slot:
		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#ExplosionItem,ost_id(a1)		; load explosion object
		addq.b	#2,ost_routine(a1)			; don't create an animal
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)

	.fail:
		move.b	#id_ani_monitor_breaking,ost_anim(a0)	; set monitor type to broken
		move.b	#-1,ost_monitor_slot(a0)		; PowerUp object takes over the monitor slot
		bsr.w	SaveState
		beq.s	Mon_Animate
		bset	#0,(a2)					; remember broken

Mon_Animate:	; Routine 6
		lea	(Ani_Monitor).l,a1
		bsr.w	AnimateSprite

Mon_Display:	; Routine 8
		move.w	ost_x_pos(a0),d0
		bsr.w	CheckActive
		bne.s	.clear_slot
		bra.w	DisplaySprite
		
	.clear_slot:
		moveq	#0,d0
		move.b	ost_monitor_slot(a0),d0
		bmi.w	DeleteObject				; branch if slot isn't used
		lea	(v_monitor_slots).w,a1
		add.w	d0,d0
		subq.b	#1,(a1,d0.w)				; decrement slot usage counter
		bra.w	DeleteObject
; ===========================================================================

Mon_Drop:	; Routine $A
		bsr.w	ObjectFall				; apply gravity and update position
		jsr	(FindFloorObj).l
		tst.w	d1					; has monitor hit the floor?
		bpl.s	Mon_Animate				; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		clr.w	ost_y_vel(a0)				; stop moving
		move.b	#id_Mon_Solid,ost_routine(a0)		; goto Mon_Solid next
		bra.s	Mon_Animate

; ---------------------------------------------------------------------------
; Subroutine to	make a monitor solid (mostly the same as SolidObject)
; ---------------------------------------------------------------------------

Mon_Solid_Detect:
		tst.b	ost_render(a0)
		bpl.w	Sol_OffScreen				; branch if object isn't on screen
		tst.w	(v_debug_active_hi).w
		bne.w	Sol_None				; branch if debug mode is in use
		tst.b	ost_solid(a0)
		bne.w	Sol_Stand				; branch if Sonic is already standing on object
		bsr.w	RangePlusX				; get distances between Sonic (a1) and object (a0)
		cmp.w	#0,d1
		bgt.w	Sol_None				; branch if outside x hitbox
		bsr.w	RangePlusY2
		bpl.w	Sol_None				; branch if outside y hitbox
		
		cmp.w	d1,d3
		blt.w	.side					; branch if Sonic is to the side
		
		tst.w	d2
		bmi.w	.above					; branch if Sonic is above
		
		sub.w	d3,ost_y_pos(a1)			; snap to hitbox
		neg.w	ost_y_vel(a1)				; stop Sonic moving up
		moveq	#solid_bottom,d1			; set collision flag to bottom
		rts
		
	.side:
		cmpi.b	#id_Roll,ost_anim(a1)
		bne.w	Sol_Side				; use regular side collision if not rolling/jumping
		tst.w	d0
		bmi.s	.left					; branch if Sonic is on left side
		moveq	#solid_right,d1				; set collision flag to right
		rts
		
	.left:
		moveq	#solid_left,d1				; set collision flag to left
		rts
		
	.above:
		cmpi.b	#id_Roll,ost_anim(a1)
		bne.w	Sol_Above				; use regular top collision if not rolling/jumping
		tst.w	ost_y_vel(a1)
		bmi.w	Sol_None				; branch if Sonic is moving up
		add.w	d3,ost_y_pos(a1)			; snap to hitbox
		move.b	#4,ost_solid(a0)
		moveq	#solid_top,d1				; set collision flag to top
		rts
		
; ---------------------------------------------------------------------------
; Subroutine to	find a free monitor slot, set animation and load graphics

;	uses d0.l, d1.l, d2.l, d3.w, a1, a2
; ---------------------------------------------------------------------------

Mon_FindSlot:
		lea	(v_monitor_slots).w,a1
		movea.l	a1,a2
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		
		moveq	#8-1,d1					; number of slots to check
	.loop1:
		cmp.b	1(a1),d0
		beq.s	.found_match				; branch if type matches existing type
		adda.w	#2,a1					; next slot
		dbf	d1,.loop1				; repeat for all slots
		
		movea.l	a2,a1
		moveq	#8-1,d1
	.loop2:
		tst.w	(a1)
		beq.s	.found_empty				; branch if slot is fully empty
		adda.w	#2,a1					; next slot
		dbf	d1,.loop2				; repeat for all slots
		
		movea.l	a2,a1
		moveq	#8-1,d1
	.loop3:
		tst.b	(a1)
		beq.s	.found_empty				; branch if slot is available but not empty
		adda.w	#2,a1					; next slot
		dbf	d1,.loop3				; repeat for all slots
		
		move.b	#id_ani_monitor_static,ost_anim(a0)	; use static animation
		rts
		
	.found_match:
		addq.b	#1,(a1)+				; increment usage counter
		neg.w	d1
		addq.w	#7,d1					; convert d0 from 7~0 to 0~7
		move.b	d1,ost_monitor_slot(a0)
		move.b	d1,ost_anim(a0)
		rts
		
	.found_empty:
		bsr.s	.found_match				; set ost_anim & ost_monitor_slot
		move.b	d0,(a1)					; save type to slot
		
		set_dma_size	sizeof_cell*4,d2		; number of tiles to load
		add.w	d1,d1
		add.w	d1,d1					; d1 * 4
		move.l	Mon_GfxSlots(pc,d1.w),d1		; get VRAM address from list below
		add.w	d0,d0
		move.w	d0,d3
		add.w	d0,d0
		add.w	d3,d0					; d0 * 6
		lea	Mon_GfxSource(pc,d0.w),a2		; get ROM address for gfx
		jmp	AddDMA					; add gfx to DMA queue

Mon_GfxSlots:
		set_dma_dest	vram_monitors+$400
		set_dma_dest	vram_monitors+$480
		set_dma_dest	vram_monitors+$500
		set_dma_dest	vram_monitors+$580
		set_dma_dest	vram_monitors+$600
		set_dma_dest	vram_monitors+$680
		set_dma_dest	vram_monitors+$700
		set_dma_dest	vram_monitors+$780

Mon_GfxSource:
		set_dma_src	Art_EggmanIcon			; Eggman
		set_dma_src	Art_EggmanIcon			; Sonic (unused)
		set_dma_src	Art_ShoeIcon			; Speed shoes
		set_dma_src	Art_ShieldIcon			; Shield
		set_dma_src	Art_InvIcon			; Invincibility
		set_dma_src	Art_RingIcon			; Rings
		set_dma_src	Art_SIcon			; S
		set_dma_src	Art_GogglesIcon			; Goggles
		
countof_monitor_types:	equ (*-Mon_GfxSource)/6
; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Monitor:	index *
		ptr ani_monitor_0
		ptr ani_monitor_1
		ptr ani_monitor_2
		ptr ani_monitor_3
		ptr ani_monitor_4
		ptr ani_monitor_5
		ptr ani_monitor_6
		ptr ani_monitor_7
		ptr ani_monitor_static
		ptr ani_monitor_sonic
		ptr ani_monitor_breaking
		
ani_monitor_static:
		dc.w 1
		dc.w id_frame_monitor_static0
		dc.w id_frame_monitor_static1
		dc.w id_frame_monitor_static2
		dc.w id_Anim_Flag_Restart
		even

ani_monitor_sonic:
		dc.w 1
		dc.w id_frame_monitor_static0
		dc.w id_frame_monitor_sonic
		dc.w id_frame_monitor_sonic
		dc.w id_frame_monitor_static1
		dc.w id_frame_monitor_sonic
		dc.w id_frame_monitor_sonic
		dc.w id_frame_monitor_static2
		dc.w id_frame_monitor_sonic
		dc.w id_frame_monitor_sonic
		dc.w id_Anim_Flag_Restart
		even

ani_monitor_0:
		dc.w 1
		dc.w id_frame_monitor_static0
		dc.w id_frame_monitor_0
		dc.w id_frame_monitor_0
		dc.w id_frame_monitor_static1
		dc.w id_frame_monitor_0
		dc.w id_frame_monitor_0
		dc.w id_frame_monitor_static2
		dc.w id_frame_monitor_0
		dc.w id_frame_monitor_0
		dc.w id_Anim_Flag_Restart
		even

ani_monitor_1:
		dc.w 1
		dc.w id_frame_monitor_static0
		dc.w id_frame_monitor_1
		dc.w id_frame_monitor_1
		dc.w id_frame_monitor_static1
		dc.w id_frame_monitor_1
		dc.w id_frame_monitor_1
		dc.w id_frame_monitor_static2
		dc.w id_frame_monitor_1
		dc.w id_frame_monitor_1
		dc.w id_Anim_Flag_Restart
		even

ani_monitor_2:
		dc.w 1
		dc.w id_frame_monitor_static0
		dc.w id_frame_monitor_2
		dc.w id_frame_monitor_2
		dc.w id_frame_monitor_static1
		dc.w id_frame_monitor_2
		dc.w id_frame_monitor_2
		dc.w id_frame_monitor_static2
		dc.w id_frame_monitor_2
		dc.w id_frame_monitor_2
		dc.w id_Anim_Flag_Restart
		even

ani_monitor_3:
		dc.w 1
		dc.w id_frame_monitor_static0
		dc.w id_frame_monitor_3
		dc.w id_frame_monitor_3
		dc.w id_frame_monitor_static1
		dc.w id_frame_monitor_3
		dc.w id_frame_monitor_3
		dc.w id_frame_monitor_static2
		dc.w id_frame_monitor_3
		dc.w id_frame_monitor_3
		dc.w id_Anim_Flag_Restart
		even

ani_monitor_4:
		dc.w 1
		dc.w id_frame_monitor_static0
		dc.w id_frame_monitor_4
		dc.w id_frame_monitor_4
		dc.w id_frame_monitor_static1
		dc.w id_frame_monitor_4
		dc.w id_frame_monitor_4
		dc.w id_frame_monitor_static2
		dc.w id_frame_monitor_4
		dc.w id_frame_monitor_4
		dc.w id_Anim_Flag_Restart
		even

ani_monitor_5:
		dc.w 1
		dc.w id_frame_monitor_static0
		dc.w id_frame_monitor_5
		dc.w id_frame_monitor_5
		dc.w id_frame_monitor_static1
		dc.w id_frame_monitor_5
		dc.w id_frame_monitor_5
		dc.w id_frame_monitor_static2
		dc.w id_frame_monitor_5
		dc.w id_frame_monitor_5
		dc.w id_Anim_Flag_Restart
		even

ani_monitor_6:
		dc.w 1
		dc.w id_frame_monitor_static0
		dc.w id_frame_monitor_6
		dc.w id_frame_monitor_6
		dc.w id_frame_monitor_static1
		dc.w id_frame_monitor_6
		dc.w id_frame_monitor_6
		dc.w id_frame_monitor_static2
		dc.w id_frame_monitor_6
		dc.w id_frame_monitor_6
		dc.w id_Anim_Flag_Restart
		even

ani_monitor_7:
		dc.w 1
		dc.w id_frame_monitor_static0
		dc.w id_frame_monitor_7
		dc.w id_frame_monitor_7
		dc.w id_frame_monitor_static1
		dc.w id_frame_monitor_7
		dc.w id_frame_monitor_7
		dc.w id_frame_monitor_static2
		dc.w id_frame_monitor_7
		dc.w id_frame_monitor_7
		dc.w id_Anim_Flag_Restart
		even

ani_monitor_breaking:
		dc.w 2
		dc.w id_frame_monitor_static0
		dc.w id_frame_monitor_static1
		dc.w id_frame_monitor_static2
		dc.w id_frame_monitor_broken
		dc.w id_Anim_Flag_Back, 1
		even
