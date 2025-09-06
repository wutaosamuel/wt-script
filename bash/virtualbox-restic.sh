#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 -r <repo> -t <target> -g <tag> "
    echo ""
    echo "  -g, --tag     tag for snapshot"
    exit 1
}

repo=""
target="./"
tag=""

basename=""
dirname=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -g|--tag)
            tag="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z "${repo}" ]]; then
    echo "repo is empty"
    #usage
fi

target=$(readlink -f "${target}")
basename=$(basename "${target}")
dirname=$(dirname "${target}")
cd "${dirname}"

if [ -z "${tag}" ]; then 
    restic -r "${repo}" --verbose backup "${basename}" 
else 
    restic -r "${repo}" --verbose backup "${basename}" --tag "${tag}"
fi
echo "${basename} backup done"
