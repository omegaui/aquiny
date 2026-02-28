#!/bin/bash

notify-send -a "aquiny" "$2" "$3"
aplay "$1.wav"
rm "$1.wav"