; ---------------------------------------------------------------------------
; Object 4B - giant ring for entry to special stage

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_MZ1, ObjPos_MZ2
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_LZ1, ObjPos_LZ2
;	ObjPos_SLZ1, ObjPos_SLZ2
; ---------------------------------------------------------------------------

GiantRing:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	GRing_Index(pc,d0.w),d1
		jmp	GRing_Index(pc,d1.w)
; ===========================================================================
GRing_Index:	index *,,2
		ptr GRing_Main
		ptr GRing_Animate
		ptr GRing_Collect
		ptr GRing_Collect2
		ptr GRing_Delete
; ===========================================================================

GRing_Main:	; Routine 0
		cmpi.l	#emerald_all,(v_emeralds).w
		beq.w	DeleteObject				; branch if you have all emeralds
		cmpi.w	#50,(v_rings).w
		bcs.w	DeleteObject				; branch if have fewer than 50 rings
		move.l	#Map_GRing,ost_mappings(a0)
		move.w	#(vram_giantring/sizeof_cell)+tile_pal2,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#$40,ost_displaywidth(a0)
		addq.b	#2,ost_routine(a0)			; goto GRing_Animate next
		move.b	#2,ost_priority(a0)
		move.b	#id_React_Ring,ost_col_type(a0)		; when Sonic hits the item, goto GRing_Collect next (see ReactToItem)
		move.b	#8,ost_col_width(a0)
		move.b	#16,ost_col_height(a0)
		rts	
; ===========================================================================

GRing_Animate:	; Routine 2
		lea	Ani_BigRing(pc),a1
		bsr.w	AnimateSprite
		set_dma_dest vram_giantring,d1			; set VRAM address to write gfx
		jsr	DPLCSprite				; write gfx if frame has changed
		bra.w	DespawnQuick
; ===========================================================================

GRing_Collect:	; Routine 4
		addq.b	#2,ost_routine(a0)			; goto GRing_Collect2 next
		move.b	#0,ost_col_type(a0)			; no collision
		move.l	#Map_Flash,ost_mappings(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.b	#0,ost_priority(a0)
		move.b	#id_ani_bigring_flash,ost_anim(a0)	; use flash animation
		move.w	(v_ost_player+ost_x_pos).w,d0
		cmp.w	ost_x_pos(a0),d0			; has Sonic come from the left?
		bcs.s	.noflip					; if yes, branch
		bset	#render_xflip_bit,ost_render(a0)	; reverse flash object

	.noflip:
		play.w	1, jsr, sfx_GiantRing			; play giant ring sound

GRing_Collect2:	; Routine 6
		lea	Ani_BigRing(pc),a1
		bsr.w	AnimateSprite				; animate and goto GRing_Delete when finished
		set_dma_dest vram_giantring,d1			; set VRAM address to write gfx
		jsr	DPLCSprite				; write gfx if frame has changed

		cmpi.b	#id_frame_flash_full,ost_frame(a0)	; is 3rd frame displayed?
		bne.w	DisplaySprite				; if not, branch
		move.l	#0,(v_ost_player).w			; remove Sonic object
		move.b	#1,(f_giantring_collected).w		; stop Sonic getting bonuses
		clr.w	(v_invincibility).w			; remove invincibility
		clr.b	(v_shield).w				; remove shield
		bra.w	DisplaySprite
; ===========================================================================

GRing_Delete:	; Routine 8
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_BigRing:	index *
		ptr ani_bigring_0
		ptr ani_bigring_flash
		
ani_bigring_0:
		dc.w 7
		dc.w id_frame_bigring_front
		dc.w id_frame_bigring_45_1
		dc.w id_frame_bigring_side
		dc.w id_frame_bigring_45_2
		dc.w id_Anim_Flag_Restart
		
ani_bigring_flash:
		dc.w 1
		dc.w id_frame_flash_0
		dc.w id_frame_flash_1
		dc.w id_frame_flash_2
		dc.w id_frame_flash_full
		dc.w id_frame_flash_4
		dc.w id_frame_flash_5
		dc.w id_frame_flash_6
		dc.w id_frame_flash_final
		dc.w id_Anim_Flag_Routine
