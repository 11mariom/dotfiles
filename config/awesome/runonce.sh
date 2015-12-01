#!/bin/bash
aw="$HOME/.config/awesome"
notify="$HOME/dev/scripts/bash/bashnotify/"

numlockx &

if [[ ! $(pidof urxvtd) ]]; then
    urxvtd -q -f -o &&

    urxvtc -e sh ${aw}/tmux_st ${aw}; urxvtc
fi

if [[ ! $(pidof firefox-bin) ]]; then
    $HOME/bin/firefox-bin &
fi

if [[ ! $(pidof xcompmgr) ]]; then
    xcompmgr -cfF -r4.2 -o.67 -l-5 -t-5 -D5 &
fi

if [[ ! $(pidof xbindkeys) ]]; then
    xbindkeys
fi

if [[ ! $(pidof clipit) ]]; then
    clipit &
fi

if [[ ! $(pidof mpdscribble) ]]; then
    mpdscribble &
fi

#${notify}/bashnotifystart.sh restart &
#killall -9 widgets
#${aw}/widgets &
#xmodmap -e "pointer = 1 2 3 8 10 6 7 4 9 5 11 12 13 14 15" &
