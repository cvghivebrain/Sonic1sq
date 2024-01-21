; ---------------------------------------------------------------------------
; Object subtypes
; ---------------------------------------------------------------------------

; SpinPlatform
type_spin_platform:	equ $80					; $8x - small spinning platform
type_spin_platform_alt:	equ $90					; $9x - small spinning platform, longer delay between spins

; Saws
type_saw_pizza_still:	equ 0					; 0 - pizza cutter, doesn't move
type_saw_pizza_sideways: equ 1					; 1 - pizza cutter, moves side-to-side
type_saw_pizza_updown:	equ 2					; 2 - pizza cutter, moves up and down
type_saw_ground_right:	equ 3					; 3 - ground saw, moves right
type_saw_ground_left:	equ 4					; 4 - ground saw, moves left

; ScrapStomp
type_stomp_slow:	equ 0					; stomper, drops quickly and rises slowly
type_stomp_fast_short:	equ 1					; stomper, drops quickly and rises quickly (64px)
type_stomp_fast_long:	equ 2					; stomper, drops quickly and rises quickly (96px)

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
