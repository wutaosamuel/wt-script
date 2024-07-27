#!/bin/bash

export ALL_PROXY="http://172.16.8.172:10089"

args=("$@")

for i in "${!args[@]}";
do
	echo "$i. Entered cmd[$i]: ${args[$i]}"
	echo 
	bash -c "${args[$i]}"
	echo
done
