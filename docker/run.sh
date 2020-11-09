#/bin/bash

if [ -n $(docker images -f "reference=nagios:latest" -q) ]; then
    
    if [ ! $(nc -z -w 3 localhost 80) ]; then

        docker run --name nginx-nagios \
            -v $(pwd)/web-80.conf:/etc/nginx/conf.d/web-80.conf \
            -v $(pwd)/../init.sh:/usr/share/nginx/html/index.txt \
            -p 80:80 \
            -d 48763/nginx:1.12.2
    else
        echo "Port is already allocated."
        exit 1
    fi

    docker build ./nagios -t nagios
    docker rm -f nginx-nagios
fi

if [ -n $(docker ps -f "name=nagios" -q) ]; then

    if [ ! $(nc -z -w 3 localhost 80) ]; then

        docker run --name nagios \
            -v $(pwd)/../project/:/usr/local/nagios/etc/project
            -p 80:80 \
            -d nagios
    else
        echo "Port is already allocated."
        exit 1
    fi

else
    echo "nagios serivce already started."
fi