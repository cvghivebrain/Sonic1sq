; ---------------------------------------------------------------------------
; Sprite mappings - zone title cards
; ---------------------------------------------------------------------------
Map_Card:	index *
		ptr frame_card_oval
		ptr frame_card_act
		ptr frame_card_zone
		ptr frame_card_greenhill
		ptr frame_card_marble
		ptr frame_card_springyard
		ptr frame_card_labyrinth
		ptr frame_card_starlight
		ptr frame_card_scrapbrain
		ptr frame_card_final
		ptr frame_card_sonichas
		ptr frame_card_ketchuphas
		ptr frame_card_mustardhas
		ptr frame_card_passed
		
frame_card_act:
		spritemap					; ACT #
		piece -$14, 4, 3x1, 0
		piece 8, -$C, 2x3, 3
		endsprite
		
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
		
frame_card_zone:
		spritemap					; ZONE
		piece 0, 0, 4x2, 0				; ZO
		piece $20, 0, 4x2, 8				; NE
		endsprite
		
frame_card_greenhill:
		spritemap					; GREEN HILL
		piece 0, 0, 4x2, 16				; GR
		piece $20, 0, 2x2, 12				; E
		piece $30, 0, 2x2, 12				; E
		piece $40, 0, 2x2, 8				; N
		piece $60, 0, 3x2, 24				; HI
		piece $78, 0, 2x2, 30				; L
		piece $88, 0, 2x2, 30				; L
		endsprite
		
frame_card_marble:
		spritemap					; MARBLE
		piece 0, 0, 4x2, 16				; MA
		piece $20, 0, 4x2, 24				; RB
		piece $40, 0, 2x2, 32				; L
		piece $50, 0, 2x2, 12				; E
		endsprite
		
frame_card_springyard:
		spritemap					; SPRING YARD
		piece 0, 0, 4x2, 16				; SP
		piece $20, 0, 3x2, 24				; RI
		piece $38, 0, 2x2, 8				; N
		piece $48, 0, 2x2, 30				; G
		piece $68, 0, 4x2, 34				; YA
		piece $88, 0, 2x2, 24				; R
		piece $98, 0, 2x2, 42				; D
		endsprite
		
frame_card_labyrinth:
		spritemap					; LABYRINTH
		piece 0, 0, 4x2, 16				; LA
		piece $20, 0, 4x2, 24				; BY
		piece $40, 0, 3x2, 32				; RI
		piece $58, 0, 2x2, 8				; N
		piece $68, 0, 4x2, 38				; TH
		endsprite
		
frame_card_starlight:
		spritemap					; STAR LIGHT
		piece 0, 0, 4x2, 16				; ST
		piece $20, 0, 4x2, 24				; AR
		piece $50, 0, 3x2, 32				; LI
		piece $68, 0, 4x2, 38				; GH
		piece $78, 0, 2x2, 20				; T
		endsprite
		
frame_card_scrapbrain:
		spritemap					; SCRAP BRAIN
		piece 0, 0, 4x2, 16				; SC
		piece $20, 0, 4x2, 24				; RA
		piece $50, 0, 2x2, 32				; P
		piece $70, 0, 2x2, 36				; B
		piece $80, 0, 4x2, 24				; RA
		piece $A0, 0, 1x2, 40				; I
		piece $A8, 0, 2x2, 8				; N
		endsprite
		
frame_card_final:
		spritemap					; FINAL
		piece 0, 0, 3x2, 16				; FI
		piece $18, 0, 2x2, 8				; N
		piece $28, 0, 4x2, 22				; AL
		endsprite
		
frame_card_passed:
		spritemap					; PASSED
		piece 0, 0, 2x2, 12				; P
		piece $10, 0, 4x2, 4				; AS
		piece $30, 0, 2x2, 8				; S
		piece $40, 0, 4x2, 16				; ED
		endsprite
		
frame_card_sonichas:
		spritemap					; SONIC HAS
		piece 0, 0, 2x2, 8				; S
		piece $10, 0, 4x2, 24				; ON
		piece $30, 0, 3x2, 32				; IC
		piece $58, 0, 4x2, 0				; HA
		piece $78, 0, 2x2, 8				; S
		endsprite
		
frame_card_ketchuphas:
		spritemap					; KETCHUP HAS
		piece 0, 0, 2x2, 24				; K
		piece $10, 0, 2x2, 16				; E
		piece $20, 0, 4x2, 28				; TC
		piece $40, 0, 2x2, 0				; H
		piece $50, 0, 2x2, 36				; U
		piece $60, 0, 2x2, 12				; P
		piece $80, 0, 4x2, 0				; HA
		piece $A0, 0, 2x2, 8				; S
		endsprite
		
frame_card_mustardhas:
		spritemap					; MUSTARD HAS
		piece 0, 0, 4x2, 24				; MU
		piece $20, 0, 2x2, 8				; S
		piece $30, 0, 2x2, 32				; T
		piece $40, 0, 2x2, 4				; A
		piece $50, 0, 2x2, 36				; R
		piece $60, 0, 2x2, 20				; D
		piece $80, 0, 4x2, 0				; HA
		piece $A0, 0, 2x2, 8				; S
		endsprite
