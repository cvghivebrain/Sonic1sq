; ---------------------------------------------------------------------------
; Test if macro argument is used
; ---------------------------------------------------------------------------

ifarg		macros
		if strlen("\1")>0

ifnotarg	macros
		if strlen("\1")=0

; ---------------------------------------------------------------------------
; Align and pad.
; input: length to align to, value to use as padding (default is 0)
; ---------------------------------------------------------------------------

align:		macro length,value
		ifarg \value
		dcb.b (\length-(*%\length))%\length,\value
		else
		dcb.b (\length-(*%\length))%\length,0
		endc
		endm

; ---------------------------------------------------------------------------
; Save and restore registers from the stack.
; ---------------------------------------------------------------------------

chkifreg:	macro
		isreg: = 1					; assume string is register
		isregm: = 0					; assume single register
		regtmp: equs \1					; copy input
		rept strlen(\1)
		regchr:	substr ,1,"\regtmp"			; get first character
		regtmp:	substr 2,,"\regtmp"			; remove first character
		if instr("ad01234567/-","\regchr")
		else
		isreg: = 0					; string isn't register if it contains characters besides those listed
		endc
		if instr("/-","\regchr")
		isregm: = 1					; string is multi-register
		endc
		endr
		endm

pushr:		macro
		chkifreg "\1"
		if (isreg=1)&(isregm=1)
			ifarg \0				; check if size is specified
			movem.\0	\1,-(sp)		; save multiple registers (b/w)
			else
			movem.l	\1,-(sp)			; save multiple registers
			endc
		else
			ifarg \0				; check if size is specified
			move.\0	\1,-(sp)			; save one register (b/w)
			else
			move.l	\1,-(sp)			; save one whole register
			endc
		endc
		endm

popr:		macro
		chkifreg "\1"
		if (isreg=1)&(isregm=1)
			ifarg \0				; check if size is specified
			movem.\0	(sp)+,\1		; restore multiple registers (b/w)
			else
			movem.l	(sp)+,\1			; restore multiple whole registers
			endc
		else
			ifarg \0				; check if size is specified
			move.\0	(sp)+,\1			; restore one register (b/w)
			else
			move.l	(sp)+,\1			; restore one whole register
			endc
		endc
		endm

; ---------------------------------------------------------------------------
; Align and pad RAM sections so that they are divisible by a longword.
; ---------------------------------------------------------------------------

rsalign:	macros
		rs.b (\1-(__rs%\1))%\1

rsblock:	macro
		rsalign 2					; align to even address
		rsblock_\1: equ __rs
		endm

rsblockend:	macro
		rs.b (4-((__rs-rsblock_\1)%4))%4		; align to 4 (starting from rsblock)
		loops_to_clear_\1: equ ((__rs-rsblock_\1)/4)-1	; number of loops needed to clear block with longword writes
		endm

; ---------------------------------------------------------------------------
; Organise object RAM usage.
; ---------------------------------------------------------------------------

rsobj:		macro name
		rsobj_name: equs "\name"			; remember name of current object
		rsset ost_used					; start at end of regular OST usage
		pusho						; save options
		opt	ae+					; enable auto evens
		endm

rsobjend:	macro
		if __rs>sizeof_ost
		inform	3,"OST for \rsobj_name exceeds maximum by $%h bytes.",__rs-sizeof_ost
		else
		inform	0,"0-$%h bytes of OST for \rsobj_name used, leaving $%h bytes unused.",__rs-1,sizeof_ost-__rs
		endc
		popo
		endm

; ---------------------------------------------------------------------------
; Create a pointer index.
; input: start location (usually * or 0; leave blank to make pointers
;  relative to themselves), id start (default 0), id increment (default 1)
; ---------------------------------------------------------------------------

index:		macro
		nolist
		pusho
		opt	m-

		if strlen("\1")>0				; check if start is defined
		index_start: = \1
		else
		index_start: = -1
		endc
		if strlen("\0")=0				; check if width is defined (b, w, l)
		index_width: equs "w"				; use w by default
		else
		index_width: equs "\0"
		endc
		
		if strcmp("\index_width","b")
		index_width_int: = 1
		elseif strcmp("\index_width","w")
		index_width_int: = 2
		elseif strcmp("\index_width","l")
		index_width_int: = 4
		else
		fail
		endc
		
		if strlen("\2")=0				; check if first pointer id is defined
		ptr_id: = 0					; use 0 by default
		else
		ptr_id: = \2
		endc
		if strlen("\3")=0				; check if pointer id increment is defined
		ptr_id_inc: = 1					; use 1 by default
		else
		ptr_id_inc: = \3
		endc
		
		tmp_array: equs "empty"				; clear tmp_array

		popo
		list
		endm
	
; ---------------------------------------------------------------------------
; Create a mirrored pointer index. Used to keep Sonic's mappings & DPLC
; indexes aligned.
; input: same as index (see above), prefix, pointer label array
; ---------------------------------------------------------------------------

mirror_index:	macro
		nolist
		pusho
		opt	m-

		index.\0 \1,\2,\3
		ptr_prefix: equs "\4"
		ptr_pos: = 1
		ptr_bar: = instr(1,"\5","|")			; find first bar
		while ptr_bar>0
		ptr_sub: substr ptr_pos,ptr_bar-1,"\5"		; get label
		ptr \ptr_prefix\_\ptr_sub			; create pointer
		ptr_pos: = ptr_bar+1
		ptr_bar: = instr(ptr_pos,"\5","|")		; find next bar
		endw
		ptr_sub: substr ptr_pos,,"\5"
		ptr \ptr_prefix\_\ptr_sub			; final pointer

		popo
		list
		endm

; ---------------------------------------------------------------------------
; Item in a pointer index.
; input: pointer target, pointer label array (optional)
; ---------------------------------------------------------------------------

ptr:		macro
		nolist
		pusho
		opt	m-

		if index_start=-1
		dc.\index_width \1-*
		else
		dc.\index_width \1-index_start
		endc
		
		if ~def(prefix_id)
		prefix_id: equs "id_"
		endc
		
		if instr("\1",".")=1				; check if pointer is local
		else
			if ~def(\prefix_id\\1)
			\prefix_id\\1: equ ptr_id		; create id for pointer
			else
			\prefix_id\\1_\$ptr_id: equ ptr_id	; if id already exists, append number
			endc
		endc
		
		if strlen("\2")=0				; check if label should be stored
		else
			if strcmp("\tmp_array","empty")
			tmp_array: equs "\1"			; store first label
			else
			tmp_array: equs "\tmp_array|\1"		; store subsequent labels
			endc
		\2: equs tmp_array
		endc
		
		ptr_id: = ptr_id+ptr_id_inc			; increment id

		popo
		list
		endm

; ---------------------------------------------------------------------------
; Set a VRAM address via the VDP control port.
; input: 16-bit VRAM address, control port (default is ($C00004).l)
; ---------------------------------------------------------------------------

locVRAM:	macro loc,controlport
		ifarg \controlport
		move.l	#($40000000+(((loc)&$3FFF)<<16)+(((loc)&$C000)>>14)),\controlport
		else
		move.l	#($40000000+(((loc)&$3FFF)<<16)+(((loc)&$C000)>>14)),(vdp_control_port).l
		endc
		endm

; ---------------------------------------------------------------------------
; DMA copy data from 68K (ROM/RAM) to VRAM/CRAM/VSRAM.
; input: source, length, destination ([vram address]|cram|vsram),
;  cram/vsram destination (0 by default)
; ---------------------------------------------------------------------------

dma:		macro source,length,dest1,dest2
		dma_type: = $4000
		dma_type2: = $80
		
		if strcmp("\dest1","cram")
		dma_type: = $C000
			ifarg \dest2
			dma_dest: =\dest2
			else
			dma_dest: = 0
			endc
		elseif strcmp("\dest1","vsram")
		dma_type2: = $90
			ifarg \dest2
			dma_dest: =\dest2
			else
			dma_dest: = 0
			endc
		else
		dma_dest: = \dest1
		endc
		
		lea	(vdp_control_port).l,a6
		move.l	#$94000000+(((\length>>1)&$FF00)<<8)+$9300+((\length>>1)&$FF),(a6)
		move.l	#$96000000+(((\source>>1)&$FF00)<<8)+$9500+((\source>>1)&$FF),(a6)
		move.w	#$9700+((((\source>>1)&$FF0000)>>16)&$7F),(a6)
		move.w	#dma_type+(dma_dest&$3FFF),(a6)
		move.w	#dma_type2+((dma_dest&$C000)>>14),(v_vdp_dma_buffer).w
		move.w	(v_vdp_dma_buffer).w,(a6)
		endm

; ---------------------------------------------------------------------------
; DMA destination, source and size
; ---------------------------------------------------------------------------

set_dma_dest:	macro
		if narg=1
		dc.l $40000080+(((\1)&$3FFF)<<16)+(((\1)&$C000)>>14)
		else
		move.l	#$40000080+(((\1)&$3FFF)<<16)+(((\1)&$C000)>>14),\2
		endc
		endm

set_dma_size:	macro
		if narg=1
		dc.l $93009400+((((\1)>>1)&$FF)<<16)+((((\1)>>1)&$FF00)>>8)
		else
		move.l	#$93009400+((((\1)>>1)&$FF)<<16)+((((\1)>>1)&$FF00)>>8),\2
		endc
		endm

set_dma_src:	macro
		dc.w $9500+(((\1)>>1)&$FF)
		dc.w $9600+((((\1)>>1)&$FF00)>>8)
		dc.w $9700+((((\1)>>1)&$7F0000)>>16)
		if narg=2
		dc.w \2
		endc
		endm

; ---------------------------------------------------------------------------
; Dynamic PLCs
; ---------------------------------------------------------------------------

dplcinit:	macro
		dplc_base: = \1
		endm

dplc:		macro src,size
		set_dma_src dplc_base+((\src)*sizeof_cell)	; src = tile number within source data
		set_dma_size (\size)*sizeof_cell		; size = number of tiles to load
		endm

; ---------------------------------------------------------------------------
; Disable display
; ---------------------------------------------------------------------------

disable_display:	macro
		move.w	(v_vdp_mode_buffer).w,d0		; $81xx
		andi.b	#$BF,d0					; clear bit 6
		move.w	d0,(vdp_control_port).l
		endm

; ---------------------------------------------------------------------------
; Enable display
; ---------------------------------------------------------------------------

enable_display:	macro
		move.w	(v_vdp_mode_buffer).w,d0		; $81xx
		ori.b	#$40,d0					; set bit 6
		move.w	d0,(vdp_control_port).l
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

objpos:		macro xpos,ypos,id,subtype
		dc.w \xpos, \ypos
		obj_id: = \id
		ifarg \subtype
		obj_sub\@: equ \subtype
		else
		obj_sub\@: equ 0
		endc
		obj_xflip: = 0
		obj_yflip: = 0
		obj_rem: = 0
		ifarg \5
		rept narg-4
			if strcmp("\5","xflip")
			obj_xflip: = 1
			elseif strcmp("\5","yflip")
			obj_yflip: = 2
			elseif strcmp("\5","rem")
			obj_rem: = $80
			else
			endc
		shift
		endr
		endc
		
		dc.b obj_rem+obj_xflip+obj_yflip, obj_sub\@
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

; ---------------------------------------------------------------------------
; Long conditional jumps
; ---------------------------------------------------------------------------

jcond:		macro btype,jumpto
		\btype\.s	.nojump\@
		jmp	jumpto
	.nojump\@:
		endm

jhi:		macro
		jcond bls,\1
		endm

jcc:		macro
		jcond bcs,\1
		endm

jhs:		macro
		jcc	\1
		endm

jls:		macro
		jcond bhi,\1
		endm

jcs:		macro
		jcond bcc,\1
		endm

jlo:		macro
		jcs	\1
		endm

jeq:		macro
		jcond bne,\1
		endm

jne:		macro
		jcond beq,\1
		endm

jgt:		macro
		jcond ble,\1
		endm

jge:		macro
		jcond blt,\1
		endm

jle:		macro
		jcond bgt,\1
		endm

jlt:		macro
		jcond bge,\1
		endm

jpl:		macro
		jcond bmi,\1
		endm

jmi:		macro
		jcond bpl,\1
		endm

; ---------------------------------------------------------------------------
; Convert to absolute value (i.e. always positive)
; ---------------------------------------------------------------------------

abs:		macro
		ifarg \0
		tst.\0	\1
		bpl.s	.already_pos\@				; branch if already positive
		nxg.\0	\1
		else
		tst.l	\1
		bpl.s	.already_pos\@
		nxg.l	\1
		endc
	.already_pos\@:
		endm

; ---------------------------------------------------------------------------
; Align address register to even
; ---------------------------------------------------------------------------

evenr:		macro
		exg	d0,\1
		btst	#0,d0
		beq.s	.already_even\@				; branch if already even
		add.l	#1,d0					; skip odd byte
	.already_even\@:
		exg	d0,\1
		endm
		