Dynamic App Collection Toolkit

This collection of scripts allows a user to adjust dynamic app collection settings on an 
individual collector basis.  It consists of 3 scripts:

  * tweak_dynamic_app_collection.bash
  * keep_tweak.bash
  * monitor_dynamic_app_collection.bash
  
Please remember to `chmod +x` the scripts after extracting them.

BACKGROUND:
The dynamic app collection process on collectors consists of a parent process that 
generates a number of "chunk workers" (default 2) that each run collection processes for 
specific runtime environments.  The number of collection processes (called "request 
workers") can be up to, by default, 2 or 2 times the number of cores, whichever is higher.  
These request workers will each process up to (by default) 200 dynamic app/device pairs.

These variables are set in the master.system_settings_core table, which means that they 
can not be tweaked via [PROC_OVERRIDE] in /etc/silo.conf like other processes. They can 
either be set at the central database via MySQL query, which affects all collectors, or 
at the collector via MySQL query. However, a mechanism needs to be put in place so that 
when the central database pushes the system_settings_core table to the collector, the 
adjustments will be re-inserted.

IMPLEMENTATION:
The tweak_dynamic_app_collection.bash script allows you to set the number of chunk workers 
(-c #), the number of request workers (-r #), and the number of dynamic app/device pairs 
that each request worker will process (-s #).

Edit the "keep_tweak.bash" script and enter the values you used for 
tweak_dynamic_app_collection.bash, then enter keep_tweak.bash into the root crontab to run 
every minute. (* * * * * /home/em7admin/keep_tweak.bash)  The keep_tweak script contains a 
-l option to log when it had to re-apply the tweaks.

Once you have your settings in place, you can use monitor_dynamic_app_collection.bash to 
ensure that the correct number of chunk workers and request workers activate, and that 
system load doesn't increase and remain at too high a level. The script honors the following 
options:
  * -m to show the current values in mysql
  * -s to show the last sigterm from /var/log/em7/silo.log
  * -t to set the time of the dynamic collection  process to watch.
  
So, something like `watch -n 5 ./monitor_dynamic_app_collection.bash -m -s -t 18:00`

When applying settings, be sure to watch the load, as each minute, dynamic_collect.py will
spawn the number of chunk workers and request workers you set.
