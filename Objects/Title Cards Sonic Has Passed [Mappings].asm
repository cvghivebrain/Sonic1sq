; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC HAS PASSED" title card
; ---------------------------------------------------------------------------
Map_Has:	index *
		ptr frame_has_ringbonus
		ptr frame_has_timebonus
		ptr frame_has_score
		ptr frame_has_sonichas
		ptr frame_has_ketchuphas
		ptr frame_has_mustardhas
		ptr frame_has_passed
		ptr frame_has_oval
		ptr frame_has_act1
		ptr frame_has_act2
		ptr frame_has_act3
		
frame_has_sonichas:
		spritemap					; SONIC HAS
		piece -$48, -8, 2x2, $3E
		piece -$38, -8, 2x2, $32
		piece -$28, -8, 2x2, $2E
		piece -$18, -8, 1x2, $20
		piece -$10, -8, 2x2, 8
		piece $10, -8, 2x2, $1C
		piece $20, -8, 2x2, 0
		piece $30, -8, 2x2, $3E
		endsprite
		
		; x pos start, x pos stop
		dc.w 4, $124
		
frame_has_ketchuphas:
		spritemap					; KETCHUP HAS
		piece -$70, -8, 2x2, tile_card_K
		piece -$60, -8, 2x2, tile_card_E
		piece -$50, -8, 2x2, tile_card_T
		piece -$40, -8, 2x2, tile_card_C
		piece -$30, -8, 2x2, tile_card_H
		piece -$20, -8, 2x2, tile_card_U
		piece -$10, -8, 2x2, tile_card_P
		piece $10, -8, 2x2, $1C
		piece $20, -8, 2x2, 0
		piece $30, -8, 2x2, $3E
		endsprite
		
		dc.w $1C, $13C
		
frame_has_mustardhas:
		spritemap					; MUSTARD HAS
		piece -$70, -8, 2x2, tile_card_M
		piece -$60, -8, 2x2, tile_card_U
		piece -$50, -8, 2x2, tile_card_S
		piece -$40, -8, 2x2, tile_card_T
		piece -$30, -8, 2x2, tile_card_A
		piece -$20, -8, 2x2, tile_card_R
		piece -$10, -8, 2x2, tile_card_D
		piece $10, -8, 2x2, $1C
		piece $20, -8, 2x2, 0
		piece $30, -8, 2x2, $3E
		endsprite
		
		dc.w $1C, $13C
		
frame_has_passed:
		spritemap					; PASSED
		piece -$30, -8, 2x2, $36
		piece -$20, -8, 2x2, 0
		piece -$10, -8, 2x2, $3E
		piece 0, -8, 2x2, $3E
		piece $10, -8, 2x2, $10
		piece $20, -8, 2x2, $C
		endsprite
		
tile_hud:	= $138
tile_nums:	= $14E
		
frame_has_score:
		spritemap					; SCORE
		piece 0, 0, 4x2, tile_hud			; SCOR
		piece 32, 0, 1x2, tile_hud+$14			; E
		piece 29, -1, 2x2, 8				; mini oval
		piece 152, 0, 1x2, tile_nums			; 0
		endsprite
		
frame_has_timebonus:
		spritemap					; TIME BONUS
		piece 0, 0, 4x2, tile_hud+$E			; TIME
		piece 41, 0, 4x2, 0				; BONU
		piece 73, 0, 1x2, tile_hud			; S
		piece 70, -1, 2x2, 8				; mini oval
		piece 152, 0, 1x2, tile_nums			; 0
		endsprite
		
frame_has_ringbonus:
		spritemap					; RING BONUS
		piece 0, 0, 4x2, tile_hud+6			; RING
		piece 41, 0, 4x2, 0				; BONU
		piece 73, 0, 1x2, tile_hud			; S
		piece 70, -1, 2x2, 8				; mini oval
		piece 152, 0, 1x2, tile_nums			; 0
		endsprite
