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
		include "Macros.asm"
		include "Macros - Objects.asm"
		include "sound\Sounds.asm"
		include "sound\Sound Equates.asm"
		include "Constants.asm"
		include "RAM Addresses.asm"
		include	"Start Positions.asm"
		include "Debugger.asm"

		cpu	68000

EnableSRAM:	equ 0						; change to 1 to enable SRAM
BackupSRAM:	equ 1
AddressSRAM:	equ 3						; 0 = odd+even; 2 = even only; 3 = odd only

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
		dcb.l 8,ErrorTrap				; Unused (reserved)
		dc.b "SEGA MEGA DRIVE "				; Hardware system ID (Console name)
		dc.b "(C)SEGA \date"				; Copyright holder and release date (generally year)
		dc.b "SONIC 1-SQUARED                                 " ; Domestic name
		dc.b "SONIC 1-SQUARED                                 " ; International name
		dc.b "GM 00004049-SQ"				; Serial/version number

Checksum: 	dc.w $0
		dc.b "J6              "				; I/O support
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
		beq.s	FirstRun
		cmpi.l	#'init',(v_checksum_pass).w		; has checksum routine already run?
		beq.w	GameInit				; if yes, branch

FirstRun:
		lea	(v_keep_after_reset).w,a1		; $FFFFFE00
		move.w	#(($FFFFFFFF-v_keep_after_reset+1)/4)-1,d1
		bsr.w	ClearRAM				; clear RAM ($FE00-$FFFF)

		move.b	(console_version).l,d0
		andi.b	#console_region+console_speed,d0	; get bits 7+6 of console version
		move.b	d0,(v_console_region).w			; save to RAM
		move.l	#'init',(v_checksum_pass).w		; set flag so checksum won't run again

GameInit:
		lea	($FF0000).l,a1
		move.w	#((v_keep_after_reset&$FFFF)/4)-1,d1
		moveq	#0,d0
	.loop:
		move.l	d0,(a1)+
		dbf	d1,.loop				; clear RAM up to v_keep_after_reset

		jsr	VDPSetupGame				; clear CRAM and set VDP registers
		bsr.w	DacDriverLoad
		bsr.w	JoypadInit				; initialise joypads
		move.b	#id_Sega,(v_gamemode).w			; set Game Mode to Sega Screen

MainGameLoop:
		move.b	(v_gamemode).w,d0			; load gamemode
		andi.w	#$7F,d0					; ignore high bit
		add.w	d0,d0
		add.w	d0,d0					; multiply by 4
		movea.l	GameModeArray(pc,d0.w),a1		; get pointer
		jsr	(a1)					; jump to gamemode
		bra.s	MainGameLoop				; loop indefinitely

; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------
GameModeArray:	index.l 0
		ptr GM_Sega					; Sega Screen
		ptr GM_Title					; Title	Screen
		ptr GM_Demo					; Demo Mode
		ptr GM_Level					; Normal Level
		ptr GM_Special					; Special Stage
		ptr GM_Continue					; Continue Screen
		ptr GM_Ending					; End of game sequence
		ptr GM_Credits					; Credits
		ptr GM_HiddenCredits				; Hidden Japanese credits screen
		ptr GM_TryAgain					; Try Again/End screen

id_Sega:	equ id_GM_Sega
id_Title:	equ id_GM_Title
id_Demo:	equ id_GM_Demo
id_Level:	equ id_GM_Level
id_Special:	equ id_GM_Special
id_Continue:	equ id_GM_Continue
id_Ending:	equ id_GM_Ending
id_Credits:	equ id_GM_Credits
id_HiddenCredits: equ id_GM_HiddenCredits
id_TryAgain:	equ id_GM_TryAgain
; ===========================================================================
		include	"Includes\GM_Sega.asm"
Pal_Sega1:	incbin	"Palettes\Sega - Stripe.bin"
Pal_Sega2:	incbin	"Palettes\Sega - All.bin"
		include "Includes\GM_Title.asm"
		include "Includes\GM_Level.asm"
		include "Includes\GM_Special.asm"
Pal_SSCyc1:	incbin	"Palettes\Cycle - Special Stage 1.bin"
Pal_SSCyc2:	incbin	"Palettes\Cycle - Special Stage 2.bin"
		include "Includes\GM_Continue.asm"
		include "Includes\GM_Ending.asm"
		include "Includes\GM_Credits.asm"
		include "Includes\GM_TryAgain.asm"
		include "Includes\GM_HiddenCredits.asm"
		
		include	"Includes\VBlank & HBlank.asm"
		include	"Includes\ApplyBrightness.asm"
		include	"Includes\JoypadInit & ReadJoypads.asm"
		include	"Includes\ClearScreen.asm"
		include	"sound\PlaySound + DacDriverLoad.asm"
		include	"Includes\PauseGame.asm"
		include	"Includes\NavigateMenu.asm"
		include	"Includes\LoadTilemap.asm"
		include "DMA & PLCs\DMA.asm"
		include "Includes\Kosinski Decompression.asm"
		include "Includes\HiveDec.asm"

		include	"Zones & Characters.asm"
		include	"Includes\PaletteCycle.asm"
		include	"Includes\PaletteFadeIn, PaletteFadeOut & PaletteWhiteOut.asm"
		include "Includes\PalLoad & PalPointers.asm"
		include "Includes\WaterFilter.asm"
		include "Includes\LZWaterFeatures.asm"
		include "Includes\WaitForVBlank.asm"
		include "Includes\MoveSonicInDemo & DemoRecorder.asm"
		include "Includes\OscillateNumInit & OscillateNumDo.asm"
		include "Includes\SynchroAnimate.asm"
		include	"Includes\LevelParameterLoad.asm"
		include	"Includes\DeformLayers.asm"
		include	"Includes\DrawTilesWhenMoving, DrawTilesAtStart & DrawChunks.asm"
		include "Includes\DynamicLevelEvents.asm"
		include "Includes\ExecuteObjects.asm"
		include "Includes\BuildSprites.asm"
		include "Includes\ObjPosLoad.asm"
		include "Includes\AnimateLevelGfx.asm"
		
startof_obj:	equ *

		include "Objects\_RandomNumber.asm"
		include "Objects\_CalcSine & CalcAngle.asm"
		include "Objects\_AddPoints.asm"
		
		include "Objects\Continue Screen Items.asm"	; ContScrItem
		include "Objects\Continue Screen Sonic.asm"	; ContSonic

		include "Objects\Ending Sonic.asm"		; EndSonic
		include "Objects\Ending Chaos Emeralds.asm"	; EndChaos
		include "Objects\Ending StH Text.asm"		; EndSTH
		include "Objects\Ending Eggman Try Again.asm"	; EndEggman
		include "Objects\Ending Chaos Emeralds Try Again.asm" ; TryChaos

		include "Objects\GHZ Bridge.asm"		; Bridge
		include "Objects\GHZ, MZ & SLZ Swinging Platforms, SBZ Ball on Chain.asm" ; SwingingPlatform
		include "Objects\GHZ Boss Ball.asm"		; BossBall
		include "Objects\GHZ Spiked Helix Pole.asm"	; Helix
		include "Objects\Platforms.asm"			; BasicPlatform
		include "Objects\GHZ Collapsing Ledge.asm"	; CollapseLedge
		include "Objects\MZ, SLZ & SBZ Collapsing Floors.asm" ; CollapseFloor
		incfile	Ledge_SlopeData,"Collision\GHZ Collapsing Ledge Heightmap",bin
		incfile	Ledge_SlopeData_Flip,"Collision\GHZ Collapsing Ledge Heightmap (Flipped)",bin
		include "Objects\GHZ Roll Tunnel.asm"		; RollTunnel
		include "Objects\GHZ Bridge Stump & SLZ Fireball Launcher.asm" ; Scenery

		include "Objects\Unused Switch.asm"		; MagicSwitch

		include "Objects\SBZ Door.asm"			; AutoDoor

		include "Objects\GHZ Walls.asm"			; EdgeWalls

		include "Objects\Ball Hog.asm"			; BallHog
		include "Objects\Ball Hog Cannonball.asm"	; Cannonball

		include "Objects\Buzz Bomber Missile Vanishing.asm" ; MissileDissolve

		include "Objects\Explosions.asm"		; ExplosionItem & ExplosionBomb

		include "Objects\Animals.asm"			; Animals
		include "Objects\Points.asm"			; Points

		include "Objects\Crabmeat.asm"			; Crabmeat

		include "Objects\Buzz Bomber.asm"		; BuzzBomber
		include "Objects\Buzz Bomber Missile.asm"	; Missile

		include "Objects\Rings.asm"			; Rings
		include "Objects\_CollectRing.asm"
		include "Objects\Ring Loss.asm"			; RingLoss
		include "Objects\Giant Ring.asm"		; GiantRing

		include "Objects\Monitors.asm"			; Monitor
		include "Objects\Monitor Contents.asm"		; PowerUp

		include "Objects\Title Screen Sonic.asm"	; TitleSonic
		include "Objects\Title Screen Press Start & TM.asm" ; PSBTM

		include "Objects\_AnimateSprite.asm"

		include "Objects\Chopper.asm"			; Chopper

		include "Objects\Jaws.asm"			; Jaws

		include "Objects\Burrobot.asm"			; Burrobot

		include "Objects\MZ Grass Platforms.asm"	; LargeGrass
		incfile	LGrass_Coll_Wide,"Collision\MZ Grass Platforms Heightmap (Wide)",bin
		incfile LGrass_Coll_Sloped,"Collision\MZ Grass Platforms Heightmap (Sloped)",bin
		include "Objects\MZ Burning Grass.asm"		; GrassFire
		include "Objects\MZ Green Glass Blocks.asm"	; GlassBlock
		include "Objects\MZ Chain Stompers.asm"		; ChainStomp
		include "Objects\MZ Unused Sideways Stomper.asm" ; SideStomp
		include "Objects\MZ Pushable Blocks.asm"	; PushBlock

		include "Objects\Button.asm"			; Button
		include "Objects\Spikes.asm"			; Spikes

		include "Objects\GHZ Purple Rock.asm"		; PurpleRock
		include "Objects\GHZ Waterfall Sound.asm"	; WaterSound
		include "Objects\Tile Switcher.asm"		; TileSwitch
		include "Objects\Event Gate.asm"		; EventGate

		include "Objects\GHZ & SLZ Smashable Walls.asm"	; SmashWall
		include "Objects\_Shatter & Crumble.asm"

		include "Objects\_ObjectFall & SpeedToPos.asm"
		include "Objects\_DisplaySprite.asm"
		include "Objects\_DeleteObject & DeleteChild.asm"
		include "Objects\_CheckOffScreen.asm"
		include "Objects\_FindFreeObj & FindNextFreeObj.asm"
		include "Objects\_CloneObject & RunLast.asm"
		include "Objects\_FindNearestObj.asm"

		include "Objects\Springs.asm"			; Springs

		include "Objects\Newtron.asm"			; Newtron

		include "Objects\Roller.asm"			; Roller

		include "Objects\MZ & SLZ Fireball Launchers.asm"
		include "Objects\Fireballs.asm"			; FireBall

		include "Objects\SBZ Flamethrower.asm"		; Flamethrower

		include "Objects\MZ Purple Brick Block.asm"	; MarbleBrick

		include "Objects\SYZ Lamp.asm"			; SpinningLight

		include "Objects\SYZ Bumper.asm"		; Bumper

		include "Objects\Signpost & HasPassedAct.asm"	; Signpost & HasPassedAct

		include "Objects\MZ Lava Fountain.asm"		; LavaFountain
		include "Objects\MZ Lava Fall.asm"		; LavaFall
		include "Objects\MZ Lava Wall.asm"		; LavaWall
		include "Objects\MZ Invisible Lava Tag.asm"	; LavaTag

		include "Objects\Moto Bug.asm"			; MotoBug

		include "Objects\Yadrin.asm"			; Yadrin

		include "Objects\_SolidObject.asm"
		include "Objects\_SkipMappings.asm"
		include "Objects\_DespawnObject & CheckActive.asm"

		include "Objects\MZ Smashable Green Block.asm"	; SmashBlock

		include "Objects\MZ Moving Blocks.asm"		; MovingBlock
		include "Objects\SBZ Striped Yellow Platform.asm" ; YellowPlatform
		include "Objects\SBZ Sliding Red Platform.asm"	; SlideBlock
		include "Objects\LZ Half Block.asm"		; HalfBlock

		include "Objects\Batbrain.asm"			; Batbrain

		include "Objects\SYZ Doors.asm"			; YardDoor
		include "Objects\SYZ Floating Blocks.asm"	; FloatingBlock
		include "Objects\SLZ Square Blocks.asm"		; SquareBlock

		include "Objects\SYZ & LZ Spike Ball Chain.asm"	; SpikeBall

		include "Objects\SYZ Large Spike Balls.asm"	; BigSpikeBall

		include "Objects\SLZ Elevator.asm"		; Elevator

		include "Objects\SLZ Circling Platform.asm"	; CirclingPlatform

		include "Objects\SLZ Stairs.asm"		; Staircase

		include "Objects\SLZ Pylon.asm"			; Pylon

		include "Objects\Invisible Solid Blocks.asm"	; Invisibarrier

		include "Objects\Sonic.asm"			; SonicPlayer
		include "Objects\Sonic [Animations].asm"	; Ani_Sonic
		include "Objects\_ReactToItem, HurtSonic & KillSonic.asm"

		include "Objects\HUD.asm"			; HUD
		include "Objects\_HexToDec.asm"
		include "Objects\HUD Debug Overlay.asm"		; DebugOverlay

		include "Objects\SLZ Fans.asm"			; Fan

		include "Objects\SLZ Seesaw.asm"		; Seesaw
		incfile	See_DataSlope,"Collision\SLZ Seesaw Heightmap",bin
		incfile	See_DataFlip,"Collision\SLZ Seesaw Heightmap (Flipped)",bin

		include "Objects\Bomb Enemy.asm"		; Bomb

		include "Objects\Orbinaut.asm"			; Orbinaut
		
		include "Objects\_PosToChunk & PosToTile.asm"
		include "Objects\_FloorDist.asm"
		include "Objects\_CeilingDist.asm"
		include "Objects\_WallRightDist.asm"
		include "Objects\_WallLeftDist.asm"

		include "Objects\LZ Harpoon.asm"		; Harpoon
		include "Objects\LZ Blocks.asm"			; LabyrinthBlock
		include "Objects\LZ Cork.asm"			; Cork
		include "Objects\_Sink.asm"
		include "Objects\LZ Rising Platform.asm"	; LabyrinthPlatform
		include "Objects\LZ Gargoyle Head.asm"		; Gargoyle
		include "Objects\LZ Conveyor Belt Platforms.asm" ; LabyrinthConvey
		include "Objects\LZ Wheel.asm"			; Wheel
		include "Objects\LZ Bubble Maker.asm"		; BubbleMaker
		include "Objects\LZ Bubbles.asm"		; Bubble
		include "Objects\LZ Waterfall.asm"		; Waterfall
		include "Objects\LZ Drowning Numbers.asm"	; DrownCount
		include "Objects\_ResumeMusic.asm"
		include "Objects\LZ Pole.asm"			; Pole
		include "Objects\LZ Flapping Door.asm"		; FlapDoor
		include "Objects\LZ Door Vertical.asm"		; LabyrinthDoorV
		include "Objects\LZ Door Horizontal.asm"	; LabyrinthDoorH

		include "Objects\Shield & Invincibility.asm"	; ShieldItem
		include "Objects\LZ Water Surface.asm"		; WaterSurface
		include "Objects\LZ Water Splash.asm"		; Splash
		include "Objects\SBZ Rotating Disc Junction.asm" ; Junction

		include "Objects\_FindNearestTile, FindFloor & FindWall.asm"

		include "Objects\SBZ Running Disc.asm"		; RunningDisc
		include "Objects\SBZ Conveyor Belt.asm"		; Conveyor
		include "Objects\SBZ Spinning Platforms.asm"	; SpinPlatform
		include "Objects\SBZ Trapdoor.asm"		; Trapdoor
		include "Objects\SBZ Saws.asm"			; Saws
		include "Objects\SBZ Stomper.asm"		; ScrapStomp
		include "Objects\SBZ Door Horizontal.asm"	; ScrapDoorH
		include "Objects\SBZ3 Big Pillar Door.asm"	; BigPillar
		include "Objects\SBZ Vanishing Platform.asm"	; VanishPlatform
		include "Objects\SBZ Electric Orb.asm"		; Electro
		include "Objects\SBZ Conveyor Belt Platforms.asm" ; SpinConvey
		include "Objects\SBZ Girder Block.asm"		; Girder
		include "Objects\SBZ Teleporter.asm"		; Teleport

		include "Objects\Caterkiller.asm"		; Caterkiller
		include "Objects\Splats.asm"			; Splats

		include "Objects\Lamppost.asm"			; Lamppost

		include "Objects\Hidden Bonus Points.asm"	; HiddenBonus

		include "Objects\Credits & Sonic Team Presents.asm" ; CreditsText

		include "Objects\GHZ Boss, BossExplode & BossMove.asm" ; BossGreenHill
		include "Objects\Bosses [Animations].asm"	; Ani_Bosses
		include "Objects\Boss Exhaust.asm"		; Exhaust
		include "Objects\Boss Face.asm"			; BossFace
		include "Objects\Boss Weapons.asm"		; BossWeapon
		include "Objects\Bosses.asm"			; Boss
		include "Objects\_Exploding.asm"

		include "Objects\LZ Boss.asm"			; BossLabyrinth
		include "Objects\MZ Boss Fire.asm"		; BossFire
		include "Objects\SLZ Boss.asm"			; BossStarLight
		include "Objects\SLZ Boss Spikeballs.asm"	; BossSpikeball
		include "Objects\SYZ Boss.asm"			; BossSpringYard
		include "Objects\SYZ Blocks at Boss.asm"	; BossBlock

		include "Objects\SBZ2 Blocks That Eggman Breaks.asm" ; FalseFloor
		include "Objects\SBZ2 Eggman.asm"		; ScrapEggman

		include "Objects\FZ Boss.asm"			; BossFinal
		include "Objects\FZ Cylinders.asm"		; EggmanCylinder
		include "Objects\FZ Plasma Balls.asm"		; BossPlasma

		include "Objects\Prison Capsule.asm"		; Prison

		include "Objects\Special Stage Sonic.asm"	; SonicSpecial

		include "Objects\_DebugMode.asm"

		include "Objects\Title Cards.asm"		; TitleCard
		include "Objects\Game Over & Time Over.asm"	; GameOverCard
		include "Objects\Title Cards Sonic Has Passed.asm" ; HasPassedCard
		include "Objects\Special Stage Results.asm"	; SSResult
		include "Objects\Special Stage Results Chaos Emeralds.asm" ; SSRChaos
		
		inform	0,"Object code occupies $%h bytes ($%h-$%h).",*-startof_obj,startof_obj,*

		include	"Includes\VDPSetupGame.asm"
		include "Objects\_DebugMode [Lists].asm"
		include "Objects\Special Stage Walls [Mappings].asm" ; Map_SSWalls

; ---------------------------------------------------------------------------
; Compressed graphics - title screen
; ---------------------------------------------------------------------------
		incfile	Kos_SegaLogo,"Graphics Moduled\Sega Logo",kpm
		incfile	KosMap_SegaLogo,"Other Kosinski\Sega Logo",kos
		incfile	KosMap_SegaLogoBG,"Other Kosinski\Sega Logo BG",kos
		incfile	KosMap_Title,"Other Kosinski\Title Screen",kos
		incfile	KosMap_JapNames,"Other Kosinski\Hidden Japanese Credits",kos
		incfile	Kos_TitleFg,"Graphics Moduled\Title Screen Foreground",kpm
		incfile	Kos_TitleSonic,"Graphics Moduled\Title Screen Sonic",kpm
		incfile	Kos_TitleTM,"Graphics Moduled\Title Screen TM",kpm
		incfile	Kos_JapNames,"Graphics Moduled\Hidden Japanese Credits",kpm
		incfile	Kos_Text,"Graphics Moduled\Level Select Text",kpm
; ---------------------------------------------------------------------------
; Uncompressed graphics	- Sonic
; ---------------------------------------------------------------------------
		include	"Graphics Sonic\Sonic graphics list.asm"
		include "Graphics Sonic\Sonic [Mappings].asm"	; Map_Sonic
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
		incfile Art_Goggles,"Graphics\Unused - Goggles",bin,dma_safe
; ---------------------------------------------------------------------------
; Compressed graphics - special stage
; ---------------------------------------------------------------------------
		incfile	UncMap_FishBirds,"Misc Data\SS Fish Birds",bin,dma_safe
		incfile	KosMap_SSBubbles,"Other Kosinski\SS Bubbles",kos
		incfile	KosMap_SSClouds,"Other Kosinski\SS Clouds",kos
		incfile Kos_SSWalls,"Graphics Moduled\Special Stage Walls",kpm
		incfile Kos_SSBgFish,"Graphics Moduled\Special Stage Birds & Fish",kpm
		incfile Kos_SSBgCloud,"Graphics Moduled\Special Stage Clouds",kpm
		incfile Kos_SSGOAL,"Graphics Moduled\Special Stage GOAL",kpm
		incfile Kos_SSRBlock,"Graphics Moduled\Special Stage R",kpm
		incfile Kos_SS1UpBlock,"Graphics Moduled\Special Stage 1UP",kpm
		incfile Kos_SSEmStars,"Graphics Moduled\Special Stage Emerald Twinkle",kpm
		incfile Kos_SSRedWhite,"Graphics Moduled\Special Stage Red-White",kpm
		incfile Kos_SSZone1,"Graphics Moduled\Special Stage ZONE1",kpm
		incfile Kos_SSZone2,"Graphics Moduled\Special Stage ZONE2",kpm
		incfile Kos_SSZone3,"Graphics Moduled\Special Stage ZONE3",kpm
		incfile Kos_SSZone4,"Graphics Moduled\Special Stage ZONE4",kpm
		incfile Kos_SSZone5,"Graphics Moduled\Special Stage ZONE5",kpm
		incfile Kos_SSZone6,"Graphics Moduled\Special Stage ZONE6",kpm
		incfile Kos_SSUpDown,"Graphics Moduled\Special Stage UP-DOWN",kpm
		incfile Kos_SSEmerald,"Graphics Moduled\Special Stage Emeralds",kpm
		incfile Kos_SSGhost,"Graphics Moduled\Special Stage Ghost",kpm
		incfile Kos_SSWBlock,"Graphics Moduled\Special Stage W",kpm
		incfile Kos_SSGlass,"Graphics Moduled\Special Stage Glass",kpm
		incfile Art_ResultEm,"Graphics\Special Stage Result Emeralds",bin,dma_safe
		incfile Art_ResultCont,"Graphics\Special Stage Result Continue",bin,dma_safe
; ---------------------------------------------------------------------------
; Compressed graphics - GHZ stuff
; ---------------------------------------------------------------------------
		incfile Kos_Swing,"Graphics Moduled\GHZ Swinging Platform",kpm
		incfile Kos_Bridge,"Graphics Moduled\GHZ Bridge",kpm
		incfile Art_Ball,"Graphics\GHZ Giant Ball",bin,dma_safe
		incfile Kos_Spikes,"Graphics Moduled\Spikes",kpm
		incfile Kos_SpikePole,"Graphics Moduled\GHZ Spiked Helix Pole",kpm
		incfile Kos_PurpleRock,"Graphics Moduled\GHZ Purple Rock",kpm
		incfile Kos_GhzSmashWall,"Graphics Moduled\GHZ Smashable Wall",kpm
		incfile Kos_GhzEdgeWall,"Graphics Moduled\GHZ Walls",kpm
; ---------------------------------------------------------------------------
; Compressed graphics - LZ stuff
; ---------------------------------------------------------------------------
		incfile Kos_Water,"Graphics Moduled\LZ Water Surface",kpm
		incfile Kos_Splash,"Graphics Moduled\LZ Waterfall & Splashes",kpm
		incfile Kos_LzSpikeBall,"Graphics Moduled\LZ Spiked Ball & Chain",kpm
		incfile Kos_FlapDoor,"Graphics Moduled\LZ Flapping Door",kpm
		incfile Kos_Bubbles,"Graphics Moduled\LZ Bubbles & Countdown",kpm
		incfile Kos_LzHalfBlock,"Graphics Moduled\LZ 32x16 Block",kpm
		incfile Kos_LzDoorV,"Graphics Moduled\LZ Vertical Door",kpm
		incfile Kos_Harpoon,"Graphics Moduled\LZ Harpoon",kpm
		incfile Kos_LzPole,"Graphics Moduled\LZ Breakable Pole",kpm
		incfile Kos_LzDoorH,"Graphics Moduled\LZ Horizontal Door",kpm
		incfile Kos_LzWheel,"Graphics Moduled\LZ Wheel",kpm
		incfile Kos_Gargoyle,"Graphics Moduled\LZ Gargoyle & Fireball",kpm
		incfile Kos_LzPlatform,"Graphics Moduled\LZ Rising Platform",kpm
		incfile Kos_Cork,"Graphics Moduled\LZ Cork",kpm
		incfile Kos_LzBlock,"Graphics Moduled\LZ 32x32 Block",kpm
		incfile Kos_Sbz3HugeDoor,"Graphics Moduled\SBZ3 Huge Sliding Door",kpm
; ---------------------------------------------------------------------------
; Compressed graphics - MZ stuff
; ---------------------------------------------------------------------------
		incfile Kos_MzMetal,"Graphics Moduled\MZ Metal Blocks",kpm
		incfile Kos_MzButton,"Graphics Moduled\MZ Button",kpm
		incfile Kos_MzGlass,"Graphics Moduled\MZ Green Glass Block",kpm
		incfile Kos_Fireball,"Graphics Moduled\Fireballs",kpm
		incfile Kos_Lava,"Graphics Moduled\MZ Lava",kpm
		incfile Kos_MzBlock,"Graphics Moduled\MZ Green Pushable Block",kpm
; ---------------------------------------------------------------------------
; Compressed graphics - SLZ stuff
; ---------------------------------------------------------------------------
		incfile Kos_Seesaw,"Graphics Moduled\SLZ Seesaw",kpm
		incfile Kos_SlzSpike,"Graphics Moduled\SLZ Little Spikeball",kpm
		incfile Kos_Fan,"Graphics Moduled\SLZ Fan",kpm
		incfile Kos_SlzWall,"Graphics Moduled\SLZ Breakable Wall",kpm
		incfile Kos_Pylon,"Graphics Moduled\SLZ Pylon",kpm
		incfile Kos_SlzSwing,"Graphics Moduled\SLZ Swinging Platform",kpm
		incfile Kos_SlzBlock,"Graphics Moduled\SLZ 32x32 Block",kpm
		incfile Kos_SlzCannon,"Graphics Moduled\SLZ Cannon",kpm
; ---------------------------------------------------------------------------
; Compressed graphics - SYZ stuff
; ---------------------------------------------------------------------------
		incfile Kos_Bumper,"Graphics Moduled\SYZ Bumper",kpm
		incfile Kos_SmallSpike,"Graphics Moduled\SYZ Small Spikeball",kpm
		incfile Kos_Button,"Graphics Moduled\Button",kpm
		incfile Kos_BigSpike,"Graphics Moduled\SYZ Large Spikeball",kpm
; ---------------------------------------------------------------------------
; Compressed graphics - SBZ stuff
; ---------------------------------------------------------------------------
		incfile Kos_SbzDisc,"Graphics Moduled\SBZ Running Disc",kpm
		incfile Kos_SbzJunction,"Graphics Moduled\SBZ Junction Wheel",kpm
		incfile Kos_Cutter,"Graphics Moduled\SBZ Pizza Cutter",kpm
		incfile Kos_Stomper,"Graphics Moduled\SBZ Stomper",kpm
		incfile Kos_SpinPlatform,"Graphics Moduled\SBZ Spinning Platform",kpm
		incfile Kos_TrapDoor,"Graphics Moduled\SBZ Trapdoor",kpm
		incfile Kos_SbzFloor,"Graphics Moduled\SBZ Collapsing Floor",kpm
		incfile Kos_Electric,"Graphics Moduled\SBZ Electrocuter",kpm
		incfile Kos_SbzBlock,"Graphics Moduled\SBZ Vanishing Block",kpm
		incfile Kos_FlamePipe,"Graphics Moduled\SBZ Flaming Pipe",kpm
		incfile Kos_SbzDoorV,"Graphics Moduled\SBZ Small Vertical Door",kpm
		incfile Kos_SlideFloor,"Graphics Moduled\SBZ Sliding Floor Trap",kpm
		incfile Kos_SbzDoorH,"Graphics Moduled\SBZ Large Horizontal Door",kpm
		incfile Kos_Girder,"Graphics Moduled\SBZ Crushing Girder",kpm
; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
		incfile Kos_BallHog,"Graphics Moduled\Ball Hog",kpm
		incfile Kos_Crabmeat,"Graphics Moduled\Crabmeat",kpm
		incfile Kos_Buzz,"Graphics Moduled\Buzz Bomber",kpm
		incfile Kos_Burrobot,"Graphics Moduled\Burrobot",kpm
		incfile Kos_Chopper,"Graphics Moduled\Chopper",kpm
		incfile Kos_Jaws,"Graphics Moduled\Jaws",kpm
		incfile Kos_Roller,"Graphics Moduled\Roller",kpm
		incfile Kos_Motobug,"Graphics Moduled\Motobug",kpm
		incfile Kos_Newtron,"Graphics Moduled\Newtron",kpm
		incfile Kos_Yadrin,"Graphics Moduled\Yadrin",kpm
		incfile Kos_Batbrain,"Graphics Moduled\Batbrain",kpm
		incfile Kos_Bomb,"Graphics Moduled\Bomb Enemy",kpm
		incfile Kos_Orbinaut,"Graphics Moduled\Orbinaut",kpm
		incfile Kos_Cater,"Graphics Moduled\Caterkiller",kpm
		incfile Kos_Splats,"Graphics Moduled\Splats",kpm
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
		incfile Art_TitleCard,"Graphics\Title Cards",bin,dma_safe
		incfile Art_TitleCardAct,"Graphics\Title Card Act",bin,dma_safe
		incfile Art_TitleCard2,"Graphics\Title Card 2",bin,dma_safe
		incfile Art_TitleCard3,"Graphics\Title Card 3",bin,dma_safe
		incfile Art_TitleCardBonus,"Graphics\Title Card Bonus",bin,dma_safe
		incfile Art_TitleCardA,"Graphics\Title Card Letter A",bin,dma_safe
		incfile Art_TitleCardB,"Graphics\Title Card Letter B",bin,dma_safe
		incfile Art_TitleCardC,"Graphics\Title Card Letter C",bin,dma_safe
		incfile Art_TitleCardD,"Graphics\Title Card Letter D",bin,dma_safe
		incfile Art_TitleCardE,"Graphics\Title Card Letter E",bin,dma_safe
		incfile Art_TitleCardF,"Graphics\Title Card Letter F",bin,dma_safe
		incfile Art_TitleCardG,"Graphics\Title Card Letter G",bin,dma_safe
		incfile Art_TitleCardH,"Graphics\Title Card Letter H",bin,dma_safe
		incfile Art_TitleCardI,"Graphics\Title Card Letter I",bin,dma_safe
		incfile Art_TitleCardK,"Graphics\Title Card Letter K",bin,dma_safe
		incfile Art_TitleCardL,"Graphics\Title Card Letter L",bin,dma_safe
		incfile Art_TitleCardM,"Graphics\Title Card Letter M",bin,dma_safe
		incfile Art_TitleCardN,"Graphics\Title Card Letter N",bin,dma_safe
		incfile Art_TitleCardO,"Graphics\Title Card Letter O",bin,dma_safe
		incfile Art_TitleCardP,"Graphics\Title Card Letter P",bin,dma_safe
		incfile Art_TitleCardR,"Graphics\Title Card Letter R",bin,dma_safe
		incfile Art_TitleCardS,"Graphics\Title Card Letter S",bin,dma_safe
		incfile Art_TitleCardT,"Graphics\Title Card Letter T",bin,dma_safe
		incfile Art_TitleCardU,"Graphics\Title Card Letter U",bin,dma_safe
		incfile Art_TitleCardY,"Graphics\Title Card Letter Y",bin,dma_safe
		incfile Art_TitleCardZ,"Graphics\Title Card Letter Z",bin,dma_safe
		incfile Art_HUDMain,"Graphics\HUD",bin,dma_safe
		incfile Art_Lives,"Graphics\HUD - Life Counter Icon",bin,dma_safe
		incfile	Art_HUDNums,"Graphics\HUD Numbers",bin,dma_safe
		incfile	Art_LivesNums,"Graphics\Lives Counter Numbers",bin,dma_safe
		incfile	Art_Red99,"Graphics\Red 99",bin,dma_safe
		incfile	Art_Overlay,"Graphics\Debug Overlay",bin,dma_safe
		incfile Kos_Ring,"Graphics Moduled\Rings",kpm
		incfile Art_Shield,"Graphics\Shield",bin,dma_safe
		incfile Art_Stars,"Graphics\Invincibility",bin,dma_safe
		incfile Art_Monitors,"Graphics\Monitors",bin,dma_safe
		incfile Art_RingIcon,"Graphics\Monitor Contents - Ring",bin,dma_safe
		incfile Art_EggmanIcon,"Graphics\Monitor Contents - Eggman",bin,dma_safe
		incfile Art_ShieldIcon,"Graphics\Monitor Contents - Shield",bin,dma_safe
		incfile Art_InvIcon,"Graphics\Monitor Contents - Invincible",bin,dma_safe
		incfile Art_SIcon,"Graphics\Monitor Contents - S",bin,dma_safe
		incfile Art_GogglesIcon,"Graphics\Monitor Contents - Goggles",bin,dma_safe
		incfile Art_ShoeIcon,"Graphics\Monitor Contents - Shoes",bin,dma_safe
		incfile Art_Explode,"Graphics\Explosion",bin,dma_safe
		incfile Kos_Points,"Graphics Moduled\Points",kpm
		incfile Art_GameOver,"Graphics\Game Over",bin,dma_safe
		incfile Kos_HSpring,"Graphics Moduled\Spring Horizontal",kpm
		incfile Kos_VSpring,"Graphics Moduled\Spring Vertical",kpm
		incfile Art_Signpost,"Graphics\Signpost",bin,dma_safe
		incfile Kos_Lamp,"Graphics Moduled\Lamppost",kpm
		incfile Art_BigFlash,"Graphics\Giant Ring Flash",bin,dma_safe
		incfile Art_Bonus,"Graphics\Hidden Bonuses",bin,dma_safe
; ---------------------------------------------------------------------------
; Compressed graphics - continue screen
; ---------------------------------------------------------------------------
		incfile	Art_ContSonic,"Graphics\Continue Screen Sonic",bin,dma_safe
		incfile	Art_MiniSonic,"Graphics\Continue Screen Mini Sonic",bin,dma_safe
; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
		incfile	Art_Rabbit,"Graphics\Animal Rabbit",bin,dma_safe
		incfile	Art_Chicken,"Graphics\Animal Chicken",bin,dma_safe
		incfile	Art_Penguin,"Graphics\Animal Penguin",bin,dma_safe
		incfile	Art_Seal,"Graphics\Animal Seal",bin,dma_safe
		incfile	Art_Pig,"Graphics\Animal Pig",bin,dma_safe
		incfile	Art_Flicky,"Graphics\Animal Flicky",bin,dma_safe
		incfile	Art_Squirrel,"Graphics\Animal Squirrel",bin,dma_safe
; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
		incfile	Kos_GHZ_1st,"Graphics Moduled\GHZ Main",kpm
		incfile	Kos_GHZ_2nd,"Graphics Moduled\GHZ Main2",kpm
		incfile	Kos_MZ,"Graphics Moduled\MZ Main",kpm
		incfile	Kos_SYZ,"Graphics Moduled\SYZ Main",kpm
		incfile	Kos_LZ,"Graphics Moduled\LZ Main",kpm
		incfile	Kos_SLZ,"Graphics Moduled\SLZ Main",kpm
		incfile	Kos_SBZ,"Graphics Moduled\SBZ Main",kpm
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
		incfile Art_Eggman,"Graphics\Boss - Ship",bin,dma_safe
		incfile Art_MZPipe,"Graphics\MZ Boss Pipe",bin,dma_safe
		incfile Art_SLZPipe,"Graphics\SLZ Boss Pipe",bin,dma_safe
		incfile Art_GHZAnchor,"Graphics\GHZ Boss Anchor",bin,dma_safe
		incfile Art_SYZSpike,"Graphics\SYZ Boss Spike",bin,dma_safe
		incfile Art_Prison,"Graphics\Prison Capsule",bin,dma_safe
		incfile Art_PrisonBroken,"Graphics\Prison Capsule Broken",bin,dma_safe
		incfile Art_Sbz2Eggman,"Graphics\Boss - Eggman in SBZ2 & FZ",bin,dma_safe
		incfile Kos_FzBoss,"Graphics Moduled\Boss - Final Zone",kpm
		incfile Kos_FzEggman,"Graphics Moduled\Boss - Eggman after FZ Fight",kpm
		incfile Art_Exhaust,"Graphics\Boss - Exhaust Flame",bin,dma_safe
		incfile Art_Face,"Graphics\Boss - Face",bin,dma_safe
		incfile Kos_EndEm,"Graphics Moduled\Ending - Emeralds",kpm
		incfile Kos_EndSonic,"Graphics Moduled\Ending - Sonic",kpm
		incfile Kos_TryAgain,"Graphics Moduled\Ending - Try Again",kpm
		incfile Kos_EndFlower,"Graphics Moduled\Ending - Flowers",kpm
		incfile Art_CreditText,"Graphics\Ending - Credits",bin,dma_safe
		incfile Art_EndStH,"Graphics\Ending - StH Logo",bin,dma_safe
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
		incfile	SS_1,"Other Kosinski\SS1",kos
		incfile	SS_2,"Other Kosinski\SS2",kos
		incfile	SS_3,"Other Kosinski\SS3",kos
		incfile	SS_4,"Other Kosinski\SS4",kos
		incfile	SS_5,"Other Kosinski\SS5",kos
		incfile	SS_6,"Other Kosinski\SS6",kos
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
		incfile	Art_BigRing,"Graphics\Giant Ring",bin,dma_safe

		include "DMA & PLCs\UncPLC.asm"
		include "DMA & PLCs\SlowPLC.asm"
		include "Objects\GHZ Giant Ball [Mappings].asm"	; Map_GBall
		include "Objects\GHZ Bridge [Mappings].asm"	; Map_Bri
		include "Objects\GHZ & MZ Swinging Platforms [Mappings].asm" ; Map_Swing_GHZ
		include "Objects\SLZ Swinging Platforms [Mappings].asm" ; Map_Swing_SLZ
		include "Objects\GHZ Spiked Helix Pole [Mappings].asm" ; Map_Hel
		include "Objects\Platforms [Mappings].asm"	; Map_Platform
		include "Objects\GHZ Collapsing Ledge [Mappings].asm" ; Map_Ledge
		include "Objects\GHZ Purple Rock [Mappings].asm" ; Map_PRock
		include "Objects\GHZ & SLZ Smashable Walls [Mappings].asm" ; Map_Smash
		include "Objects\GHZ Walls [Mappings].asm"	; Map_Edge
		include "Objects\MZ, SLZ & SBZ Collapsing Floors [Mappings].asm" ; Map_CFlo
		include "Objects\MZ Lava Wall [Mappings].asm"	; Map_LWall
		include "Objects\MZ Grass Platforms [Mappings].asm" ; Map_LGrass
		include "Objects\Fireballs [Mappings].asm"	; Map_Fire
		include "Objects\MZ Green Glass Blocks [Mappings].asm" ; Map_Glass
		include "Objects\MZ Chain Stompers [Mappings].asm" ; Map_CStom
		include "Objects\MZ Unused Sideways Stomper [Mappings].asm" ; Map_SStom
		include "Objects\MZ Pushable Blocks [Mappings].asm" ; Map_Push
		include "Objects\MZ Purple Brick Block [Mappings].asm" ; Map_Brick
		include "Objects\MZ Lava Geyser [Mappings].asm"	; Map_Geyser
		include "Objects\MZ Smashable Green Block [Mappings].asm" ; Map_Smab
		include "Objects\MZ Moving Blocks [Mappings].asm" ; Map_MBlock
		include "Objects\SBZ Striped Yellow Platform [Mappings].asm" ; Map_YPlat
		include "Objects\SBZ Sliding Red Platform [Mappings].asm" ; Map_Slide
		include "Objects\LZ Half Block [Mappings].asm"	; Map_MBlockLZ
		include "Objects\SYZ Lamp [Mappings].asm"	; Map_Light
		include "Objects\SYZ Bumper [Mappings].asm"	; Map_Bump
		include "Objects\SYZ Floating Blocks [Mappings].asm" ; Map_FBlock
		include "Objects\SLZ Square Blocks [Mappings].asm" ; Map_SBlock
		include "Objects\SYZ & LZ Spike Ball Chain [Mappings].asm" ; Map_SBall, Map_SBall2
		include "Objects\SYZ & SBZ Large Spike Balls [Mappings].asm" ; Map_BBall
		include "Objects\SYZ Blocks at Boss [Mappings].asm" ; Map_BossBlock
		include "Objects\LZ Water Surface [Mappings].asm" ; Map_Surf
		include "Objects\LZ Pole [Mappings].asm"	; Map_Pole
		include "Objects\LZ Flapping Door [Mappings].asm" ; Map_Flap
		include "Objects\LZ Harpoon [Mappings].asm"	; Map_Harp
		include "Objects\LZ Blocks [Mappings].asm"	; Map_LBlock
		include "Objects\LZ Cork [Mappings].asm"	; Map_Cork
		include "Objects\LZ Rising Platform [Mappings].asm" ; Map_LPlat
		include "Objects\LZ Gargoyle Head [Mappings].asm" ; Map_Gar
		include "Objects\LZ Conveyor Belt Platforms [Mappings].asm" ; Map_LConv
		include "Objects\LZ Bubbles [Mappings].asm"	; Map_Bub
		include "Objects\LZ Waterfall [Mappings].asm"	; Map_WFall
		include "Objects\LZ Water Splash [Mappings].asm" ; Map_Splash
		include "Objects\LZ Door Vertical [Mappings].asm" ; Map_DoorV
		include "Objects\LZ Door Horizontal [Mappings].asm" ; Map_DoorH
		include "Objects\SLZ Fireball Launcher [Mappings].asm" ; Map_Scen
		include "Objects\SLZ Elevator [Mappings].asm"	; Map_Elev
		include "Objects\SLZ Circling Platform [Mappings].asm" ; Map_Circ
		include "Objects\SLZ Stairs [Mappings].asm"	; Map_Stair
		include "Objects\SLZ Pylon [Mappings].asm"	; Map_Pylon
		include "Objects\SLZ Fans [Mappings].asm"	; Map_Fan
		include "Objects\SLZ Seesaw [Mappings].asm"	; Map_Seesaw
		include "Objects\SLZ Seesaw Spike Ball [Mappings].asm" ; Map_SSawBall
		include "Objects\SLZ Boss Spikeballs [Mappings].asm" ; Map_BSBall
		include "Objects\SBZ Door [Mappings].asm"	; Map_ADoor
		include "Objects\SBZ Flamethrower [Mappings].asm" ; Map_Flame
		include "Objects\SBZ Rotating Disc Junction [Mappings].asm" ; Map_Jun
		include "Objects\SBZ Running Disc [Mappings].asm" ; Map_Disc
		include "Objects\SBZ Spinning Platforms [Mappings].asm" ; Map_Spin
		include "Objects\SBZ Trapdoor [Mappings].asm"	; Map_Trap
		include "Objects\SBZ Saws [Mappings].asm"	; Map_Saw
		include "Objects\SBZ Stomper [Mappings].asm"	; Map_Stomp
		include "Objects\SBZ Door Horizontal [Mappings].asm" ; Map_SDoorH
		include "Objects\SBZ3 Big Pillar Door [Mappings].asm" ; Map_Pillar
		include "Objects\SBZ Vanishing Platform [Mappings].asm" ; Map_VanP
		include "Objects\SBZ Electric Orb [Mappings].asm" ; Map_Elec
		include "Objects\SBZ Girder Block [Mappings].asm" ; Map_Gird
		include "Objects\SBZ2 Eggman [Mappings].asm"	; Map_SEgg
		include "Objects\SBZ2 Blocks That Eggman Breaks [Mappings].asm" ; Map_FFloor
		include "Objects\FZ Eggman in Damaged Ship [Mappings].asm" ; Map_FZDamaged
		include "Objects\FZ Eggman Ship Legs [Mappings].asm" ; Map_FZLegs
		include "Objects\FZ Cylinders [Mappings].asm"	; Map_EggCyl
		include "Objects\FZ Plasma Launcher [Mappings].asm" ; Map_PLaunch
		include "Objects\FZ Plasma Balls [Mappings].asm" ; Map_Plasma
		include "Objects\Shield & Invincibility [Mappings].asm" ; Map_Shield
		include "Objects\Signpost [Mappings].asm"	; Map_Sign
		include "Objects\Giant Ring [Mappings].asm"	; Map_GRing
		include "Objects\Giant Ring Flash [Mappings].asm" ; Map_Flash
		include "Objects\Ring [Mappings].asm"		; Map_Ring
		include "Objects\Monitors [Mappings].asm"	; Map_Monitor
		include "Objects\Button [Mappings].asm"		; Map_But
		include "Objects\Spikes [Mappings].asm"		; Map_Spike
		include "Objects\Springs [Mappings].asm"	; Map_Spring
		include "Objects\Lamppost [Mappings].asm"	; Map_Lamp
		include "Objects\Hidden Bonus Points [Mappings].asm" ; Map_Bonus
		include "Objects\Animals [Mappings].asm"	; Map_Animal1, Map_Animal2 & Map_Animal3
		include "Objects\Points [Mappings].asm"		; Map_Points
		include "Objects\Invisible Solid Blocks [Mappings].asm" ; Map_Invis
		include "Objects\Prison Capsule [Mappings].asm"	; Map_Pri
		include "Objects\Title Cards Sonic Has Passed [Mappings].asm" ; Map_Has
		include "Objects\Title Cards [Mappings].asm"	; Map_Card
		include "Objects\Continue Screen [Mappings].asm" ; Map_ContScr
		include "Objects\Ending Sonic [Mappings].asm"	; Map_ESon
		include "Objects\Ending Chaos Emeralds [Mappings].asm" ; Map_ECha
		include "Objects\Ending StH Text [Mappings].asm" ; Map_ESth
		include "Objects\Ending Eggman Try Again [Mappings].asm" ; Map_EEgg
		include "Objects\Unused Switch [Mappings].asm"	; Map_Switch
		include "Objects\Ball Hog [Mappings].asm"	; Map_Hog
		include "Objects\Buzz Bomber Missile Vanishing [Mappings].asm" ; Map_MisDissolve
		include "Objects\Crabmeat [Mappings].asm"	; Map_Crab
		include "Objects\Buzz Bomber [Mappings].asm"	; Map_Buzz
		include "Objects\Buzz Bomber Missile [Mappings].asm" ; Map_Missile
		include "Objects\Chopper [Mappings].asm"	; Map_Chop
		include "Objects\Jaws [Mappings].asm"		; Map_Jaws
		include "Objects\Burrobot [Mappings].asm"	; Map_Burro
		include "Objects\Newtron [Mappings].asm"	; Map_Newt
		include "Objects\Roller [Mappings].asm"		; Map_Roll
		include "Objects\Moto Bug [Mappings].asm"	; Map_Moto
		include "Objects\Yadrin [Mappings].asm"		; Map_Yad
		include "Objects\Batbrain [Mappings].asm"	; Map_Bat
		include "Objects\Bomb Enemy [Mappings].asm"	; Map_Bomb
		include "Objects\Orbinaut [Mappings].asm"	; Map_Orb
		include "Objects\Caterkiller [Mappings].asm"	; Map_Cat
		include "Objects\Splats [Mappings].asm"		; Map_Splats
		include "Objects\Bosses [Mappings].asm"		; Map_Bosses, Map_BossItems
		include "Objects\Explosions [Mappings].asm"	; Map_ExplodeItem & Map_ExplodeBomb
		include "Objects\HUD Score, Time & Rings [Mappings].asm" ; Map_HUD
		include "Objects\Title Screen Press Start & TM [Mappings].asm" ; Map_PSB
		include "Objects\Title Screen Sonic [Mappings].asm" ; Map_TSon
		include "Objects\Game Over & Time Over [Mappings].asm" ; Map_Over
		include "Objects\Special Stage Results Chaos Emeralds [Mappings].asm" ; Map_SSRC
		include "Objects\Special Stage Results [Mappings].asm" ; Map_SSR
		include "Objects\Special Stage R [Mappings].asm" ; Map_SS_R
		include "Objects\Special Stage Breakable & Red-White Blocks [Mappings].asm" ; Map_SS_Glass
		include "Objects\Special Stage Up [Mappings].asm" ; Map_SS_Up
		include "Objects\Special Stage Down [Mappings].asm" ; Map_SS_Down
		include "Objects\Special Stage Chaos Emeralds [Mappings].asm" ; Map_SS_Chaos1, Map_SS_Chaos2 & Map_SS_Chaos3
		include "Objects\Credits & Sonic Team Presents [Mappings].asm" ; Map_Cred

; ---------------------------------------------------------------------------
; Level	layouts
; ---------------------------------------------------------------------------
		incfile	Level_GHZ1,"Level Layouts\ghz1",hrl
		incfile	Level_GHZ2,"Level Layouts\ghz2",hrl
		incfile	Level_GHZ3,"Level Layouts\ghz3",hrl
		incfile	Level_GHZ_bg,"Level Layouts\ghzbg",hrl
		incfile	Level_LZ1,"Level Layouts\lz1",hrl
		incfile	Level_LZ_bg,"Level Layouts\lzbg",hrl
		incfile	Level_LZ2,"Level Layouts\lz2",hrl
		incfile	Level_LZ3,"Level Layouts\lz3",hrl
		incfile	Level_SBZ3,"Level Layouts\sbz3",hrl
		incfile	Level_MZ1,"Level Layouts\mz1",hrl
		incfile	Level_MZ1_bg,"Level Layouts\mz1bg",hrl
		incfile	Level_MZ2,"Level Layouts\mz2",hrl
		incfile	Level_MZ2_bg,"Level Layouts\mz2bg",hrl
		incfile	Level_MZ3,"Level Layouts\mz3",hrl
		incfile	Level_MZ3_bg,"Level Layouts\mz3bg",hrl
		incfile	Level_SLZ1,"Level Layouts\slz1",hrl
		incfile	Level_SLZ_bg,"Level Layouts\slzbg",hrl
		incfile	Level_SLZ2,"Level Layouts\slz2",hrl
		incfile	Level_SLZ3,"Level Layouts\slz3",hrl
		incfile	Level_SYZ1,"Level Layouts\syz1",hrl
		incfile	Level_SYZ_bg,"Level Layouts\syzbg",hrl
		incfile	Level_SYZ2,"Level Layouts\syz2",hrl
		incfile	Level_SYZ3,"Level Layouts\syz3",hrl
		incfile	Level_SBZ1,"Level Layouts\sbz1",hrl
		incfile	Level_SBZ1_bg,"Level Layouts\sbz1bg",hrl
		incfile	Level_SBZ2,"Level Layouts\sbz2",hrl
		incfile	Level_SBZ2_bg,"Level Layouts\sbz2bg",hrl
		incfile	Level_End,"Level Layouts\ending",hrl
		
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
; Palettes
; ---------------------------------------------------------------------------
		incfile	Pal_SegaBG,"Palettes\Sega Background",bin
		incfile	Pal_HidCred,"Palettes\Hidden Credits",bin
		incfile	Pal_Title,"Palettes\Title Screen",bin
		incfile	Pal_LevelSel,"Palettes\Level Select",bin
		incfile	Pal_Sonic,"Palettes\Sonic",bin
		incfile	Pal_SonicRed,"Palettes\Sonic Red",bin
		incfile	Pal_SonicYellow,"Palettes\Sonic Yellow",bin
		incfile	Pal_GHZ,"Palettes\Green Hill Zone",bin
		incfile	Pal_LZ,"Palettes\Labyrinth Zone",bin
		incfile	Pal_MZ,"Palettes\Marble Zone",bin
		incfile	Pal_SLZ,"Palettes\Star Light Zone",bin
		incfile	Pal_SYZ,"Palettes\Spring Yard Zone",bin
		incfile	Pal_SBZ1,"Palettes\SBZ Act 1",bin
		incfile	Pal_SBZ2,"Palettes\SBZ Act 2",bin
		incfile	Pal_Special,"Palettes\Special Stage",bin
		incfile	Pal_SBZ3,"Palettes\SBZ Act 3",bin
		incfile	Pal_SSResult,"Palettes\Special Stage Results",bin
		incfile	Pal_Continue,"Palettes\Special Stage Continue Bonus",bin
		incfile	Pal_Ending,"Palettes\Ending",bin
		
		incfile	Pal_TitleCyc,"Palettes\Cycle - Title Screen Water",bin
		incfile	Pal_GHZCyc,"Palettes\Cycle - GHZ",bin
		incfile	Pal_LZCyc1,"Palettes\Cycle - LZ Waterfall",bin
		incfile	Pal_LZCyc2,"Palettes\Cycle - LZ Conveyor Belt",bin
		incfile	Pal_SBZ3Cyc1,"Palettes\Cycle - SBZ3 Waterfall",bin
		incfile	Pal_SLZCyc,"Palettes\Cycle - SLZ",bin
		incfile	Pal_SYZCyc1,"Palettes\Cycle - SYZ1",bin
		incfile	Pal_SYZCyc2,"Palettes\Cycle - SYZ2",bin
		incfile	Pal_SBZCyc1,"Palettes\Cycle - SBZ 1",bin
		incfile	Pal_SBZCyc2,"Palettes\Cycle - SBZ 2",bin
		incfile	Pal_SBZCyc3,"Palettes\Cycle - SBZ 3",bin
		incfile	Pal_SBZCyc4,"Palettes\Cycle - SBZ 4",bin
		incfile	Pal_SBZCyc5,"Palettes\Cycle - SBZ 5",bin
		incfile	Pal_SBZCyc6,"Palettes\Cycle - SBZ 6",bin
		incfile	Pal_SBZCyc7,"Palettes\Cycle - SBZ 7",bin
		incfile	Pal_SBZCyc8,"Palettes\Cycle - SBZ 8",bin
		incfile	Pal_SBZCyc9,"Palettes\Cycle - SBZ 9",bin
		incfile	Pal_SBZCyc10,"Palettes\Cycle - SBZ 10",bin

; ---------------------------------------------------------------------------
; Demo data
; ---------------------------------------------------------------------------
		incfile	Demo_GHZ,"Demos\Intro - GHZ",bin
		incfile	Demo_MZ,"Demos\Intro - MZ",bin
		incfile	Demo_SYZ,"Demos\Intro - SYZ",bin
		incfile	Demo_SS,"Demos\Intro - Special Stage",bin
		incfile	Demo_EndGHZ1,"Demos\Ending - GHZ1",bin
		incfile	Demo_EndMZ,"Demos\Ending - MZ",bin
		incfile	Demo_EndSYZ,"Demos\Ending - SYZ",bin
		incfile	Demo_EndLZ,"Demos\Ending - LZ",bin
		incfile	Demo_EndSLZ,"Demos\Ending - SLZ",bin
		incfile	Demo_EndSBZ1,"Demos\Ending - SBZ1",bin
		incfile	Demo_EndSBZ2,"Demos\Ending - SBZ2",bin
		incfile	Demo_EndGHZ2,"Demos\Ending - GHZ2",bin
		
; ---------------------------------------------------------------------------
; Sound driver data
; ---------------------------------------------------------------------------
		include "sound/Sound Data.asm"

; ---------------------------------------------------------------
; Error handling module
; ---------------------------------------------------------------
		include	"ErrorHandler.asm"
ROM_End:
		END
