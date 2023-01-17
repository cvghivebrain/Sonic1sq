; ---------------------------------------------------------------------------
; Sprite mappings - zone title cards
; ---------------------------------------------------------------------------
Map_Card:	index *
		ptr frame_card_act1
		ptr frame_card_act2
		ptr frame_card_act3
		ptr frame_card_oval
		ptr frame_card_act
		ptr frame_card_letter
		ptr frame_card_i
		
frame_card_letter:
		spritemap					; letters A-Z (except I)
		piece -8, -8, 2x2, 0
		endsprite
		
frame_card_i:
		spritemap					; letter I
		piece -8, -8, 1x2, 0
		endsprite
		
frame_has_act1:
frame_card_act1:
		spritemap					; ACT 1
		piece -$14, 4, 4x1, $53
		piece $C, -$C, 1x3, $57
		endsprite
		
frame_has_act2:
frame_card_act2:
		spritemap					; ACT 2
		piece -$14, 4, 4x1, $53
		piece 8, -$C, 2x3, $5A
		endsprite
		
frame_has_act3:
frame_card_act3:
		spritemap					; ACT 3
		piece -$14, 4, 4x1, $53
		endsprite
		
frame_has_act:
frame_card_act:
		spritemap					; ACT #
		piece -$14, 4, 3x1, 0
		piece 8, -$C, 2x3, 3
		endsprite
		
frame_has_oval:
frame_ssr_oval:
frame_card_oval:
		spritemap					; Oval
		piece -$C, -$1C, 4x1, 0
		piece $14, -$1C, 1x3, 4
		piece -$14, -$14, 2x1, 7
		piece -$1C, -$C, 2x2, 9
		piece -$14, $14, 4x1, 0, xflip, yflip
		piece -$1C, 4, 1x3, 4, xflip, yflip
		piece 4, $C, 2x1, 7, xflip, yflip
		piece $C, -4, 2x2, 9, xflip, yflip
		piece -4, -$14, 3x1, $D
		piece -$C, -$C, 4x1, $C
		piece -$C, -4, 3x1, $C
		piece -$14, 4, 4x1, $C
		piece -$14, $C, 3x1, $C
		endsprite
		even
