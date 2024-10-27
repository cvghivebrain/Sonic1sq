; ---------------------------------------------------------------------------
; Object 76 - blocks that Eggman picks up (SYZ)

; spawned by:
;	DynamicLevelEvents - routine 0
;	BossBlock - routine 2
; ---------------------------------------------------------------------------

BossBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	BBlock_Index(pc,d0.w),d1
		jmp	BBlock_Index(pc,d1.w)
; ===========================================================================
BBlock_Index:	index *,,2
		ptr BBlock_Main
		ptr BBlock_Action
		ptr BBlock_Frag

		rsobj BossBlock
ost_bblock_mode:	rs.b 1					; ost_subtype+1			; same as subtype = solid; $FF = lifted; $A = breaking
ost_bblock_boss:	rs.l 1					; $34				; address of OST of main boss object (4 bytes)
		rsobjend
; ===========================================================================

BBlock_Main:	; Routine 0
		moveq	#0,d4					; first subtype
		move.w	#$2C10,d5				; first x position
		moveq	#10-1,d6				; number of blocks
		lea	(a0),a1					; replace current object with first block
		bra.s	.load_block
; ===========================================================================

	.loop:
		jsr	(FindFreeObj).l				; find free OST slot
		bne.s	.fail					; branch if not found

.load_block:
		move.l	#BossBlock,ost_id(a1)
		move.l	#Map_Cheese,ost_mappings(a1)
		move.w	#0+tile_pal3,ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#$10,ost_displaywidth(a1)
		move.b	#StrId_Block,ost_name(a1)
		move.b	#$10,ost_width(a1)
		move.b	#$10,ost_height(a1)
		move.w	#priority_3,ost_priority(a1)
		move.w	d5,ost_x_pos(a1)			; set x position
		move.w	#$582,ost_y_pos(a1)
		move.b	d4,ost_subtype(a1)			; blocks have subtypes 0-9
		move.b	d4,ost_bblock_mode(a1)
		addq.w	#1,d4					; increment subtype
		addi.w	#$20,d5					; +32px for next x position
		addq.b	#2,ost_routine(a1)			; goto BBlock_Action next
		dbf	d6,.loop				; repeat sequence 9 more times

	.fail:
		rts	
; ===========================================================================

BBlock_Action:	; Routine 2
		move.b	ost_bblock_mode(a0),d0			; check mode (changed by SYZ boss when lifted)
		cmp.b	ost_subtype(a0),d0
		beq.s	.is_solid				; branch if same as subtype
		tst.b	d0
		bmi.s	.lifting				; branch if $FF

.break_block:
		bsr.w	BBlock_Break
		bra.s	.display
; ===========================================================================

.lifting:
		movea.l	ost_bblock_boss(a0),a1			; get address of OST of boss
		tst.b	ost_col_property(a1)			; has boss been hit 8 times?
		beq.s	.break_block				; if yes, branch

		move.w	ost_x_pos(a1),ost_x_pos(a0)		; move with boss
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		addi.w	#$2C,ost_y_pos(a0)			; block is 44px below boss
		cmpa.w	a0,a1
		bcs.s	.display				; branch if boss OST is before block OST in RAM
		move.w	ost_y_vel(a1),d0
		ext.l	d0
		asr.l	#8,d0
		add.w	d0,ost_y_pos(a0)
		bra.s	.display
; ===========================================================================

.is_solid:
		jsr	(SolidObject).l

.display:
		jmp	(DisplaySprite).l
; ===========================================================================

BBlock_Frag:	; Routine 4
		tst.b	ost_render(a0)				; is object on-screen?
		bpl.s	.delete					; if not, branch
		jsr	(ObjectFall).l				; apply gravity and update position
		jmp	(DisplaySprite).l
; ===========================================================================

.delete:
		jmp	(DeleteObject).l

; ---------------------------------------------------------------------------
; Subroutine to break block into fragments 
; ---------------------------------------------------------------------------

BBlock_Break:
		lea	BBlock_FragData(pc),a4
		moveq	#0,d4		; first fragment is top left
		moveq	#3,d1
		moveq	#$38,d2
		addq.b	#2,ost_routine(a0)			; goto BBlock_Frag next
		move.b	#8,ost_displaywidth(a0)
		move.b	#8,ost_height(a0)
		lea	(a0),a1					; replace block with first fragment
		bra.s	.load_frag
; ===========================================================================

	.loop:
		jsr	(FindNextFreeObj).l			; find free OST slot
		bne.s	.fail					; branch if not found

.load_frag:
		lea	(a0),a2
		lea	(a1),a3
		moveq	#(sizeof_ost/16)-1,d3

	.loop_copy:
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		dbf	d3,.loop_copy				; copy contents of OST to other 3 fragments

		move.w	(a4)+,ost_x_vel(a1)
		move.w	(a4)+,ost_y_vel(a1)
		move.w	(a4)+,d3
		add.w	d3,ost_x_pos(a1)
		move.w	(a4)+,d3
		add.w	d3,ost_y_pos(a1)
		move.b	d4,ost_frame(a1)			; set frame (raw mappings are not used like in other broken blocks)
		addq.w	#1,d4					; use next frame
		dbf	d1,.loop				; repeat sequence 3 more times

	.fail:
		play_sound sfx_Smash				; play smashing sound
		rts
; End of function BBlock_Break

; ===========================================================================
BBlock_FragData:
		dc.w -$180, -$200, -8, -8			; x/y speed, x/y pos
		dc.w $180, -$200, $10, 0
		dc.w -$100, -$100, 0, $10
		dc.w $100, -$100, $10, $10
