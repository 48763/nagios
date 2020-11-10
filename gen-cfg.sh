#!/bin/bash
. ./conf

REGION=""
ignore=0
PROJECT=""
ENV=""
HOST=""
MEMBERS=""
CFG_PATH=""
mode=0

set_cfg() {
    CFG_PATH="${NAGIOS_PATH}/${1}"
}

write_config() {
    echo "${1}" >> ${CFG_PATH}
}

check_config() {
    cat ${CFG_PATH} 2>&1 | grep "${1}" > /dev/null 2>&1
    echo $?
}

set_ignore() {
    echo ${NEEDREGION} | grep ${REGION} > /dev/null
    ignore=${?}
}

configure_host() {
    
    # some project not exist subproject.
    if [ "${PROJECT}" = "${HOST}" ]; then
        HOST="${ENV}-${HOST}"
    else
        HOST="${PROJECT}-${ENV}-${HOST}"
    fi

    if [ 0 -ne $(check_config "${HOST}$") ]; then
        write_config "define host {"
        write_config "    use                     linux-server"
        write_config "    host_name               ${HOST}"
        write_config "    address                 127.0.0.1"
        write_config "}"
        write_config ""
    fi
    MEMBERS="${MEMBERS}${HOST},"
}

configure_hostg() {

    if [ 0 -ne $(check_config " ${PROJECT}$") ]; then
        write_config "define hostgroup {"
        write_config "    hostgroup_name          ${PROJECT}"
        write_config "    members                 ${MEMBERS}"
        write_config "}"
        write_config ""
    else
        line=$(( 1 + $(grep -n " ${PROJECT}$" ${CFG_PATH} | cut -d : -f1) ))
        
        MEMBERS="${MEMBERS},$(sed -n ${line}p ${CFG_PATH} | awk '{print $2}')"
        MEMBERS="$(echo ${MEMBERS} | sed 's/,/ /g')"

        NEW_MEMBERS=""
        for host in ${MEMBERS}
        do  
            echo ${NEW_MEMBERS} | grep ${host} > /dev/null
            if [ 0 -ne $? ]; then 
                NEW_MEMBERS="${NEW_MEMBERS}${host},"
            fi
        done
        sed -i "${line}s/.*/    members                 ${NEW_MEMBERS%,}/" ${CFG_PATH} 
    fi
}

configure_svc() {
    # enhanced 
    url=${1%%/*}
    path=${1#*/}

    if [[ ${url} = ${path} ]]; then
          path="/"
    fi
    
    if [ 0 -ne $(check_config "${HOST} ${1}$") ]; then
        write_config "define service {"
        write_config "    use https_check"
        write_config "    host_name ${HOST}"
        write_config "    service_description HTTP ${HOST} ${1}"
        write_config "    check_command https_check!-H ${url} -u ${path}"
        write_config "    servicegroups ${PROJECT}-${ENV}"
        write_config "}"
        write_config ""
        
        write_config "define service {"
        write_config "    use ssl_check"
        write_config "    host_name ${HOST}"
        write_config "    service_description SSL ${HOST} ${1}"
        write_config "    check_command ssl_check!-H ${url}"
        write_config "    servicegroups ${PROJECT}-${ENV}"
        write_config "}"
        write_config ""
    fi
}

configure_svcg() {

    if [ 0 -ne $(check_config "${PROJECT}-${ENV}$") ]; then
        write_config "define servicegroup {"
        write_config "    servicegroup_name ${PROJECT}-${ENV}"
        write_config "}"
        write_config ""
    fi
}

if [ ! -d ${NAGIOS_PATH} ]; then
    echo No find directory.
    exit 1
fi

if [ ! -d ${NAGIOS_PATH}/svc ]; then
    mkdir ${NAGIOS_PATH}/svc
fi

while read output
do

    punct="${output% *}"

    if [ "#" = "${punct}" ]; then
        REGION=${output#* }
        set_ignore
    elif [ 0 -eq ${ignore} ]; then

        if [ "-" = "${punct}" ]; then

            if [ 1 -ne $mode ]; then
                set_cfg "host.cfg"
                configure_host

                set_cfg "svc/${PROJECT}-${ENV}.cfg"
                mode=1
            fi

            configure_svc ${output#* }

        elif [ "####" = "${punct}" ]; then
            HOST=${output#* }
        elif [ "###" = "${punct}" ]; then
            ENV=${output#* }
            set_cfg "svcgp.cfg"
            configure_svcg
        elif [ 0 -ne $mode ]; then
            mode=0
        elif [ "##" = "${punct}" ]; then

            if [ "" != "${MEMBERS}" ]; then
                MEMBERS="${MEMBERS%,}"
                set_cfg "host.cfg"
                configure_hostg
                MEMBERS=""
            fi

            PROJECT=${output#* }
            HOST=${output#* }
        fi
    fi

done < <(cat url.md && echo)