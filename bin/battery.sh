#!/bin/sh

/usr/bin/pmset -g ps | awk '{ if (NR == 2) print $2 " - " $4; }' | sed "s/;//g"
