#!/bin/sh
number_of_processes="$(pgrep -f 'counter'|wc -l)"
if [ "$number_of_processes" -eq 2 ]
then
echo "$(sleep 600)"
echo 0 > /tmp/number_of_errors
exit 0
fi
exit 0