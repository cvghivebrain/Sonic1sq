; ---------------------------------------------------------------------------
; compare the size of an index with ZoneCount constant
; (should be used immediately after the index)
; input: index address, element size
; ---------------------------------------------------------------------------

zonewarning:	macro loc,elementsize
	@end:
		if (@end-loc)-(ZoneCount*elementsize)<>0
		inform 1,"Size of \loc ($%h) does not match ZoneCount ($\#ZoneCount).",(@end-loc)/elementsize
		endc
		endm

; ---------------------------------------------------------------------------
; Copy a tilemap from 68K (ROM/RAM) to the VRAM without using DMA
; input: source, destination, width [cells], height [cells]
; ---------------------------------------------------------------------------

copyTilemap:	macro source,loc,x,y,width,height
		lea	(source).l,a1
		vram_loc: = (loc)+(sizeof_vram_row*(y))+((x)*2)
		locVRAM	vram_loc,d0
		moveq	#width-1,d1
		moveq	#height-1,d2
		bsr.w	TilemapToVRAM
		endm

; ---------------------------------------------------------------------------
; check if object moves out of range
; input: location to jump to if out of range, x-axis pos (ost_x_pos(a0) by default)
; ---------------------------------------------------------------------------

out_of_range:	macro exit,pos
		if narg=2
		move.w	pos,d0					; get object position (if specified as not ost_x_pos)
		else
		move.w	ost_x_pos(a0),d0			; get object position
		endc
		andi.w	#$FF80,d0				; round down to nearest $80
		move.w	(v_camera_x_pos).w,d1			; get screen position
		subi.w	#128,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0					; d0 = approx distance between object and screen (negative if object is left of screen)
		cmpi.w	#128+320+192,d0
		bhi.\0	exit					; branch if d0 is negative or higher than 640
		endm

; ---------------------------------------------------------------------------
; Sprite mappings header and footer
; ---------------------------------------------------------------------------

spritemap:	macro
		if ~def(current_sprite)
		current_sprite: = 1
		endc
		sprite_start: = *+1
		dc.w (sprite_\#current_sprite-sprite_start)/6
		endm

endsprite:	macro
		sprite_\#current_sprite: equ *
		current_sprite: = current_sprite+1
		endm

; ---------------------------------------------------------------------------
; Sprite mappings piece
; input: xpos, ypos, size, tile index
; optional: xflip, yflip, pal2|pal3|pal4, hi (any order)
; ---------------------------------------------------------------------------

piece:		macro
		dc.b \2		; ypos
		sprite_width:	substr	1,1,"\3"
		sprite_height:	substr	3,3,"\3"
		dc.b ((sprite_width-1)<<2)+sprite_height-1
		sprite_xpos: = \1
		if \4<0						; is tile index negative?
			sprite_tile: = $10000+(\4)		; convert signed to unsigned
		else
			sprite_tile: = \4
		endc
		
		sprite_xflip: = 0
		sprite_yflip: = 0
		sprite_hi: = 0
		sprite_pal: = 0
		rept narg-4
			if strcmp("\5","xflip")
			sprite_xflip: = $800
			elseif strcmp("\5","yflip")
			sprite_yflip: = $1000
			elseif strcmp("\5","hi")
			sprite_hi: = $8000
			elseif strcmp("\5","pal2")
			sprite_pal: = $2000
			elseif strcmp("\5","pal3")
			sprite_pal: = $4000
			elseif strcmp("\5","pal4")
			sprite_pal: = $6000
			else
			endc
		shift
		endr
		
		dc.w (sprite_tile+sprite_xflip+sprite_yflip+sprite_hi+sprite_pal)&$FFFF
		dc.w sprite_xpos
		endm

; ---------------------------------------------------------------------------
; Object placement
; input: xpos, ypos, object id, subtype
; optional: xflip, yflip, rem (any order)
; ---------------------------------------------------------------------------

objpos:		macro
		dc.w \1		; xpos
		obj_ypos: = \2
		if strcmp("\3","0")
		obj_id: = 0
		else
		obj_id: = \3
		endc
		obj_sub\@: equ \4
		obj_xflip: = 0
		obj_yflip: = 0
		obj_rem: = 0
		rept narg-4
			if strcmp("\5","xflip")
			obj_xflip: = $4000
			elseif strcmp("\5","yflip")
			obj_yflip: = $8000
			elseif strcmp("\5","rem")
			obj_rem: = $80
			else
			endc
		shift
		endr
		
		dc.w obj_ypos+obj_xflip+obj_yflip
		dc.b obj_rem, obj_sub\@
		dc.l obj_id
		endm

endobj:		macros
		objpos $ffff,0,0,0

; ---------------------------------------------------------------------------
; Incbins a file and records its (uncompressed) size
; input: label, file name (without extension), extension
; optional: dma_safe - keep within a 128kB section
; ---------------------------------------------------------------------------

incfile:	macro label,name,extension
		filename: equs \name				; remove quotes from file name
		sizeof_\label: equ filesize("\filename\.bin")	; save size of associated .bin file
		if strcmp("\4","dma_safe")			; is DMA safe flag set?
			if (*&$1FFFF) + sizeof_\label > $20000	; does file occupy two 128kB sections?
			align $20000				; add padding so that it doesn't
			endc
		endc
	\label:	incbin	"\filename\.\extension"			; incbin actual file
		even
		endm
