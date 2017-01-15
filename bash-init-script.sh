#!/bin/bash

lock_file="/var/lock/$0.lock"



# ----------------------------------------------------------------------------------------------------------
function log(){
    echo "[$(date +'%Y-%m-%d %H:%M:%S.%6N')] $1"
}



function info(){
    log "[INFO] $1"
}



function error(){
    >&2 log "[ERR] $1" 
}



# ----------------------------------------------------------------------------------------------------------
function get_options(){
    OPTS=$(getopt -o h --long help -n 'parse-options' -- "$@")
    if [ $? -ne 0 ]; then
        error "Cannot parse command line options"
        return 1
    fi

    eval set -- "$OPTS"

    while :; do
        case "$1" in
           # -a|---long-a)       val="$2"; shift; shift;;

           -h|--help)            usage; exit 1;  shift;;
           --)                   shift; break ;;
           * )                   break ;;
        esac
    done
}



function usage(){
cat << __USAGE__ >&2

Usage $0 

   # -a|-----long-a              long option a

   -h|--help                   shows help and exit


__USAGE__
}



function init(){
    return 0
}



function on_exit(){
    info "Clearing out data..."
    rm "$lock_file" 2>/dev/null
    return 0
}



function startup(){
    info "Starting script..."
    trap on_exit EXIT SIGINT
    touch "$lock_file"
    return 0
}



# ----------------------------------------------------------------------------------------------------------
startup

get_options "$@" || exit 1
init || exit 2


info "Completed."

exit 0
