; ---------------------------------------------------------------------------
; Character definitions
; ---------------------------------------------------------------------------

CharacterDefs:
		; Sonic
		dc.l SonicPlayer				; object pointer for level
		dc.l SonicSpecial				; object pointer for Special Stage
		dc.w -1						; palette patch id (actual palette is loaded by LoadPerZone; use -1 to skip)
		dc.w id_UPLC_SonicIcon				; life icon graphics
		dc.w id_HasSet_Sonic				; "Sonic has passed" settings
		dc.w id_UPLC_SonicCard				; "Sonic has passed" graphics
		dc.w id_SSRSet_Sonic				; "Sonic got them all" settings
		dc.w id_UPLC_SSRSonic				; "Sonic got them all" graphics
		dc.w 18/2, 38/2					; width, height (standing/running etc.)
		dc.w 14/2, 28/2					; width, height (rolling/jumping)
		dc.w 18/2, 34/2					; hitbox width, height (standing/running etc.)
		dc.w 18/2, 24/2					; hitbox width, height (rolling/jumping)
	CharacterDefs_size:

		; Red Sonic
		dc.l SonicPlayer
		dc.l SonicSpecial
		dc.w id_Pal_SonicRed
		dc.w id_UPLC_SonicIcon
		dc.w id_HasSet_Ketchup
		dc.w id_UPLC_KetchupCard
		dc.w id_SSRSet_Ketchup
		dc.w id_UPLC_SSRKetchup
		dc.w 18/2, 38/2
		dc.w 14/2, 28/2
		dc.w 18/2, 34/2
		dc.w 18/2, 24/2

		; Yellow Sonic
		dc.l SonicPlayer
		dc.l SonicSpecial
		dc.w id_Pal_SonicYellow
		dc.w id_UPLC_SonicIcon
		dc.w id_HasSet_Mustard
		dc.w id_UPLC_MustardCard
		dc.w id_SSRSet_Mustard
		dc.w id_UPLC_SSRMustard
		dc.w 18/2, 38/2
		dc.w 14/2, 28/2
		dc.w 18/2, 34/2
		dc.w 18/2, 24/2
