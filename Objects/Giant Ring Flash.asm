; ---------------------------------------------------------------------------
; Object 7C - flash effect when	you collect the	giant ring

; spawned by:
;	GiantRing
; ---------------------------------------------------------------------------

RingFlash:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Flash_Index(pc,d0.w),d1
		jmp	Flash_Index(pc,d1.w)
; ===========================================================================
Flash_Index:	index *,,2
		ptr Flash_Main
		ptr Flash_ChkDel
		ptr Flash_Delete

		rsobj RingFlash
ost_flash_parent:	rs.l 1 ; $3C				; address of OST of parent object (4 bytes)
		rsobjend
; ===========================================================================

Flash_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Flash_ChkDel next
		move.l	#Map_Flash,ost_mappings(a0)
		move.w	#(vram_giantring/sizeof_cell)+tile_pal2,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#0,ost_priority(a0)
		move.b	#$20,ost_displaywidth(a0)

Flash_ChkDel:	; Routine 2
		bsr.s	Flash_Collect
		move.w	ost_x_pos(a0),d0
		bsr.w	CheckActive
		bne.w	DeleteObject
		bra.w	DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to animate the flash and remove Sonic
; ---------------------------------------------------------------------------

Flash_Collect:
		lea	(Ani_Flash).l,a1
		bsr.w	AnimateSprite
		set_dma_dest vram_giantring,d1			; set VRAM address to write gfx
		jsr	DPLCSprite				; write gfx if frame has changed
		tst.b	ost_mode(a0)			; has animation finished?
		bne.s	.finish					; if yes, branch

		cmpi.b	#id_frame_flash_full,ost_frame(a0)	; is 3rd frame displayed?
		bne.s	.exit					; if not, branch
		movea.l	ost_flash_parent(a0),a1			; get parent object address
		move.b	#id_GRing_Delete,ost_routine(a1)	; delete parent object
		move.b	#id_Blank,(v_ost_player+ost_anim).w	; make Sonic invisible
		move.b	#1,(f_giantring_collected).w		; stop Sonic getting bonuses
		clr.b	(v_invincibility).w			; remove invincibility
		clr.b	(v_shield).w				; remove shield

	.exit:
		rts	
; ===========================================================================

.finish:
		addq.b	#2,ost_routine(a0)			; goto Flash_Delete next
		move.l	#0,(v_ost_player).w			; remove Sonic object
		addq.l	#4,sp					; don't return to Flash_ChkDel
		rts

; ===========================================================================

Flash_Delete:	; Routine 4
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Flash:	index *
		ptr ani_flash_0
		
ani_flash_0:
		dc.w 1
		dc.w id_frame_flash_0
		dc.w id_frame_flash_1
		dc.w id_frame_flash_2
		dc.w id_frame_flash_full
		dc.w id_frame_flash_4
		dc.w id_frame_flash_5
		dc.w id_frame_flash_6
		dc.w id_frame_flash_final
		dc.w id_Anim_Flag_Routine2
		even
