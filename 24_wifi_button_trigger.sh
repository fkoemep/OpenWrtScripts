#!/bin/sh

[ "${ACTION}" = "released" -o -n "${TYPE}" ] || exit 0

if [ $(uci get wireless.@wifi-iface[1].disabled) -eq 1 ]
then
uci delete wireless.@wifi-iface[1].disabled
uci commit wireless
/sbin/wifi up radio1
(/usr/local/sbin/disable_24_wifi.sh)&
fi

return 0