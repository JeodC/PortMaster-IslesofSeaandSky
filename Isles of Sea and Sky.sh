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
BITRATE=64

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 777 "$GAMEDIR/gmloadernext"

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs:$GAMEDIR/tools/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PATH="$GAMEDIR/tools:$PATH"

# Functions
install() {
    echo "Performing first-run setup..." > $CUR_TTY
    # Purge unneeded files
    rm -rf assets/*.exe assets/*.dll assets/.gitkeep
    # Rename data.win
    echo "Moving game files..." > $CUR_TTY
    mv "./assets/data.win" "./game.droid"
    mv assets/* ./
    rmdir assets
    apply_patch
    compress_audio || return 1
    # Do localization fonts if low ram
    if [ $DEVICE_RAM -lt 2 ]; then
        rm -rf "$GAMEDIR/localization_fonts.csv"
        mv patch/localization_fonts.csv ./
        find $GAMEDIR -type f -iname "*.ttf" ! -iname "Commodore Rounded v1-1.ttf" ! -iname "small_pixel.ttf" -delete
    fi
}

apply_patch() {
    echo "Applying patch..." > $CUR_TTY
    if [ -f "$controlfolder/xdelta3" ]; then
        error=$("$controlfolder/xdelta3" -d -s "$GAMEDIR/game.droid" "$GAMEDIR/patch/patch_idol_sfx.xdelta" "$GAMEDIR/game2.droid" 2>&1)
        if [ $? -eq 0 ]; then
            rm -rf "$GAMEDIR/game.droid"
            mv "$GAMEDIR/game2.droid" "$GAMEDIR/game.droid"
            echo "Patch applied successfully." > $CUR_TTY
        else
            echo "Failed to apply patch. Error: $error" > $CUR_TTY
            rm -f "$GAMEDIR/game2.droid"
            return 1
        fi
    else
        echo "Error: xdelta3 not found in $controlfolder. Try updating PortMaster." > $CUR_TTY
        return 1
    fi
}

compress_audio() {
    echo "Compressing audio. The process will take 5-10 minutes"  > $CUR_TTY

    gm-Ktool.py -b $BITRATE "$GAMEDIR/game.droid" "$GAMEDIR/game2.droid" || return 1

    if [ $? -eq 0 ]; then
            rm -rf "$GAMEDIR/game.droid"
            mv "$GAMEDIR/game2.droid" "$GAMEDIR/game.droid"
            echo "Audio compression applied successfully." > $CUR_TTY
        else
            echo "Audio compression failed." > $CUR_TTY
            rm -f "$GAMEDIR/game2.droid"
            return 1
    fi
}

if [ ! -f "$GAMEDIR/game.droid" ] && [ ! -f "$GAMEDIR/.installed" ]; then
    install && touch "$GAMEDIR/.installed" || return 1 # Only touch if function is successful
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext" -c "control.gptk" &
./gmloadernext game.apk

# Kill processes
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
