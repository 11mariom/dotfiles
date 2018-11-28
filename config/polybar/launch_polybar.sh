#!/bin/bash

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    if [[ $m == "DP-1-1" ]]; then
      tray="left"
    else
      tray="disable"
    fi

    MONITOR=$m TRAY=$tray polybar --reload example &
  done
else
  polybar --reload example &
fi
