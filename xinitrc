#!/bin/sh
export SDL_AUDIODRIVER=alsa

eval $(gpg-agent --daemon)

case $1 in
    fluxbox)
	exec fluxbox
	;;
    test)
	exec awesome -c /tmp/rc.lua
	;;
    steam)
	STEAM_RUNTIME=1 exec steam #-bigpicture
	;;
    *)
	exec $1
	;;
esac

