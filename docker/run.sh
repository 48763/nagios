#/bin/bash

if [ -z $(docker images -f "reference=nagios:latest" -q) ]; then

    nc -z -w 3 localhost 80
    if [ 0 -ne $? ]; then

        docker run --name nginx-nagios \
            -v $(pwd)/web-80.conf:/etc/nginx/conf.d/web-80.conf \
            -v $(pwd)/../init.sh:/usr/share/nginx/html/index.txt \
            -p 80:80 \
            -d 48763/nginx:1.12.2 > /dev/null
    else
        echo "Port is already allocated."
        exit 1
    fi

    docker build ./nagios -t nagios
    docker rm -f nginx-nagios
else
    echo "Nagios images already exist."
fi

if [ -z $(docker ps -f "name=nagios" -q) ]; then

    nc -z -w 3 localhost 80
    if [ 0 -ne $? ]; then

        docker run --name nagios \
            -v $(pwd)/../project/:/usr/local/nagios/etc/project \
            -p 80:80 \
            -d nagios > /dev/null

        echo "Start nagios service."
    else
        echo "Port is already allocated."
        exit 1
    fi

else
    echo "Nagios serivce already started."
fi