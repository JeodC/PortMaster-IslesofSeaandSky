## Installation
Add your game data from your Steam installation to `ports/islesofseaandsky/assets`. First-time run will handle sorting data.

Due to some memory issues, localization has been removed. The fonts that are used do not contain all the characters needed for other languages. This may be remedied in the future. If you use a high-ram device, you can try manually 
adding the original `localization_fonts.csv` and the missing font `.ttf` files and see if it's playable.

## Default Gameplay Controls
| Button | Action |
|--|--|
|START|Menus|
|SELECT|Map|
|D-PAD / Analog|Move|
|L1|Undo|
|R1|Reset room|

## Config
The xdelta patch enables `pm-config.ini`, which has some performance options. Testing found that `FrameSkip=40` works pretty well for the H700 chip. For no stuttering at all, you can set `IdolSFX=0` to turn off the special effect that bogs down the cpu.

## Thanks
Cicada Games -- The game  
JohnnyOnFlame -- GMLoaderNext  
Testers and Devs from the PortMaster Discord  