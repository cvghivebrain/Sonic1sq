; ---------------------------------------------------------------------------
; Sprite mappings - Caterkiller	enemy (MZ, SBZ)
; ---------------------------------------------------------------------------
Map_Cat:	index *
		ptr frame_cat_head1
		ptr frame_cat_body1
		ptr frame_cat_mouth1
		
frame_cat_head1:						; caterkiller head, mouth closed
		spritemap
		piece	-8, -$E, 2x3, 0
		endsprite
		
frame_cat_body1:						; caterkiller body
		spritemap
		piece	-8, -8, 2x2, $C
		endsprite
		
frame_cat_mouth1:						; caterkiller head, mouth open
		spritemap
		piece	-8, -$E, 2x3, 6
		endsprite
