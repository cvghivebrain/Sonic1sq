; ---------------------------------------------------------------------------
; Dynamic level events

;	uses d0.l, d1.w, d2.l, a1
; ---------------------------------------------------------------------------

DynamicLevelEvents:
		move.l	(v_dle_ptr).w,d0
		beq.s	.keep_boundary				; branch if pointer is empty
		movea.l	d0,a1
		jsr	(a1)					; update v_boundary_bottom_next if needed
		moveq	#2,d2
		move.w	(v_boundary_bottom_next).w,d1		; new boundary y pos is written here
		sub.w	(v_boundary_bottom).w,d1
		beq.s	.keep_boundary				; branch if boundary is where it should be
		bcc.s	.move_boundary_down			; branch if new boundary is below current one

		neg.w	d2
		move.w	(v_camera_y_pos).w,d1
		cmp.w	(v_boundary_bottom_next).w,d1
		bls.s	.camera_below				; branch if camera y pos is above boundary
		andi.w	#$FFFE,d1				; round down to nearest 2px
		move.w	d1,(v_boundary_bottom).w

	.camera_below:
		add.w	d2,(v_boundary_bottom).w		; move boundary up 2px
		move.b	#1,(f_boundary_bottom_change).w

	.keep_boundary:
		moveq	#2,d2
		move.w	(v_boundary_right_next).w,d1
		sub.w	(v_boundary_right).w,d1
		beq.s	.keep_right				; branch if right boundary is unchanged
		bpl.s	.move_right				; branch if new boundary is right of current one
		neg.w	d2

	.move_right:
		add.w	d2,(v_boundary_right).w			; update boundary

	.keep_right:
		rts
; ===========================================================================

.move_boundary_down:
		move.w	(v_camera_y_pos).w,d1
		addq.w	#8,d1
		cmp.w	(v_boundary_bottom).w,d1
		bcs.s	.down_2px				; branch if boundary is at least 8px below camera
		btst	#status_air_bit,(v_ost_player+ost_status).w
		beq.s	.down_2px				; branch if Sonic isn't in the air
		moveq	#8,d2					; boundary moves 8px instead of 2px

	.down_2px:
		add.w	d2,(v_boundary_bottom).w		; move boundary down 2px (or 8px)
		move.b	#1,(f_boundary_bottom_change).w
		bra.s	.keep_boundary

; ---------------------------------------------------------------------------
; Green	Hill Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_GHZ1:
		lea	DLE_GHZ1_Sect(pc),a1

; ---------------------------------------------------------------------------
; Subroutine to update level boundaries

; input:
;	a1 = address of section & camera boundary data

; output:
;	d0.w = v_camera_x_pos

;	uses d0.w, a1
; ---------------------------------------------------------------------------

DLE_BoundaryUpdate:
		move.w	(v_dle_section).w,d0
		adda.w	d0,a1					; jump to current section
		move.w	(v_camera_x_pos).w,d0
		cmp.w	(a1),d0
		bcs.s	.prev_sect				; branch if camera is left of section
		cmp.w	6(a1),d0
		bcc.s	.next_sect				; branch if camera is right of next section
		rts

	.prev_sect:
		subq.w	#6,(v_dle_section).w
		move.w	-4(a1),(v_boundary_top).w
		move.w	-2(a1),(v_boundary_bottom_next).w
		rts

	.next_sect:
		addq.w	#6,(v_dle_section).w
		move.w	8(a1),(v_boundary_top).w
		move.w	10(a1),(v_boundary_bottom_next).w
		rts

DLE_GHZ1_Sect:	dc.w 0, 0, $300					; v_camera_x_pos, v_boundary_top, v_boundary_bottom_next
		dc.w $1780, 0, $400
		dc.w -1
; ===========================================================================

DLE_GHZ2:
		lea	DLE_GHZ2_Sect(pc),a1
		bra.s	DLE_BoundaryUpdate

DLE_GHZ2_Sect:	dc.w 0, 0, $300
		dc.w $ED0, 0, $200
		dc.w $1600, 0, $400
		dc.w $1D60, 0, $300
		dc.w -1
; ===========================================================================

DLE_GHZ3:
		lea	DLE_GHZ3_Sect(pc),a1
		bra.s	DLE_BoundaryUpdate

DLE_GHZ3_Sect:	dc.w 0, 0, $300
		dc.w $380, 0, $310
		dc.w $960, 0, $4C0
		dc.w $1700, 0, $300
		dc.w -1

; ---------------------------------------------------------------------------
; Labyrinth Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_LZ3:
		tst.b	(v_button_state+$F).w			; has switch $F	been pressed?
		beq.s	.skip_layout				; if not, branch
		lea	(v_level_layout+(sizeof_levelrow*2)+6).w,a1 ; address of layout at row 2, column 6
		cmpi.b	#7,(a1)
		beq.s	.skip_layout				; branch if already modified
		move.b	#7,(a1)					; modify level layout
		play.w	1, jsr, sfx_Rumbling			; play rumbling sound

	.skip_layout:
		tst.b	(v_dle_routine).w
		bne.s	.skip_boss				; branch if boss is already loaded
		cmpi.w	#$1CA0,(v_camera_x_pos).w
		bcs.s	.skip_boss2				; branch if camera is left of $1CA0
		cmpi.w	#$600,(v_camera_y_pos).w
		bcc.s	.skip_boss2				; branch if camera is below $600

		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#BossLabyrinth,ost_id(a1)		; load LZ boss object

	.fail:
		play.w	0, jsr, mus_Boss			; play boss music
		move.b	#1,(f_boss_loaded).w			; lock screen
		addq.b	#2,(v_dle_routine).w			; don't load boss again
		rts
; ===========================================================================

.skip_boss2:
		rts
; ===========================================================================

.skip_boss:
		rts
; ===========================================================================

DLE_SBZ3:
		cmpi.w	#$D00,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $D00
		cmpi.w	#$18,(v_ost_player+ost_y_pos).w		; has Sonic reached the top of the level?
		bcc.s	.exit					; if not, branch

		clr.b	(v_last_lamppost).w
		move.w	#1,(f_restart).w			; restart level
		move.w	#id_FZ,(v_zone).w			; set level number to 0502 (FZ)
		move.b	#1,(v_lock_multi).w			; lock controls, position & animation

	.exit:
		rts

; ---------------------------------------------------------------------------
; Marble Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_MZ1:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_MZ1_Index(pc,d0.w),d0
		jmp	DLE_MZ1_Index(pc,d0.w)
; ===========================================================================
DLE_MZ1_Index:	index *
		ptr DLE_MZ1_0
		ptr DLE_MZ1_2
		ptr DLE_MZ1_4
		ptr DLE_MZ1_6
; ===========================================================================

DLE_MZ1_0:
		move.w	#$1D0,(v_boundary_bottom_next).w
		cmpi.w	#$700,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $700

		move.w	#$220,(v_boundary_bottom_next).w
		cmpi.w	#$D00,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $D00

		move.w	#$340,(v_boundary_bottom_next).w
		cmpi.w	#$340,(v_camera_y_pos).w
		bcs.s	.exit					; branch if camera is above $340

		addq.b	#2,(v_dle_routine).w			; goto DLE_MZ1_2 next

	.exit:
		rts
; ===========================================================================

DLE_MZ1_2:
		cmpi.w	#$340,(v_camera_y_pos).w
		bcc.s	.next					; branch if camera is below $340

		subq.b	#2,(v_dle_routine).w			; goto DLE_MZ1_0 next
		rts
; ===========================================================================

.next:
		move.w	#0,(v_boundary_top).w
		cmpi.w	#$E00,(v_camera_x_pos).w
		bcc.s	.exit					; branch if camera is right of $E00

		move.w	#$340,(v_boundary_top).w
		move.w	#$340,(v_boundary_bottom_next).w
		cmpi.w	#$A90,(v_camera_x_pos).w
		bcc.s	.exit					; branch if camera is right of $A90

		move.w	#$500,(v_boundary_bottom_next).w
		cmpi.w	#$370,(v_camera_y_pos).w
		bcs.s	.exit					; branch if camera is above $370

		addq.b	#2,(v_dle_routine).w			; goto DLE_MZ1_4 next

	.exit:
		rts
; ===========================================================================

DLE_MZ1_4:
		cmpi.w	#$370,(v_camera_y_pos).w
		bcc.s	.next					; branch if camera is below $370

		subq.b	#2,(v_dle_routine).w			; goto DLE_MZ1_2 next
		rts
; ===========================================================================

.next:
		cmpi.w	#$500,(v_camera_y_pos).w
		bcs.s	.exit					; branch if camera is above $500
		cmpi.w	#$B80,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $B80
		move.w	#$500,(v_boundary_top).w
		addq.b	#2,(v_dle_routine).w			; goto DLE_MZ1_6 next

	.exit:
		rts
; ===========================================================================

DLE_MZ1_6:
		cmpi.w	#$B80,(v_camera_x_pos).w
		bcc.s	.skip_mid				; branch if camera is right of $B80

		cmpi.w	#$340,(v_boundary_top).w
		beq.s	.exit					; branch if top boundary is set for middle section

		subq.w	#2,(v_boundary_top).w			; move top boundary up 2px
		rts
	.skip_mid:
		cmpi.w	#$500,(v_boundary_top).w
		beq.s	.skip_btm				; branch if top boundary is set for bottom section

		cmpi.w	#$500,(v_camera_y_pos).w
		bcs.s	.exit					; branch if camera is above $500

		move.w	#$500,(v_boundary_top).w
	.skip_btm:

		cmpi.w	#$E70,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $E70

		move.w	#0,(v_boundary_top).w
		move.w	#$500,(v_boundary_bottom_next).w
		cmpi.w	#$1430,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $1430

		move.w	#$210,(v_boundary_bottom_next).w

	.exit:
		rts
; ===========================================================================

DLE_MZ2:
		move.w	#$520,(v_boundary_bottom_next).w
		cmpi.w	#$1700,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $1700

		move.w	#$200,(v_boundary_bottom_next).w

	.exit:
		rts
; ===========================================================================

DLE_MZ3:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_MZ3_Index(pc,d0.w),d0
		jmp	DLE_MZ3_Index(pc,d0.w)
; ===========================================================================
DLE_MZ3_Index:	index *
		ptr DLE_MZ3_Boss
		ptr DLE_MZ3_End
; ===========================================================================

DLE_MZ3_Boss:
		move.w	#$720,(v_boundary_bottom_next).w
		cmpi.w	#$1560,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $1560

		move.w	#$210,(v_boundary_bottom_next).w
		cmpi.w	#$17F0,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $17F0

		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#BossMarble,ost_id(a1)			; load MZ boss object
		move.w	#$19F0,ost_x_pos(a1)
		move.w	#$22C,ost_y_pos(a1)

	.fail:
		play.w	0, jsr, mus_Boss			; play boss music
		move.b	#1,(f_boss_loaded).w			; lock screen
		addq.b	#2,(v_dle_routine).w			; goto DLE_MZ3_End next
		rts
; ===========================================================================

.exit:
		rts
; ===========================================================================

DLE_MZ3_End:
		move.w	(v_camera_x_pos).w,(v_boundary_left).w	; set boundary to current position
		rts

; ---------------------------------------------------------------------------
; Star Light Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_SLZ3:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_SLZ3_Index(pc,d0.w),d0
		jmp	DLE_SLZ3_Index(pc,d0.w)
; ===========================================================================
DLE_SLZ3_Index:	index *
		ptr DLE_SLZ3_Main
		ptr DLE_SLZ3_Boss
		ptr DLE_SLZ3_End
; ===========================================================================

DLE_SLZ3_Main:
		cmpi.w	#$1E70,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $1E70

		move.w	#$210,(v_boundary_bottom_next).w
		addq.b	#2,(v_dle_routine).w			; goto DLE_SLZ3_Boss next

	.exit:
		rts
; ===========================================================================

DLE_SLZ3_Boss:
		cmpi.w	#$2000,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $2000

		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#BossStarLight,(a1)			; load SLZ boss object

	.fail:
		play.w	0, jsr, mus_Boss			; play boss music
		move.b	#1,(f_boss_loaded).w			; lock screen
		addq.b	#2,(v_dle_routine).w			; goto DLE_SLZ3_End next
		rts
; ===========================================================================

.exit:
		rts
; ===========================================================================

DLE_SLZ3_End:
		move.w	(v_camera_x_pos).w,(v_boundary_left).w	; set boundary to current position
		rts
		rts

; ---------------------------------------------------------------------------
; Spring Yard Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_SYZ2:
		move.w	#$520,(v_boundary_bottom_next).w
		cmpi.w	#$25A0,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $25A0

		move.w	#$420,(v_boundary_bottom_next).w
		cmpi.w	#$4D0,(v_ost_player+ost_y_pos).w
		bcs.s	.exit					; branch if Sonic is above $4D0

		move.w	#$520,(v_boundary_bottom_next).w

	.exit:
		rts
; ===========================================================================

DLE_SYZ3:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_SYZ3_Index(pc,d0.w),d0
		jmp	DLE_SYZ3_Index(pc,d0.w)
; ===========================================================================
DLE_SYZ3_Index:	index *
		ptr DLE_SYZ3_Main
		ptr DLE_SYZ3_Boss
		ptr DLE_SYZ3_End
; ===========================================================================

DLE_SYZ3_Main:
		cmpi.w	#$2AC0,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $2AC0

		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.exit					; branch if not found
		move.l	#BossBlock,ost_id(a1)			; load blocks that boss picks up
		addq.b	#2,(v_dle_routine).w			; goto DLE_SYZ3_Boss next

	.exit:
		rts
; ===========================================================================

DLE_SYZ3_Boss:
		cmpi.w	#$2C00,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $2C00

		move.w	#$4CC,(v_boundary_bottom_next).w
		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#BossSpringYard,ost_id(a1)		; load SYZ boss	object
		addq.b	#2,(v_dle_routine).w			; goto DLE_SYZ3_End next

	.fail:
		play.w	0, jsr, mus_Boss			; play boss music
		move.b	#1,(f_boss_loaded).w			; lock screen
		rts
; ===========================================================================

.exit:
		rts
; ===========================================================================

DLE_SYZ3_End:
		move.w	(v_camera_x_pos).w,(v_boundary_left).w	; set boundary to current position
		rts

; ---------------------------------------------------------------------------
; Scrap	Brain Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_SBZ1:
		move.w	#$720,(v_boundary_bottom_next).w
		cmpi.w	#$1880,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $1880

		move.w	#$620,(v_boundary_bottom_next).w
		cmpi.w	#$2000,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $2000

		move.w	#$2A0,(v_boundary_bottom_next).w

	.exit:
		rts
; ===========================================================================

DLE_SBZ2:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_SBZ2_Index(pc,d0.w),d0
		jmp	DLE_SBZ2_Index(pc,d0.w)
; ===========================================================================
DLE_SBZ2_Index:	index *
		ptr DLE_SBZ2_Main
		ptr DLE_SBZ2_Blocks
		ptr DLE_SBZ2_Eggman
		ptr DLE_SBZ2_End
; ===========================================================================

DLE_SBZ2_Main:
		move.w	#$800,(v_boundary_bottom_next).w
		cmpi.w	#$1800,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $1800

		move.w	#$510,(v_boundary_bottom_next).w
		cmpi.w	#$1E00,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $1E00

		addq.b	#2,(v_dle_routine).w			; goto DLE_SBZ2_Blocks next

	.exit:
		rts
; ===========================================================================

DLE_SBZ2_Blocks:
		cmpi.w	#$1EB0,(v_camera_x_pos).w
		bcs.s	.exit					; branch if camera is left of $1EB0

		addq.b	#2,(v_dle_routine).w			; goto DLE_SBZ2_Eggman next
; ===========================================================================

.exit:
		rts
; ===========================================================================

DLE_SBZ2_Eggman:
		cmpi.w	#$1F60,(v_camera_x_pos).w
		bcs.s	.set_boundary				; branch if camera is left of $1F60

		addq.b	#2,(v_dle_routine).w			; goto DLE_SBZ2_End next
		move.b	#1,(f_boss_loaded).w			; lock screen

	.set_boundary:
		bra.s	DLE_SBZ2_SetBoundary
; ===========================================================================

DLE_SBZ2_End:
		cmpi.w	#$2050,(v_camera_x_pos).w
		bcs.s	DLE_SBZ2_SetBoundary			; branch if camera is left of $2050
		rts
; ===========================================================================

DLE_SBZ2_SetBoundary:
		move.w	(v_camera_x_pos).w,(v_boundary_left).w	; set boundary to current position
		rts
; ===========================================================================

DLE_FZ:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_FZ_Index(pc,d0.w),d0
		jmp	DLE_FZ_Index(pc,d0.w)
; ===========================================================================
DLE_FZ_Index:	index *
		ptr DLE_FZ_Main
		ptr DLE_FZ_Boss
		ptr DLE_FZ_Arena
		ptr DLE_FZ_Wait
		ptr DLE_FZ_End
; ===========================================================================

DLE_FZ_Main:
		cmpi.w	#$2148,(v_camera_x_pos).w
		bcs.s	.set_boundary				; branch if camera is left of $2148

		addq.b	#2,(v_dle_routine).w			; goto DLE_FZ_Boss next

	.set_boundary:
		bra.s	DLE_SBZ2_SetBoundary
; ===========================================================================

DLE_FZ_Boss:
		cmpi.w	#$2300,(v_camera_x_pos).w
		bcs.s	.set_boundary				; branch if camera is left of $2300

		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.set_boundary				; branch if not found
		move.l	#BossFinal,ost_id(a1)			; load FZ boss object
		addq.b	#2,(v_dle_routine).w			; goto DLE_FZ_Arena next
		move.b	#1,(f_boss_loaded).w			; lock screen

	.set_boundary:
		bra.s	DLE_SBZ2_SetBoundary
; ===========================================================================

DLE_FZ_Arena:
		cmpi.w	#$2450,(v_camera_x_pos).w		; boss arena is here
		bcs.s	.set_boundary				; branch if camera is left of $2450

		addq.b	#2,(v_dle_routine).w			; goto DLE_FZ_Wait next

	.set_boundary:
		bra.s	DLE_SBZ2_SetBoundary
; ===========================================================================

DLE_FZ_Wait:
		rts						; wait until boss is beaten
; ===========================================================================

DLE_FZ_End:
		bra.s	DLE_SBZ2_SetBoundary			; allow scrolling right
