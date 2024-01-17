; ---------------------------------------------------------------------------
; Sprite mappings - special stage results screen
; ---------------------------------------------------------------------------
Map_SSR:	index *
		ptr frame_ssr_contsonic1
		ptr frame_ssr_contsonic2

frame_ssr_contsonic1:
		spritemap
		piece $90, 0, 2x3, 0, pal2
		endsprite
		
frame_ssr_contsonic2:
		spritemap
		piece $90, 0, 2x3, 6, pal2
		endsprite
