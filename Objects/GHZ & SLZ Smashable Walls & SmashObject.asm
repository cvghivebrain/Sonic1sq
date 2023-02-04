; ---------------------------------------------------------------------------
; Object 3C - smashable	wall (GHZ, SLZ)

; spawned by:
;	ObjPos_GHZ2, ObjPos_GHZ3 - subtypes 0/1/2
;	ObjPos_SLZ1, ObjPos_SLZ3 - subtype 1
; ---------------------------------------------------------------------------

SmashWall:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Smash_Index(pc,d0.w),d1
		jmp	Smash_Index(pc,d1.w)
; ===========================================================================
Smash_Index:	index *,,2
		ptr Smash_Main
		ptr Smash_Solid
; ===========================================================================

Smash_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Smash_Solid next
		move.l	#Map_Smash,ost_mappings(a0)
		move.w	(v_tile_wall).w,ost_tile(a0)
		add.w	#tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#4,ost_priority(a0)
		move.b	ost_subtype(a0),ost_frame(a0)
		move.b	#16,ost_width(a0)
		move.b	#32,ost_height(a0)

Smash_Solid:	; Routine 2
		bsr.w	SolidNew
		andi.b	#4+8,d1
		beq.s	.dont_break				; branch if no collision with left/right
		cmpi.b	#id_Roll,ost_anim(a1)
		bne.s	.dont_break				; branch if Sonic isn't rolling
		move.w	ost_x_vel(a1),d0			; get Sonic's speed
		abs.w	d0					; make it +ve
		cmpi.w	#$480,d0
		bcs.s	.dont_break				; branch if speed is too low
		lea	Smash_FragRight(pc),a4			; use fragments that move right
		andi.b	#8,d1
		bne.s	.right					; branch if collision with right side
		lea	Smash_FragLeft(pc),a4			; use fragments that move left
		
	.right:
		bsr.s	Shatter
		
	.dont_break:
		bra.w	DespawnObject
		
Smash_FragRight:
		dc.w $400, -$500				; x speed, y speed
		dc.w $600, -$100
		dc.w $600, $100
		dc.w $400, $500
		dc.w $600, -$600
		dc.w $800, -$200
		dc.w $800, $200
		dc.w $600, $600

Smash_FragLeft:	dc.w -$600, -$600
		dc.w -$800, -$200
		dc.w -$800, $200
		dc.w -$600, $600
		dc.w -$400, -$500
		dc.w -$600, -$100
		dc.w -$600, $100
		dc.w -$400, $500
		
; ---------------------------------------------------------------------------
; Subroutine to	smash a	block (GHZ/SLZ walls and MZ blocks)
;
; input:
;	a4 = address of list of x/y speed values for each fragment

;	uses d0.l, d1.w, a1, a2
; ---------------------------------------------------------------------------

Shatter:
		moveq	#0,d0
		move.b	ost_frame(a0),d0
		add.w	d0,d0
		movea.l	ost_mappings(a0),a2			; get mappings address
		adda.w	(a2,d0.w),a2				; jump to frame
		move.w	(a2)+,d1				; get number of sprites
		subi.w	#1,d1					; -1 for loops
		
	.loop:
		bsr.w	FindNextFreeObj
		bne.s	.fail
		move.l	#Fragment,ost_id(a1)			; load fragment object
		move.l	a2,ost_mappings(a1)			; raw mappings
		adda.l	#6,a2					; next piece in mappings
		move.b	#render_rel+render_rawmap+render_onscreen,ost_render(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_priority(a0),ost_priority(a1)
		move.b	ost_displaywidth(a0),ost_displaywidth(a1)
		move.w	(a4)+,ost_x_vel(a1)
		move.w	(a4)+,ost_y_vel(a1)
		dbf	d1,.loop				; repeat for all sprite pieces
		
	.fail:
		bsr.w	DeleteObject				; delete parent object
		play.w	1, jmp, sfx_Smash			; play smashing sound
		
; ---------------------------------------------------------------------------
; Fragment of shattered object

; spawned by:
;	SmashWall
; ---------------------------------------------------------------------------

Fragment:
		bsr.w	SpeedToPos				; update position
		addi.w	#$70,ost_y_vel(a0)			; make fragment fall faster
		tst.b	ost_render(a0)				; is fragment on-screen?
		bpl.w	DeleteObject				; if not, branch
		bra.w	DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to	smash a	block (GHZ walls and MZ	blocks)
;
; input:
;	d1 = number of fragments to load, minus 1
;	d2 = initial gravity (added to y speed of each fragment)
; ---------------------------------------------------------------------------

SmashObject:
		moveq	#0,d0
		move.b	ost_frame(a0),d0
		add.w	d0,d0
		movea.l	ost_mappings(a0),a3			; get mappings address
		adda.w	(a3,d0.w),a3				; jump to frame
		addq.w	#2,a3					; use first sprite piece from that frame
		bset	#render_rawmap_bit,ost_render(a0)	; raw sprite
		move.l	ost_id(a0),d4
		move.b	ost_render(a0),d5
		movea.l	a0,a1
		bra.s	.loadfrag
; ===========================================================================

	.loop:
		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.playsnd				; branch if not found
		addq.w	#6,a3					; next sprite in mappings frame

.loadfrag:
		move.b	#4,ost_routine(a1)
		move.l	d4,ost_id(a1)
		move.l	a3,ost_mappings(a1)
		move.b	d5,ost_render(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_priority(a0),ost_priority(a1)
		move.b	ost_displaywidth(a0),ost_displaywidth(a1)
		move.w	(a4)+,ost_x_vel(a1)
		move.w	(a4)+,ost_y_vel(a1)
		cmpa.l	a0,a1					; is parent OST before fragment OST in RAM?
		bcc.s	.parent_earlier				; if yes, branch

		; fragment OST is before parent, so Smash_FragMove must be duplicated here
		move.l	a0,-(sp)
		movea.l	a1,a0
		bsr.w	SpeedToPos				; update position now
		add.w	d2,ost_y_vel(a0)			; apply gravity
		movea.l	(sp)+,a0
		bsr.w	DisplaySprite_a1

	.parent_earlier:
		dbf	d1,.loop

	.playsnd:
		play.w	1, jmp, sfx_Smash			; play smashing sound
