#!/bin/bash
. ./conf
# jp, tw, cn, etc.
REGION=""
# project
PROJECT=""
# prod, sit, dev
ENV=""
# subproject
HOST=""
# host group
MEMBER=""
# config path
CFG_PATH=""
# write mode, 1 mean enable.
mode=0
ignore=0

set_config() {
    echo "$1" >> ${NAGIOS_PATH}${CFG_PATH}
}

configure_host() {
    
    # some project not exist subproject.
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

configure_hostg() {

    set_config "define hostgroup {"
    set_config "    hostgroup_name          ${PROJECT}"
    set_config "    members                 ${MEMBER}"
    set_config "}"
    set_config ""
}

configure_svcg() {

    set_config "define servicegroup {"
    set_config "    servicegroup_name ${PROJECT}-${ENV}"
    set_config "}"
    set_config ""
}

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

while read output
do

    punct="${output% *}"

    if [ "#" = "${punct}" ]; then
        REGION=${output#* }
        echo ${NEEDREGION} | grep ${REGION}
        ignore=${?}
    elif [ 0 -eq ${ignore} ]; then

        if [ "-" = "${punct}" ]; then

            if [ 1 -ne $mode ]; then
                mode=1
                
                CFG_PATH="host.cfg"
                configure_host

                CFG_PATH="svc/${PROJECT}-${ENV}.cfg"
            fi

            configure_svc ${output#* }

        elif [ "####" = "${punct}" ]; then
            HOST=${output#* }
        elif [ "###" = "${punct}" ]; then
            ENV=${output#* }
            CFG_PATH="svcgp.cfg"
            configure_svcg
        elif [ 0 -ne $mode ]; then
            # disable witer mode.
            mode=0
        elif [ "##" = "${punct}" ]; then
            # member not null write hostgroup, when change project
            if [ "" != "${MEMBER}" ]; then
                MEMBER="${MEMBER%,}"
                CFG_PATH="host.cfg"
                configure_hostg
                MEMBER=""
            fi
            
            PROJECT=${output#* }
            HOST=${output#* }
    fi

done < <(cat url.md)