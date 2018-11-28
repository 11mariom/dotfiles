#!/bin/bash

if type "xrandr"; then
  if [ "$(xrandr | grep -c " connected")x" == "3x" ]; then
    ~/.screenlayout/workspace.sh
  else
    xrandr --auto
  fi
fi
