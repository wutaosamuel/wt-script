#!/bin/bash

export http_proxy="http://127.0.0.1:1087"
export https_proxy="http://127.0.0.1:1087"

args=("$@")

for i in "${!args[@]}";
do
	echo "$i. Entered cmd[$i]: ${args[$i]}"
	echo 
	bash -c "${args[$i]}"
	echo
done