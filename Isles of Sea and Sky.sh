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

# Setup permissions
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
echo "Loading, please wait... (might take a while!)" > /dev/tty0

# Variables
GAMEDIR="/$directory/ports/islesofseaandsky"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 777 "$GAMEDIR/gmloadernext"

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs:$GAMEDIR/utils/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Run the installer file if it hasn't been run yet
install() {
  echo "Performing first-run setup..." > $CUR_TTY
  # Purge unneeded files
  rm -rf assets/*.exe assets/*.dll assets/.gitkeep
  # Rename data.win
  echo "Moving game files..." > $CUR_TTY
  mv "./assets/data.win" "./game.droid"
  mv patch/* ./
  mv assets/* ./
  find $GAMEDIR -type f -iname "*.ttf" ! -iname "Commodore Rounded v1-1.ttf" ! -iname "small_pixel.ttf" -delete
  rm -rf "$GAMEDIR/assets"
}

# Do localization fonts patch if low ram
if [ $DEVICE_RAM -lt 2 ]; then
rm -rf assets/localization_fonts.csv
mv patch/* ./
rm -rf "$GAMEDIR/patch"
fi

if [ ! -f "$GAMEDIR/game.droid" ]; then
    install
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext" -c "control.gptk" &
./gmloadernext game.apk

# Kill processes
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
