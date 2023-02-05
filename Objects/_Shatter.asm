; ---------------------------------------------------------------------------
; Subroutine to	smash a	block (GHZ/SLZ walls and MZ blocks)
;
; input:
;	d2.w = gravity for fragments
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
		move.w	d2,ost_inertia(a1)
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
		move.w	ost_inertia(a0),d0			; get gravity
		add.w	d0,ost_y_vel(a0)			; make fragment fall faster
		tst.b	ost_render(a0)				; is fragment on-screen?
		bpl.w	DeleteObject				; if not, branch
		bra.w	DisplaySprite
