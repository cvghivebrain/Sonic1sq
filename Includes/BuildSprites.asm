; ---------------------------------------------------------------------------
; Subroutine to	convert	objects into proper Mega Drive sprites

; output:
;	a2 = address of last sprite in sprite buffer
;	(a3) = camera x position
;	(a5) = camera y position

;	uses d0.l, d1.l, d2.w, d3.w, d4.l, d5.l, d6.l, d7.l, a0, a1, a4, a6
; ---------------------------------------------------------------------------

BuildSprites:
		lea	(v_camera_x_pos).w,a3			; get address for camera x position
		lea	(v_camera_y_pos).w,a5			; get address for camera y position
		lea	(v_sprite_buffer).w,a2			; set address for sprite table - $280 bytes, copied to VRAM at VBlank
		moveq	#0,d5
		move.b	(v_spritemask_height).w,d0
		beq.s	.no_mask				; branch if spritemask isn't defined
		bsr.w	BuildSpr_Mask				; draw spritemask
		
	.no_mask:
		lea	(v_sprite_queue).w,a4			; address of sprite queue - $400 bytes, 8 sections of $80 bytes (1 word for count, $3F words for OST addresses)
		moveq	#countof_priority-1,d7			; there are 8 priority levels

	.priority_loop:
		tst.w	(a4)					; are there objects left in current section?
		beq.w	.next_priority				; if not, branch
		moveq	#2,d6					; start address within current section (1st word is object count)

	.object_loop:
		movea.w	(a4,d6.w),a0				; load address of OST of object
		tst.l	ost_id(a0)
		beq.w	.next_object				; if object id is 0, branch

		bclr	#render_onscreen_bit,ost_render(a0)	; set as not visible
		move.b	ost_render(a0),d4
		btst	#render_rel_bit,d4
		beq.w	.abs_screen_coords			; branch if render_abs

		; check object is visible
		move.w	ost_displaywidth_hi(a0),d0
		move.w	ost_x_pos(a0),d1
		sub.w	(a3),d1					; d1 = object x pos on screen (-ve if left of screen)
		move.w	d1,d3
		add.w	d0,d1
		add.w	d0,d0
		addi.w	#screen_width,d0
		cmp.w	d0,d1
		bcc.s	.next_object				; branch if outside left/right of screen
		addi.w	#screen_left,d3				; d3 = x pos of object on screen, +128px for VDP sprite coordinate

		moveq	#32,d0
		btst	#render_useheight_bit,d4		; is use height flag on?
		beq.s	.assume_height				; if not, branch
		move.w	ost_height_hi(a0),d0
		
	.assume_height:
		move.w	ost_y_pos(a0),d1
		sub.w	(a5),d1
		move.w	d1,d2
		add.w	d0,d1
		add.w	d0,d0
		addi.w	#screen_height,d0
		cmp.w	d0,d1
		bcc.s	.next_object				; branch if outside top/bottom of screen
		addi.w	#screen_top,d2				; d2 = y pos of object on screen, +128px for VDP sprite coordinate

	.draw_object:
		movea.l	ost_mappings(a0),a1			; get address of mappings
		moveq	#0,d1
		btst	#render_rawmap_bit,d4			; is raw mappings flag on?
		bne.s	.draw_now				; if yes, branch

		move.w	ost_frame_hi(a0),d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1				; jump to frame within mappings
		move.w	(a1)+,d1				; number of sprite pieces
		bmi.s	.skip_draw				; branch if frame contained 0 sprite pieces

	.draw_now:
		andi.w	#render_xflip+render_yflip,d4
		add.b	d4,d4
		move.w	BuildSpr_Index(pc,d4.w),d0
		jsr	BuildSpr_Index(pc,d0.w)			; write data from sprite pieces to buffer
		
		move.w	ost_subsprite(a0),d0
		beq.s	.skip_draw				; branch if no subsprites are found
		movea.w	d0,a1					; a1 = RAM address of subsprite table
		move.w	(a1)+,d1				; number of sprite pieces
		beq.s	.skip_draw				; branch if 0
		subq.w	#1,d1					; subtract 1 for loops
		bsr.w	BuildSpr_Sub

	.skip_draw:
		bset	#render_onscreen_bit,ost_render(a0)	; set object as visible

	.next_object:
		addq.w	#2,d6					; read next object in sprite queue
		subq.w	#2,(a4)					; number of objects left
		bne.w	.object_loop				; branch if not 0

	.next_priority:
		lea	sizeof_priority(a4),a4			; next priority section ($80)
		dbf	d7,.priority_loop			; repeat for all sections
		move.b	d5,(v_spritecount).w			; set sprite count
		move.b	#0,-5(a2)				; set current sprite to link to first
		rts
; ===========================================================================

	.abs_screen_coords:
		move.w	ost_y_screen(a0),d2			; d2 = y pos
		move.w	ost_x_pos(a0),d3			; d3 = x pos
		bra.s	.draw_object

; ---------------------------------------------------------------------------
; Subroutines to convert and add sprite mappings to the sprite buffer
;
; input:
;	d1.w = number of sprite pieces
;	d2.w = VDP y position
;	d3.w = VDP x position
;	d5.b = current sprite count
;	a1 = current address in sprite mappings
;	a2 = current address in sprite buffer

;	uses d0.w, d1.w, d4.w, d5.b, a1, a2
; ---------------------------------------------------------------------------

BuildSpr_Index:	index *,,2
		ptr BuildSpr_Normal
		ptr BuildSpr_FlipX
		ptr BuildSpr_FlipY
		ptr BuildSpr_FlipXY
; ===========================================================================

BuildSpr_Normal:
		cmpi.b	#countof_max_sprites,d5
		beq.s	.exit					; branch if at max sprites
		move.b	(a1)+,d0				; get relative y pos from mappings
		ext.w	d0
		add.w	d2,d0					; add VDP y pos
		move.w	d0,(a2)+				; write y pos to sprite buffer

		move.b	(a1)+,(a2)+				; write sprite size to buffer
		addq.b	#1,d5					; increment sprite counter
		move.b	d5,(a2)+				; write link to next sprite in buffer

		move.w	(a1)+,d0				; get tile number from mappings
		add.w	ost_tile(a0),d0				; add VRAM setting
		move.w	d0,(a2)+				; write to buffer

		move.w	(a1)+,d0				; get relative x pos from mappings
		add.w	d3,d0					; add VDP x pos
		move.w	d0,d4
		subi.w	#screen_left-32,d4
		cmpi.w	#screen_width+32,d4
		bhi.s	.abort_x				; branch if sprite is off screen
		move.w	d0,(a2)+				; write x pos to buffer
		dbf	d1,BuildSpr_Normal			; next sprite piece

	.exit:
		rts
		
	.abort_x:
		subq.w	#6,a2					; undo this sprite
		subq.b	#1,d5					; decrement sprite counter
		dbf	d1,BuildSpr_Normal			; next sprite piece
		rts
; ===========================================================================

BuildSpr_FlipX:
		cmpi.b	#countof_max_sprites,d5
		beq.s	.exit					; branch if at max sprites
		move.b	(a1)+,d0				; y position
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		
		moveq	#0,d4
		move.b	(a1)+,d4
		move.b	d4,(a2)+				; size
		addq.b	#1,d5
		move.b	d5,(a2)+				; link
		
		move.w	(a1)+,d0				; art tile
		add.w	ost_tile(a0),d0
		eori.w	#$800,d0				; toggle xflip in VDP
		move.w	d0,(a2)+				; write to buffer
		
		move.w	(a1)+,d0				; get x-offset
		neg.w	d0					; negate it
		add.b	d4,d4
		sub.w	BuildSpr_FlipX_Shift(pc,d4.w),d0	; calculate flipped position by size
		btst	#render_xshift_bit,ost_render(a0)
		beq.s	.noshift				; branch if xflip shift flag is clear
		addq.w	#1,d0
		
	.noshift:
		add.w	d3,d0
		move.w	d0,d4
		subi.w	#screen_left-32,d4
		cmpi.w	#screen_width+32,d4
		bhi.s	.abort_x				; branch if sprite is off screen
		move.w	d0,(a2)+				; write to buffer
		dbf	d1,BuildSpr_FlipX			; process next sprite piece

	.exit:
		rts
		
	.abort_x:
		subq.w	#6,a2					; undo this sprite
		subq.b	#1,d5					; decrement sprite counter
		dbf	d1,BuildSpr_FlipX			; next sprite piece
		rts
; ===========================================================================

BuildSpr_FlipY:
		cmpi.b	#countof_max_sprites,d5
		beq.s	.exit					; branch if at max sprites
		move.b	(a1)+,d0				; get y-offset
		moveq	#0,d4
		move.b	(a1),d4					; get size
		ext.w	d0
		neg.w	d0					; negate y-offset
		add.b	d4,d4
		sub.w	BuildSpr_FlipY_Shift(pc,d4.w),d0	; calculate flipped position by size
		add.w	d2,d0					; add y-position
		move.w	d0,(a2)+				; write to buffer
		
		move.b	(a1)+,(a2)+				; size
		addq.b	#1,d5
		move.b	d5,(a2)+				; link
		
		move.w	(a1)+,d0				; art tile
		add.w	ost_tile(a0),d0
		eori.w	#$1000,d0				; toggle yflip in VDP
		move.w	d0,(a2)+
		
		move.w	(a1)+,d0				; x-position
		add.w	d3,d0
		move.w	d0,d4
		subi.w	#screen_left-32,d4
		cmpi.w	#screen_width+32,d4
		bhi.s	.abort_x				; branch if sprite is off screen
		move.w	d0,(a2)+				; write to buffer
		dbf	d1,BuildSpr_FlipY			; process next sprite piece

	.exit:
		rts
		
	.abort_x:
		subq.w	#6,a2					; undo this sprite
		subq.b	#1,d5					; decrement sprite counter
		dbf	d1,BuildSpr_FlipY			; next sprite piece
		rts
; ===========================================================================		
BuildSpr_FlipX_Shift:
		dc.w ((0*2)&$18)+8, ((1*2)&$18)+8, ((2*2)&$18)+8, ((3*2)&$18)+8
		dc.w ((4*2)&$18)+8, ((5*2)&$18)+8, ((6*2)&$18)+8, ((7*2)&$18)+8
		dc.w ((8*2)&$18)+8, ((9*2)&$18)+8, (($A*2)&$18)+8, (($B*2)&$18)+8
		dc.w (($C*2)&$18)+8, (($D*2)&$18)+8, (($E*2)&$18)+8, (($F*2)&$18)+8
		
BuildSpr_FlipY_Shift:
		dc.w ((0*8)&$18)+8, ((1*8)&$18)+8, ((2*8)&$18)+8, ((3*8)&$18)+8
		dc.w ((4*8)&$18)+8, ((5*8)&$18)+8, ((6*8)&$18)+8, ((7*8)&$18)+8
		dc.w ((8*8)&$18)+8, ((9*8)&$18)+8, (($A*8)&$18)+8, (($B*8)&$18)+8
		dc.w (($C*8)&$18)+8, (($D*8)&$18)+8, (($E*8)&$18)+8, (($F*8)&$18)+8
; ===========================================================================

BuildSpr_FlipXY:
		cmpi.b	#countof_max_sprites,d5
		beq.s	.exit					; branch if at max sprites
		move.b	(a1)+,d0				; calculated flipped y
		moveq	#0,d4
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		sub.w	BuildSpr_FlipY_Shift(pc,d4.w),d0	; calculate flipped position by size
		add.w	d2,d0
		move.w	d0,(a2)+				; write to buffer
		
		move.b	(a1)+,(a2)+				; size
		addq.b	#1,d5
		move.b	d5,(a2)+				; link
		
		move.w	(a1)+,d0				; art tile
		add.w	ost_tile(a0),d0
		eori.w	#$1800,d0				; toggle x/yflip in VDP
		move.w	d0,(a2)+
		
		move.w	(a1)+,d0				; calculate flipped x
		neg.w	d0
		sub.w	BuildSpr_FlipX_Shift(pc,d4.w),d0	; calculate flipped position by size
		btst	#render_xshift_bit,ost_render(a0)
		beq.s	.noshift				; branch if xflip shift flag is clear
		addq.w	#1,d0
		
	.noshift:
		add.w	d3,d0
		move.w	d0,d4
		subi.w	#screen_left-32,d4
		cmpi.w	#screen_width+32,d4
		bhi.s	.abort_x				; branch if sprite is off screen
		move.w	d0,(a2)+				; write to buffer
		dbf	d1,BuildSpr_FlipXY			; process next sprite piece

	.exit:
		rts
		
	.abort_x:
		subq.w	#6,a2					; undo this sprite
		subq.b	#1,d5					; decrement sprite counter
		dbf	d1,BuildSpr_FlipXY			; next sprite piece
		rts
; ===========================================================================

BuildSpr_Sub:
		cmpi.b	#countof_max_sprites,d5
		beq.s	.exit					; branch if at max sprites
		move.b	(a1)+,d0				; get relative y pos from subsprite table
		ext.w	d0
		add.w	d2,d0					; add VDP y pos
		move.w	d0,d4
		subi.w	#screen_top-32,d4
		cmpi.w	#screen_height+32,d4
		bhi.s	.abort_y				; branch if subsprite is off screen
		move.w	d0,(a2)+				; write y pos to sprite buffer

		move.b	(a1)+,(a2)+				; write sprite size to buffer
		addq.b	#1,d5					; increment sprite counter
		move.b	d5,(a2)+				; write link to next sprite in buffer

		move.w	(a1)+,(a2)+				; write VRAM setting to buffer

		move.w	(a1)+,d0				; get relative x pos from subsprite table
		add.w	d3,d0					; add VDP x pos
		move.w	d0,d4
		subi.w	#screen_left-32,d4
		cmpi.w	#screen_width+32,d4
		bhi.s	.abort_x				; branch if subsprite is off screen
		move.w	d0,(a2)+				; write x pos to buffer
		dbf	d1,BuildSpr_Sub				; next sprite piece

	.exit:
		rts
		
	.abort_y:
		addq.w	#5,a1					; skip this subsprite
		dbf	d1,BuildSpr_Sub				; next sprite piece
		rts
		
	.abort_x:
		subq.w	#6,a2					; undo this subsprite
		subq.b	#1,d5					; decrement sprite counter
		dbf	d1,BuildSpr_Sub				; next sprite piece
		rts
; ===========================================================================

BuildSpr_Mask:
		andi.w	#$FF,d0					; d0 = height of whole spritemask
		moveq	#32,d3					; d3 = height of 1x4 sprite
		moveq	#0,d1
		move.b	(v_spritemask_pos).w,d1
		addi.w	#screen_top,d1				; d1 = y position
		cmp.w	d3,d0
		bhi.s	.over_32				; branch if height is > 32px
		move.w	d1,(a2)+				; y pos
		move.b	#sprite1x4,(a2)+			; sprite size
		addq.b	#1,d5					; increment sprite counter
		move.b	d5,(a2)+				; link to next sprite
		move.l	#1,(a2)+				; VRAM setting & x pos
		sub.w	d3,d0
		add.w	d0,d1					; masking sprites should partially overlap
		move.w	d1,(a2)+
		move.b	#sprite1x4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.l	#0,(a2)+
		rts
		
	.over_32:
		move.w	d0,d2
		lsr.w	#5,d2					; divide by 32 (discard remainder)
		subq.w	#1,d2					; minus 1 for loops
		
	.loop:
		bsr.s	.mask_32
		add.w	d3,d1					; next sprite is 32px lower
		dbf	d2,.loop				; repeat for all 32px blocks
		
		andi.w	#$1F,d0					; d0 = remaining height
		sub.w	d3,d0
		add.w	d0,d1
		
	.mask_32:
		move.w	d1,(a2)+				; y pos
		move.b	#sprite1x4,(a2)+			; sprite size
		addq.b	#1,d5					; increment sprite counter
		move.b	d5,(a2)+				; link to next sprite
		move.l	#1,(a2)+				; VRAM setting & x pos
		move.w	d1,(a2)+
		move.b	#sprite1x4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.l	#0,(a2)+
		rts
		
