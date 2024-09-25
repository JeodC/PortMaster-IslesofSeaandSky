#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="/$directory/ports/iosas"
BITRATE=64

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Setup permissions
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$ESUDO chmod +x -R $GAMEDIR/*
echo "Loading, please wait... (might take a while!)" > $CUR_TTY

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs:$GAMEDIR/tools/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PATH="$GAMEDIR/tools:$PATH"
export TMPDIR="$GAMEDIR/tmp"

# Check if patchlog.txt to skip patching
if [ ! -f patchlog.txt ]; then
    $GPTOKEYB "love" &
    ./love patcher -f "tools/patchscript" -g "Isles of Sea and Sky" -t "about 5 minutes"
    $ESUDO kill -9 $(pidof gptokeyb)
else
    echo "Patching process already completed. Skipping."
fi

# Display loading splash
if [ -f "$GAMEDIR/game.droid" ]; then
    $ESUDO ./libs/splash "splash.png" 1 
    $ESUDO ./libs/splash "splash.png" 8000
fi

if [ -f "$GAMEDIR/game.droid" ]; then
    $ESUDO ./libs/splash "splash.png" 1 
    $ESUDO ./libs/splash "splash.png" 12000 &
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext" -c "control.gptk" &
./gmloadernext game.apk

# Kill processes
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
