#!/bin/sh -uf

# hieronymus - Suspend/continue freedesktop compliant Linux processes with ease! Useful for pausing video games!
# Copyright 2015 Daemon Lee Schmidt

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

AUTOSELECT_FLAG=false

while [[ $# > 0 ]]
do
key="$1"

case $key in
  -a|--auto)
  AUTOSELECT_FLAG=true
  shift
  ;;
  *)
  ;;
esac
shift
done

if $AUTOSELECT_FLAG ; then
  WINID=$(xprop -root 32x '\t$0' _NET_ACTIVE_WINDOW | cut -f 2)
  if [ $WINID == "0x0" ]; then
    echo "You can't suspend the root window!"
    exit 1
  fi
  CRIMINAL=$(xprop -id $WINID _NET_WM_PID | grep -o '[0-9]*')
else
  CRIMINAL=$(xprop _NET_WM_PID | grep -o '[0-9]*')
fi

if [[ -z $CRIMINAL ]]; then
  echo "This is a strange window."
  exit 2
fi

CURSTATE=$(cat /proc/$CRIMINAL/status | grep 'State' | cut -f 2)

if [[ "$CURSTATE" != "T (stopped)" ]]; then
  kill -STOP $CRIMINAL
else
  kill -CONT $CRIMINAL
fi
