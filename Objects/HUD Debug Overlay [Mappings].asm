; ---------------------------------------------------------------------------
; Sprite mappings - width/height overlay
; ---------------------------------------------------------------------------
Map_Overlay:	index *
		ptr frame_overlay_centre
		ptr frame_overlay_centre
		ptr frame_overlay_centre
		ptr frame_overlay_centre
		i: = 4
		rept 50
		ptr frame_overlay_\#i
		i: = i+1
		endr

frame_overlay_centre:
		spritemap
		piece	-1, -2, 1x1, 1, hi
		endsprite

		i: = 4
		rept 50
frame_overlay_\#i:
		spritemap
		piece	0, 0-i, 1x1, 0, hi
		piece	0, -8+i, 1x1, 0, yflip, hi
		endsprite
		i: = i+1
		endr
		