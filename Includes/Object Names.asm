; ---------------------------------------------------------------------------
; Object names for pause debug menu
; ---------------------------------------------------------------------------

objname:	macro txt,name
		StrId_\name: equ (*-Str_Names)/8
		dc.b \txt
		endm
	
Str_Names:	objname "UNKNOWN ",Unknown
		objname "ANIMAL  ",Animal
		objname "BALL    ",Ball
		objname "BALLHOG ",BallHog
		objname "BATBRAIN",Batbrain
		objname "BIGRING ",BigRing
		objname "BLOCK   ",Block
		objname "BOMB    ",Bomb
		objname "BOMBFRAG",BombFrag
		objname "BOMBFUSE",Fuse
		objname "BONUS   ",Bonus
		objname "BOSS    ",Boss
		objname "BRIDGE  ",Bridge
		objname "BUBBLE  ",Bubble
		objname "BUBMAKER",BubbleMaker
		objname "BUMPER  ",Bumper
		objname "BURROBOT",Burrobot
		objname "BUTTON  ",Button
		objname "BUZZBOMB",BuzzBomber
		objname "CATERKIL",Caterkiller
		objname "CATERSEG",CaterSegment
		objname "CHAIN   ",Chain
		objname "CHOPPER ",Chopper
		objname "COLLAPSE",CollapseFloor
		objname "CONVEYOR",Conveyor
		objname "CORK    ",Cork
		objname	"CPUUSAGE",CPU
		objname "CRABMEAT",Crabmeat
		objname "CYLINDER",Cylinder
		objname "DEBUG   ",Debug
		objname "DISC    ",Disc
		objname "DOOR    ",Door
		objname "DROWN   ",Drown
		objname "ELECTRO ",Electro
		objname "ELEVATOR",Elevator
		objname "EXPLOSIO",Explosion
		objname "FAN     ",Fan
		objname "FIRE    ",Fire
		objname "FIREBALL",Fireball
		objname "FIREMAKE",FireMaker
		objname "FLAMETHR",Flamethrower
		objname "FRAG    ",Frag
		objname "GAMEOVER",GameOver
		objname "GARGOYLE",Gargoyle
		objname "GATE    ",Gate
		objname "GIRDER  ",Girder
		objname "GLASSBLO",GlassBlock
		objname "GRASSBLO",GrassBlock
		objname "HARPOON ",Harpoon
		objname "HELIX   ",Helix
		objname "HELIXSPI",HelixSpike
		objname "HUD     ",HUD
		objname "HUDCOUNT",HUDCount
		objname "INVINCIB",Invincible
		objname "JAWS    ",Jaws
		objname "JUNCTION",Junction
		objname "LAMPPOST",Lamppost
		objname "LAVA    ",Lava
		objname "LAVAFALL",LavaFall
		objname "LAVAFOUN",LavaFountain
		objname "LAVAWALL",LavaWall
		objname "LEDGE   ",Ledge
		objname "MISSILE ",Missile
		objname "MONITOR ",Monitor
		objname "MOTOBUG ",MotoBug
		objname "NEWTRON ",Newtron
		objname "ORBINAUT",Orbinaut
		objname "ORBSPIKE",OrbSpike
		objname "OVERLAY ",Overlay
		objname "PLATFORM",Platform
		objname "POINTS  ",Points
		objname "POLE    ",Pole
		objname "POWERUP ",PowerUp
		objname "PRISON  ",Prison
		objname "PUSHBLOC",PushBlock
		objname "RING    ",Ring
		objname "RINGLOSS",RingLoss
		objname "ROCK    ",Rock
		objname "ROLLER  ",Roller
		objname "SAW     ",Saw
		objname "SCENERY ",Scenery
		objname "SEESAW  ",Seesaw
		objname "SHIELD  ",Shield
		objname "SIGNPOST",Signpost
		objname "SMASHBLO",SmashBlock
		objname "SMASHWAL",SmashWall
		objname "SMOKE   ",Smoke
		objname "SOLID   ",Solid
		objname "SONIC   ",Sonic
		objname "SPARKLE ",Sparkle
		objname "SPIKEBAL",Spikeball
		objname "SPIKES  ",Spikes
		objname "SPLASH  ",Splash
		objname "SPLATS  ",Splats
		objname "SPRING  ",Spring
		objname "STAIR   ",Stair
		objname "STOMPER ",Stomper
		objname "TELEPORT",Teleport
		objname "TITLECAR",TitleCard
		objname "TRAPDOOR",Trapdoor
		objname "WALL    ",Wall
		objname "WATERFAL",Waterfall
		objname "WATERSND",WaterSound
		objname "WATERSUR",WaterSurface
		objname "YADRIN  ",Yadrin
		