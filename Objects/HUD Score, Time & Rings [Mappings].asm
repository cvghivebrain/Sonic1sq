; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
Map_HUD:	index *
		ptr frame_hud_allyellow
		ptr frame_hud_ringred
		ptr frame_hud_timered
		ptr frame_hud_allred
		ptr frame_hud_lifeicon
		
tile_colon:	equ $2A

frame_hud_allyellow:
		spritemap
		piece	0, 0, 4x2, 0, hi			; SCOR
		piece	$20, 0, 1x2, $14, hi			; E
		piece	0, $10, 4x2, $E, hi			; TIME
		piece	0, $20, 4x2, 6, hi			; RING
		piece	$20, $20, 1x2, 0, hi			; S
		piece	50, 18, 1x1, tile_colon, hi		; :
		endsprite
		
frame_hud_ringred:
		spritemap
		piece	0, 0, 4x2, 0, hi			; SCOR
		piece	$20, 0, 1x2, $14, hi			; E
		piece	0, $10, 4x2, $E, hi			; TIME
		piece	0, $20, 4x2, 6, hi, pal2		; RING
		piece	$20, $20, 1x2, 0, hi, pal2		; S
		piece	50, 18, 1x1, tile_colon, hi		; :
		endsprite
		
frame_hud_timered:
		spritemap
		piece	0, 0, 4x2, 0, hi			; SCOR
		piece	$20, 0, 1x2, $14, hi			; E
		piece	0, $10, 4x2, $E, hi, pal2		; TIME
		piece	0, $20, 4x2, 6, hi			; RING
		piece	$20, $20, 1x2, 0, hi			; S
		piece	50, 18, 1x1, tile_colon, hi		; :
		endsprite
		
frame_hud_allred:
		spritemap
		piece	0, 0, 4x2, 0, hi			; SCOR
		piece	$20, 0, 1x2, $14, hi			; E
		piece	0, $10, 4x2, $E, hi, pal2		; TIME
		piece	0, $20, 4x2, 6, hi, pal2		; RING
		piece	$20, $20, 1x2, 0, hi, pal2		; S
		piece	50, 18, 1x1, tile_colon, hi		; :
		endsprite
		
frame_hud_lifeicon:
		spritemap
		piece	0, 0, 2x2, 0, hi			; icon
		piece	$10, 0, 4x1, 4, hi			; SONIC
		;piece	$30, 0, 3x1, 8, hi			; extra tiles for longer name
		piece	$16, 8, 1x1, $B, hi			; x
		endsprite
