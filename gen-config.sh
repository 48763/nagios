#!/bin/bash
set -x
REGION=""
PROJECT=""
ENV=""
HOST=""

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
    echo 0
}

###
configure_hostg() {
    echo 0
}

###
configure_svcg() {
    echo 0
}

#-
configure_svc() {
    echo 0
}

while read output
do
    echo $output
    punct="${output% *}"

    if [ "-" = "${punct}" ]; then

        if [ 1 -ne $mode ]; then
            mode=1
            #set -> config
            echo "${REGION}"
            echo "${PROJECT}-${ENV}, ${HOST}"
        fi
        
        #set -> svc
        echo "${output#* }"

    elif [ "####" = "${punct}" ]; then
        HOST=${output#* }
        mode=0
    elif [ "###" = "${punct}" ]; then
        ENV=${output#* }
        mode=0
    elif [ "##" = "${punct}" ]; then
        PROJECT=${output#* }
        HOST=${output#* }
    elif [ "#" = "${punct}" ]; then
        REGION=${output#* }
    fi

done < <(cat url.md)