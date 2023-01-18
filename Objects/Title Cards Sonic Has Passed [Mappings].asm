; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC HAS PASSED" title card
; ---------------------------------------------------------------------------
Map_Has:	index *
		ptr frame_has_ringbonus
		ptr frame_has_timebonus
		ptr frame_has_score
		
tile_tmphud:	= tile_Art_HUDMain-tile_Art_TitleCardBonus
tile_tmpnums:	= tile_Art_HUDNums-tile_Art_TitleCardBonus
		
frame_has_score:
		spritemap					; SCORE
		piece 0, 0, 4x2, tile_tmphud			; SCOR
		piece 32, 0, 1x2, tile_tmphud+$14		; E
		piece 29, -1, 2x2, 8				; mini oval
		piece 152, 0, 1x2, tile_tmpnums			; 0
		endsprite
		
frame_has_timebonus:
		spritemap					; TIME BONUS
		piece 0, 0, 4x2, tile_tmphud+$E			; TIME
		piece 41, 0, 4x2, 0				; BONU
		piece 73, 0, 1x2, tile_tmphud			; S
		piece 70, -1, 2x2, 8				; mini oval
		piece 152, 0, 1x2, tile_tmpnums			; 0
		endsprite
		
frame_has_ringbonus:
		spritemap					; RING BONUS
		piece 0, 0, 4x2, tile_tmphud+6			; RING
		piece 41, 0, 4x2, 0				; BONU
		piece 73, 0, 1x2, tile_tmphud			; S
		piece 70, -1, 2x2, 8				; mini oval
		piece 152, 0, 1x2, tile_tmpnums			; 0
		endsprite
