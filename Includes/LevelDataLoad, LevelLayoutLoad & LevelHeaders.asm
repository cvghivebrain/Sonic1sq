; ---------------------------------------------------------------------------
; Level	layout loading subroutine

; Levels are "cropped" in ROM. In RAM the level and background each comprise
; eight $40 byte rows, which are stored alternately.
; ---------------------------------------------------------------------------

LevelDataLoad:
LevelLayoutLoad:
		lea	(v_level_layout).w,a3
		move.w	#((v_sprite_queue-v_level_layout)/4)-1,d1
		moveq	#0,d0

	.clear_ram:
		move.l	d0,(a3)+
		dbf	d1,.clear_ram				; clear the RAM ($A400-ABFF)

		lea	(v_level_layout).w,a3			; RAM address for level layout
		moveq	#0,d1
		bsr.w	LevelLayoutLoad2			; load level layout into RAM
		lea	(v_level_layout+level_max_width).w,a3	; RAM address for background layout
		moveq	#2,d1

; "LevelLayoutLoad2" is	run twice - for	the level and the background

LevelLayoutLoad2:
		move.w	(v_zone).w,d0				; get zone & act numbers as word
		lsl.b	#6,d0					; move act number (bits 0/1) next to zone number
		lsr.w	#5,d0					; d0 = zone/act expressed as one byte
		move.w	d0,d2
		add.w	d0,d0
		add.w	d2,d0					; d0 = zone/act * 6 (because level index is 6 bytes per act)
		add.w	d1,d0					; add d1: 0 for level; 2 for background
		lea	(Level_Index).l,a1
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1				; jump to actual level data
		moveq	#0,d1
		move.w	d1,d2
		move.b	(a1)+,d1				; load cropped level width (in tiles)
		move.b	(a1)+,d2				; load cropped level height (in tiles)

	.loop_row:
		move.w	d1,d0
		movea.l	a3,a0

	.loop_tile:
		move.b	(a1)+,(a0)+
		dbf	d0,.loop_tile				; load 1 row
		lea	sizeof_levelrow(a3),a3			; do next row
		dbf	d2,.loop_row				; repeat for number of rows
		rts
