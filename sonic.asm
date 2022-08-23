;  =========================================================================
; |                           Sonic 1-squared                               |
;  =========================================================================

		opt	l.					; . is the local label symbol
		opt	ae-					; automatic evens are disabled by default
		opt	ws+					; allow statements to contain white-spaces
		opt	w+					; print warnings
		opt	m+					; do not expand macros - if enabled, this can break assembling

		include "Mega Drive.asm"
		include "Macros - More CPUs.asm"
		include "Macros - 68k Extended.asm"
		include "Macros - General.asm"
		include "Macros - Sonic.asm"
		include "sound\Sounds.asm"
		include "sound\Sound Equates.asm"
		include "Constants.asm"
		include "RAM Addresses.asm"
		include	"Start Positions.asm"
		include "Includes\Compatibility.asm"

		cpu	68000

EnableSRAM:	equ 0						; change to 1 to enable SRAM
BackupSRAM:	equ 1
AddressSRAM:	equ 3						; 0 = odd+even; 2 = even only; 3 = odd only

; Change to 0 to build the original version of the game, dubbed REV00
; Change to 1 to build the later version, dubbed REV01, which includes various bugfixes and enhancements
; Change to 2 to build the version from Sonic Mega Collection, dubbed REVXB, which fixes the infamous "spike bug"
	if ~def(Revision)					; bit-perfect check will automatically set this variable
Revision:	equ 1
	endc

ZoneCount:	equ 6						; discrete zones are: GHZ, MZ, SYZ, LZ, SLZ, and SBZ

; ===========================================================================

ROM_Start:
Vectors:	dc.l v_stack_pointer&$FFFFFF			; Initial stack pointer value
		dc.l EntryPoint					; Start of program
		dc.l BusError					; Bus error
		dc.l AddressError				; Address error
		dc.l IllegalInstr				; Illegal instruction
		dc.l ZeroDivide					; Division by zero
		dc.l ChkInstr					; CHK exception
		dc.l TrapvInstr					; TRAPV exception
		dc.l PrivilegeViol				; Privilege violation
		dc.l Trace					; TRACE exception
		dc.l Line1010Emu				; Line-A emulator
		dc.l Line1111Emu				; Line-F emulator
		dcb.l 2,ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Format error
		dc.l ErrorExcept				; Uninitialized interrupt
		dcb.l 8,ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Spurious exception
		dc.l ErrorTrap					; IRQ level 1
		dc.l ErrorTrap					; IRQ level 2
		dc.l ErrorTrap					; IRQ level 3
		dc.l HBlank					; IRQ level 4 (horizontal retrace interrupt)
		dc.l ErrorTrap					; IRQ level 5
		dc.l VBlank					; IRQ level 6 (vertical retrace interrupt)
		dc.l ErrorTrap					; IRQ level 7
		dcb.l 16,ErrorTrap				; TRAP #00..#15 exceptions
		dcb.l 8,ErrorTrap				; Unused (reserved)
		if Revision<>2
			dcb.l 8,ErrorTrap			; Unused (reserved)
		else
	Spike_Bugfix:
								; Relocated code from Spike_Hurt. REVXB was a nasty hex-edit.
			move.l	ost_y_pos(a0),d3
			move.w	ost_y_vel(a0),d0
			ext.l	d0
			asl.l	#8,d0
			jmp	(Spike_Resume).l

			dc.w ErrorTrap
			dcb.l 3,ErrorTrap
		endc
		dc.b "SEGA MEGA DRIVE "				; Hardware system ID (Console name)
		dc.b "(C)SEGA \date"				; Copyright holder and release date (generally year)
		dc.b "SONIC 1-SQUARED                                 " ; Domestic name
		dc.b "SONIC 1-SQUARED                                 " ; International name

	if Revision=0
		dc.b "GM 00001009-00"				; Serial/version number (Rev 0)
	else
		dc.b "GM 00004049-01"				; Serial/version number (Rev non-0)
	endc

Checksum: 	dc.w $0
		dc.b "J               "				; I/O support
ROM_Start_Ptr:	dc.l ROM_Start					; Start address of ROM
ROM_End_Ptr:	dc.l ROM_End-1					; End address of ROM
		dc.l $FF0000					; Start address of RAM
		dc.l $FFFFFF					; End address of RAM

	if EnableSRAM=1
		dc.b "RA", $A0+(BackupSRAM<<6)+(AddressSRAM<<3), $20
		dc.l $200001					; SRAM start
		dc.l $200FFF					; SRAM end
	else
		dc.l $20202020					; dummy values (SRAM disabled)
		dc.l $20202020					; SRAM start
		dc.l $20202020					; SRAM end
	endc

		dc.b "                                                    " ; Notes (unused, anything can be put in this space, but it has to be 52 bytes.)
		dc.b "JUE             "				; Region (Country code)
EndOfHeader:

; ===========================================================================
; Crash/Freeze the 68000. Unlike Sonic 2, Sonic 1 uses the 68000 for playing music, so it stops too

ErrorTrap:
		nop
		nop
		bra.s	ErrorTrap
; ===========================================================================

		include	"Includes\Mega Drive Setup.asm"		; EntryPoint

GameProgram:
		tst.w	(vdp_control_port).l
		btst	#6,(port_e_control).l
		beq.s	CheckSumCheck
		cmpi.l	#'init',(v_checksum_pass).w		; has checksum routine already run?
		beq.w	GameInit				; if yes, branch

CheckSumCheck:
		movea.l	#EndOfHeader,a0				; start	checking bytes after the header	($200)
		movea.l	#ROM_End_Ptr,a1				; stop at end of ROM
		move.l	(a1),d0
		moveq	#0,d1

	.loop:
		add.w	(a0)+,d1
		cmp.l	a0,d0
		bhs.s	.loop
		movea.l	#Checksum,a1				; read the checksum
		cmp.w	(a1),d1					; compare checksum in header to ROM
		bne.w	CheckSumError				; if they don't match, branch

	CheckSumOk:
		lea	(v_keep_after_reset).w,a6		; $FFFFFE00
		moveq	#0,d7
		move.w	#(($FFFFFFFF-v_keep_after_reset+1)/4)-1,d6
	.clearRAM:
		move.l	d7,(a6)+
		dbf	d6,.clearRAM				; clear RAM ($FE00-$FFFF)

		move.b	(console_version).l,d0
		andi.b	#$C0,d0
		move.b	d0,(v_console_region).w			; get region setting
		move.l	#'init',(v_checksum_pass).w		; set flag so checksum won't run again

GameInit:
		lea	($FF0000).l,a6
		moveq	#0,d7
		move.w	#((v_keep_after_reset&$FFFF)/4)-1,d6
	.clearRAM:
		move.l	d7,(a6)+
		dbf	d6,.clearRAM				; clear RAM ($0000-$FDFF)

		bsr.w	VDPSetupGame				; clear CRAM and set VDP registers
		bsr.w	DacDriverLoad
		bsr.w	JoypadInit				; initialise joypads
		move.b	#id_Sega,(v_gamemode).w			; set Game Mode to Sega Screen

MainGameLoop:
		move.b	(v_gamemode).w,d0			; load Game Mode
		andi.w	#$1C,d0					; limit Game Mode value to $1C max (change to $7C to add more game modes)
		jsr	GameModeArray(pc,d0.w)			; jump to apt location in ROM
		bra.s	MainGameLoop				; loop indefinitely

; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------
gmptr:		macro
		id_\1:	equ *-GameModeArray
		if narg=1
		bra.w	GM_\1
		else
		bra.w	GM_\2
		endc
		endm

GameModeArray:
		gmptr Sega					; Sega Screen ($00)
		gmptr Title					; Title	Screen ($04)
		gmptr Demo, Level				; Demo Mode ($08)
		gmptr Level					; Normal Level ($0C)
		gmptr Special					; Special Stage	($10)
		gmptr Continue					; Continue Screen ($14)
		gmptr Ending					; End of game sequence ($18)
		gmptr Credits					; Credits ($1C)
		rts
; ===========================================================================

CheckSumError:
		bsr.w	VDPSetupGame
		move.l	#$C0000000,(vdp_control_port).l		; set VDP to CRAM write
		moveq	#(sizeof_pal_all/2)-1,d7

	.fillred:
		move.w	#cRed,(vdp_data_port).l			; fill palette with red
		dbf	d7,.fillred				; repeat $3F more times

	.endlessloop:
		bra.s	.endlessloop
; ===========================================================================

		incfile	Kos_Text,"Graphics Kosinski\Level Select & Debug Text",kos

		include	"Includes\VBlank & HBlank.asm"
		include	"Includes\JoypadInit & ReadJoypads.asm"
		include	"Includes\VDPSetupGame.asm"
		include	"Includes\ClearScreen.asm"
		include	"sound\PlaySound + DacDriverLoad.asm"
		include	"Includes\PauseGame.asm"
		include	"Includes\TilemapToVRAM.asm"

		include "Includes\Nemesis Decompression.asm"
		include "Includes\AddPLC, NewPLC, RunPLC, ProcessPLC & QuickPLC.asm"
		include "Includes\DMA.asm"

		include "Includes\Enigma Decompression.asm"
		include "Includes\Kosinski Decompression.asm"

; ---------------------------------------------------------------------------
; Palette data & routines
; ---------------------------------------------------------------------------
		include "Includes\PaletteCycle.asm"
Pal_TitleCyc:	incbin	"Palettes\Cycle - Title Screen Water.bin"
Pal_GHZCyc:	incbin	"Palettes\Cycle - GHZ.bin"
Pal_LZCyc1:	incbin	"Palettes\Cycle - LZ Waterfall.bin"
Pal_LZCyc2:	incbin	"Palettes\Cycle - LZ Conveyor Belt.bin"
Pal_LZCyc3:	incbin	"Palettes\Cycle - LZ Conveyor Belt Underwater.bin"
Pal_SBZ3Cyc1:	incbin	"Palettes\Cycle - SBZ3 Waterfall.bin"
Pal_SLZCyc:	incbin	"Palettes\Cycle - SLZ.bin"
Pal_SYZCyc1:	incbin	"Palettes\Cycle - SYZ1.bin"
Pal_SYZCyc2:	incbin	"Palettes\Cycle - SYZ2.bin"
Pal_SBZCyc1:	incbin	"Palettes\Cycle - SBZ 1.bin"
Pal_SBZCyc2:	incbin	"Palettes\Cycle - SBZ 2.bin"
Pal_SBZCyc3:	incbin	"Palettes\Cycle - SBZ 3.bin"
Pal_SBZCyc4:	incbin	"Palettes\Cycle - SBZ 4.bin"
Pal_SBZCyc5:	incbin	"Palettes\Cycle - SBZ 5.bin"
Pal_SBZCyc6:	incbin	"Palettes\Cycle - SBZ 6.bin"
Pal_SBZCyc7:	incbin	"Palettes\Cycle - SBZ 7.bin"
Pal_SBZCyc8:	incbin	"Palettes\Cycle - SBZ 8.bin"
Pal_SBZCyc9:	incbin	"Palettes\Cycle - SBZ 9.bin"
Pal_SBZCyc10:	incbin	"Palettes\Cycle - SBZ 10.bin"
		include	"Includes\PaletteFadeIn, PaletteFadeOut, PaletteWhiteIn & PaletteWhiteOut.asm"
		include	"Includes\GM_Sega.asm"
Pal_Sega1:	incbin	"Palettes\Sega - Stripe.bin"
Pal_Sega2:	incbin	"Palettes\Sega - All.bin"
		include "Includes\PalLoad & PalPointers.asm"
Pal_SegaBG:	incbin	"Palettes\Sega Background.bin"
Pal_Title:	incbin	"Palettes\Title Screen.bin"
Pal_LevelSel:	incbin	"Palettes\Level Select.bin"
Pal_Sonic:	incbin	"Palettes\Sonic.bin"
Pal_GHZ:	incbin	"Palettes\Green Hill Zone.bin"
Pal_LZ:		incbin	"Palettes\Labyrinth Zone.bin"
Pal_LZWater:	incbin	"Palettes\Labyrinth Zone Underwater.bin"
Pal_MZ:		incbin	"Palettes\Marble Zone.bin"
Pal_SLZ:	incbin	"Palettes\Star Light Zone.bin"
Pal_SYZ:	incbin	"Palettes\Spring Yard Zone.bin"
Pal_SBZ1:	incbin	"Palettes\SBZ Act 1.bin"
Pal_SBZ2:	incbin	"Palettes\SBZ Act 2.bin"
Pal_Special:	incbin	"Palettes\Special Stage.bin"
Pal_SBZ3:	incbin	"Palettes\SBZ Act 3.bin"
Pal_SBZ3Water:	incbin	"Palettes\SBZ Act 3 Underwater.bin"
Pal_LZSonWater:	incbin	"Palettes\Sonic - LZ Underwater.bin"
Pal_SBZ3SonWat:	incbin	"Palettes\Sonic - SBZ3 Underwater.bin"
Pal_SSResult:	incbin	"Palettes\Special Stage Results.bin"
Pal_Continue:	incbin	"Palettes\Special Stage Continue Bonus.bin"
Pal_Ending:	incbin	"Palettes\Ending.bin"

		include "Includes\WaitForVBlank.asm"
		include "Objects\_RandomNumber.asm"
		include "Objects\_CalcSine & CalcAngle.asm"
Angle_Data:	incbin	"Misc Data\Angle Table.bin"
		include "Includes\Demo Pointers.asm"
		include "Includes\GM_Title.asm"

		include "Includes\GM_Level.asm"
		include "Includes\LZWaterFeatures.asm"

		include "Includes\MoveSonicInDemo & DemoRecorder.asm"
		include "Includes\OscillateNumInit & OscillateNumDo.asm"
		include "Includes\SynchroAnimate.asm"

; ---------------------------------------------------------------------------
; Normal demo data
; ---------------------------------------------------------------------------
Demo_GHZ:	incbin	"Demos\Intro - GHZ.bin"
		even
Demo_MZ:	incbin	"Demos\Intro - MZ.bin"
		even
Demo_SYZ:	incbin	"Demos\Intro - SYZ.bin"
		even
Demo_SS:	incbin	"Demos\Intro - Special Stage.bin"
		even

		include "Includes\GM_Special.asm"

Pal_SSCyc1:	incbin	"Palettes\Cycle - Special Stage 1.bin"
		even
Pal_SSCyc2:	incbin	"Palettes\Cycle - Special Stage 2.bin"
		even

		include "Includes\GM_Continue.asm"

		include "Objects\Continue Screen Items.asm"	; ContScrItem
		include "Objects\Continue Screen Sonic.asm"	; ContSonic
		include "Objects\Continue Screen [Mappings].asm" ; Map_ContScr

		include "Includes\GM_Ending.asm"

		include "Objects\Ending Sonic.asm"		; EndSonic
		include "Objects\Ending Chaos Emeralds.asm"	; EndChaos
		include "Objects\Ending StH Text.asm"		; EndSTH

		include "Objects\Ending Sonic [Mappings].asm"	; Map_ESon
		include "Objects\Ending Chaos Emeralds [Mappings].asm" ; Map_ECha
		include "Objects\Ending StH Text [Mappings].asm" ; Map_ESth

		include "Includes\GM_Credits.asm"

		include "Objects\Ending Eggman Try Again.asm"	; EndEggman
		include "Objects\Ending Chaos Emeralds Try Again.asm" ; TryChaos
		include "Objects\Ending Eggman Try Again [Mappings].asm" ; Map_EEgg

; ---------------------------------------------------------------------------
; Ending demo data
; ---------------------------------------------------------------------------
Demo_EndGHZ1:	incbin	"Demos\Ending - GHZ1.bin"
		even
Demo_EndMZ:	incbin	"Demos\Ending - MZ.bin"
		even
Demo_EndSYZ:	incbin	"Demos\Ending - SYZ.bin"
		even
Demo_EndLZ:	incbin	"Demos\Ending - LZ.bin"
		even
Demo_EndSLZ:	incbin	"Demos\Ending - SLZ.bin"
		even
Demo_EndSBZ1:	incbin	"Demos\Ending - SBZ1.bin"
		even
Demo_EndSBZ2:	incbin	"Demos\Ending - SBZ2.bin"
		even
Demo_EndGHZ2:	incbin	"Demos\Ending - GHZ2.bin"
		even

		include	"Includes\LevelParameterLoad.asm"
		include	"Includes\DeformLayers.asm"
		include	"Includes\DrawTilesWhenMoving, DrawTilesAtStart & DrawChunks.asm"

		include	"Zones.asm"
		include "Includes\LevelDataLoad, LevelLayoutLoad & LevelHeaders.asm"
		include "Includes\DynamicLevelEvents.asm"

		include "Objects\GHZ Bridge.asm"		; Bridge

		include "Objects\_DetectPlatform.asm"
		include "Objects\_SlopeObject.asm"

		include "Objects\GHZ, MZ & SLZ Swinging Platforms, SBZ Ball on Chain.asm" ; SwingingPlatform
		
		include "Objects\_ExitPlatform.asm"

		include "Objects\GHZ Bridge [Mappings].asm"	; Map_Bri

		include "Objects\_MoveWithPlatform.asm"

		include "Objects\GHZ Boss Ball.asm"		; BossBall

		include "Objects\GHZ & MZ Swinging Platforms [Mappings].asm" ; Map_Swing_GHZ
		include "Objects\SLZ Swinging Platforms [Mappings].asm" ; Map_Swing_SLZ

		include "Objects\GHZ Spiked Helix Pole.asm"	; Helix
		include "Objects\GHZ Spiked Helix Pole [Mappings].asm" ; Map_Hel

		include "Objects\Platforms.asm"			; BasicPlatform
		include "Objects\Platforms [Mappings].asm"	; Map_Plat_Unused, Map_Plat_GHZ, Map_Plat_SYZ, Map_Plat_SLZ

		include "Objects\GHZ Collapsing Ledge.asm"	; CollapseLedge
		include "Objects\MZ, SLZ & SBZ Collapsing Floors.asm" ; CollapseFloor

Ledge_SlopeData:
		incbin	"Collision\GHZ Collapsing Ledge Heightmap.bin" ; used by CollapseLedge
		even

		include "Objects\GHZ Collapsing Ledge [Mappings].asm" ; Map_Ledge
		include "Objects\MZ, SLZ & SBZ Collapsing Floors [Mappings].asm" ; Map_CFlo

		include "Objects\GHZ Bridge Stump & SLZ Fireball Launcher.asm" ; Scenery
		include "Objects\SLZ Fireball Launcher [Mappings].asm" ; Map_Scen

		include "Objects\Unused Switch.asm"		; MagicSwitch
		include "Objects\Unused Switch [Mappings].asm"	; Map_Switch

		include "Objects\SBZ Door.asm"			; AutoDoor
		include "Objects\SBZ Door [Mappings].asm"	; Map_ADoor

		include "Objects\GHZ Walls.asm"			; EdgeWalls

		include "Objects\Ball Hog.asm"			; BallHog
		include "Objects\Ball Hog Cannonball.asm"	; Cannonball

		include "Objects\Buzz Bomber Missile Vanishing.asm" ; MissileDissolve

		include "Objects\Explosions.asm"		; ExplosionItem & ExplosionBomb
		include "Objects\Ball Hog [Mappings].asm"	; Map_Hog
		include "Objects\Buzz Bomber Missile Vanishing [Mappings].asm" ; Map_MisDissolve
		include "Objects\Explosions [Mappings].asm"	; Map_ExplodeItem & Map_ExplodeBomb

		include "Objects\Animals.asm"			; Animals
		include "Objects\Points.asm"			; Points
		include "Objects\Animals [Mappings].asm"	; Map_Animal1, Map_Animal2 & Map_Animal3
		include "Objects\Points [Mappings].asm"		; Map_Points

		include "Objects\Crabmeat.asm"			; Crabmeat
		include "Objects\Crabmeat [Mappings].asm"	; Map_Crab

		include "Objects\Buzz Bomber.asm"		; BuzzBomber
		include "Objects\Buzz Bomber Missile.asm"	; Missile
		include "Objects\Buzz Bomber [Mappings].asm"	; Map_Buzz
		include "Objects\Buzz Bomber Missile [Mappings].asm" ; Map_Missile

		include "Objects\Rings.asm"			; Rings
		include "Objects\_CollectRing.asm"
		include "Objects\Ring Loss.asm"			; RingLoss
		include "Objects\Giant Ring.asm"		; GiantRing
		include "Objects\Giant Ring Flash.asm"		; RingFlash
		include "Objects\Ring [Mappings].asm"		; Map_Ring

		include "Objects\Monitors.asm"			; Monitor
		include "Objects\Monitor Contents.asm"		; PowerUp
		include "Objects\Monitors [Mappings].asm"	; Map_Monitor

		include "Objects\Title Screen Sonic.asm"	; TitleSonic
		include "Objects\Title Screen Press Start & TM.asm" ; PSBTM

		include "Objects\_AnimateSprite.asm"

		include "Objects\Title Screen Press Start & TM [Mappings].asm" ; Map_PSB
		include "Objects\Title Screen Sonic [Mappings].asm" ; Map_TSon

		include "Objects\Chopper.asm"			; Chopper
		include "Objects\Chopper [Mappings].asm"	; Map_Chop

		include "Objects\Jaws.asm"			; Jaws
		include "Objects\Jaws [Mappings].asm"		; Map_Jaws

		include "Objects\Burrobot.asm"			; Burrobot
		include "Objects\Burrobot [Mappings].asm"	; Map_Burro

		include "Objects\MZ Grass Platforms.asm"	; LargeGrass
LGrass_Coll_Wide:
		incbin	"Collision\MZ Grass Platforms Heightmap (Wide).bin" ; used by LargeGrass
		even
LGrass_Coll_Narrow:
		incbin	"Collision\MZ Grass Platforms Heightmap (Narrow).bin" ; used by LargeGrass
		even
LGrass_Coll_Sloped:
		incbin	"Collision\MZ Grass Platforms Heightmap (Sloped).bin" ; used by LargeGrass
		even
		include "Objects\MZ Burning Grass.asm"		; GrassFire
		include "Objects\MZ Grass Platforms [Mappings].asm" ; Map_LGrass
		include "Objects\Fireballs [Mappings].asm"	; Map_Fire

		include "Objects\MZ Green Glass Blocks.asm"	; GlassBlock
		include "Objects\MZ Green Glass Blocks [Mappings].asm" ; Map_Glass

		include "Objects\MZ Chain Stompers.asm"		; ChainStomp
		include "Objects\MZ Unused Sideways Stomper.asm" ; SideStomp
		include "Objects\MZ Chain Stompers [Mappings].asm" ; Map_CStom
		include "Objects\MZ Unused Sideways Stomper [Mappings].asm" ; Map_SStom

		include "Objects\Button.asm"			; Button
		include "Objects\Button [Mappings].asm"		; Map_But

		include "Objects\MZ & LZ Pushable Blocks.asm"	; PushBlock
		include "Objects\MZ & LZ Pushable Blocks [Mappings].asm" ; Map_Push

		include "Objects\Title Cards.asm"		; TitleCard
		include "Objects\Game Over & Time Over.asm"	; GameOverCard
		include "Objects\Sonic Has Passed Title Card.asm" ; HasPassedCard

		include "Objects\Special Stage Results.asm"	; SSResult
		include "Objects\Special Stage Results Chaos Emeralds.asm" ; SSRChaos
		include "Objects\Game Over & Time Over [Mappings].asm" ; Map_Over
		include "Objects\Special Stage Results Chaos Emeralds [Mappings].asm" ; Map_SSRC

		include "Objects\Spikes.asm"			; Spikes
		include "Objects\Spikes [Mappings].asm"		; Map_Spike

		include "Objects\GHZ Purple Rock.asm"		; PurpleRock
		include "Objects\GHZ Waterfall Sound.asm"	; WaterSound
		include "Objects\GHZ Purple Rock [Mappings].asm" ; Map_PRock

		include "Objects\GHZ & SLZ Smashable Walls & SmashObject.asm" ; SmashWall
		include "Objects\GHZ & SLZ Smashable Walls [Mappings].asm" ; Map_Smash

		include "Includes\ExecuteObjects.asm"

		include "Objects\_ObjectFall & SpeedToPos.asm"
		include "Objects\_DisplaySprite.asm"
		include "Objects\_DeleteObject & DeleteChild.asm"

		include "Includes\BuildSprites.asm"
		include "Objects\_CheckOffScreen.asm"

		include "Includes\ObjPosLoad.asm"
		include "Objects\_FindFreeObj & FindNextFreeObj.asm"

		include "Objects\Springs.asm"			; Springs
		include "Objects\Springs [Mappings].asm"	; Map_Spring

		include "Objects\Newtron.asm"			; Newtron
		include "Objects\Newtron [Mappings].asm"	; Map_Newt

		include "Objects\Roller.asm"			; Roller
		include "Objects\Roller [Mappings].asm"		; Map_Roll

		include "Objects\GHZ Walls [Mappings].asm"	; Map_Edge

		include "Objects\MZ & SLZ Fireball Launchers.asm"
		include "Objects\Fireballs.asm"			; FireBall

		include "Objects\SBZ Flamethrower.asm"		; Flamethrower
		include "Objects\SBZ Flamethrower [Mappings].asm" ; Map_Flame

		include "Objects\MZ Purple Brick Block.asm"	; MarbleBrick
		include "Objects\MZ Purple Brick Block [Mappings].asm" ; Map_Brick

		include "Objects\SYZ Lamp.asm"			; SpinningLight
		include "Objects\SYZ Lamp [Mappings].asm"	; Map_Light

		include "Objects\SYZ Bumper.asm"		; Bumper
		include "Objects\SYZ Bumper [Mappings].asm"	; Map_Bump

		include "Objects\Signpost & HasPassedAct.asm"	; Signpost & HasPassedAct

		include "Objects\MZ Lava Geyser Maker.asm"	; GeyserMaker
		include "Objects\MZ Lava Geyser.asm"		; LavaGeyser
		include "Objects\MZ Lava Wall.asm"		; LavaWall
		include "Objects\MZ Invisible Lava Tag.asm"	; LavaTag
		include "Objects\MZ Invisible Lava Tag [Mappings].asm" ; Map_LTag
		include "Objects\MZ Lava Geyser [Mappings].asm"	; Map_Geyser

		include "Objects\Moto Bug.asm"			; MotoBug
		include "Objects\_DespawnObject.asm"
		include "Objects\Moto Bug [Mappings].asm"	; Map_Moto

		include "Objects\Yadrin.asm"			; Yadrin
		include "Objects\Yadrin [Mappings].asm"		; Map_Yad

		include "Objects\_SolidObject.asm"
		include "Objects\_SkipMappings.asm"

		include "Objects\MZ Smashable Green Block.asm"	; SmashBlock
		include "Objects\MZ Smashable Green Block [Mappings].asm" ; Map_Smab

		include "Objects\MZ, LZ & SBZ Moving Blocks.asm" ; MovingBlock
		include "Objects\MZ, LZ & SBZ Moving Blocks [Mappings].asm" ; Map_MBlock, Map_MBlockLZ

		include "Objects\Batbrain.asm"			; Batbrain
		include "Objects\Batbrain [Mappings].asm"	; Map_Bat

		include "Objects\SYZ & SLZ Floating Blocks, LZ Doors.asm" ; FloatingBlock
		include "Objects\SYZ & SLZ Floating Blocks, LZ Doors [Mappings].asm" ; Map_FBlock

		include "Objects\SYZ & LZ Spike Ball Chain.asm"	; SpikeBall
		include "Objects\SYZ & LZ Spike Ball Chain [Mappings].asm" ; Map_SBall, Map_SBall2

		include "Objects\SYZ Large Spike Balls.asm"	; BigSpikeBall
		include "Objects\SYZ & SBZ Large Spike Balls [Mappings].asm" ; Map_BBall

		include "Objects\SLZ Elevator.asm"		; Elevator
		include "Objects\SLZ Elevator [Mappings].asm"	; Map_Elev

		include "Objects\SLZ Circling Platform.asm"	; CirclingPlatform
		include "Objects\SLZ Circling Platform [Mappings].asm" ; Map_Circ

		include "Objects\SLZ Stairs.asm"		; Staircase
		include "Objects\SLZ Stairs [Mappings].asm"	; Map_Stair

		include "Objects\SLZ Pylon.asm"			; Pylon
		include "Objects\SLZ Pylon [Mappings].asm"	; Map_Pylon

		include "Objects\LZ Water Surface.asm"		; WaterSurface
		include "Objects\LZ Water Surface [Mappings].asm" ; Map_Surf

		include "Objects\LZ Pole.asm"			; Pole
		include "Objects\LZ Pole [Mappings].asm"	; Map_Pole

		include "Objects\LZ Flapping Door.asm"		; FlapDoor
		include "Objects\LZ Flapping Door [Mappings].asm" ; Map_Flap

		include "Objects\Invisible Solid Blocks.asm"	; Invisibarrier
		include "Objects\Invisible Solid Blocks [Mappings].asm" ; Map_Invis

		include "Objects\SLZ Fans.asm"			; Fan
		include "Objects\SLZ Fans [Mappings].asm"	; Map_Fan

		include "Objects\SLZ Seesaw.asm"		; Seesaw
See_DataSlope:	incbin	"Collision\SLZ Seesaw Heightmap (Sloped).bin" ; used by Seesaw
		even
See_DataFlat:	incbin	"Collision\SLZ Seesaw Heightmap (Flat).bin" ; used by Seesaw
		even
		include "Objects\SLZ Seesaw [Mappings].asm"	; Map_Seesaw
		include "Objects\SLZ Seesaw Spike Ball [Mappings].asm" ; Map_SSawBall

		include "Objects\Bomb Enemy.asm"		; Bomb
		include "Objects\Bomb Enemy [Mappings].asm"	; Map_Bomb

		include "Objects\Orbinaut.asm"			; Orbinaut
		include "Objects\Orbinaut [Mappings].asm"	; Map_Orb

		include "Objects\LZ Harpoon.asm"		; Harpoon
		include "Objects\LZ Harpoon [Mappings].asm"	; Map_Harp

		include "Objects\LZ Blocks.asm"			; LabyrinthBlock
		include "Objects\LZ Blocks [Mappings].asm"	; Map_LBlock

		include "Objects\LZ Gargoyle Head.asm"		; Gargoyle
		include "Objects\LZ Gargoyle Head [Mappings].asm" ; Map_Gar

		include "Objects\LZ Conveyor Belt Platforms.asm" ; LabyrinthConvey
		include "Objects\LZ Conveyor Belt Platforms [Mappings].asm" ; Map_LConv

		include "Objects\LZ Bubbles.asm"		; Bubble
		include "Objects\LZ Bubbles [Mappings].asm"	; Map_Bub

		include "Objects\LZ Waterfall.asm"		; Waterfall
		include "Objects\LZ Waterfall [Mappings].asm"	; Map_WFall

		include "Objects\Sonic.asm"			; SonicPlayer
		include "Objects\Sonic [Animations].asm"	; Ani_Sonic

		include "Objects\LZ Drowning Numbers.asm"	; DrownCount
		include "Objects\_ResumeMusic.asm"

		include "Objects\LZ Sonic's Drowning Face [Mappings].asm" ; Map_Drown

		include "Objects\Shield & Invincibility.asm"	; ShieldItem
		include "Objects\Unused Special Stage Warp.asm"	; VanishSonic
		include "Objects\LZ Water Splash.asm"		; Splash
		include "Objects\Unused Special Stage Warp [Mappings].asm" ; Map_Vanish
		include "Objects\LZ Water Splash [Mappings].asm" ; Map_Splash

		include "Objects\_FindNearestTile, FindFloor & FindWall.asm"

		include	"Includes\ConvertCollisionArray.asm"

		include "Objects\_FindFloorObj, FindWallRightObj, FindCeilingObj & FindWallLeftObj.asm"

		include "Objects\SBZ Rotating Disc Junction.asm" ; Junction
		include "Objects\SBZ Rotating Disc Junction [Mappings].asm" ; Map_Jun

		include "Objects\SBZ Running Disc.asm"		; RunningDisc
		include "Objects\SBZ Running Disc [Mappings].asm" ; Map_Disc

		include "Objects\SBZ Conveyor Belt.asm"		; Conveyor
		include "Objects\SBZ Trapdoor & Spinning Platforms.asm" ; SpinPlatform
		include "Objects\SBZ Trapdoor & Spinning Platforms [Mappings].asm" ; Map_Trap, Map_Spin

		include "Objects\SBZ Saws.asm"			; Saws
		include "Objects\SBZ Saws [Mappings].asm"	; Map_Saw

		include "Objects\SBZ Stomper & Sliding Doors.asm" ; ScrapStomp
		include "Objects\SBZ Stomper & Sliding Doors [Mappings].asm" ; Map_Stomp

		include "Objects\SBZ Vanishing Platform.asm"	; VanishPlatform
		include "Objects\SBZ Vanishing Platform [Mappings].asm" ; Map_VanP

		include "Objects\SBZ Electric Orb.asm"		; Electro
		include "Objects\SBZ Electric Orb [Mappings].asm" ; Map_Elec

		include "Objects\SBZ Conveyor Belt Platforms.asm" ; SpinConvey

		include "Objects\SBZ Girder Block.asm"		; Girder
		include "Objects\SBZ Girder Block [Mappings].asm" ; Map_Gird

		include "Objects\SBZ Teleporter.asm"		; Teleport

		include "Objects\Caterkiller.asm"		; Caterkiller
		include "Objects\Caterkiller [Mappings].asm"	; Map_Cat

		include "Objects\Lamppost.asm"			; Lamppost
		include "Objects\Lamppost [Mappings].asm"	; Map_Lamp

		include "Objects\Hidden Bonus Points.asm"	; HiddenBonus
		include "Objects\Hidden Bonus Points [Mappings].asm" ; Map_Bonus

		include "Objects\Credits & Sonic Team Presents.asm" ; CreditsText
		include "Objects\Credits & Sonic Team Presents [Mappings].asm" ; Map_Cred

		include "Objects\GHZ Boss, BossExplode & BossMove.asm" ; BossGreenHill
		include "Objects\Bosses [Animations].asm"	; Ani_Bosses
		include "Objects\Bosses [Mappings].asm"		; Map_Bosses, Map_BossItems

		include "Objects\LZ Boss.asm"			; BossLabyrinth
		include "Objects\MZ Boss.asm"			; BossMarble
		include "Objects\MZ Boss Fire.asm"		; BossFire
		include "Objects\SLZ Boss.asm"			; BossStarLight
		include "Objects\SLZ Boss Spikeballs.asm"	; BossSpikeball
		include "Objects\SLZ Boss Spikeballs [Mappings].asm" ; Map_BSBall
		include "Objects\SYZ Boss.asm"			; BossSpringYard
		include "Objects\SYZ Blocks at Boss.asm"	; BossBlock
		include "Objects\SYZ Blocks at Boss [Mappings].asm" ; Map_BossBlock

		include "Objects\SBZ2 Blocks That Eggman Breaks.asm" ; FalseFloor
		include "Objects\SBZ2 Eggman.asm"		; ScrapEggman
		include "Objects\SBZ2 Eggman [Mappings].asm"	; Map_SEgg
		include "Objects\SBZ2 Blocks That Eggman Breaks [Mappings].asm" ; Map_FFloor

		include "Objects\FZ Boss.asm"			; BossFinal
		include "Objects\FZ Eggman in Damaged Ship [Mappings].asm" ; Map_FZDamaged
		include "Objects\FZ Eggman Ship Legs [Mappings].asm" ; Map_FZLegs

		include "Objects\FZ Cylinders.asm"		; EggmanCylinder
		include "Objects\FZ Cylinders [Mappings].asm"	; Map_EggCyl

		include "Objects\FZ Plasma Balls.asm"		; BossPlasma
		include "Objects\FZ Plasma Launcher [Mappings].asm" ; Map_PLaunch
		include "Objects\FZ Plasma Balls [Mappings].asm" ; Map_Plasma

		include "Objects\Prison Capsule.asm"		; Prison
		include "Objects\Prison Capsule [Mappings].asm"	; Map_Pri

		include "Objects\_ReactToItem, HurtSonic & KillSonic.asm"

		include "Objects\Special Stage R [Mappings].asm" ; Map_SS_R
		include "Objects\Special Stage Breakable & Red-White Blocks [Mappings].asm" ; Map_SS_Glass
		include "Objects\Special Stage Up [Mappings].asm" ; Map_SS_Up
		include "Objects\Special Stage Down [Mappings].asm" ; Map_SS_Down
		include "Objects\Special Stage Chaos Emeralds [Mappings].asm" ; Map_SS_Chaos1, Map_SS_Chaos2 & Map_SS_Chaos3

		include "Objects\Special Stage Sonic.asm"	; SonicSpecial

		include "Includes\AnimateLevelGfx.asm"

		include "Objects\HUD.asm"			; HUD
		include "Objects\HUD Score, Time & Rings [Mappings].asm" ; Map_HUD

		include "Objects\_AddPoints.asm"

		include "Includes\HUD_Update, HUD_Base & ContScrCounter.asm"

; ---------------------------------------------------------------------------
; Uncompressed graphics	- HUD and lives counter
; ---------------------------------------------------------------------------
Art_Hud:	incbin	"Graphics\HUD Numbers.bin"		; 8x16 pixel numbers on HUD
		even
Art_LivesNums:	incbin	"Graphics\Lives Counter Numbers.bin"	; 8x8 pixel numbers on lives counter
		even

		include "Objects\_DebugMode.asm"

		align	$200,$FF
		if Revision=0
			incfile	Nem_SegaLogo,"Graphics - Compressed\Sega Logo",nem
	Eni_SegaLogo:	incbin	"Tilemaps\Sega Logo (REV00).eni" ; large Sega logo (mappings)
			even
		else
			dcb.b	$300,$FF
			incfile	Nem_SegaLogo,"Graphics - Compressed\Sega Logo (JP1)",nem
	Eni_SegaLogo:	incbin	"Tilemaps\Sega Logo.eni"	; large Sega logo (mappings)
			even
		endc
		incfile	KosMap_Title,"Other Kosinski\Title Screen",kos
Eni_JapNames:	incbin	"Tilemaps\Hidden Japanese Credits.eni"	; Japanese credits (mappings)
		even
		incfile	Kos_TitleFg,"Graphics Kosinski\Title Screen Foreground",kos
		incfile	Kos_TitleSonic,"Graphics Kosinski\Title Screen Sonic",kos
		incfile	Kos_TitleTM,"Graphics Kosinski\Title Screen TM",kos
		incfile	Nem_JapNames,"Graphics - Compressed\Hidden Japanese Credits",nem

		include "Objects\Sonic [Mappings].asm"		; Map_Sonic
		include "Objects\Sonic DPLCs.asm"		; SonicDynPLC

; ---------------------------------------------------------------------------
; Uncompressed graphics	- Sonic
; ---------------------------------------------------------------------------
Art_Sonic:	incbin	"Graphics\Sonic.bin"			; Sonic
		even
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
		incfile Nem_Smoke,"Graphics - Compressed\Unused - Smoke",nem
		incfile Nem_SyzSparkle,"Graphics - Compressed\Unused - SYZ Sparkles",nem
		incfile Nem_UnkFire,"Graphics - Compressed\Unused - Fireball",nem
		incfile Art_Warp,"Graphics\Unused - Special Stage Warp",bin,dma_safe
		incfile Nem_Goggle,"Graphics - Compressed\Unused - Goggles",nem

		include "Objects\Special Stage Walls [Mappings].asm" ; Map_SSWalls

; ---------------------------------------------------------------------------
; Compressed graphics - special stage
; ---------------------------------------------------------------------------
Eni_SSBg1:	incbin	"Tilemaps\SS Background 1.eni"		; special stage background (mappings)
		even
Eni_SSBg2:	incbin	"Tilemaps\SS Background 2.eni"		; special stage background (mappings)
		even
		incfile Nem_SSWalls,"Graphics - Compressed\Special Stage Walls",nem
		incfile Nem_SSBgFish,"Graphics - Compressed\Special Stage Birds & Fish",nem
		incfile Nem_SSBgCloud,"Graphics - Compressed\Special Stage Clouds",nem
		incfile Nem_SSGOAL,"Graphics - Compressed\Special Stage GOAL",nem
		incfile Nem_SSRBlock,"Graphics - Compressed\Special Stage R",nem
		incfile Nem_SS1UpBlock,"Graphics - Compressed\Special Stage 1UP",nem
		incfile Nem_SSEmStars,"Graphics - Compressed\Special Stage Emerald Twinkle",nem
		incfile Nem_SSRedWhite,"Graphics - Compressed\Special Stage Red-White",nem
		incfile Nem_SSZone1,"Graphics - Compressed\Special Stage ZONE1",nem
		incfile Nem_SSZone2,"Graphics - Compressed\Special Stage ZONE2",nem
		incfile Nem_SSZone3,"Graphics - Compressed\Special Stage ZONE3",nem
		incfile Nem_SSZone4,"Graphics - Compressed\Special Stage ZONE4",nem
		incfile Nem_SSZone5,"Graphics - Compressed\Special Stage ZONE5",nem
		incfile Nem_SSZone6,"Graphics - Compressed\Special Stage ZONE6",nem
		incfile Nem_SSUpDown,"Graphics - Compressed\Special Stage UP-DOWN",nem
		incfile Nem_SSEmerald,"Graphics - Compressed\Special Stage Emeralds",nem
		incfile Nem_SSGhost,"Graphics - Compressed\Special Stage Ghost",nem
		incfile Nem_SSWBlock,"Graphics - Compressed\Special Stage W",nem
		incfile Nem_SSGlass,"Graphics - Compressed\Special Stage Glass",nem
		incfile Art_ResultEm,"Graphics\Special Stage Result Emeralds",bin,dma_safe
; ---------------------------------------------------------------------------
; Compressed graphics - GHZ stuff
; ---------------------------------------------------------------------------
		incfile Kos_Swing,"Graphics Kosinski\GHZ Swinging Platform",kos
		incfile Kos_Bridge,"Graphics Kosinski\GHZ Bridge",kos
		incfile Art_Ball,"Graphics\GHZ Giant Ball",bin,dma_safe
		incfile Kos_Spikes,"Graphics Kosinski\Spikes",kos
		incfile Kos_SpikePole,"Graphics Kosinski\GHZ Spiked Helix Pole",kos
		incfile Kos_PurpleRock,"Graphics Kosinski\GHZ Purple Rock",kos
		incfile Kos_GhzSmashWall,"Graphics Kosinski\GHZ Smashable Wall",kos
		incfile Kos_GhzEdgeWall,"Graphics Kosinski\GHZ Walls",kos
; ---------------------------------------------------------------------------
; Compressed graphics - LZ stuff
; ---------------------------------------------------------------------------
		incfile Kos_Water,"Graphics Kosinski\LZ Water Surface",kos
		incfile Kos_Splash,"Graphics Kosinski\LZ Waterfall & Splashes",kos
		incfile Kos_LzSpikeBall,"Graphics Kosinski\LZ Spiked Ball & Chain",kos
		incfile Kos_FlapDoor,"Graphics Kosinski\LZ Flapping Door",kos
		incfile Kos_Bubbles,"Graphics Kosinski\LZ Bubbles & Countdown",kos
		incfile Kos_LzHalfBlock,"Graphics Kosinski\LZ 32x16 Block",kos
		incfile Kos_LzDoorV,"Graphics Kosinski\LZ Vertical Door",kos
		incfile Kos_Harpoon,"Graphics Kosinski\LZ Harpoon",kos
		incfile Kos_LzPole,"Graphics Kosinski\LZ Breakable Pole",kos
		incfile Kos_LzDoorH,"Graphics Kosinski\LZ Horizontal Door",kos
		incfile Kos_LzWheel,"Graphics Kosinski\LZ Wheel",kos
		incfile Kos_Gargoyle,"Graphics Kosinski\LZ Gargoyle & Fireball",kos
		incfile Kos_LzPlatform,"Graphics Kosinski\LZ Rising Platform",kos
		incfile Kos_Cork,"Graphics Kosinski\LZ Cork",kos
		incfile Kos_LzBlock,"Graphics Kosinski\LZ 32x32 Block",kos
		incfile Kos_Sbz3HugeDoor,"Graphics Kosinski\SBZ3 Huge Sliding Door",kos
; ---------------------------------------------------------------------------
; Compressed graphics - MZ stuff
; ---------------------------------------------------------------------------
		incfile Kos_MzMetal,"Graphics Kosinski\MZ Metal Blocks",kos
		incfile Kos_MzButton,"Graphics Kosinski\MZ Button",kos
		incfile Kos_MzGlass,"Graphics Kosinski\MZ Green Glass Block",kos
		incfile Kos_Fireball,"Graphics Kosinski\Fireballs",kos
		incfile Kos_Lava,"Graphics Kosinski\MZ Lava",kos
		incfile Kos_MzBlock,"Graphics Kosinski\MZ Green Pushable Block",kos
; ---------------------------------------------------------------------------
; Compressed graphics - SLZ stuff
; ---------------------------------------------------------------------------
		incfile Kos_Seesaw,"Graphics Kosinski\SLZ Seesaw",kos
		incfile Kos_SlzSpike,"Graphics Kosinski\SLZ Little Spikeball",kos
		incfile Kos_Fan,"Graphics Kosinski\SLZ Fan",kos
		incfile Kos_SlzWall,"Graphics Kosinski\SLZ Breakable Wall",kos
		incfile Kos_Pylon,"Graphics Kosinski\SLZ Pylon",kos
		incfile Kos_SlzSwing,"Graphics Kosinski\SLZ Swinging Platform",kos
		incfile Kos_SlzBlock,"Graphics Kosinski\SLZ 32x32 Block",kos
		incfile Kos_SlzCannon,"Graphics Kosinski\SLZ Cannon",kos
; ---------------------------------------------------------------------------
; Compressed graphics - SYZ stuff
; ---------------------------------------------------------------------------
		incfile Kos_Bumper,"Graphics Kosinski\SYZ Bumper",kos
		incfile Kos_SmallSpike,"Graphics Kosinski\SYZ Small Spikeball",kos
		incfile Kos_Button,"Graphics Kosinski\Button",kos
		incfile Kos_BigSpike,"Graphics Kosinski\SYZ Large Spikeball",kos
; ---------------------------------------------------------------------------
; Compressed graphics - SBZ stuff
; ---------------------------------------------------------------------------
		incfile Kos_SbzDisc,"Graphics Kosinski\SBZ Running Disc",kos
		incfile Kos_SbzJunction,"Graphics Kosinski\SBZ Junction Wheel",kos
		incfile Kos_Cutter,"Graphics Kosinski\SBZ Pizza Cutter",kos
		incfile Kos_Stomper,"Graphics Kosinski\SBZ Stomper",kos
		incfile Kos_SpinPlatform,"Graphics Kosinski\SBZ Spinning Platform",kos
		incfile Kos_TrapDoor,"Graphics Kosinski\SBZ Trapdoor",kos
		incfile Kos_SbzFloor,"Graphics Kosinski\SBZ Collapsing Floor",kos
		incfile Kos_Electric,"Graphics Kosinski\SBZ Electrocuter",kos
		incfile Kos_SbzBlock,"Graphics Kosinski\SBZ Vanishing Block",kos
		incfile Kos_FlamePipe,"Graphics Kosinski\SBZ Flaming Pipe",kos
		incfile Kos_SbzDoorV,"Graphics Kosinski\SBZ Small Vertical Door",kos
		incfile Kos_SlideFloor,"Graphics Kosinski\SBZ Sliding Floor Trap",kos
		incfile Kos_SbzDoorH,"Graphics Kosinski\SBZ Large Horizontal Door",kos
		incfile Kos_Girder,"Graphics Kosinski\SBZ Crushing Girder",kos
; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
		incfile Kos_BallHog,"Graphics Kosinski\Ball Hog",kos
		incfile Kos_Crabmeat,"Graphics Kosinski\Crabmeat",kos
		incfile Kos_Buzz,"Graphics Kosinski\Buzz Bomber",kos
		incfile Kos_Burrobot,"Graphics Kosinski\Burrobot",kos
		incfile Kos_Chopper,"Graphics Kosinski\Chopper",kos
		incfile Kos_Jaws,"Graphics Kosinski\Jaws",kos
		incfile Kos_Roller,"Graphics Kosinski\Roller",kos
		incfile Kos_Motobug,"Graphics Kosinski\Motobug",kos
		incfile Kos_Newtron,"Graphics Kosinski\Newtron",kos
		incfile Kos_Yadrin,"Graphics Kosinski\Yadrin",kos
		incfile Kos_Batbrain,"Graphics Kosinski\Batbrain",kos
		incfile Kos_Bomb,"Graphics Kosinski\Bomb Enemy",kos
		incfile Kos_Orbinaut,"Graphics Kosinski\Orbinaut",kos
		incfile Kos_Cater,"Graphics Kosinski\Caterkiller",kos
		incfile Nem_Splats,"Graphics - Compressed\Unused - Splats Enemy",nem
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
		incfile Art_TitleCard,"Graphics\Title Cards",bin,dma_safe
		incfile Art_HUDMain,"Graphics\HUD",bin,dma_safe
		incfile Nem_Lives,"Graphics - Compressed\HUD - Life Counter Icon",nem
		incfile Kos_Ring,"Graphics Kosinski\Rings",kos
		incfile Art_Shield,"Graphics\Shield",bin,dma_safe
		incfile Art_Stars,"Graphics\Invincibility",bin,dma_safe
		incfile Nem_Monitors,"Graphics - Compressed\Monitors",nem
		incfile Art_Explode,"Graphics\Explosion",bin,dma_safe
		incfile Kos_Points,"Graphics Kosinski\Points",kos
		incfile Art_GameOver,"Graphics\Game Over",bin,dma_safe
		incfile Kos_HSpring,"Graphics Kosinski\Spring Horizontal",kos
		incfile Kos_VSpring,"Graphics Kosinski\Spring Vertical",kos
		incfile Art_Signpost,"Graphics\Signpost",bin,dma_safe
		incfile Kos_Lamp,"Graphics Kosinski\Lamppost",kos
		incfile Art_BigFlash,"Graphics\Giant Ring Flash",bin,dma_safe
		incfile Art_Bonus,"Graphics\Hidden Bonuses",bin,dma_safe
; ---------------------------------------------------------------------------
; Compressed graphics - continue screen
; ---------------------------------------------------------------------------
		incfile	Nem_ContSonic,"Graphics - Compressed\Continue Screen Sonic",nem
		incfile	Art_MiniSonic,"Graphics\Continue Screen Stuff",bin,dma_safe
; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
		incfile	Nem_Rabbit,"Graphics - Compressed\Animal Rabbit",nem
		incfile	Nem_Chicken,"Graphics - Compressed\Animal Chicken",nem
		incfile	Nem_BlackBird,"Graphics - Compressed\Animal Blackbird",nem
		incfile	Nem_Seal,"Graphics - Compressed\Animal Seal",nem
		incfile	Nem_Pig,"Graphics - Compressed\Animal Pig",nem
		incfile	Nem_Flicky,"Graphics - Compressed\Animal Flicky",nem
		incfile	Nem_Squirrel,"Graphics - Compressed\Animal Squirrel",nem
; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
		incfile	Kos_GHZ_1st,"Graphics Kosinski\GHZ Main",kos
		incfile	Kos_GHZ_2nd,"Graphics Kosinski\GHZ Main2",kos
		incfile	Kos_MZ,"Graphics Kosinski\MZ Main",kos
		incfile	Kos_SYZ,"Graphics Kosinski\SYZ Main",kos
		incfile	Kos_LZ,"Graphics Kosinski\LZ Main",kos
		incfile	Kos_SLZ,"Graphics Kosinski\SLZ Main",kos
		incfile	Kos_SBZ,"Graphics Kosinski\SBZ Main",kos
Blk16_GHZ:	incbin	"16x16 Mappings\GHZ.bin"
		even
Blk256_GHZ:	incbin	"256x256 Mappings\GHZ.kos"
		even
Blk16_LZ:	incbin	"16x16 Mappings\LZ.bin"
		even
Blk256_LZ:	incbin	"256x256 Mappings\LZ.kos"
		even
Blk16_MZ:	incbin	"16x16 Mappings\MZ.bin"
		even
Blk256_MZ:	incbin	"256x256 Mappings\MZ.kos"
		even
Blk16_SLZ:	incbin	"16x16 Mappings\SLZ.bin"
		even
Blk256_SLZ:	incbin	"256x256 Mappings\SLZ.kos"
		even
Blk16_SYZ:	incbin	"16x16 Mappings\SYZ.bin"
		even
Blk256_SYZ:	incbin	"256x256 Mappings\SYZ.kos"
		even
Blk16_SBZ:	incbin	"16x16 Mappings\SBZ.bin"
		even
Blk256_SBZ:	incbin	"256x256 Mappings\SBZ.kos"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - bosses and ending sequence
; ---------------------------------------------------------------------------
		incfile	Art_EndFlowers,"Graphics\Ending Flowers",bin,dma_safe
		incfile Nem_Eggman,"Graphics - Compressed\Boss - Main",nem
		incfile Nem_Weapons,"Graphics - Compressed\Boss - Weapons",nem
		incfile Nem_Prison,"Graphics - Compressed\Prison Capsule",nem
		incfile Nem_Sbz2Eggman,"Graphics - Compressed\Boss - Eggman in SBZ2 & FZ",nem
		incfile Kos_FzBoss,"Graphics Kosinski\Boss - Final Zone",kos
		incfile Kos_FzEggman,"Graphics Kosinski\Boss - Eggman after FZ Fight",kos
		incfile Nem_Exhaust,"Graphics - Compressed\Boss - Exhaust Flame",nem
		incfile Kos_EndEm,"Graphics Kosinski\Ending - Emeralds",kos
		incfile Kos_EndSonic,"Graphics Kosinski\Ending - Sonic",kos
		incfile Nem_TryAgain,"Graphics - Compressed\Ending - Try Again",nem
		incfile Kos_EndFlower,"Graphics Kosinski\Ending - Flowers",kos
		incfile Nem_CreditText,"Graphics - Compressed\Ending - Credits",nem
		incfile Nem_EndStH,"Graphics - Compressed\Ending - StH Logo",nem
; ---------------------------------------------------------------------------
; Collision data
; ---------------------------------------------------------------------------
AngleMap:	incbin	"Collision\Angle Map.bin"
		even
CollArray1:	incbin	"Collision\Collision Array (Normal).bin"
		even
CollArray2:	incbin	"Collision\Collision Array (Rotated).bin"
		even
Col_GHZ:	incbin	"Collision\GHZ.bin"			; GHZ index
		even
Col_LZ:		incbin	"Collision\LZ.bin"			; LZ index
		even
Col_MZ:		incbin	"Collision\MZ.bin"			; MZ index
		even
Col_SLZ:	incbin	"Collision\SLZ.bin"			; SLZ index
		even
Col_SYZ:	incbin	"Collision\SYZ.bin"			; SYZ index
		even
Col_SBZ:	incbin	"Collision\SBZ.bin"			; SBZ index
		even
; ---------------------------------------------------------------------------
; Special Stage layouts
; ---------------------------------------------------------------------------
SS_1:		incbin	"Special Stage Layouts\1.eni"
		even
SS_2:		incbin	"Special Stage Layouts\2.eni"
		even
SS_3:		incbin	"Special Stage Layouts\3.eni"
		even
SS_4:		incbin	"Special Stage Layouts\4.eni"
		even
		if Revision=0
	SS_5:		incbin	"Special Stage Layouts\5 (REV00).eni"
			even
	SS_6:		incbin	"Special Stage Layouts\6 (REV00).eni"
		else
	SS_5:		incbin	"Special Stage Layouts\5.eni"
			even
	SS_6:		incbin	"Special Stage Layouts\6.eni"
		endc
		even
; ---------------------------------------------------------------------------
; Animated uncompressed graphics
; ---------------------------------------------------------------------------
		incfile	Art_GhzWater,"Graphics\GHZ Waterfall",bin,dma_safe
		incfile	Art_GhzFlower1,"Graphics\GHZ Flower Large",bin,dma_safe
		incfile	Art_GhzFlower2,"Graphics\GHZ Flower Small",bin,dma_safe
		incfile	Art_MzLava1,"Graphics\MZ Lava Surface",bin,dma_safe
		incfile	Art_MzLava2,"Graphics\MZ Lava",bin,dma_safe
		incfile	Art_MzTorch,"Graphics\MZ Background Torch",bin,dma_safe
		incfile	Art_SbzSmoke,"Graphics\SBZ Background Smoke",bin,dma_safe

; ---------------------------------------------------------------------------
; Level	layout index
; ---------------------------------------------------------------------------
Level_Index:	index *
		; GHZ
		ptr Level_GHZ1
		ptr Level_GHZ_bg
		ptr Level_GHZ1_unused
		
		ptr Level_GHZ2
		ptr Level_GHZ_bg
		ptr Level_GHZ2_unused
		
		ptr Level_GHZ3
		ptr Level_GHZ_bg
		ptr Level_GHZ3_unused
		
		ptr Level_GHZ4_unused
		ptr Level_GHZ4_unused
		ptr Level_GHZ4_unused
		
		; LZ
		ptr Level_LZ1
		ptr Level_LZ_bg
		ptr Level_LZ1_unused
		
		ptr Level_LZ2
		ptr Level_LZ_bg
		ptr Level_LZ2_unused
		
		ptr Level_LZ3
		ptr Level_LZ_bg
		ptr Level_LZ3_unused
		
		ptr Level_SBZ3
		ptr Level_LZ_bg
		ptr Level_SBZ3_unused
		
		; MZ
		ptr Level_MZ1
		ptr Level_MZ1bg
		ptr Level_MZ1
		
		ptr Level_MZ2
		ptr Level_MZ2bg
		ptr Level_MZ2_unused
		
		ptr Level_MZ3
		ptr Level_MZ3bg
		ptr Level_MZ3_unused
		
		ptr Level_MZ4_unused
		ptr Level_MZ4_unused
		ptr Level_MZ4_unused
		
		; SLZ
		ptr Level_SLZ1
		ptr Level_SLZ_bg
		ptr Level_SLZ_unused
		
		ptr Level_SLZ2
		ptr Level_SLZ_bg
		ptr Level_SLZ_unused
		
		ptr Level_SLZ3
		ptr Level_SLZ_bg
		ptr Level_SLZ_unused
		
		ptr Level_SLZ_unused
		ptr Level_SLZ_unused
		ptr Level_SLZ_unused
		
		; SYZ
		ptr Level_SYZ1
		ptr Level_SYZ_bg
		ptr Level_SYZ1_unused
		
		ptr Level_SYZ2
		ptr Level_SYZ_bg
		ptr Level_SYZ2_unused
		
		ptr Level_SYZ3
		ptr Level_SYZ_bg
		ptr Level_SYZ3_unused
		
		ptr Level_SYZ4_unused
		ptr Level_SYZ4_unused
		ptr Level_SYZ4_unused
		
		; SBZ
		ptr Level_SBZ1
		ptr Level_SBZ1bg
		ptr Level_SBZ1bg
		
		ptr Level_SBZ2
		ptr Level_SBZ2bg
		ptr Level_SBZ2bg
		
		; FZ
		ptr Level_SBZ2
		ptr Level_SBZ2bg
		ptr Level_SBZ2_unused
		
		ptr Level_SBZ4_unused
		ptr Level_SBZ4_unused
		ptr Level_SBZ4_unused
		zonewarning Level_Index,24
		
		; Ending
		ptr Level_End
		ptr Level_GHZ_bg
		ptr Level_End_unused
		
		ptr Level_End
		ptr Level_GHZ_bg
		ptr Level_End_unused
		
		ptr Level_End_unused
		ptr Level_End_unused
		ptr Level_End_unused
		
		ptr Level_End_unused
		ptr Level_End_unused
		ptr Level_End_unused

Level_GHZ1:	incbin	"Level Layouts\ghz1.bin"
		even
Level_GHZ1_unused:	dc.b 0,	0, 0, 0
Level_GHZ2:	incbin	"Level Layouts\ghz2.bin"
		even
Level_GHZ2_unused:	dc.b 0,	0, 0, 0
Level_GHZ3:	incbin	"Level Layouts\ghz3.bin"
		even
Level_GHZ_bg:	incbin	"Level Layouts\ghzbg.bin"
		even
Level_GHZ3_unused:	dc.b 0,	0, 0, 0
Level_GHZ4_unused:	dc.b 0,	0, 0, 0

Level_LZ1:	incbin	"Level Layouts\lz1.bin"
		even
Level_LZ_bg:	incbin	"Level Layouts\lzbg.bin"
		even
Level_LZ1_unused:	dc.b 0,	0, 0, 0
Level_LZ2:	incbin	"Level Layouts\lz2.bin"
		even
Level_LZ2_unused:	dc.b 0,	0, 0, 0
Level_LZ3:	incbin	"Level Layouts\lz3.bin"
		even
Level_LZ3_unused:	dc.b 0,	0, 0, 0
Level_SBZ3:	incbin	"Level Layouts\sbz3.bin"
		even
Level_SBZ3_unused:	dc.b 0,	0, 0, 0

Level_MZ1:	incbin	"Level Layouts\mz1.bin"
		even
Level_MZ1bg:	incbin	"Level Layouts\mz1bg.bin"
		even
Level_MZ2:	incbin	"Level Layouts\mz2.bin"
		even
Level_MZ2bg:	incbin	"Level Layouts\mz2bg.bin"
		even
Level_MZ2_unused:	dc.b 0,	0, 0, 0
Level_MZ3:	incbin	"Level Layouts\mz3.bin"
		even
Level_MZ3bg:	incbin	"Level Layouts\mz3bg.bin"
		even
Level_MZ3_unused:	dc.b 0,	0, 0, 0
Level_MZ4_unused:	dc.b 0,	0, 0, 0

Level_SLZ1:	incbin	"Level Layouts\slz1.bin"
		even
Level_SLZ_bg:	incbin	"Level Layouts\slzbg.bin"
		even
Level_SLZ2:	incbin	"Level Layouts\slz2.bin"
		even
Level_SLZ3:	incbin	"Level Layouts\slz3.bin"
		even
Level_SLZ_unused:	dc.b 0,	0, 0, 0

Level_SYZ1:	incbin	"Level Layouts\syz1.bin"
		even
Level_SYZ_bg:	if Revision=0
			incbin	"Level Layouts\syzbg.bin"
		else
			incbin	"Level Layouts\syzbg (JP1).bin"
		endc
		even
Level_SYZ1_unused:	dc.b 0,	0, 0, 0
Level_SYZ2:	incbin	"Level Layouts\syz2.bin"
		even
Level_SYZ2_unused:	dc.b 0,	0, 0, 0
Level_SYZ3:	incbin	"Level Layouts\syz3.bin"
		even
Level_SYZ3_unused:	dc.b 0,	0, 0, 0
Level_SYZ4_unused:	dc.b 0,	0, 0, 0

Level_SBZ1:	incbin	"Level Layouts\sbz1.bin"
		even
Level_SBZ1bg:	incbin	"Level Layouts\sbz1bg.bin"
		even
Level_SBZ2:	incbin	"Level Layouts\sbz2.bin"
		even
Level_SBZ2bg:	incbin	"Level Layouts\sbz2bg.bin"
		even
Level_SBZ2_unused:	dc.b 0,	0, 0, 0
Level_SBZ4_unused:	dc.b 0,	0, 0, 0
Level_End:	incbin	"Level Layouts\ending.bin"
		even
Level_End_unused:	dc.b 0,	0, 0, 0

		incfile	Art_BigRing,"Graphics\Giant Ring",bin,dma_safe

		include "Pattern Load Cues.asm"
		include "Includes\KosPLC & UncPLC.asm"
		include "Objects\MZ Lava Wall [Mappings].asm"	; Map_LWall
		include "Objects\GHZ Giant Ball [Mappings].asm"	; Map_GBall
		include "Objects\Shield & Invincibility [Mappings].asm" ; Map_Shield
		include "Objects\Signpost [Mappings].asm"	; Map_Sign
		include "Objects\Giant Ring [Mappings].asm"	; Map_GRing
		include "Objects\Giant Ring Flash [Mappings].asm" ; Map_Flash
		include "Objects\Special Stage Results [Mappings].asm" ; Map_SSR
		include "Objects\Title Cards Sonic Has Passed [Mappings].asm" ; Map_Has
		include "Objects\Title Cards [Mappings].asm"	; Map_Card

; ---------------------------------------------------------------------------
; Object position index
; ---------------------------------------------------------------------------
ObjPosLZPlatform_Index:
		index.l 0
		ptr ObjPos_LZ1pf1
		ptr ObjPos_LZ1pf2
		ptr ObjPos_LZ2pf1
		ptr ObjPos_LZ2pf2
		ptr ObjPos_LZ3pf1
		ptr ObjPos_LZ3pf2
		ptr ObjPos_LZ1pf1
		ptr ObjPos_LZ1pf2
ObjPosSBZPlatform_Index:
		ptr ObjPos_SBZ1pf1
		ptr ObjPos_SBZ1pf2
		ptr ObjPos_SBZ1pf3
		ptr ObjPos_SBZ1pf4
		ptr ObjPos_SBZ1pf5
		ptr ObjPos_SBZ1pf6
		ptr ObjPos_SBZ1pf1
		ptr ObjPos_SBZ1pf2
		include	"Object Placement\LZ Platforms.asm"
		include	"Object Placement\SBZ Platforms.asm"
		
		include "Object Subtypes.asm"
		endobj
		include	"Object Placement\GHZ1.asm"
		include	"Object Placement\GHZ2.asm"
		include	"Object Placement\GHZ3.asm"
		include	"Object Placement\LZ1.asm"
		include	"Object Placement\LZ2.asm"
		include	"Object Placement\LZ3.asm"
		include	"Object Placement\SBZ3.asm"
		include	"Object Placement\MZ1.asm"
		include	"Object Placement\MZ2.asm"
		include	"Object Placement\MZ3.asm"
		include	"Object Placement\SLZ1.asm"
		include	"Object Placement\SLZ2.asm"
		include	"Object Placement\SLZ3.asm"
		include	"Object Placement\SYZ1.asm"
		include	"Object Placement\SYZ2.asm"
		include	"Object Placement\SYZ3.asm"
		include	"Object Placement\SBZ1.asm"
		include	"Object Placement\SBZ2.asm"
		include	"Object Placement\FZ.asm"
		include	"Object Placement\Ending.asm"
ObjPos_Null:	endobj

; ---------------------------------------------------------------------------
; Sound driver data
; ---------------------------------------------------------------------------
		include "sound/Sound Data.asm"

; ---------------------------------------------------------------
; Error handling module
; ---------------------------------------------------------------
 
BusError:	jsr ErrorHandler(pc)
		dc.b "BUS ERROR",0				; text
		dc.b 1						; extended stack frame
		even
AddressError:	jsr ErrorHandler(pc)
		dc.b "ADDRESS ERROR",0				; text
		dc.b 1						; extended stack frame
		even
IllegalInstr:	jsr ErrorHandler(pc)
		dc.b "ILLEGAL INSTRUCTION",0			; text
		dc.b 0						; extended stack frame
		even
ZeroDivide:	jsr ErrorHandler(pc)
		dc.b "ZERO DIVIDE",0  				; text
		dc.b 0						; extended stack frame
		even
ChkInstr:	jsr ErrorHandler(pc)
		dc.b "CHK INSTRUCTION",0  			; text
		dc.b 0						; extended stack frame
		even
TrapvInstr:	jsr ErrorHandler(pc)
		dc.b "TRAPV INSTRUCTION",0			; text
		dc.b 0						; extended stack frame
		even
PrivilegeViol:	jsr ErrorHandler(pc)
		dc.b "PRIVILEGE VIOLATION",0			; text
		dc.b 0						; extended stack frame
		even
Trace:		jsr ErrorHandler(pc)
		dc.b "TRACE",0    				; text
		dc.b 0						; extended stack frame
		even
Line1010Emu:	jsr ErrorHandler(pc)
		dc.b "LINE 1010 EMULATOR",0			; text
		dc.b 0						; extended stack frame
		even
Line1111Emu:	jsr ErrorHandler(pc)
		dc.b "LINE 1111 EMULATOR",0			; text
		dc.b 0						; extended stack frame
		even
ErrorExcept:	jsr ErrorHandler(pc)
		dc.b "ERROR EXCEPTION",0  			; text
		dc.b 0						; extended stack frame
		even
ErrorHandler:   incbin	"ErrorHandler.bin"
ROM_End:
		END
