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
		ptr frame_cont_0
		ptr frame_cont_1
		ptr frame_cont_2
		ptr frame_cont_3
		ptr frame_cont_4
		ptr frame_cont_5
		ptr frame_cont_6
		ptr frame_cont_7
		ptr frame_cont_8
		ptr frame_cont_9
		ptr frame_cont_10
		
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
		
frame_cont_0:
		spritemap					; 00
		piece	0, 0, 1x2, 0
		piece	8, 0, 1x2, 0
		endsprite
		
frame_cont_1:
		spritemap					; 01
		piece	0, 0, 1x2, 0
		piece	8, 0, 1x2, 2
		endsprite
		
frame_cont_2:
		spritemap					; 02
		piece	0, 0, 1x2, 0
		piece	8, 0, 1x2, 4
		endsprite
		
frame_cont_3:
		spritemap					; 03
		piece	0, 0, 1x2, 0
		piece	8, 0, 1x2, 6
		endsprite
		
frame_cont_4:
		spritemap					; 04
		piece	0, 0, 1x2, 0
		piece	8, 0, 1x2, 8
		endsprite
		
frame_cont_5:
		spritemap					; 05
		piece	0, 0, 1x2, 0
		piece	8, 0, 1x2, 10
		endsprite
		
frame_cont_6:
		spritemap					; 06
		piece	0, 0, 1x2, 0
		piece	8, 0, 1x2, 12
		endsprite
		
frame_cont_7:
		spritemap					; 07
		piece	0, 0, 1x2, 0
		piece	8, 0, 1x2, 14
		endsprite
		
frame_cont_8:
		spritemap					; 08
		piece	0, 0, 1x2, 0
		piece	8, 0, 1x2, 16
		endsprite
		
frame_cont_9:
		spritemap					; 09
		piece	0, 0, 1x2, 0
		piece	8, 0, 1x2, 18
		endsprite
		
frame_cont_10:
		spritemap					; 10
		piece	0, 0, 1x2, 2
		piece	8, 0, 1x2, 0
		endsprite
