#!/bin/sh
echo "$(sleep 900)"
value=$(uci get wireless.@wifi-iface[1].disabled)
if [ "$value" = "" ]
then
uci set wireless.@wifi-iface[1].disabled='1'
uci commit wireless
/sbin/wifi up radio1
fi
exit 0