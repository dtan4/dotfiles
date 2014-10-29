#!/bin/sh

name=`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | egrep "agrCtlRSSI|state|lastTxRate| SSID" | cut -d: -f2 | tr "\\n" ";" | sed 's/^[ ]//g' | cut -d";" -f4-4 | cut -d" " -f2-`

if [ "$name" == "" ]
then
    echo "(WIFI off)"
else
    echo $name
fi
