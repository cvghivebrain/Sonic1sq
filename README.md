# Sonic 1-squared

_Sonic 1-squared_ is an enhanced version of the original _Sonic the Hedgehog_ game engine. Various changes are planned to make editing the game easier.

# Features
* The player's Chaos Emerald count is stored as a bitfield instead of a list. It's a longword, so there can be up to 32 Emeralds.
* Modified the way animation works to save 2 bytes in RAM per object. The high bit of ost_anim now serves as an update flag instead of ost_anim_restart.