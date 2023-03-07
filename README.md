# Sonic 1-squared

_Sonic 1-squared_ is an enhanced version of the original _Sonic the Hedgehog_ game engine. Various changes are planned to make editing the game easier.

# Features
* The player's Chaos Emerald count is stored as a bitfield instead of a list. It's a longword, so there can be up to 32 Emeralds.
* LoadPerZone subroutine consolidates all pointers and parameters for zones and acts. This simplifies the process of adding levels. (incomplete)
* LoadPerCharacter subroutine does the same for the Sonic object, palette and life icon, allowing for extra characters.
* LoadPerDemo loads the level number, demo data, character and start position for all demos, including those during the credits.
* Rewritten level select routine to be more customisable. It now uses standard ASCII, and supports multiple columns (which are automatically generated based on the lines-per-column setting).
* The hidden Japanese credits, "try again" and "end" screens have been given their own gamemodes, which are accessible through the level select.
* The HUD has new debug features, including a CPU cycle usage counter ($DF is max) and sprite counter ($4F is max).

## Graphics
* KosPLC subroutine loads Kosinski-compressed graphics at the beginning of a level.
* UncPLC subroutine load uncompressed graphics at any time. This complements KosPLC by loading graphics during a level. Both this and KosPLC use the DMA queue.
* DMA queue system for loading uncompressed graphics.
* Animated level graphics use a script instead of being hard-coded. The exception is Marble Zone's magma, which works somewhat differently to other animations.
* Palette cycling uses a script.
* Water palettes are generated in-game by the WaterFilter subroutine, instead of being hardcoded.
* Fading to black/white is controlled by a brightness variable, and no longer requires a "next" palette. This simplifies loading new palettes.

## Objects
* Modified the way animation works to save 2 bytes in RAM per object. The high bit of ost_anim now serves as an update flag instead of ost_anim_restart.
* Object scratch RAM is assigned automatically with __rsobj__ macro. If you attempt to use more RAM than is available ($40 bytes), assembly will fail.
* ost_id is now a longword pointer instead of a single byte (as is the case in _Sonic 3 & Knuckles_). This allows for unlimited object types, and slightly improves performance.
* ost_frame extended to a word (ost_frame_hi), allowing objects to have up to 8,192 distinct frames of animation.
* Sprite mappings use 6 bytes per piece instead of 5, and the piece count is a word instead of a byte. This ensures the data is always aligned to even.
* ost_parent contains the parent object's OST address (shortened to a word), if GetParent was called when the child object was created.
* Monitor icons load only as needed, allowing for up to 256 unique monitor types (with a maximum of 8 loaded at any one time).
* Each title card has its own PLC, so only letters that are used need to be loaded. Title cards are automatically centered by the __autocard__ macro. Title card mappings are also automated, and can use sprite mappings more efficiently by joining two letters together as a single sprite.

## Bugfixes
* Spikes no longer kill Sonic immediately after losing rings. Add $80 to the subtype to restore the original lethal behaviour.

# Credits
* [flamewing](https://github.com/flamewing) for [mdcomp](https://github.com/flamewing/mdcomp).
* [vladikcomper](https://github.com/vladikcomper) for the advanced error handler.
* [Devon](https://github.com/Ralakimus) for the optimised CalcAngle routine.