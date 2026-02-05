#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 -r <repo> -g <tag> "
    echo "  -r, --repo    repo path"
    echo "  -g, --tag     tag for snapshot"
    echo "  -h, --help    usage"
    exit 1
}

repo=""
tag=""

target_dirs=(

)

while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|--repo)
            repo="$2"
            shift 2
            ;;
        -g|--tag)
            tag="$2"
            shift 2
            ;;
        -h|--help)
            usage
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z "$repo" ]]; then
    echo "repo is empty"
    usage
fi

if [ -z "$tag" ]; then 
    restic -r "$repo" --verbose backup "${target_dirs[@]}" 
else 
    restic -r "$repo" --verbose backup "${target_dirs[@]}" --tag "$tag"
fi
