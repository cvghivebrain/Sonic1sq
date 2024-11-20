; ---------------------------------------------------------------------------
; Subroutine to load demo data
; ---------------------------------------------------------------------------

LoadPerDemo:
		move.w	(v_demo_num).w,d0			; get demo number
		mulu.w	#DemoDefs_size-DemoDefs,d0		; get offset for particular demo
		lea	DemoDefs(pc),a4
		adda.w	d0,a4					; jump to relevant demo data

		move.w	(a4)+,d0				; get zone number
		move.b	d0,(v_zone).w
		move.w	(a4)+,d0				; get act number
		move.b	d0,(v_act).w

		move.w	(a4)+,(v_character1).w			; get character id

		move.l	(a4)+,(v_demo_ptr).w			; get pointer for demo data

		move.l	(a4)+,(v_demo_x_start).w		; get start position

		rts

countof_demo:		equ (DemoDefs_Credits-DemoDefs)/(DemoDefs_size-DemoDefs) ; number of regular demos (4)
countof_credits:	equ (DemoDefs_end-DemoDefs_Credits)/(DemoDefs_size-DemoDefs) ; number of credits demos (8)

DemoDefs:
		dc.w id_GHZ					; zone
		dc.w 0						; act
		dc.w 0						; character
		dc.l Demo_GHZ					; pointer for demo control data
		dc.w 0,0					; start position (0,0 to use default level start)
	DemoDefs_size:

		dc.w id_MZ
		dc.w 0
		dc.w 1
		dc.l Demo_MZ
		dc.w 0,0

		dc.w id_SYZ
		dc.w 0
		dc.w 2
		dc.l Demo_SYZ
		dc.w 0,0

		; Special Stage
		dc.w -1
		dc.w 0
		dc.w 0
		dc.l Demo_SS
		dc.w 0,0

DemoDefs_Credits:
		dc.w id_GHZ
		dc.w 0
		dc.w 0
		dc.l Demo_EndGHZ1
		dc.w $0050, $03B0

		dc.w id_MZ
		dc.w 1
		dc.w 1
		dc.l Demo_EndMZ
		dc.w $0EA0, $046C

		dc.w id_SYZ
		dc.w 2
		dc.w 0
		dc.l Demo_EndSYZ
		dc.w $1750, $00BD

		dc.w id_LZ
		dc.w 2
		dc.w 0
		dc.l Demo_EndLZ
		dc.w $0A00, $062C

		dc.w id_SLZ
		dc.w 2
		dc.w 0
		dc.l Demo_EndSLZ
		dc.w $0BB0, $004C

		dc.w id_SBZ
		dc.w 0
		dc.w 0
		dc.l Demo_EndSBZ1
		dc.w $1570, $016C

		dc.w id_SBZ
		dc.w 1
		dc.w 0
		dc.l Demo_EndSBZ2
		dc.w $01B0, $072C

		dc.w id_GHZ
		dc.w 0
		dc.w 0
		dc.l Demo_EndGHZ2
		dc.w $1400, $02AC
	DemoDefs_end:
