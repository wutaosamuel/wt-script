#!/bin/bash

this_proxy="http://172.16.8.172:10089"

args=()

# parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--proxy)
            this_proxy="$2"
            shift 2
            ;;
        *)
            args+=("$1")
            shift
            ;;
    esac
done

export ALL_PROXY=$this_proxy
export all_proxy=$this_proxy

export HTTP_PROXY=$this_proxy
export http_proxy=$this_proxy

export HTTPS_PROXY=$this_proxy
export https_proxy=$this_proxy

#export SOCKS_PROXY=$this_proxy
#export socks_proxy=$this_proxy

export FTP_PROXY=$this_proxy
export ftp_proxy=$this_proxy

export TELNET_PROXY=$this_proxy
export telnet_proxy=$this_proxy

#export RSYNC_PROXY=$this_proxy
#export rsync_proxy=$this_proxy

for i in "${!args[@]}";
do
	echo "$i. Entered cmd[$i]: ${args[$i]}"
	echo 
	bash -c "${args[$i]}"
	echo
done
