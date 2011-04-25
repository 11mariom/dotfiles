#!/bin/bash
aw="/home/mario/.config/awesome"

numlockx &

if [ ! $(pidof urxvtd) ]; then
    urxvtd -q -f -o &&

    urxvtc -e ncmpcpp; urxvtc -e sh ${aw}/tmux_st; urxvtc
fi

if [ ! $(pidof firefox-bin) ]; then
    $HOME/fx4/firefox &
fi

killall -9 mpd_notify 
${aw}/mpd_notify &
killall -9 widgets
${aw}/widgets &
