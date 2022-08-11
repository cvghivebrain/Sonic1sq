; ---------------------------------------------------------------------------
; Sprite mappings - signpost
; ---------------------------------------------------------------------------
Map_Sign:	index *
		ptr frame_sign_eggman
		ptr frame_sign_spin1
		ptr frame_sign_spin2
		ptr frame_sign_spin3
		ptr frame_sign_sonic
		
frame_sign_eggman:
		spritemap
		piece	-$18, -$10, 3x4, 0
		piece	0, -$10, 3x4, 0, xflip
		piece	-4, $10, 1x2, $C
		endsprite
		
		dplcinit Art_Signpost				; address of signpost gfx
		dplc 0,14					; offset, size (in tiles)
		
frame_sign_spin1:
		spritemap
		piece	-$10, -$10, 4x4, 0
		piece	-4, $10, 1x2, $10
		endsprite
		
		dplc 14,18
		
frame_sign_spin2:
		spritemap
		piece	-4, -$10, 1x4, 0
		piece	-4, $10, 1x2, 4, xflip
		endsprite
		
		dplc 32,6
		
frame_sign_spin3:
		spritemap
		piece	-$10, -$10, 4x4, 0, xflip
		piece	-4, $10, 1x2, $10, xflip
		endsprite
		
		dplc 14,18
		
frame_sign_sonic:
		spritemap
		piece	-$18, -$10, 3x4, 0
		piece	0, -$10, 3x4, $C
		piece	-4, $10, 1x2, $18
		endsprite
		
		dplc 38,26
