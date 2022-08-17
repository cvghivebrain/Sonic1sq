; ---------------------------------------------------------------------------
; Sprite mappings - zone title cards
; ---------------------------------------------------------------------------
Map_Card:	index *
		ptr frame_card_ghz
		ptr frame_card_lz
		ptr frame_card_mz
		ptr frame_card_slz
		ptr frame_card_syz
		ptr frame_card_sbz
		ptr frame_card_zone
		ptr frame_card_act1
		ptr frame_card_act2
		ptr frame_card_act3
		ptr frame_card_oval
		ptr frame_card_fz
		
frame_card_ghz:
		spritemap					; GREEN HILL
		piece -$4C, -8, 2x2, $18
		piece -$3C, -8, 2x2, $3A
		piece -$2C, -8, 2x2, $10
		piece -$1C, -8, 2x2, $10
		piece -$C, -8, 2x2, $2E
		piece $14, -8, 2x2, $1C
		piece $24, -8, 1x2, $20
		piece $2C, -8, 2x2, $26
		piece $3C, -8, 2x2, $26
		endsprite
		
		dc.w 0,	$120					; GREEN HILL
		dc.w -$104, $13C				; ZONE
		dc.w $414, $154					; ACT x
		dc.w $214, $154					; oval
		
frame_card_lz:
		spritemap					; LABYRINTH
		piece -$44, -8, 2x2, $26
		piece -$34, -8, 2x2, 0
		piece -$24, -8, 2x2, 4
		piece -$14, -8, 2x2, $4A
		piece -4, -8, 2x2, $3A
		piece $C, -8, 1x2, $20
		piece $14, -8, 2x2, $2E
		piece $24, -8, 2x2, $42
		piece $34, -8, 2x2, $1C
		endsprite
		
		dc.w 0,	$120					; LABYRINTH
		dc.w -$10C, $134
		dc.w $40C, $14C
		dc.w $20C, $14C
		
frame_card_mz:
		spritemap					; MARBLE
		piece -$31, -8, 2x2, $2A
		piece -$20, -8, 2x2, 0
		piece -$10, -8, 2x2, $3A
		piece 0, -8, 2x2, 4
		piece $10, -8, 2x2, $26
		piece $20, -8, 2x2, $10
		endsprite
		
		dc.w 0,	$120					; MARBLE
		dc.w -$120, $120
		dc.w $3F8, $138
		dc.w $1F8, $138
		
frame_card_slz:
		spritemap					; STAR LIGHT
		piece -$4C, -8, 2x2, $3E
		piece -$3C, -8, 2x2, $42
		piece -$2C, -8, 2x2, 0
		piece -$1C, -8, 2x2, $3A
		piece 4, -8, 2x2, $26
		piece $14, -8, 1x2, $20
		piece $1C, -8, 2x2, $18
		piece $2C, -8, 2x2, $1C
		piece $3C, -8, 2x2, $42
		endsprite
		
		dc.w 0,	$120					; STAR LIGHT
		dc.w -$104, $13C
		dc.w $414, $154
		dc.w $214, $154
		
frame_card_syz:
		spritemap					; SPRING YARD
		piece -$54, -8, 2x2, $3E
		piece -$44, -8, 2x2, $36
		piece -$34, -8, 2x2, $3A
		piece -$24, -8, 1x2, $20
		piece -$1C, -8, 2x2, $2E
		piece -$C, -8, 2x2, $18
		piece $14, -8, 2x2, $4A
		piece $24, -8, 2x2, 0
		piece $34, -8, 2x2, $3A
		piece $44, -8, 2x2, $C
		endsprite
		
		dc.w 0,	$120					; SPRING YARD
		dc.w -$FC, $144
		dc.w $41C, $15C
		dc.w $21C, $15C
		
frame_card_sbz:
		spritemap					; SCRAP BRAIN
		piece -$54, -8, 2x2, $3E
		piece -$44, -8, 2x2, 8
		piece -$34, -8, 2x2, $3A
		piece -$24, -8, 2x2, 0
		piece -$14, -8, 2x2, $36
		piece $C, -8, 2x2, 4
		piece $1C, -8, 2x2, $3A
		piece $2C, -8, 2x2, 0
		piece $3C, -8, 1x2, $20
		piece $44, -8, 2x2, $2E
		endsprite
		
		dc.w 0,	$120					; SCRAP BRAIN
		dc.w -$FC, $144
		dc.w $41C, $15C
		dc.w $21C, $15C
		
frame_card_fz:
		spritemap					; FINAL
		piece -$24, -8, 2x2, $14
		piece -$14, -8, 1x2, $20
		piece -$C, -8, 2x2, $2E
		piece 4, -8, 2x2, 0
		piece $14, -8, 2x2, $26
		endsprite
		
		dc.w 0,	$120					; FINAL
		dc.w -$11C, $124
		dc.w $3EC, $3EC
		dc.w $1EC, $12C
		
frame_card_zone:
		spritemap					; ZONE
		piece -$20, -8, 2x2, $4E
		piece -$10, -8, 2x2, $32
		piece 0, -8, 2x2, $2E
		piece $10, -8, 2x2, $10
		endsprite
		even
		
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
		piece 8, -$C, 2x3, $60
		endsprite
		
frame_has_oval:
frame_ssr_oval:
frame_card_oval:
		spritemap					; Oval
		piece -$C, -$1C, 4x1, $70
		piece $14, -$1C, 1x3, $74
		piece -$14, -$14, 2x1, $77
		piece -$1C, -$C, 2x2, $79
		piece -$14, $14, 4x1, $70, xflip, yflip
		piece -$1C, 4, 1x3, $74, xflip, yflip
		piece 4, $C, 2x1, $77, xflip, yflip
		piece $C, -4, 2x2, $79, xflip, yflip
		piece -4, -$14, 3x1, $7D
		piece -$C, -$C, 4x1, $7C
		piece -$C, -4, 3x1, $7C
		piece -$14, 4, 4x1, $7C
		piece -$14, $C, 3x1, $7C
		endsprite
		even
