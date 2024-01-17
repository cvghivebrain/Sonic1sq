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
		ptr frame_card_specialstage
		ptr frame_card_chaosemeralds
		ptr frame_card_sonicgot
		ptr frame_card_ketchupgot
		ptr frame_card_mustardgot
		ptr frame_card_gotthemall
		
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
		
titlecardmap:	macro letterset
		letters: equs "\letterset"
		spritemap
		xpos: = 0
		rept narg-1
		ifarg \2
		
		letterpos: = instr("\letters","\2")-1
		tiletmp: = letterpos*4				; get tile id
		prevstr: substr 1,letterpos,"\letters"		; get letters before current
		if instr("\prevstr","i")
		tiletmp: = tiletmp-2				; take I into account when finding tile id
		endc
		
		width: = strlen("\2")*16			; width of piece in px
		if instr("\2","i")
		width: = width-8				; take I into account for width
		endc
		tilewidth: = width/8				; width of piece in tiles
		
		piece xpos, 0, \#tilewidth\x2, tiletmp
		xpos: = xpos+width
		else
		xpos: = xpos+titlecardspace			; space
		endc
		shift						; next piece
		endr
		endsprite
		endm
		
		titlecardspace: = 16				; 16px space between words
		
frame_card_zone:
		titlecardmap	\letters_UPLC_GHZCard,ZO,NE
		
frame_card_greenhill:
		titlecardmap	\letters_UPLC_GHZCard,GR,E,E,N,,HI,L,L
		
frame_card_marble:
		titlecardmap	\letters_UPLC_MZCard,MA,RB,L,E
		
frame_card_springyard:
		titlecardmap	\letters_UPLC_SYZCard,SP,RI,N,G,,YA,R,D
		
frame_card_labyrinth:
		titlecardmap	\letters_UPLC_LZCard,LA,BY,RI,N,TH
		
frame_card_starlight:
		titlecardmap	\letters_UPLC_SLZCard,ST,AR,,LI,GH,T
		
frame_card_scrapbrain:
		titlecardmap	\letters_UPLC_SBZCard,SC,RA,P,,B,RA,I,N
		
frame_card_final:
		titlecardmap	\letters_UPLC_FZCard,FI,N,AL
		
frame_card_passed:
		titlecardmap	\letters_UPLC_SonicCard,P,AS,S,ED
		
frame_card_sonichas:
		titlecardmap	\letters_UPLC_SonicCard,S,ON,IC,,HA,S
		
frame_card_ketchuphas:
		titlecardmap	\letters_UPLC_KetchupCard,K,E,TC,H,U,P,,HA,S
		
frame_card_mustardhas:
		titlecardmap	\letters_UPLC_MustardCard,MU,S,T,A,R,D,,HA,S
		
frame_card_specialstage:
		titlecardmap	\letters_UPLC_SSRSS,SP,EC,IA,L,,S,T,A,G,E
		
frame_card_chaosemeralds:
		titlecardmap	\letters_UPLC_SSRChaos,CH,AO,S,,EM,E,R,A,LD,S
		
		titlecardspace: = 8				; 8px spacing for "got them all"
		
frame_card_sonicgot:
		titlecardmap	\letters_UPLC_SSRSonic,S,O,NI,C,,GO,T,,TH,EM,,AL,L
		
frame_card_ketchupgot:
		titlecardmap	\letters_UPLC_SSRKetchup,K,E,T,C,H,UP
		
frame_card_mustardgot:
		titlecardmap	\letters_UPLC_SSRMustard,M,US,T,A,RD
		
frame_card_gotthemall:
		titlecardmap	\letters_UPLC_SSRKetchup,GO,T,,TH,EM,,AL,L
