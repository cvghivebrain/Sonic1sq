; ---------------------------------------------------------------------------
; Object 65 - waterfalls (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3 - subtypes 0/2/3/4/5/6/7/8

; subtypes:
;	%H000FFFF
;	H - 1 for high priority sprite
;	FFFF - frame id

type_wfall_vert:	equ id_frame_wfall_vertnarrow		; 0 - vertical narrow
type_wfall_cornermedium: equ id_frame_wfall_cornermedium	; 2 - corner
type_wfall_cornernarrow: equ id_frame_wfall_cornernarrow	; 3 - corner narrow
type_wfall_cornermedium2: equ id_frame_wfall_cornermedium2	; 4 - corner
type_wfall_cornernarrow2: equ id_frame_wfall_cornernarrow2	; 5 - corner narrow
type_wfall_cornernarrow3: equ id_frame_wfall_cornernarrow3	; 6 - corner narrow
type_wfall_vertwide:	equ id_frame_wfall_vertwide		; 7 - vertical wide
type_wfall_diagonal:	equ id_frame_wfall_diagonal		; 8 - diagonal
type_wfall_hi_bit:	equ 7
type_wfall_hi:		equ 1<<type_wfall_hi_bit		; +$80 - high priority sprite
; ---------------------------------------------------------------------------

Waterfall:
		move.l	#Map_WFall,ost_mappings(a0)
		move.w	#tile_Kos_Splash+tile_pal3,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#$18,ost_displaywidth(a0)
		move.w	#priority_1,ost_priority(a0)
		move.b	ost_subtype(a0),d0
		bpl.s	.not_high				; branch if not +$80
		bset	#tile_hi_bit,ost_tile(a0)
		
	.not_high:
		andi.b	#$F,d0					; read only the	low nybble
		move.b	d0,ost_frame(a0)			; set frame number
		
		shortcut	DespawnQuick
		bra.w	DespawnQuick
		
; ---------------------------------------------------------------------------
; Waterfall splashes (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3 - subtypes 0/1/$82

; subtypes:
;	%H00000LW
;	H - 1 for high priority sprite
;	L - 1 to hide until level is updated by button (LZ3 only)
;	W - 1 to float on water surface

type_wfallsp_float_bit:	equ 0
type_wfallsp_hide_bit:	equ 1
type_wfallsp_hi_bit:	equ 7
type_wfallsp_float:	equ 1<<type_wfallsp_float_bit		; matches y position to water surface
type_wfallsp_hide:	equ 1<<type_wfallsp_hide_bit		; hide until level is updated by button
type_wfallsp_hi:	equ 1<<type_wfallsp_hi_bit		; +$80 - high priority sprite
; ---------------------------------------------------------------------------

WaterfallSplash:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	WFall_Index(pc,d0.w),d1
		jmp	WFall_Index(pc,d1.w)
; ===========================================================================
WFall_Index:	index *,,2
		ptr WFall_Main
		ptr WFall_Animate
; ===========================================================================

WFall_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto WFall_Animate next
		move.l	#Map_WFall,ost_mappings(a0)
		move.w	#tile_Kos_Splash+tile_pal3,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#$18,ost_displaywidth(a0)
		move.w	#priority_1,ost_priority(a0)
		tst.b	ost_subtype(a0)				; get object type
		bpl.s	WFall_Animate				; branch if $00-$7F
		bset	#tile_hi_bit,ost_tile(a0)

WFall_Animate:	; Routine 2
		shortcut
		move.b	ost_subtype(a0),d0
		btst	#type_wfallsp_float_bit,d0
		beq.s	.not_floating				; branch if not floating on water surface
		move.w	(v_water_height_actual).w,d1
		subi.w	#$10,d1
		move.w	d1,ost_y_pos(a0)			; match object position to water height
		
	.not_floating:
		btst	#type_wfallsp_hide_bit,d0
		beq.s	.not_hidden				; branch if not hidden
		cmpi.b	#7,(v_level_layout+$106).w		; check if level has been modified by pressing a button (LZ3 only)
		bne.w	DespawnQuick_NoDisplay			; don't display sprite
		
	.not_hidden:
		lea	Ani_WFall(pc),a1
		jsr	(AnimateSprite).l
		bra.w	DespawnQuick

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_WFall:	index *
		ptr ani_wfall_splash
		
ani_wfall_splash:
		dc.w 5
		dc.w id_frame_wfall_splash1
		dc.w id_frame_wfall_splash2
		dc.w id_frame_wfall_splash3
		dc.w id_Anim_Flag_Restart
