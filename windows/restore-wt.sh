#!/bin/bash
# Open one bash tab per directory in Windows Terminal, then optionally run a command in each tab.
# Run inside Windows Terminal: add tabs to the current window.
# Double-click (outside Windows Terminal): open a new window.

DIRS=(
    "/c/Users/user/projA"
    "/d/work/projB"
)

PROFILE="Bash"    # Windows Terminal profile name, e.g. "Bash", "Windows PowerShell"

# Command run in every tab after it opens. Empty = only open tabs.
# Can be overridden with -x/--exec.
POST_CMD="mchp ."

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Open one Windows Terminal tab per directory listed in DIRS (edit the script
to change the list). If a command is given, run it in every tab after it
opens; if the command is empty, nothing is run.

Options:
  -x, --exec CMD  Command to run in every tab (overrides POST_CMD in the script;
                  an empty string means run nothing)
  -n, --new       Always open a new Windows Terminal window
  -c, --current   Always add tabs to the current (most recent) window
  -h, --help      Show this help message and exit

Default behavior:
  Inside Windows Terminal (WT_SESSION is set): add tabs to the current window.
  Otherwise (e.g. double-click): open a new window.

Examples:
  $(basename "$0")
  $(basename "$0") -x "git status"
  $(basename "$0") --new -x "git pull && git log --oneline -3"

Profile: "$PROFILE" (change PROFILE in the script to use another profile)
Command: "${POST_CMD:-<none>}" (default; change POST_CMD in the script)
EOF
}

MODE="auto"
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)    usage; exit 0 ;;
        -n|--new)     MODE="new" ;;
        -c|--current) MODE="current" ;;
        -x|--exec)
            if [ $# -lt 2 ]; then echo "Option $1 requires an argument" >&2; exit 1; fi
            POST_CMD="$2"; shift ;;
        --exec=*)     POST_CMD="${1#--exec=}" ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
    shift
done

case "$MODE" in
    new)     WINDOW="new" ;;
    current) WINDOW="0" ;;
    auto)    if [ -n "$WT_SESSION" ]; then WINDOW="0"; else WINDOW="new"; fi ;;
esac

# Treat whitespace-only POST_CMD as empty
HAS_POST=0
[ -n "${POST_CMD//[[:space:]]/}" ] && HAS_POST=1

if [ "$HAS_POST" -eq 1 ]; then
    # Run the command, then keep an interactive shell open so the tab stays.
    # wt.exe treats ';' as a command separator, so escape every ';' as '\;'.
    TAB_CMD="$POST_CMD; exec bash -l -i"
    TAB_CMD="${TAB_CMD//;/\\;}"
    # Use the full path of the current bash to avoid System32\bash.exe (WSL).
    BASH_WIN="$(cygpath -w "$BASH")"
fi

args=()
for dir in "${DIRS[@]}"; do
    [ -d "$dir" ] || { echo "skip: $dir"; continue; }
    [ ${#args[@]} -gt 0 ] && args+=(";")

    unix_dir="$(cygpath -u "$dir")"
    tab=(new-tab -p "$PROFILE" -d "$(cygpath -w "$dir")" --title "$(basename "$unix_dir")")
    if [ "$HAS_POST" -eq 1 ]; then
        tab+=("$BASH_WIN" -l -i -c "$TAB_CMD")
    fi
    args+=("${tab[@]}")
done

[ ${#args[@]} -gt 0 ] && wt.exe -w "$WINDOW" "${args[@]}"
