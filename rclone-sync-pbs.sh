#!/bin/bash

# PBS post-backup replacement: sync datastore to OneDrive using rclone
# No pruning here — PBS handles retention!

# === Config ===
SRC="/mnt/internal5backups"    # Your PBS datastore path
DST="onedrivecrypt:"               # Your rclone destination
EMAIL="jvanderweerden@gmail.com"                  # Your email address
SUBJECT="PBS Rclone Upload Report - $(hostname) - $(date '+%Y-%m-%d %H:%M')"
LOG=$(mktemp)

# === Begin logging ===
{
  echo "[INFO] PBS Rclone Upload started at $(date)"
  
  # Run rclone sync with --min-age to avoid syncing in-progress backups
  rclone sync "$SRC" "$DST" \
    --fast-list \
    --min-age 1d \
    --log-level INFO
  RC=$?

  # Check result
  if [ $RC -eq 0 ]; then
    echo "[INFO] rclone sync completed successfully."
  else
    echo "[ERROR] rclone sync failed with exit code $RC"
  fi

  echo "[INFO] PBS Rclone Upload finished at $(date)"
} > "$LOG" 2>&1

# === Send email ===
mail -s "$SUBJECT" "$EMAIL" < "$LOG"

# === Clean up ===
rm -f "$LOG"
