#!/bin/bash

cpu_core=8

# parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--core-num)
            cpu_core="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

for ((i = 0; i < $cpu_core; i++)); do
    /usr/bin/cpufreq-set -c $i -g performance
done
