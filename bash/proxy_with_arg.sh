#!/bin/bash

export http_proxy="http://172.16.63.20:10089"
export https_proxy="http://172.16.63.20:10089"

# TODO: check connection with ping

args=("$@")

for arg in "${args[@]}";
do
	echo "Entered cmd: $1"
	echo ""
	bash -c "$1"
	echo
done