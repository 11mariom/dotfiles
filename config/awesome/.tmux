#!/bin/sh
set -x

tmux new-session -d -s awesome
tmux new-window -t awesome:2
tmux join-pane -v -p 70 -s awesome:2 -t awesome:1

tmux attach -t awesome
