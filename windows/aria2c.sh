#!/bin/bash

input_file="New\ Text\ Document.txt"
all_proxy="http://172.16.63.20:10089"
job=6

# parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--input)
            input_file="$2"
            shift 2
            ;;
				--all-proxy)
            all_proxy="$2"
            shift 2
            ;;
				-j)
            job="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

aria2c -i $input_file -j $job --all-proxy=$all_proxy
