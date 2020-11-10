if [ ! $(grep /usr/local/nagios/etc/project $@) ]; then
    line=$(( 2 + $(grep -n "cfg_dir$" $@ | cut -d : -f1) ))
    sed -i "${line} a cfg_dir=/usr/local/nagios/etc/project" $@
fi

service apache2 start

exec "./bin/nagios" "$@"