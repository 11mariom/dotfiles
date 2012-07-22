#!/bin/sh

case $1 in
    fluxbox)
	exec fluxbox
	;;
    test)
	exec awesome -c /tmp/rc.lua
	;;
    *)
	exec $1
	;;
esac

