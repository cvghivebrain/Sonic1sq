; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
Map_HUD:	index *
		ptr frame_hud_allyellow
		ptr frame_hud_ringred
		ptr frame_hud_timered
		ptr frame_hud_allred
		ptr frame_hud_lifeicon
		ptr frame_hud_debug
		ptr frame_hud_debugsonic
		ptr frame_hud_debugsonictop
		ptr frame_hud_debugcpu

frame_hud_allyellow:
		spritemap
		piece	0, 0, 4x2, 0, hi			; SCOR
		piece	$20, 0, 1x2, $14, hi			; E
		piece	$28, 0, 4x2, $24, hi			; score counter
		piece	$48, 0, 3x2, $2C, hi
		piece	0, $10, 4x2, $E, hi			; TIME
		piece	$28, $10, 4x2, $1C, hi			; time counter
		piece	0, $20, 4x2, 6, hi			; RING
		piece	$20, $20, 1x2, 0, hi			; S
		piece	$30, $20, 3x2, $16, hi			; ring counter
		endsprite
		
frame_hud_ringred:
		spritemap
		piece	0, 0, 4x2, 0, hi			; SCOR
		piece	$20, 0, 1x2, $14, hi			; E
		piece	$28, 0, 4x2, $24, hi			; score counter
		piece	$48, 0, 3x2, $2C, hi
		piece	0, $10, 4x2, $E, hi			; TIME
		piece	$28, $10, 4x2, $1C, hi			; time counter
		piece	0, $20, 4x2, 6, hi, pal2		; RING
		piece	$20, $20, 1x2, 0, hi, pal2		; S
		piece	$30, $20, 3x2, $16, hi			; ring counter
		endsprite
		
frame_hud_timered:
		spritemap
		piece	0, 0, 4x2, 0, hi			; SCOR
		piece	$20, 0, 1x2, $14, hi			; E
		piece	$28, 0, 4x2, $24, hi			; score counter
		piece	$48, 0, 3x2, $2C, hi
		piece	0, $10, 4x2, $E, hi, pal2		; TIME
		piece	$28, $10, 4x2, $1C, hi			; time counter
		piece	0, $20, 4x2, 6, hi			; RING
		piece	$20, $20, 1x2, 0, hi			; S
		piece	$30, $20, 3x2, $16, hi			; ring counter
		endsprite
		
frame_hud_allred:
		spritemap
		piece	0, 0, 4x2, 0, hi			; SCOR
		piece	$20, 0, 1x2, $14, hi			; E
		piece	$28, 0, 4x2, $24, hi			; score counter
		piece	$48, 0, 3x2, $2C, hi
		piece	0, $10, 4x2, $E, hi, pal2		; TIME
		piece	$28, $10, 4x2, $1C, hi			; time counter
		piece	0, $20, 4x2, 6, hi, pal2		; RING
		piece	$20, $20, 1x2, 0, hi, pal2		; S
		piece	$30, $20, 3x2, $16, hi			; ring counter
		endsprite
		
frame_hud_lifeicon:
		spritemap
		piece	0, 0, 2x2, 0, hi			; icon
		piece	$10, 0, 4x1, 4, hi			; SONIC
		piece	$30, 0, 1x1, 8, hi			; extra tiles for longer name
		piece	$16, 8, 1x1, 9, hi			; x
		piece	$20, 8, 2x1, 10, hi			; number
		endsprite
		
frame_hud_debug:
		spritemap
		piece	0, 0, 2x1, $34, hi			; sprite counter
		piece	0, 12, 4x1, $D0, hi			; camera x pos
		piece	0, 20, 4x1, $D4, hi			; camera y pos
		endsprite
		
frame_hud_debugsonic:
		spritemap
		piece	-16, 24, 4x1, 0, hi			; object x pos
		piece	-16, 32, 4x1, 4, hi			; object y pos
		endsprite
		
frame_hud_debugsonictop:
		spritemap
		piece	-16, -40, 4x1, 0, hi			; object x pos
		piece	-16, -32, 4x1, 4, hi			; object y pos
		endsprite
		
frame_hud_debugcpu:
		spritemap
		piece	0, -4, 1x1, 2, hi
		endsprite
