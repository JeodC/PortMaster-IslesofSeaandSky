## Isles of Sea and Sky -- PortMaster Edition
Isles of Sea and Sky is a sokoban block puzzle game with Zelda-like elements and a stunning soundtrack. With a lot of effort, this game is able to be run on small-arm linux handhelds using a Game Maker compatibility layer called GMLoader-Next and some patches to reduce memory and cpu usage.

<div align="center">
  <table>
    <tr>
      <td align="center">
        <p align="center">Isles of Sea and Sky Launch Trailer</p>  
        <a href="https://www.youtube.com/watch?v=euaG9rsGrfA">
          <img src="https://img.youtube.com/vi/euaG9rsGrfA/0.jpg" alt="Isles of Sea and Sky Launch Trailer" width="300"/>
        </a>
      </td>
      <td align="center">
        <p>&nbsp;</p> <!-- Adjust spaces to match -->
        <img src="https://images.squarespace-cdn.com/content/v1/5cef1ac40bf916000135fdcc/f4b9a8a8-b054-4e14-9f1e-cc2687e888e2/iss_river.gif" alt="Isles of Sea and Sky GIF" width="300"/>
      </td>
    </tr>
  </table>
</div>

## Installation
Add your game data from your Steam installation to `ports/islesofseaandsky/assets`. First-time run will handle sorting data.

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
Cicada Games -- The game and [press kit materials](https://islesofseaandsky.com/press-kit) used to create the splash screens  
Kotzebuedog -- The phenomenal audio patch that makes this port possible  
nate -- Custom loading splash engine  
JohnnyOnFlame -- GMLoaderNext  
Testers and Devs from the PortMaster Discord  
