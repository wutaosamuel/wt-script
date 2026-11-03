#!/usr/bin/env bash
#
# rclone_bisync.sh
#
# Keep a local folder and a remote SMB folder (accessed via an rclone
# remote) in sync using "rclone bisync". Any file or folder that has been
# deleted on one side will be deleted on the other side as well, so both
# folders stay identical.
#
# Requirements:
#   - rclone must be installed and available in PATH.
#   - An rclone remote must already be configured to point at the SMB
#     share (see REMOTE_PATH below).
#
# Usage:
#   ./rclone_bisync.sh --resync --apply   # first run: build the baseline
#   ./rclone_bisync.sh                    # dry-run: preview what would change
#   ./rclone_bisync.sh --apply            # actually perform the sync/delete
#
# Notes:
#   - By default this script runs in dry-run mode, so nothing is changed
#     until you pass --apply.
#   - rclone bisync requires --resync on the very first run (or whenever
#     the sync baseline/cache has been lost) to establish a starting point.

set -euo pipefail

# ---------------------------------------------------------------------------
# Fixed paths - edit these variables to match your setup.
# ---------------------------------------------------------------------------
LOCAL_PATH="/path/to/local/folder"
REMOTE_PATH="myremote:share/folder"

# Directory where rclone bisync stores its state files (snapshot .lst files,
# lock files, etc). Pinning this to a fixed path avoids issues where the
# default cache directory differs between shells/environments (e.g. WSL vs
# Git Bash), which could otherwise make the baseline appear "missing".
WORKDIR="/path/to/state/dir"

# Conflict resolution when both sides changed the same file differently.
#   none   keeps both copies as ...conflict1 / ...conflict2 (safest, no data loss)
#   newer  keeps the more recently modified file
#   older  keeps the less recently modified file
#   larger keeps the larger file
#   smaller keeps the smaller file
# See the rclone bisync documentation for details.
CONFLICT_RESOLVE="none"

# ---------------------------------------------------------------------------
# Defaults (do not edit below unless you know what you are doing)
# ---------------------------------------------------------------------------
DO_RESYNC=false
DO_APPLY=false

print_help() {
    cat <<EOF
Usage: $(basename "$0") [options]

Keep a local folder and a remote SMB folder in sync using "rclone bisync".
Files or folders that were deleted on either side will be deleted on the
other side as well, so both folders remain identical.

Local path:       ${LOCAL_PATH}
Remote path:      ${REMOTE_PATH}
State dir:        ${WORKDIR}
Conflict resolve: ${CONFLICT_RESOLVE}
(To change these paths, edit the LOCAL_PATH / REMOTE_PATH / WORKDIR
variables at the top of this script. WORKDIR stores the bisync baseline
and state files, fixed to this path regardless of the shell/environment
the script is run from. CONFLICT_RESOLVE controls what happens when both
sides changed the same file differently.)

Options:
  -h, --help    Show this help message and exit.
  --resync      Rebuild the sync baseline. Required on the very first run,
                or whenever the bisync baseline/cache is missing or
                corrupted. Combine with --apply to actually write it.
  --apply       Actually perform the sync/delete operations. Without this
                flag, the script only runs in dry-run mode and prints what
                would be done, without changing anything.

Examples:
  $(basename "$0") --resync --apply     # first run, build the baseline
  $(basename "$0")                      # dry-run, preview pending changes
  $(basename "$0") --apply              # confirmed run, actually sync/delete
EOF
}

# ---------------------------------------------------------------------------
# Parse command-line arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        --resync)
            DO_RESYNC=true
            shift
            ;;
        --apply)
            DO_APPLY=true
            shift
            ;;
        *)
            echo "Error: unknown option '$1'" >&2
            echo "Run '$(basename "$0") --help' for usage." >&2
            exit 1
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Sanity checks
# ---------------------------------------------------------------------------
if [[ "$LOCAL_PATH" == "/path/to/local/folder" \
   || "$REMOTE_PATH" == "myremote:share/folder" \
   || "$WORKDIR" == "/path/to/state/dir" ]]; then
    echo "Error: default placeholder paths detected." >&2
    echo "Please edit LOCAL_PATH / REMOTE_PATH / WORKDIR at the top of this script" >&2
    echo "to match your setup before running." >&2
    exit 1
fi

if ! command -v rclone >/dev/null 2>&1; then
    echo "Error: rclone command not found. Please install rclone and make sure it is in PATH." >&2
    exit 1
fi

if [[ ! -d "$LOCAL_PATH" ]]; then
    echo "Error: local path '$LOCAL_PATH' does not exist or is not a directory." >&2
    echo "Edit the LOCAL_PATH variable at the top of this script." >&2
    exit 1
fi

mkdir -p "$WORKDIR"

# ---------------------------------------------------------------------------
# Build the rclone bisync command
# ---------------------------------------------------------------------------
BISYNC_ARGS=(
    bisync
    "$LOCAL_PATH"
    "$REMOTE_PATH"
    --workdir "$WORKDIR"
    --conflict-resolve "$CONFLICT_RESOLVE"
    -v
    --create-empty-src-dirs
    --compare size,modtime
)

if [[ "$DO_RESYNC" == true ]]; then
    BISYNC_ARGS+=(--resync)
fi

if [[ "$DO_APPLY" != true ]]; then
    BISYNC_ARGS+=(--dry-run)
fi

echo "Local path:       $LOCAL_PATH"
echo "Remote path:      $REMOTE_PATH"
echo "Work dir:         $WORKDIR"
echo "Conflict resolve: $CONFLICT_RESOLVE"
if [[ "$DO_APPLY" == true ]]; then
    echo "Mode: APPLY (changes will be made)"
else
    echo "Mode: DRY-RUN (no changes will be made; pass --apply to execute)"
fi
if [[ "$DO_RESYNC" == true ]]; then
    echo "Resync: enabled (rebuilding baseline)"
fi
echo

echo "Running: rclone ${BISYNC_ARGS[*]}"
echo

# Run rclone and capture its real exit code. Temporarily disable errexit so
# a non-zero exit does not abort the script before we can handle it.
set +e
rclone "${BISYNC_ARGS[@]}"
status=$?
set -e

echo
if [[ $status -eq 0 ]]; then
    if [[ "$DO_APPLY" == true ]]; then
        echo "Sync completed successfully."
    else
        echo "Dry-run completed. No changes were made."
        echo "Re-run with --apply to actually perform these changes."
    fi
else
    echo "Error: rclone bisync failed with exit code $status." >&2
    if [[ "$DO_RESYNC" != true ]]; then
        echo "If this is the first run, or the sync baseline is missing/corrupted," >&2
        echo "try running again with --resync --apply to rebuild the baseline." >&2
    fi
    exit "$status"
fi
