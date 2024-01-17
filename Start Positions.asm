; ---------------------------------------------------------------------------
; Sonic start position constants
; ---------------------------------------------------------------------------

startpos:	macro
		startpos_\3: equ (\1<<16)+\2
		endm

		; Special Stages
		startpos $03D0, $02E0, ss1
		startpos $0328, $0574, ss2
		startpos $04E4, $02E0, ss3
		startpos $03AD, $02E0, ss4
		startpos $0340, $06B8, ss5
		startpos $049B, $0358, ss6
