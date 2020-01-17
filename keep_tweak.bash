#!/bin/bash
#
# keep_tweak is designed to be placed in crontab to prevent Config Push
# un-doing our changes.
#
# New in 1.2: Made tweaks options so that upgrades to the script won't overwrite
# New in 1.1: Added logging option so that we don't have to worry about
#             filling the /home partition with unnecessary log messages
#
VER="1.2"
while getopts "c:r:s:lhv" opt ; do
	case $opt in
		"c") CHUNK_VAL=$OPTARG ;;
		"r") REQ_VAL=$OPTARG ;;
		"s") SIZE_VAL=$OPTARG ;;
		"h") echo "Usage: $0 [-l]" ; echo ; 
		     echo "If -l is set, any time the script needs to correct the database, it logs a timestamp to /home/em7admin/apply_tweak.log"
			 echo "Once you have set your parameters below, add the following line via 'crontab -e':"
			 echo "* * * * * /home/em7admin/keep_tweak.bash [-l]" ; exit 0 ;;
		"l") LOGGING=1 ;;
		"v") echo "$0, version $VER" ; exit 0 ;;
		*) echo "Invalid option" ; exit 1 ;;
	esac
done	

[[ ! $CHUNK_VAL ]] && CHUNK_VAL=3
[[ ! $REQ_VAL ]] && REQ_VAL=6
[[ ! $SIZE_VAL ]] && SIZE_VAL=200	
if [ "$(/opt/em7/bin/silo_mysql -NBe "SELECT dynamic_collect_num_chunk_workers FROM master.system_settings_core")" != "$CHUNK_VAL" ] ; then
	/home/em7admin/tweak_dynamic_app_collection.bash -c $CHUNK_VAL -r $REQ_VAL -s $SIZE_VAL
	[[ $LOGGING ]] && echo "[$(date +%F" "%T)] Tweak applied" >> /home/em7admin/apply_tweak.log
fi
