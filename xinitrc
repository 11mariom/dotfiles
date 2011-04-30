#!/bin/sh

case $1 in
    fluxbox)
	exec fluxbox
	;;
    *)
	exec awesome
	;;
esac

