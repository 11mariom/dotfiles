#!/bin/sh
set -x

tmux new-session -d -s awesome
tmux new-window -t awesome:2

tmux attach -t awesome
