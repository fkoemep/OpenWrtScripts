#!/bin/sh
#This script switches between WLAN networks based on priority and by checking internet access, author: @gerarg
status_network1="$(ifstatus wwan | jsonfilter -e '@["up"]')"
status_network2="$(ifstatus wwan2 | jsonfilter -e '@["up"]')"
status_network3="$(ifstatus wwan3 | jsonfilter -e '@["up"]')"
number_of_processes="$(pgrep -f 'restart-dns'|wc -l)"
is_network1_disabled="$(uci get wireless.@wifi-iface[2].disabled)"

#Checking for active networks, otherwise we don't do anything
if { [ "$status_network1" = true ] || [ "$status_network2" = true ] || [ "$status_network3" = true ]; } && [ "$number_of_processes" -eq 2 ]; then

#Checking internet access
if wget -q --spider https://www.google.com > /dev/null; then

#We have internet access, we're gonna try to switch to network1 (provided network1 has internet access) and disable network 2 and 3
if ping -c4 -I wlan1 8.8.8.8 > /dev/null && [ "$status_network1" = true ] && { [ "$status_network2" = true ] || [ "$status_network3" = true ]; }; then
uci set wireless.@wifi-iface[3].disabled='1'
uci set wireless.@wifi-iface[4].disabled='1'
uci commit wireless
/sbin/wifi down radio1 && /sbin/wifi up radio1
logger -s "Detected internet access, switching to network 1"
exit 0
fi


#No internet access, we're going to try to fix it
else
[ ! -f "/tmp/number_of_errors" ] && number_of_errors=0 || number_of_errors=$(cat /tmp/number_of_errors) 

#If we can't access internet 4 or more times in a 10 minute timespan, we're going to try the most user-disruptve fix by restarting the network service
if [ "$number_of_errors" -ge 4 ]; then
kill -9 "$(pgrep -f contador)"
kill -9 "$(pgrep -f 'sleep 600')"
/etc/init.d/network stop && /etc/init.d/network start
/etc/init.d/firewall stop && /etc/init.d/firewall start
/etc/init.d/dnsmasq stop && /etc/init.d/dnsmasq start
/etc/init.d/https-dns-proxy stop && /etc/init.d/https-dns-proxy start
logger -s "Restarted everything (but the router)"
echo 0 > /tmp/number_of_errors
exit 0
fi

#Trying to fix it by restarting the dns related services
/etc/init.d/dnsmasq stop && /etc/init.d/dnsmasq start
/etc/init.d/https-dns-proxy stop && /etc/init.d/https-dns-proxy start
logger -s "DNS services restarted"
echo "$(sleep 10)"

if wget -q --spider https://www.google.com > /dev/null; then
logger -s "Internet access recovered"
exit 0
else
/sbin/wifi up radio1
number_of_errors="$((number_of_errors + 1))"
echo "${number_of_errors}" > /tmp/number_of_errors
if [ "$number_of_errors" -eq 1 ]; then 
(/usr/local/sbin/counter.sh)&
fi
logger -s "WiFi restarted"
echo "$(sleep 10)"
if ping -c 4 8.8.8.8 > /dev/null 
then
logger -s "Internet access recovered"
exit 0
else

if [ "$status_network2" = false ]; then
uci delete wireless.@wifi-iface[3].disabled
uci commit wireless
/sbin/wifi down radio1 && /sbin/wifi up radio1
echo "$((number_of_errors + 1))" > /tmp/number_of_errors
logger -s "Switched to network2"
exit 0

fi
fi
fi
fi
fi
exit 0