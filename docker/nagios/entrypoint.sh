service apache2 start

exec "/usr/local/nagios/bin/nagios" "$@"