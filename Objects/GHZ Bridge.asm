; ---------------------------------------------------------------------------
; Object 11 - GHZ bridge (max length 15)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3 - subtype $C (12 logs)
; ---------------------------------------------------------------------------

Bridge:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Bri_Index(pc,d0.w),d1
		jmp	Bri_Index(pc,d1.w)
; ===========================================================================
Bri_Index:	index *,,2
		ptr Bri_Main
		ptr Bri_Solid

		rsobj Bridge
ost_bridge_y_start:	rs.w 1					; original y position
ost_bridge_y_subspr:	rs.w 1					; y position of subsprites
ost_bridge_bend:	rs.b 1					; number of pixels the bridge has been deflected
ost_bridge_current_log:	rs.b 1					; log Sonic is currently standing on (left to right, starts at 0)
ost_bridge_last_log:	rs.b 1					; log on the far right
		rsobjend
; ===========================================================================

Bri_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Bri_Solid next
		move.w	#tile_Kos_Bridge+tile_pal3,ost_tile(a0)
		move.b	#render_rel+render_sublvl,ost_render(a0)
		move.w	#priority_2,ost_priority(a0)
		move.b	ost_subtype(a0),d3
		andi.w	#$F,d3					; read low nybble of subtype
		move.w	d3,d2
		lsl.w	#3,d3					; multiply by 8
		move.w	d3,ost_displaywidth_hi(a0)
		move.w	d3,ost_width_hi(a0)
		move.b	#8,ost_height(a0)
		move.b	#StrId_Bridge,ost_name(a0)
		move.w	ost_y_pos(a0),d4
		move.w	d4,ost_bridge_y_start(a0)
		subq.w	#8,d4
		move.w	d4,ost_bridge_y_subspr(a0)
		
		sub.w	ost_x_pos(a0),d3
		neg.w	d3					; d3 = x pos of left edge
		bsr.w	FindFreeSub				; find empty subsprite
		bne.s	Bri_Solid				; branch if empty slot isn't found
		move.w	d2,d0					; number of subsprites
		subq.b	#1,d2
		move.b	d2,ost_bridge_last_log(a0)		; save id of rightmost log
		moveq	#sprite2x2,d1				; size 2x2
		move.w	ost_tile(a0),d2				; tile setting
		moveq	#16,d5					; each log is 16px wide
		moveq	#0,d6
		bsr.w	InitSubXY

Bri_Solid:	; Routine 2
		shortcut
		tst.w	(v_debug_active_hi).w
		bne.w	DespawnSub				; branch if debug mode is in use
		bsr.w	SolidObjectTop_SkipChk
		beq.s	.skip_solid				; branch if no collision
		move.w	ost_solid_x_pos(a0),d4
		lsr.w	#4,d4
		move.b	d4,ost_bridge_current_log(a0)		; set current log based on Sonic's x pos on object
		
	.skip_solid:
		getsonic					; a1 = OST of Sonic
		move.w	ost_bridge_y_start(a0),d0
		bsr.s	Bri_Sink
		bra.w	DespawnSub
		
; ---------------------------------------------------------------------------
; Subroutine to sink bridge when stood on
; ---------------------------------------------------------------------------

Bri_Sink:
		tst.b	ost_mode(a0)
		bne.s	.standing_on				; branch if object is being stood on
		tst.b	ost_sink(a0)
		beq.s	.default				; branch if object is in default position
		subq.b	#2,ost_sink(a0)				; incrementally return block to default
		bra.s	.update_y

.standing_on:
		cmpi.b	#$1E,ost_sink(a0)
		bne.s	.keep_sinking				; branch if not at maximum sink level
		tst.w	ost_x_vel(a1)
		beq.s	.exit					; branch if Sonic isn't moving
		bra.s	.update_y
		
	.keep_sinking:
		addq.b	#2,ost_sink(a0)				; keep sinking

.update_y:
		moveq	#0,d1
		move.b	ost_bridge_current_log(a0),d1
		move.w	ost_x_pos(a1),d2
		cmp.w	ost_x_pos(a0),d2
		bcs.s	.left_side				; branch if Sonic is on the left half
		neg.b	d1
		add.b	ost_bridge_last_log(a0),d1
	.left_side:
		lsl.w	#5,d1
		add.b	ost_sink(a0),d1
		move.w	Bri_Sink_Data(pc,d1.w),d2
		move.b	d2,ost_bridge_bend(a0)
		add.w	d2,d0
		
	.default:
		move.w	d0,ost_y_pos(a0)			; update position
		
	.exit:
		rts
		
Bri_Sink_Data:
		dc.w 0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2
		dc.w 0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4
		dc.w 0,0,1,1,2,2,3,3,3,4,4,4,5,5,5,6
		dc.w 0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8
		dc.w 0,1,2,2,3,3,4,5,5,6,7,7,8,9,9,10
		dc.w 0,1,2,3,4,5,6,7,7,8,9,9,10,11,11,12
		dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,13,14
		dc.w 0,1,2,3,4,5,6,7,9,10,11,12,13,14,15,16
		
; ---------------------------------------------------------------------------
; GHZ bridge log

; spawned by:
;	Bridge - subtypes 0-$F (each log within a bridge is numbered)
; ---------------------------------------------------------------------------

BridgeLog:
		getparent					; a1 = OST of parent object
		moveq	#0,d2
		move.b	ost_bridge_bend(a1),d2
		beq.s	.align_to_parent			; branch if bridge is in default state
		moveq	#0,d0
		moveq	#0,d1
		move.b	ost_bridge_current_log(a1),d0
		move.b	ost_subtype(a0),d1
		cmp.b	d1,d0
		beq.s	.align_to_parent			; branch if this log was most recently stood on
		bhi.s	.left_side				; branch if log is left of where Sonic stood
		move.b	ost_bridge_last_log(a1),d3
		neg.b	d0
		add.b	d3,d0
		neg.b	d1
		add.b	d3,d1
		
	.left_side:
		add.w	d0,d0
		move.w	Bri_Fractions(pc,d0.w),d0		; get fraction based on number of logs between depressed log and left/right end
		addq.b	#1,d1
		mulu.w	d1,d0
		mulu.w	d2,d0
		pushr.w	d0
		moveq	#0,d0
		popr.b	d0
		;lsr.w	#8,d0
		add.w	ost_bridge_y_start(a1),d0
		move.w	d0,ost_y_pos(a0)
		bra.w	DisplaySprite
		
	.align_to_parent:
		move.w	ost_y_pos(a1),ost_y_pos(a0)		; align with parent object
		bra.w	DisplaySprite
		
Bri_Fractions:	dc.w 0, $100/2, $100/3, $100/4, $100/5, $100/6, $100/7, $100/8, $100/9, $100/10, $100/11, $100/12, $100/13, $100/14, $100/15, $100/16
