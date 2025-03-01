#!/bin/bash

# export http_proxy="http://127.0.0.1:1087"
# export https_proxy="http://127.0.0.1:1087"

export ALL_PROXY=$PROXY
export all_proxy=$PROXY

export HTTP_PROXY=$PROXY
export http_proxy=$PROXY

export HTTPS_PROXY=$PROXY
export https_proxy=$PROXY

export FTP_PROXY=$PROXY
export ftp_proxy=$PROXY

export TELNET_PROXY=$PROXY
export telnet_proxy=$PROXY

args=("$@")

for i in "${!args[@]}";
do
	echo "$i. Entered cmd[$i]: ${args[$i]}"
	echo 
	bash -c "${args[$i]}"
	echo
done