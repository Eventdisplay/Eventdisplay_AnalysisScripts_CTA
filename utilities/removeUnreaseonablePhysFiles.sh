#!/bin/bash
#
# remove PHYS files which are definitely empty
# e.g., LST4 for 2LST arrays
#
if [ ! -n "$1" ]
then
    echo "./removeUnreaseonablePhysFiles.sh <path>"
    echo
    echo
    exit
fi

if [[ ! -d "$1" ]]; then
  echo "Error, directory does not exist" 
  exit
fi

OPTION="-delete -print"

# North LST arrays
find "$1" -name "*NIM4LST4*3LSTs00MSTs-*" -print -delete
find "$1" -name "*NIM4LST4*2LSTs00MSTs-*" -print -delete
find "$1" -name "*NIM3LST3*2LSTs00MSTs-*" -print -delete
# South LST arrays
find "$1" -name "*NIM4LST4*3LSTs00MSTs00SSTs-*" -print -delete
find "$1" -name "*NIM4LST4*2LSTs00MSTs00SSTs-*" -print -delete
find "$1" -name "*NIM3LST3*2LSTs00MSTs00SSTs-*" -print -delete

find "$1" -name "*NIM3LST3MST3*2LSTs03MSTs*" -print -delete
find "$1" -name "*NIM4LST4MST4*2LSTs03MSTs*" -print -delete
