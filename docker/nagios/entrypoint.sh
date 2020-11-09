service apache2 start

line=$(( 2 + $(grep -n "cfg_dir$" nagios.cfg | cut -d : -f1) ))
sed -i "${line} a cfg_dir=/usr/local/nagios/etc/project" $@

exec "./bin/nagios" "$@"