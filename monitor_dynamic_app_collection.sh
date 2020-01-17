#!/bin/bash
#
# New in version 1.2: Collector ID displayed when -m option is given
# New in Version 1.1: if time is not defined, don't try to track process
#
VER="1.2"
while getopts "mst:v" opt ; do
        case $opt in
                "m") MYSQL=1 ;;
                "s") SIGTERM=1 ;;
                "t") TIME="$OPTARG" ;;
                "v") echo "$0, version $VER" ; exit 0 ;;
                *) echo "Invalid option" ; exit 1 ;;
        esac
done

echo "Load Average: $(uptime | awk -F":" {'print $NF'})"
echo
MEM=$(free | grep Mem | grep -v grep)
MEM_IN_USE=$(echo $MEM | awk {'print $3'})
TOTAL_MEM=$(echo $MEM | awk {'print $2'})
echo "Memory Usage: $(awk "BEGIN {print $MEM_IN_USE/$TOTAL_MEM*100}")%"
echo
if [[ $MYSQL ]] ; then
        /opt/em7/bin/silo_mysql -e "SELECT a.id AS 'Collector ID', b.dynamic_collect_num_chunk_workers,b.dynamic_collect_num_request_workers,b.dynamic_collect_request_chunk_size FROM master.system_settings_licenses a, master.system_settings_core b\G" | grep -v "\*"
        echo
fi
[[ $SIGTERM ]] && echo "Last SIGTERM: $(grep -i sigterm /var/log/em7/silo.log | tail -1)"
echo
if [ $TIME ] ; then
        WATCH_PID=$(ps -ef | grep dynamic_collect.py | grep "$TIME" | grep $(ps -ef | grep proc_mgr.py | grep -v grep | awk {'print $2'}) | grep -v grep | awk {'print $2'})
        echo "Monitoring PID $WATCH_PID:"
        ps --forest $(ps -e --no-header -o pid,ppid|awk -vp=$WATCH_PID 'function r(s){print s;s=a[s];while(s){sub(",","",s);t=s;sub(",.*","",t);sub("[0-9]+","",s);r(t)}}{a[$2]=a[$2]","$1}END{r(p)}')
fi