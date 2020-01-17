#!/bin/bash
# based on https://docs.sciencelogic.com/8-12-1/Content/Web_Admin_and_Accounts/System_Administration/sys_admin_collector_groups.htm#Tuning
#
# New in Version 1.1: show version
#
VER="1.1"

NUM_CORES=$(cat /proc/cpuinfo  | grep processor | wc -l)
REC_VAL=$(( NUM_CORES + NUM_CORES / 2 ))
declare -a TWEAKS VALUE

while getopts "hc:r:s:Vv" opt ; do
        case $opt in
                "h") echo "Usage: $0 [-h] [-c #] [-r #] [-s #] [-V] [-v]" ; echo "where:" 
				     echo "  -h = help message (what you're reading now)" 
				     echo "  -c = number of chunk workers (default 2, current value: $(/opt/em7/bin/silo_mysql -NBe "SELECT dynamic_collect_num_chunk_workers FROM master.system_settings_core"))" 
					 echo "  -r = the number of request workers per chunk worker (default 2 or 2xCPU, whichever is higher, recommend starting at $REC_VAL, current value: $(/opt/em7/bin/silo_mysql -NBe "SELECT dynamic_collect_num_request_workers FROM master.system_settings_core"))"
					 echo "  -s = number of requests per request worker (default 200, current value: $(/opt/em7/bin/silo_mysql -NBe "SELECT dynamic_collect_request_chunk_size FROM master.system_settings_core"))"
					 echo "  -V = verbose (prints output to screen)" 
					 echo "  -v = show version" ; echo ; exit 0 ;;
                "c") TWEAKS+=("dynamic_collect_num_chunk_workers") ; VALUE+=($OPTARG) ;;
                "r") TWEAKS+=("dynamic_collect_num_request_workers") ; VALUE+=($OPTARG) ;;
                "s") TWEAKS+=("dynamic_collect_request_chunk_size") ; VALUE+=($OPTARG) ;;
				"V") VERBOSE=1 ;;
				"v") echo "$0, version $VER" ; exit 0 ;;
                *) echo "Invalid option" ; exit 1 ;;
        esac
done

i=0
for TWEAK in "${TWEAKS[@]}" ; do
        VAL=${VALUE[$i]}
        [[ $VERBOSE ]] && echo "Setting $TWEAK to $VAL"
        /opt/em7/bin/silo_mysql -e "UPDATE master.system_settings_core SET $TWEAK = $VAL"
        ((i++))
done
