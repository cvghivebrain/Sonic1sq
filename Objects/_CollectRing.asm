; ---------------------------------------------------------------------------
; Subroutine to	update ring counters and lives when a ring is collected
;
; input:
;	d0.w = rings to add

;	uses d0.w
; ---------------------------------------------------------------------------

CollectRing:
		add.w	d0,(v_rings).w				; add 1 to rings
		ori.b	#1,(v_hud_rings_update).w		; update the rings counter
		move.b	(v_ring_reward).w,d0
		andi.w	#$7F,d0					; get number of lives gained from rings
		add.w	d0,d0
		move.w	Ring_NextLife(pc,d0.w),d0		; get ring target for next life
		cmp.w	(v_rings).w,d0
		bls.s	.got_life				; branch if ring count matches or exceeds target
		move.w	#sfx_Ring,d0				; play ring sound
		jmp	PlaySound1
		
	.got_life:
		addq.b	#1,(v_ring_reward).w			; increment to next target
		addq.b	#1,(v_lives).w				; add 1 to the number of lives you have
		addq.b	#1,(f_hud_lives_update).w		; update the lives counter
		move.w	#mus_ExtraLife,d0			; play extra life music
		jmp	PlaySound1
		
Ring_NextLife:	dc.w 100, 200, 300, 400, 500, 600, 700, 800, 900, 9999
