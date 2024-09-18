; ---------------------------------------------------------------------------
; Object 1E - Ball Hog enemy (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2

; subtypes:
;	%HHHHLLLL
;	HHHH - cannonball bounce height (*$100 for ost_y_vel)
;	LLLL - cannonball life span in seconds
; ---------------------------------------------------------------------------

BallHog:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Hog_Index(pc,d0.w),d1
		jmp	Hog_Index(pc,d1.w)
; ===========================================================================
Hog_Index:	index *,,2
		ptr Hog_Main
		ptr Hog_Action
; ===========================================================================

Hog_Main:	; Routine 0
		move.b	#$13,ost_height(a0)
		move.b	#8,ost_width(a0)
		move.l	#Map_Hog,ost_mappings(a0)
		move.w	(v_tile_ballhog).w,ost_tile(a0)
		addi.w	#tile_pal2,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_4,ost_priority(a0)
		move.b	#id_React_Enemy,ost_col_type(a0)
		move.b	#12,ost_col_width(a0)
		move.b	#18,ost_col_height(a0)
		move.b	#$C,ost_displaywidth(a0)
		addq.b	#2,ost_routine(a0)			; goto Hog_Action next
		jmp	SnapFloor				; align to floor
; ===========================================================================

Hog_Action:	; Routine 2
		shortcut
		lea	Ani_Hog(pc),a1
		bsr.w	AnimateSprite
		cmpi.b	#id_frame_hog_open,ost_frame(a0)
		bne.w	DespawnObject				; branch if not on last frame
		cmpi.b	#9,ost_anim_time(a0)
		bne.w	DespawnObject				; branch if not only just on last frame
		
		bsr.w	FindFreeObj
		bne.w	DespawnObject
		move.l	#Cannonball,ost_id(a1)			; load cannonball object ($20)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	#-$100,ost_x_vel(a1)			; cannonball bounces to the left
		move.w	#0,ost_y_vel(a1)
		moveq	#-4,d0
		btst	#status_xflip_bit,ost_status(a0)	; is Ball Hog facing right?
		beq.s	.noflip					; if not, branch
		neg.w	d0
		neg.w	ost_x_vel(a1)				; cannonball bounces to	the right

	.noflip:
		add.w	d0,ost_x_pos(a1)
		addi.w	#$C,ost_y_pos(a1)
		move.b	ost_subtype(a0),ost_subtype(a1)		; copy object type from Ball Hog
		bra.w	DespawnObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Hog:	index *
		ptr ani_hog_0
		
ani_hog_0:	dc.w 9
		dc.w id_frame_hog_standing
		dc.w id_frame_hog_standing
		dc.w id_frame_hog_squat
		dc.w id_frame_hog_squat
		dc.w id_frame_hog_leap
		dc.w id_frame_hog_squat
		dc.w id_frame_hog_standing
		dc.w id_frame_hog_standing
		dc.w id_frame_hog_squat
		dc.w id_frame_hog_squat
		dc.w id_frame_hog_leap
		dc.w id_frame_hog_squat
		dc.w id_frame_hog_standing
		dc.w id_frame_hog_standing
		dc.w id_frame_hog_squat
		dc.w id_frame_hog_squat
		dc.w id_frame_hog_leap
		dc.w id_frame_hog_squat
		dc.w id_frame_hog_standing
		dc.w id_frame_hog_standing
		dc.w id_frame_hog_open
		dc.w id_Anim_Flag_Restart
