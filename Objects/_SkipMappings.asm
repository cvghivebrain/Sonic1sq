; ---------------------------------------------------------------------------
; Subroutine to jump to data immediately after sprite mappings

; input:
;	d0 = frame number
;	a2 = address of mappings (e.g. Map_Sonic)

; output:
;	a2 = address of data after mappings
;	uses d0, d2
; ---------------------------------------------------------------------------

SkipMappings:
		add.w	d0,d0
		adda.w	(a2,d0.w),a2				; jump to mappings for frame
		move.w	(a2)+,d0				; read sprite count from mappings
		add.w	d0,d0
		move.w	d0,d2
		add.w	d0,d0
		add.w	d2,d0					; multiply by 6
		lea	(a2,d0.w),a2				; jump to data immediately after mappings
		rts
