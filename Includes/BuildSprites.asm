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
		lea	(v_sprite_queue).w,a4			; address of sprite queue - $400 bytes, 8 sections of $80 bytes (1 word for count, $3F words for OST addresses)
		moveq	#8-1,d7					; there are 8 priority levels

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
		moveq	#0,d0
		move.b	ost_displaywidth(a0),d0
		move.w	ost_x_pos(a0),d1
		sub.w	(a3),d1
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
		move.b	ost_height(a0),d0
		
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
		cmpi.b	#countof_max_sprites,d5
		beq.s	.skip_draw				; branch if at max sprites
		andi.w	#render_xflip+render_yflip,d4
		add.b	d4,d4
		move.w	BuildSpr_Index(pc,d4.w),d4
		jsr	BuildSpr_Index(pc,d4.w)			; write data from sprite pieces to buffer

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
		cmpi.b	#countof_max_sprites,d5			; max displayable sprites ($50)
		beq.s	.max_sprites				; branch if at max
		move.l	#0,(a2)					; set next sprite to link to first
		rts	
; ===========================================================================

	.max_sprites:
		move.b	#0,-5(a2)				; set current sprite to link to first
		rts
; ===========================================================================

	.abs_screen_coords:
		move.w	ost_y_screen(a0),d2			; d2 = y pos
		move.w	ost_x_pos(a0),d3			; d3 = x pos
		bra.s	.draw_object

; ---------------------------------------------------------------------------
; Subroutine to	convert	and add sprite mappings to the sprite buffer
;
; input:
;	d1.w = number of sprite pieces
;	d2.w = VDP y position
;	d3.w = VDP x position
;	d5.b = current sprite count
;	a1 = current address in sprite mappings
;	a2 = current address in sprite buffer

;	uses d0.w, d1.w, d4.b, d5.b, a1, a2
; ---------------------------------------------------------------------------

BuildSpr_Draw:
BuildSpr_Index:	index *,,2
		ptr BuildSpr_Normal
		ptr BuildSpr_FlipX
		ptr BuildSpr_FlipY
		ptr BuildSpr_FlipXY
; ===========================================================================

BuildSpr_Normal:
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
		andi.w	#$1FF,d0				; keep within 512px
		bne.s	.x_not_0				; branch if x pos isn't 0
		addq.w	#1,d0					; add 1 to prevent sprite masking (sprites at x pos 0 act as masks)

	.x_not_0:
		move.w	d0,(a2)+				; write to buffer
		dbf	d1,BuildSpr_Normal			; next sprite piece

		rts

; ===========================================================================

BuildSpr_FlipX:
		move.b	(a1)+,d0				; y position
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4				; size
		move.b	d4,(a2)+	
		addq.b	#1,d5					; link
		move.b	d5,(a2)+
		move.w	(a1)+,d0				; art tile
		add.w	ost_tile(a0),d0
		eori.w	#$800,d0				; toggle xflip in VDP
		move.w	d0,(a2)+				; write to buffer
		move.w	(a1)+,d0				; get x-offset
		neg.w	d0					; negate it
		add.b	d4,d4					; calculate flipped position by size
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0				; keep within 512px
		bne.s	.x_not_0
		addq.w	#1,d0

	.x_not_0:
		move.w	d0,(a2)+				; write to buffer
		dbf	d1,BuildSpr_FlipX			; process next sprite piece

		rts

; ===========================================================================

BuildSpr_FlipY:
		move.b	(a1)+,d0				; get y-offset
		move.b	(a1),d4					; get size
		ext.w	d0
		neg.w	d0					; negate y-offset
		lsl.b	#3,d4					; calculate flip offset
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
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
		andi.w	#$1FF,d0
		bne.s	.x_not_0
		addq.w	#1,d0

	.x_not_0:
		move.w	d0,(a2)+				; write to buffer
		dbf	d1,BuildSpr_FlipY			; process next sprite piece

		rts

; ===========================================================================

BuildSpr_FlipXY:
		move.b	(a1)+,d0				; calculated flipped y
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+				; write to buffer
		move.b	(a1)+,d4				; size
		move.b	d4,(a2)+				; link
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0				; art tile
		add.w	ost_tile(a0),d0
		eori.w	#$1800,d0				; toggle x/yflip in VDP
		move.w	d0,(a2)+
		move.w	(a1)+,d0				; calculate flipped x
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	.x_not_0
		addq.w	#1,d0

	.x_not_0:
		move.w	d0,(a2)+				; write to buffer
		dbf	d1,BuildSpr_FlipXY			; process next sprite piece

		rts	
