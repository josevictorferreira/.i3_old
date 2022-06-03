#!/bin/bash

active_displays () {
  xrandr --query | grep " connected" | cut -d" " -f1 | tac
}

current_brightness () {
  xrandr --verbose | awk '/Brightness/ { print $2; exit }'
}

notify_up () {
  bright="$1"
  bright_share=$(echo "$bright * 100" | bc -l)
  notify-send -t 1000 "Brightness up to $bright_share%."
}

notify_down () {
  bright="$1"
  bright_share=$(echo "$bright * 100" | bc -l)
  notify-send -t 1000 "Brightness down to $bright_share%."
}

increase_brightness () {
  val="$1"
  bright=$(current_brightness)
  bright=$(echo "$bright + $val" | bc -l)
  if (( $(echo "$bright > 1.0" | bc -l) )); then
    bright=1.0
  elif (( $(echo "$bright < 0.0" | bc -l) )); then
    bright=0.0
  fi
  displays=$(active_displays)
  for display in $displays; do
    xrandr --output "$display" --brightness $bright
    notify_up $bright
  done
}

decrease_brightness () {
  val=$1
  bright=$(current_brightness)
  bright=$(echo "$bright - $val" | bc -l)
  if (( $(echo "$bright > 1.0" | bc -l) )); then
    bright=1.0
  elif (( $(echo "$bright < 0.0" | bc -l) )); then
    bright=0.0
  fi
  displays=$(active_displays)
  for display in $displays; do
    xrandr --output "$display" --brightness "$bright"
    notify_down $bright
  done
}

main () {
  arg="$1"
  val="$2"

  if [[ $arg == "--dec" ]]; then
    decrease_brightness "$val";
  elif [[ $arg == "--inc" ]]; then
    increase_brightness "$val";
  fi
}

main "$@"
