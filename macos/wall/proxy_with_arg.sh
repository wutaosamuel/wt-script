#!/bin/bash

export http_proxy="http://127.0.0.1:1087"
export https_proxy="http://127.0.0.1:1087"

args=("$@")

for arg in "${args[@]}";
do
	echo "Entered cmd: $1"
	echo ""
	bash -c "$1"
	echo
done