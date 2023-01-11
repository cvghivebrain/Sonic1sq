; ---------------------------------------------------------------------------
; Sprite mappings - Continue screen
; ---------------------------------------------------------------------------
Map_ContScr:	index *
		ptr frame_cont_mini1
		ptr frame_cont_mini2
		ptr frame_cont_text
		ptr frame_cont_sonic1
		ptr frame_cont_sonic2
		ptr frame_cont_sonic3
		ptr frame_cont_oval
		
frame_cont_text:
		spritemap					; "CONTINUE", stars
		piece	-60, -8, 2x2, 0
		piece	-$2C, -8, 2x2, 4
		piece	-$1C, -8, 2x2, 8
		piece	-$C, -8, 2x2, 12
		piece	4, -8, 1x2, 16
		piece	$C, -8, 2x2, 8
		piece	$1C, -8, 2x2, 18
		piece	$2C, -8, 2x2, 22
		piece	-$18, $38, 2x2, $47, pal2
		piece	8, 56, 2x2, $47, pal2
		;piece	-8, $36, 2x2, $1FC
		endsprite
		
frame_cont_sonic1:
		spritemap					; Sonic	on floor
		piece	-4, 4, 2x2, $15
		piece	-$14, -$C, 3x3, 6
		piece	4, -$C, 2x3, $F
		endsprite
		
frame_cont_sonic2:
		spritemap					; Sonic	on floor #2
		piece	-4, 4, 2x2, $19
		piece	-$14, -$C, 3x3, 6
		piece	4, -$C, 2x3, $F
		endsprite
		
frame_cont_sonic3:
		spritemap					; Sonic	on floor #3
		piece	-4, 4, 2x2, $1D
		piece	-$14, -$C, 3x3, 6
		piece	4, -$C, 2x3, $F
		endsprite
		
frame_cont_oval:
		spritemap					; circle on the floor
		piece	-$18, $60, 3x2, $26, pal2
		piece	0, $60, 3x2, $26, pal2, xflip
		endsprite
		
frame_cont_mini1:
		spritemap					; mini Sonic
		piece	0, 0, 2x3, 0
		endsprite
		
frame_cont_mini2:
		spritemap					; mini Sonic #2
		piece	0, 0, 2x3, 6
		endsprite
