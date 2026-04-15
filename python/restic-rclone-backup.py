#!/usr/bin/env python3
"""
Linux Restic Backup Script (rclone backend)

Usage: python3 backup.py

Description:
  1. Uses restic with rclone backend to back up specified directories and files
     directly to remote storage.
  2. Logs all output to the command line.

Note:
  - Restic password is prompted interactively each time.
  - Restic calls rclone internally; rclone must be installed and configured.
"""

import getpass
import os
import shutil
import subprocess
import sys
from datetime import datetime

# ==============================================================================
# USER CONFIGURATION - Edit the variables below to suit your environment
# ==============================================================================

# ---- Directories to back up (add/remove entries as needed) ----
BACKUP_DIRS = [
    "/root",
]

# ---- Individual files to back up (add/remove entries as needed) ----
BACKUP_FILES = [
]

# ---- Exclude patterns (add/remove entries as needed) ----
EXCLUDE_PATTERNS = [
    "*.tmp",
    "*.log",
    "*.swp",
    "node_modules",
    ".cache",
    "__pycache__",
    "/root/snap",
    "/root/tmp",
]

# ---- Restic + Rclone configuration ----
RCLONE_REMOTE = "seafile"
RCLONE_REPO_PATH = "backup/restic"
RESTIC_REPO = f"rclone:{RCLONE_REMOTE}:{RCLONE_REPO_PATH}"

# ==============================================================================
# END OF USER CONFIGURATION - Do not modify below unless you know what you do
# ==============================================================================

TIMESTAMP = datetime.now().strftime("%Y-%m-%d_%H%M%S")


# ---------- Helper functions ----------

def log_error(*args: str) -> None:
    """Log an error message to stderr."""
    msg = f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] ERROR: {' '.join(args)}"
    print(msg, file=sys.stderr)


def log_info(*args: str) -> None:
    """Log an informational message to stdout."""
    msg = f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] INFO: {' '.join(args)}"
    print(msg)


def check_dependency(name: str) -> None:
    """Check that a required command-line tool is available."""
    if shutil.which(name) is None:
        log_error(f"'{name}' is not installed or not in PATH. Please install it first.")
        sys.exit(1)


def run_command(cmd: list[str]) -> bool:
    """Run a command, outputting stderr to the terminal. Returns True on success."""
    result = subprocess.run(cmd)
    return result.returncode == 0


def main() -> None:
    # ---------- Pre-flight checks ----------

    log_info("Starting backup process...")

    # Check required tools (restic calls rclone internally, both must exist)
    check_dependency("restic")
    check_dependency("rclone")

    # ---------- Prompt for restic password ----------

    restic_password = getpass.getpass("Enter restic repository password: ")
    os.environ["RESTIC_PASSWORD"] = restic_password

    # ---------- Validate backup sources ----------

    backup_sources: list[str] = []

    for dir_path in BACKUP_DIRS:
        if os.path.isdir(dir_path):
            backup_sources.append(dir_path)
        else:
            log_error(f"Directory does not exist, skipping: {dir_path}")

    for file_path in BACKUP_FILES:
        if os.path.isfile(file_path):
            backup_sources.append(file_path)
        else:
            log_error(f"File does not exist, skipping: {file_path}")

    if not backup_sources:
        log_error("No valid backup sources found. Aborting.")
        sys.exit(1)

    log_info(f"Backup sources ({len(backup_sources)} items):")
    for src in backup_sources:
        log_info(f"  - {src}")

    # ---------- Build restic exclude arguments ----------

    exclude_args: list[str] = []
    for pattern in EXCLUDE_PATTERNS:
        exclude_args.extend(["--exclude", pattern])

    # ---------- Check restic repository ----------

    log_info(f"Checking restic repository at {RESTIC_REPO} ...")

    check_result = subprocess.run(
        ["restic", "snapshots", "--repo", RESTIC_REPO, "--no-lock", "--quiet"],
        capture_output=True,
    )
    if check_result.returncode != 0:
        stderr_output = check_result.stderr.decode(errors="replace").strip()
        log_error(
            f"Restic repository at {RESTIC_REPO} is not accessible or not initialized.\n"
            f"       {stderr_output}\n"
            f"       Please run 'restic init --repo {RESTIC_REPO}' first."
        )
        sys.exit(1)

    log_info("Restic repository is accessible.")

    # ---------- Run restic backup ----------

    log_info("Running restic backup...")

    restic_cmd = ["restic", "backup", "-v", "--repo", RESTIC_REPO] + exclude_args + backup_sources
    if run_command(restic_cmd):
        log_info("Restic backup completed successfully.")
    else:
        log_error("Restic backup failed.")
        sys.exit(1)

    # ---------- Summary ----------

    log_info("============================================")
    log_info("Backup completed successfully!")
    log_info(f"  Restic repo : {RESTIC_REPO}")
    log_info(f"  Sources     : {len(backup_sources)} items")
    log_info(f"  Timestamp   : {TIMESTAMP}")
    log_info("============================================")


if __name__ == "__main__":
    main()