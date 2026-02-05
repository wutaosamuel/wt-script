#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 -r <repo> -t <target> -g <tag> "
    echo "  -r, --repo    repo path"
    echo "  -t, --target  target path"
    echo "  -g, --tag     tag for snapshot"
    exit 1
}

repo=""
target=""
tag=""

basename=""
dirname=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|--repo)
            repo="$2"
            shift 2
            ;;
        -t|--target)
            target="$2"
            shift 2
            ;;
        -g|--tag)
            tag="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z "$repo" || -z "$target" ]]; then
    echo "repo or target is empty"
    usage
fi

basename=$(basename "$target")
dirname=$(dirname "$target")
cd "$dirname"

if [ -z "$tag" ]; then 
    restic -r "$repo" --verbose backup "$basename" 
else 
    restic -r "$repo" --verbose backup "$basename" --tag "$tag"
fi
