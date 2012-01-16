#!/bin/bash
aw="$HOME/.config/awesome"
notify="$HOME/dev/bash/bashnotify/"

numlockx &

if [[ ! $(pidof urxvtd) ]]; then
    urxvtd -q -f -o &&

    urxvtc -e sh ${aw}/tmux_st ${aw}; urxvtc
fi

if [[ ! $(pidof firefox) ]]; then
    $HOME/bin/firefox-bin &
fi

if [[ ! $(pidof xcompmgr) ]]; then
    xcompmgr -cfF -r4.2 -o.67 -l-5 -t-5 -D5 &
fi

${notify}/bashnotifystart.sh restart &
killall -9 widgets
${aw}/widgets &
