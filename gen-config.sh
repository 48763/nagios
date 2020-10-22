#!/bin/bash
set -x
REGION=""
PROJECT=""
ENV=""
MEMBER=""
HOST=""
CFG_PATH=""
mode=0

mark() {
    echo $1 | grep -Po "^[[:punct:]]* "
}

    # file
    ## project=host
    ### env
    #### host or project
    #- list -> ping

### 
configure_host() {

    if [ "${PROJECT}" = "${HOST}" ]; then
        HOST="${ENV}-${HOST}"
    else
        HOST="${PROJECT}-${ENV}-${HOST}"
    fi

    set_config "define host {"
    set_config "    use                     linux-server"
    set_config "    host_name               ${HOST}"
    set_config "    address                 127.0.0.1"
    set_config "}"
    set_config ""

    MEMBER="${MEMBER}${HOST},"
}

###
configure_hostg() {

    set_config "define hostgroup {"
    set_config "    hostgroup_name          ${PROJECT}"
    set_config "    members                 ${MEMBER}"
    set_config "}"
    set_config ""
}

###
configure_svcg() {

    set_config "define servicegroup {"
    set_config "    servicegroup_name ${PROJECT}-${ENV}"
    set_config "}"
    set_config ""
}

#-
configure_svc() {

    set_config "define service {"
    set_config "    use https_check"
    set_config "    host_name ${HOST}"
    set_config "    service_description ${HOST} ${1}"
    set_config "    check_command ${1}"
    set_config "    servicegroups ${PROJECT}-${ENV}"
    set_config "}"
    set_config ""
}

set_config() {
    echo "$1" >> $CFG_PATH
}

while read output
do

    punct="${output% *}"

    if [ "-" = "${punct}" ]; then

        if [ 1 -ne $mode ]; then
            mode=1
            
            CFG_PATH="host.cfg"
            configure_host

            CFG_PATH="svc/${PROJECT}-${ENV}.cfg"

            echo "${REGION}"
            echo "${PROJECT}-${ENV}, ${HOST}"
        fi

        configure_svc ${output#* }

    elif [ "####" = "${punct}" ]; then
        HOST=${output#* }
    elif [ "###" = "${punct}" ]; then
        ENV=${output#* }
        CFG_PATH="svcgp.cfg"
        configure_svcg
    elif [ 0 -ne $mode ]; then
        mode=0
    elif [ "##" = "${punct}" ]; then
        
        if [ "" != "${MEMBER}" ]; then
            MEMBER="${MEMBER%,}"
            CFG_PATH="host.cfg"
            configure_hostg
            MEMBER=""
        fi
        
        PROJECT=${output#* }
        HOST=${output#* }
    elif [ "#" = "${punct}" ]; then
        REGION=${output#* }
    fi

done < <(cat url.md)