#!/bin/bash

PROXY=http://172.16.8.172:10089

export ALL_PROXY=$PROXY
export all_proxy=$PROXY

export HTTP_PROXY=$PROXY
export http_proxy=$PROXY

export HTTPS_PROXY=$PROXY
export https_proxy=$PROXY

export SOCKS_PROXY=$PROXY
export socks_proxy=$PROXY

export FTP_PROXY=$PROXY
export ftp_proxy=$PROXY

export TELNET_PROXY=$PROXY
export telnet_proxy=$PROXY

export RSYNC_PROXY=$PROXY
export rsync_proxy=$PROXY

args=("$@")

for i in "${!args[@]}";
do
	echo "$i. Entered cmd[$i]: ${args[$i]}"
	echo 
	bash -c "${args[$i]}"
	echo
done
