; ---------------------------------------------------------------------------
; Object subtypes
; ---------------------------------------------------------------------------

; CollapseLedge
type_ledge_left:	equ id_frame_ledge_left		; 0 - facing left
type_ledge_right:	equ id_frame_ledge_right	; 1 - also facing left, but always xflipped to face right

; FireMaker
type_fire_rate30:	equ (30/30)<<3				; every 0.5 seconds
type_fire_rate60:	equ (60/30)<<3				; every 1 second
type_fire_rate90:	equ (90/30)<<3				; every 1.5 seconds
type_fire_rate120:	equ (120/30)<<3				; every 2 seconds
type_fire_rate150:	equ (150/30)<<3				; every 2.5 seconds
type_fire_rate180:	equ (180/30)<<3				; every 3 seconds
type_fire_vertical:	equ 0
type_fire_horizontal:	equ $40
type_fire_gravity:	equ $80

; Harpoon
type_harp_h:		equ id_ani_harp_h_extending	; 0 - horizontal
type_harp_v:		equ id_ani_harp_v_extending	; 2 - vertical
type_harp_sync:		equ 8				; synchronised animation

; LabyrinthBlock
type_lblock_solid:	equ 0				; doesn't move
type_lblock_sink:	equ 1				; sinks when stood on

; Waterfall
type_wfall_vert:	equ id_frame_wfall_vertnarrow		; 0 - vertical narrow
type_wfall_cornermedium: equ id_frame_wfall_cornermedium	; 2 - corner
type_wfall_cornernarrow: equ id_frame_wfall_cornernarrow	; 3 - corner narrow
type_wfall_cornermedium2: equ id_frame_wfall_cornermedium2	; 4 - corner
type_wfall_cornernarrow2: equ id_frame_wfall_cornernarrow2	; 5 - corner narrow
type_wfall_cornernarrow3: equ id_frame_wfall_cornernarrow3	; 6 - corner narrow
type_wfall_vertwide:	equ id_frame_wfall_vertwide		; 7 - vertical wide
type_wfall_diagonal:	equ id_frame_wfall_diagonal		; 8 - diagonal
type_wfall_hi:		equ $80					; +$80 - high priority sprite

; WaterfallSplash
type_wfallsp_float:	equ 1					; matches y position to water surface
type_wfallsp_hide:	equ 2					; hide until level is updated by button

; SpinPlatform
type_spin_platform:	equ $80				; $8x - small spinning platform
type_spin_platform_alt:	equ $90				; $9x - small spinning platform, longer delay between spins

; Saws
type_saw_pizza_still:	equ 0			 	; 0 - pizza cutter, doesn't move
type_saw_pizza_sideways: equ 1			 	; 1 - pizza cutter, moves side-to-side
type_saw_pizza_updown:	equ 2			 	; 2 - pizza cutter, moves up and down
type_saw_ground_right:	equ 3			 	; 3 - ground saw, moves right
type_saw_ground_left:	equ 4			 	; 4 - ground saw, moves left

; ScrapStomp
type_stomp_slow:	equ 0				; stomper, drops quickly and rises slowly
type_stomp_fast_short:	equ 1				; stomper, drops quickly and rises quickly (64px)
type_stomp_fast_long:	equ 2				; stomper, drops quickly and rises quickly (96px)

; AnimalsEnd
type_animal_end_flicky:		equ 0
type_animal_end_flicky_onspot:	equ 1
type_animal_end_rabbit:		equ 2
type_animal_end_rabbit_onspot:	equ 3
type_animal_end_penguin:	equ 4
type_animal_end_penguin_onspot:	equ 5
type_animal_end_seal:		equ 6
type_animal_end_pig_onspot:	equ 7
type_animal_end_chicken:	equ 8
type_animal_end_squirrel:	equ 9
