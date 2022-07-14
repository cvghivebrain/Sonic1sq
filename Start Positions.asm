; ---------------------------------------------------------------------------
; Sonic start position constants
; ---------------------------------------------------------------------------

startpos:	macro
		startpos_\3: equ (\1<<16)+\2
		endm

		; Ending credits demos
		startpos $0050, $03B0, ghz1_end1
		startpos $0EA0, $046C, mz2_end
		startpos $1750, $00BD, syz3_end
		startpos $0A00, $062C, lz3_end
		startpos $0BB0, $004C, slz3_end
		startpos $1570, $016C, sbz1_end
		startpos $01B0, $072C, sbz2_end
		startpos $1400, $02AC, ghz1_end2

		; Special Stages
		startpos $03D0, $02E0, ss1
		startpos $0328, $0574, ss2
		startpos $04E4, $02E0, ss3
		startpos $03AD, $02E0, ss4
		startpos $0340, $06B8, ss5
		startpos $049B, $0358, ss6